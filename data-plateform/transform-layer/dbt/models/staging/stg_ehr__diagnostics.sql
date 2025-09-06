{{
    config(
        materialized='view',
        tags=['staging', 'condition', 'icd10']
    )
}}

with source_data as (
    select
        diagnostic_id,
        pmsi_id,
        code_diagnostic,
        type_diagnostic,
        libelle_diagnostic,
        date_diagnostic,
        current_timestamp as extracted_at
    from {{ ref('diagnostics_sample') }}
),

cleaned_data as (
    select
        -- Primary keys
        diagnostic_id,
        pmsi_id,
        
        -- Diagnostic information
        trim(upper(code_diagnostic)) as icd10_code,
        trim(type_diagnostic) as diagnosis_type,
        trim(libelle_diagnostic) as diagnosis_label_fr,
        date_diagnostic::date as diagnosis_date,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('condition_id_prefix') }}' || diagnostic_id::text as fhir_condition_id,
        '{{ var('encounter_id_prefix') }}' || pmsi_id::text as fhir_encounter_id,
        
        -- FHIR condition category mapping
        case
            when trim(lower(type_diagnostic)) like '%principal%' then 'encounter-diagnosis'
            when trim(lower(type_diagnostic)) like '%secondaire%' then 'encounter-diagnosis'
            else 'problem-list-item'
        end as condition_category,
        
        -- FHIR verification status mapping
        case
            when trim(lower(type_diagnostic)) like '%principal%' then 'confirmed'
            when trim(lower(type_diagnostic)) like '%secondaire%' then 'confirmed'
            when trim(lower(type_diagnostic)) like '%suspect%' then 'provisional'
            else 'confirmed'
        end as verification_status,
        
        -- Clinical status (assuming active if recorded)
        'active' as clinical_status,
        
        -- Data quality flags
        case when code_diagnostic is not null and length(trim(code_diagnostic)) >= 3 then true else false end as has_valid_icd10_code,
        case when date_diagnostic is not null then true else false end as has_diagnosis_date
        
    from source_data
    where pmsi_id is not null  -- Only include diagnostics with valid encounter reference
)

select * from cleaned_data