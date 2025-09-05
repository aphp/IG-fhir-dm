{{ config(
    materialized='table',
    tags=['intermediate', 'ehr', 'fhir', 'encounter', 'core']
) }}

-- Intermediate model transforming EHR PMSI data to FHIR Encounter structure
-- Implements the TransformEncounter group from the FML mapping

with source_encounters as (
    select * from {{ ref('stg_ehr__encounter') }}
),

source_patients as (
    select patient_id from {{ ref('stg_ehr__patient') }}
),

fhir_encounter_transform as (
    select
        -- FHIR Resource ID (following FML mapping src.pmsiId as id -> tgt.id = id)
        {{ generate_fhir_id('encounter_id') }} as encounter_id,
        
        -- FHIR Patient Reference (following FML mapping patientId -> tgt.subject)
        {{ create_fhir_reference('concat(\'Patient/\', e.patient_id)') }} as patient_reference,
        
        -- FHIR Identifiers array - PMSI ID
        jsonb_build_array(
            {{ create_fhir_identifier(
                "'https://hospital.eu/ehr/pmsi-id'", 
                'encounter_id', 
                'official'
            ) }}
        ) as identifiers,
        
        -- FHIR Status (following FML mapping - default to finished for historical data)
        case 
            when encounter_status = 'finished' then 'finished'
            when encounter_status = 'in-progress' then 'in-progress'
            else 'unknown'
        end as status,
        
        -- FHIR Class (following FML mapping - assume inpatient for PMSI data)
        {{ create_fhir_coding(
            'case when encounter_class = \'inpatient\' then \'IMP\' else \'AMB\' end',
            "'http://terminology.hl7.org/CodeSystem/v3-ActCode'",
            'case when encounter_class = \'inpatient\' then \'inpatient encounter\' else \'ambulatory\' end'
        ) }} as class,
        
        -- FHIR Period (following FML mapping for encounter timing)
        case 
            when period_start is not null or period_end is not null then
                {{ create_fhir_period(
                    'period_start::text', 
                    'period_end::text'
                ) }}
            else null
        end as period,
        
        -- FHIR Length (following FML mapping for duration)
        case 
            when length_of_stay_days is not null then
                {{ create_fhir_quantity(
                    'length_of_stay_days', 
                    "'day'", 
                    'http://unitsofmeasure.org',
                    "'d'"
                ) }}
            else null
        end as length,
        
        -- FHIR Hospitalization (following FML mapping for admission/discharge)
        case 
            when admission_mode is not null or discharge_mode is not null then
                jsonb_build_object(
                    'admitSource', jsonb_build_object(
                        'text', admission_mode
                    ),
                    'dischargeDisposition', jsonb_build_object(
                        'text', discharge_mode
                    )
                )
            else null
        end as hospitalization,
        
        -- FHIR Service Provider (following FML mapping src.etablissement -> tgt.serviceProvider)
        case 
            when facility_name is not null then
                {{ create_fhir_reference(
                    'concat(\'Organization/\', replace(facility_name, \' \', \'-\'))', 
                    'facility_name'
                ) }}
            else null
        end as service_provider,
        
        -- FHIR Locations array (following FML mapping for location)
        case 
            when clinical_service is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'location', {{ create_fhir_reference(
                            'concat(\'Location/\', replace(clinical_service, \' \', \'-\'))', 
                            'clinical_service'
                        ) }},
                        'status', 'active'
                    )
                )
            else null
        end as locations,
        
        -- Additional context fields
        functional_unit,
        administrative_status,
        residence_code,
        residence_label,
        data_collection_date,
        
        -- FHIR Meta with DMEncounter profile
        {{ create_fhir_meta('https://aphp.fr/ig/fhir/dm/StructureDefinition/DMEncounter') }} as meta,
        
        -- Audit fields
        current_timestamp as last_updated,
        {{ add_fhir_audit_columns() }}
        
    from source_encounters e
    inner join source_patients p on e.patient_id = p.patient_id
),

final as (
    select
        encounter_id,
        patient_reference,
        identifiers,
        status,
        class,
        period,
        length,
        hospitalization,
        service_provider,
        locations,
        meta,
        current_timestamp as last_updated,
        created_at,
        fhir_version,
        source_environment
    from fhir_encounter_transform
    where encounter_id is not null
      and patient_reference is not null
)

select * from final