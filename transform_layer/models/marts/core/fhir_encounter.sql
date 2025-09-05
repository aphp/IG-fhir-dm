{{
  config(
    materialized='incremental',
    unique_key='id',
    on_schema_change='sync_all_columns',
    tags=['mart', 'fhir', 'encounter', 'core'],
    indexes=[
      {'columns': ['patient_id'], 'type': 'btree'},
      {'columns': ['status'], 'type': 'btree'},
      {'columns': ['period_start', 'period_end'], 'type': 'btree'},
      {'columns': ['service_provider_id'], 'type': 'btree'},
      {'columns': ['class'], 'type': 'gin'},
      {'columns': ['identifiers'], 'type': 'gin'}
    ]
  )
}}

-- FHIR Encounter resources following the DMEncounter profile
-- Healthcare encounters from PMSI data

with source_encounters as (
    select * from {{ ref('int_ehr__encounter_fhir') }}
    {{ handle_late_arriving_data('last_updated') }}
),

fhir_encounters as (
    select
        -- FHIR Encounter resource structure
        encounter_id as id,
        {{ add_fhir_versioning('encounter_id') }},
        last_updated,
        
        -- FHIR Encounter core elements
        status,
        null::jsonb as status_history,  -- Could be enhanced with status change tracking
        class,
        null::jsonb as class_history,   -- Could be enhanced with class change tracking
        null::jsonb as types,           -- Could be mapped from PMSI encounter types
        null::jsonb as service_type,    -- Could be mapped from clinical service
        null::jsonb as priority,        -- Not available in source data
        
        -- FHIR Identifiers
        identifiers,
        
        -- FHIR Patient Reference
        (patient_reference->>'reference')::text as patient_id,
        
        -- FHIR Episode of Care - not available in source
        null::jsonb as episode_of_care_ids,
        
        -- FHIR Based on - not available in source
        null::jsonb as based_on,
        
        -- FHIR Participants - could be enhanced with performer mapping
        null::jsonb as participants,
        
        -- FHIR Appointments - not available in source
        null::jsonb as appointments,
        
        -- FHIR Period
        case 
            when period is not null then
                (period->>'start')::timestamp with time zone
            else null
        end as period_start,
        
        case 
            when period is not null then
                (period->>'end')::timestamp with time zone
            else null
        end as period_end,
        
        -- FHIR Length
        length,
        
        -- FHIR Reason - not available in source data
        null::jsonb as reason_codes,
        null::jsonb as reason_references,
        
        -- FHIR Diagnoses - could be populated from related conditions
        null::jsonb as diagnoses,
        
        -- FHIR Accounts - not available in source
        null::jsonb as accounts,
        
        -- FHIR Hospitalization
        hospitalization,
        
        -- Extract pre-admission identifier if available
        case 
            when hospitalization is not null then
                hospitalization->>'preAdmissionIdentifier'
            else null
        end as pre_admission_identifier,
        
        -- Origin location - not available in source
        null as origin_location_id,
        
        -- FHIR Locations
        locations,
        
        -- FHIR Service Provider
        case 
            when service_provider is not null then
                (service_provider->>'reference')::text
            else null
        end as service_provider_id,
        
        -- FHIR Part of - for sub-encounters (not available in source)
        null as part_of_encounter_id,
        
        -- FHIR Meta
        meta,
        
        -- Additional fields
        null as implicit_rules,
        'fr' as language,
        null as text_div,
        null::jsonb as contained,
        null::jsonb as extensions,
        null::jsonb as modifier_extensions,
        
        -- Audit fields
        created_at,
        fhir_version,
        source_environment
        
    from source_encounters
),

final as (
    select
        id,
        version_id,
        last_updated,
        status,
        status_history,
        class,
        class_history,
        types,
        service_type,
        priority,
        identifiers,
        patient_id,
        episode_of_care_ids,
        based_on,
        participants,
        appointments,
        period_start,
        period_end,
        length,
        reason_codes,
        reason_references,
        diagnoses,
        accounts,
        hospitalization,
        pre_admission_identifier,
        origin_location_id,
        locations,
        service_provider_id,
        part_of_encounter_id,
        meta,
        implicit_rules,
        language,
        text_div,
        contained,
        extensions,
        modifier_extensions,
        created_at,
        fhir_version,
        source_environment
    from fhir_encounters
    where id is not null
      and patient_id is not null
)

select * from final