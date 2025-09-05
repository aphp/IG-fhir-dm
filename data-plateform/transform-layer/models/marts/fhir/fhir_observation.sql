{{
    config(
        materialized='table',
        unique_key='id',
        tags=['mart', 'fhir', 'observation']
    )
}}

-- FHIR Observation resource mart table
-- Compliant with FHIR R4 Observation resource structure
-- Unified for laboratory, vital signs, and lifestyle observations
with observation_data as (
    select * from {{ ref('int_observation_unified') }}
    where is_valid_observation = true
),

fhir_observation as (
    select
        -- FHIR Resource metadata
        fhir_observation_id as id,
        'Observation' as resourceType,
        fhir_meta as meta,
        
        -- Observation identifiers
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'system', 'http://aphp.fr/fhir/NamingSystem/observation-id',
                'value', replace(fhir_observation_id, substring(fhir_observation_id from '^[^-]+-'), '')
            )
        ) as identifier,
        
        -- Observation status
        observation_status as status,
        
        -- Category
        fhir_category as category,
        
        -- Observation code (LOINC)
        fhir_code as code,
        
        -- Patient reference
        jsonb_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'display', 'Patient ' || fhir_patient_id
        ) as subject,
        
        -- Subject ID for relationships
        fhir_patient_id as subject_id,
        
        -- Encounter reference (if available)
        case
            when fhir_encounter_id is not null then
                jsonb_build_object(
                    'reference', 'Encounter/' || fhir_encounter_id,
                    'display', 'Encounter ' || fhir_encounter_id
                )
            else null
        end as encounter,
        
        -- Encounter ID for relationships
        fhir_encounter_id as encounter_id,
        
        -- Effective time
        fhir_effective as effectiveDateTime,
        
        -- Issued timestamp
        to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as issued,
        
        -- Performer (who made the observation)
        jsonb_build_array(
            jsonb_build_object(
                'reference', case observation_source
                    when 'laboratory' then 'Organization/lab-' || lower(replace(performer_name, ' ', '-'))
                    when 'vital-signs' then 'PractitionerRole/nurse'
                    when 'social-history' then 'Practitioner/social-worker'
                    else 'Practitioner/unknown'
                end,
                'display', performer_name
            )
        ) as performer,
        
        -- Observation value
        case 
            when fhir_value ? 'valueQuantity' then fhir_value
            when fhir_value ? 'valueBoolean' then fhir_value
            when fhir_value ? 'valueString' then fhir_value
            else null
        end as value,
        
        -- Data absent reason (if no value)
        case
            when fhir_value is null then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://terminology.hl7.org/CodeSystem/data-absent-reason',
                            'code', 'unknown',
                            'display', 'Unknown'
                        )
                    )
                )
            else null
        end as dataAbsentReason,
        
        -- Interpretation (basic implementation)
        case
            when observation_category = 'vital-signs' and loinc_code = '8480-6' and numeric_value > 140 then  -- High systolic BP
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation',
                                'code', 'H',
                                'display', 'High'
                            )
                        )
                    )
                )
            when observation_category = 'vital-signs' and loinc_code = '8480-6' and numeric_value < 90 then  -- Low systolic BP
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation',
                                'code', 'L',
                                'display', 'Low'
                            )
                        )
                    )
                )
            when observation_category = 'vital-signs' and numeric_value is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation',
                                'code', 'N',
                                'display', 'Normal'
                            )
                        )
                    )
                )
            else null
        end as interpretation,
        
        -- Note (additional information)
        case
            when display_name_fr != loinc_code then
                jsonb_build_array(
                    jsonb_build_object(
                        'text', 'Source: ' || observation_source || ' - ' || display_name_fr,
                        'time', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                    )
                )
            else null
        end as note,
        
        -- Body site (for vital signs and physical observations)
        case
            when observation_category = 'vital-signs' and loinc_code in ('8480-6', '8462-4') then  -- Blood pressure
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '40983000',
                            'display', 'Upper arm structure'
                        )
                    )
                )
            when observation_category = 'vital-signs' and loinc_code = '8867-4' then  -- Heart rate
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '8205005',
                            'display', 'Wrist region structure'
                        )
                    )
                )
            else null
        end as bodySite,
        
        -- Method (for specific types of observations)
        case
            when observation_category = 'laboratory' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '115341008',
                            'display', 'Laboratory procedure'
                        )
                    )
                )
            when observation_category = 'vital-signs' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '17621005',
                            'display', 'Normal'
                        )
                    )
                )
            else null
        end as method,
        
        -- Specimen (for laboratory observations)
        case
            when observation_category = 'laboratory' then
                jsonb_build_object(
                    'reference', 'Specimen/specimen-' || replace(fhir_observation_id, substring(fhir_observation_id from '^[^-]+-'), ''),
                    'display', 'Laboratory specimen'
                )
            else null
        end as specimen,
        
        -- Reference range
        fhir_reference_range as referenceRange,
        
        -- Has member (for grouped observations like blood pressure)
        case
            when observation_category = 'vital-signs' and loinc_code in ('8480-6', '8462-4') then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'Observation/blood-pressure-' || replace(fhir_observation_id, substring(fhir_observation_id from '^[^-]+-'), ''),
                        'display', 'Blood pressure measurement'
                    )
                )
            else null
        end as hasMember,
        
        -- Component (for multi-component observations)
        case
            when observation_category = 'vital-signs' and observation_source = 'vital-signs' 
            and numeric_value is not null and value_unit is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'code', fhir_code,
                        'valueQuantity', (fhir_value->>'valueQuantity')::jsonb
                    )
                )
            else null
        end as component,
        
        -- Audit and source fields
        observation_source,
        observation_category,
        loinc_code,
        display_name_fr,
        value_type,
        numeric_value,
        string_value,
        boolean_value,
        value_unit,
        performer_name,
        extracted_at,
        current_timestamp as last_updated
        
    from observation_data
)

select 
    -- FHIR Resource structure
    id,
    resourceType,
    meta,
    identifier,
    status,
    category,
    code,
    subject,
    subject_id,
    encounter,
    encounter_id,
    effectiveDateTime,
    issued,
    performer,
    value,
    dataAbsentReason,
    interpretation,
    note,
    bodySite,
    method,
    specimen,
    referenceRange,
    hasMember,
    component,
    
    -- Audit and source fields
    observation_source,
    observation_category,
    loinc_code,
    display_name_fr,
    value_type,
    numeric_value,
    string_value,
    boolean_value,
    value_unit,
    performer_name,
    extracted_at,
    last_updated
    
from fhir_observation