{{
    config(
        materialized='table',
        unique_key='id',
        tags=['mart', 'fhir', 'encounter']
    )
}}

-- FHIR Encounter resource mart table
-- Compliant with FHIR R4 Encounter resource structure
with encounter_data as (
    select * from {{ ref('int_encounter_episodes') }}
    where is_valid_encounter = true
),

fhir_encounter as (
    select
        -- FHIR Resource metadata
        fhir_encounter_id as id,
        'Encounter' as resourceType,
        fhir_meta as meta,
        
        -- Encounter identifiers
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'system', 'http://aphp.fr/fhir/NamingSystem/pmsi-episode',
                'value', pmsi_id::text
            )
        ) as identifier,
        
        -- Encounter status
        encounter_status as status,
        
        -- Encounter class (inpatient, ambulatory, emergency)
        jsonb_build_object(
            'system', 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
            'code', encounter_class,
            'display', case encounter_class
                when 'IMP' then 'inpatient encounter'
                when 'AMB' then 'ambulatory'
                when 'EMER' then 'emergency'
                else 'unknown'
            end
        ) as class,
        
        -- Service type
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://snomed.info/sct',
                    'code', service_type_snomed,
                    'display', service_department
                )
            )
        ) as serviceType,
        
        -- Priority
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://terminology.hl7.org/CodeSystem/v3-ActPriority',
                    'code', case encounter_priority
                        when 'urgent' then 'UR'
                        when 'routine' then 'R'
                        else 'R'
                    end,
                    'display', encounter_priority
                )
            )
        ) as priority,
        
        -- Patient reference
        jsonb_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'display', 'Patient ' || fhir_patient_id
        ) as subject,
        
        -- Subject ID for relationships
        fhir_patient_id as subject_id,
        
        -- Episode of care (optional - could link multiple encounters)
        case 
            when length_of_stay_days > 1 then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'EpisodeOfCare/episode-' || pmsi_id,
                        'display', 'Episode ' || pmsi_id
                    )
                )
            else null
        end as episodeOfCare,
        
        -- Participant (care team)
        jsonb_build_array(
            jsonb_build_object(
                'type', jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://terminology.hl7.org/CodeSystem/v3-ParticipationType',
                                'code', 'ATND',
                                'display', 'attender'
                            )
                        )
                    )
                ),
                'individual', jsonb_build_object(
                    'reference', 'Practitioner/service-' || lower(replace(service_department, ' ', '-')),
                    'display', service_department
                )
            )
        ) as participant,
        
        -- Encounter period
        fhir_period as period,
        
        -- Length of stay
        jsonb_build_object(
            'value', length_of_stay_days,
            'unit', 'days',
            'system', 'http://unitsofmeasure.org',
            'code', 'd'
        ) as length,
        
        -- Reason for encounter (could be linked to diagnoses)
        case
            when encounter_class = 'EMER' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '50849002',
                                'display', 'Emergency medical treatment'
                            )
                        )
                    )
                )
            else null
        end as reasonCode,
        
        -- Hospitalization details
        fhir_hospitalization as hospitalization,
        
        -- Location details
        case 
            when fhir_location is not null 
            then fhir_location
            else null 
        end as location,
        
        -- Service provider
        jsonb_build_object(
            'reference', 'Organization/' || '{{ var("default_organization_id") }}',
            'display', facility_name
        ) as serviceProvider,
        
        -- Part of (if this is a sub-encounter)
        case
            when encounter_class = 'AMB' and admission_type like '%consultation%' then
                jsonb_build_object(
                    'reference', 'Encounter/parent-' || pmsi_id,
                    'display', 'Parent encounter'
                )
            else null
        end as partOf,
        
        -- Audit and source fields
        length_of_stay_days,
        facility_name,
        service_department,
        admission_type,
        discharge_disposition,
        extracted_at,
        current_timestamp as last_updated,
        
        -- Source identifiers for traceability
        pmsi_id as source_pmsi_id,
        patient_id as source_patient_id
        
    from encounter_data
)

select 
    -- FHIR Resource structure
    id,
    resourceType,
    meta,
    identifier,
    status,
    class,
    serviceType,
    priority,
    subject,
    subject_id,
    episodeOfCare,
    participant,
    period,
    length,
    reasonCode,
    hospitalization,
    location,
    serviceProvider,
    partOf,
    
    -- Audit and source fields
    length_of_stay_days,
    facility_name,
    service_department,
    admission_type,
    discharge_disposition,
    source_pmsi_id,
    source_patient_id,
    extracted_at,
    last_updated
    
from fhir_encounter