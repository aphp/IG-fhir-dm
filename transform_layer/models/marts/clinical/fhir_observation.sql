{{
  config(
    materialized='incremental',
    unique_key='id',
    on_schema_change='sync_all_columns',
    tags=['mart', 'fhir', 'observation', 'clinical'],
    indexes=[
      {'columns': ['subject_patient_id'], 'type': 'btree'},
      {'columns': ['encounter_id'], 'type': 'btree'},
      {'columns': ['status'], 'type': 'btree'},
      {'columns': ['effective_date_time'], 'type': 'btree'},
      {'columns': ['observation_profile'], 'type': 'btree'},
      {'columns': ['laboratory_type'], 'type': 'btree'},
      {'columns': ['vital_sign_type'], 'type': 'btree'},
      {'columns': ['lifestyle_type'], 'type': 'btree'},
      {'columns': ['categories'], 'type': 'gin'},
      {'columns': ['code'], 'type': 'gin'}
    ]
  )
}}

-- FHIR Observation resources for laboratory, vital signs, and lifestyle observations
-- Combines multiple observation types following various DM observation profiles

with laboratory_observations as (
    select
        observation_id as id,
        'laboratory' as observation_profile,
        null as laboratory_type,
        null as vital_sign_type,
        null as lifestyle_type,
        patient_reference,
        encounter_reference,
        identifiers,
        status,
        categories,
        code,
        effective_date_time,
        value_quantity,
        value_string,
        null::jsonb as value_codeable_concept,
        null::jsonb as components,
        reference_ranges,
        performers,
        notes,
        meta,
        last_updated,
        created_at,
        fhir_version,
        source_environment
    from {{ ref('int_ehr__laboratory_observation_fhir') }}
    {{ handle_late_arriving_data('last_updated') }}
),

-- Note: Additional observation types would be unioned here
-- vital_signs_observations as (...),
-- lifestyle_observations as (...),

all_observations as (
    select * from laboratory_observations
    -- UNION ALL
    -- select * from vital_signs_observations
    -- UNION ALL  
    -- select * from lifestyle_observations
),

fhir_observations as (
    select
        -- FHIR Observation resource structure
        id,
        {{ add_fhir_versioning('id') }},
        last_updated,
        
        -- FHIR Observation core elements
        status,
        categories,
        code,
        
        -- FHIR Identifiers
        identifiers,
        
        -- FHIR Based on - not available in source
        null::jsonb as based_on,
        null::jsonb as part_of,
        
        -- FHIR Patient Reference
        (patient_reference->>'reference')::text as subject_patient_id,
        
        -- FHIR Encounter Reference
        case 
            when encounter_reference is not null then
                (encounter_reference->>'reference')::text
            else null
        end as encounter_id,
        
        -- FHIR Focus - not available in source
        null::jsonb as focus,
        
        -- FHIR Effective timing
        effective_date_time::timestamp with time zone,
        null::jsonb as effective_period,
        null::jsonb as effective_timing,
        null::timestamp with time zone as effective_instant,
        
        -- FHIR Issued - use effective datetime if available
        effective_date_time::timestamp with time zone as issued,
        
        -- FHIR Performers
        performers,
        
        -- FHIR Values
        value_quantity,
        value_codeable_concept,
        value_string,
        null::boolean as value_boolean,
        null::integer as value_integer,
        null::jsonb as value_range,
        null::jsonb as value_ratio,
        null::jsonb as value_sampled_data,
        null::time as value_time,
        null::timestamp with time zone as value_date_time,
        null::jsonb as value_period,
        
        -- FHIR Data absent reason - not available in source
        null::jsonb as data_absent_reason,
        
        -- FHIR Interpretation and notes
        null::jsonb as interpretations,
        notes,
        
        -- FHIR Body site - not available in source
        null::jsonb as body_site,
        
        -- FHIR Method and specimen - not available in source
        null::jsonb as method,
        null as specimen_id,
        null as device_id,
        
        -- FHIR Reference ranges
        reference_ranges,
        
        -- FHIR Related observations - not available in source
        null::jsonb as has_members,
        null::jsonb as derived_from,
        
        -- FHIR Components (for multi-component observations like blood pressure)
        components,
        
        -- Profile-specific fields for filtering and indexing
        observation_profile,
        laboratory_type,
        vital_sign_type,
        lifestyle_type,
        
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
        
    from all_observations
),

final as (
    select
        id,
        version_id,
        last_updated,
        status,
        categories,
        code,
        identifiers,
        based_on,
        part_of,
        subject_patient_id,
        encounter_id,
        focus,
        effective_date_time,
        effective_period,
        effective_timing,
        effective_instant,
        issued,
        performers,
        value_quantity,
        value_codeable_concept,
        value_string,
        value_boolean,
        value_integer,
        value_range,
        value_ratio,
        value_sampled_data,
        value_time,
        value_date_time,
        value_period,
        data_absent_reason,
        interpretations,
        notes,
        body_site,
        method,
        specimen_id,
        device_id,
        reference_ranges,
        has_members,
        derived_from,
        components,
        observation_profile,
        laboratory_type,
        vital_sign_type,
        lifestyle_type,
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
    from fhir_observations
    where id is not null
      and subject_patient_id is not null
      and code is not null
)

select * from final