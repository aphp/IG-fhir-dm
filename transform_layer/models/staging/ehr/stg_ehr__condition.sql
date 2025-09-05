{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'condition']
) }}

-- Staging model for diagnostic conditions
-- Source-conformed with ICD-10 code validation and categorization

with source as (
    select * from {{ source('ehr', 'diagnostics') }}
),

standardized as (
    select
        -- Primary key
        diagnostic_id as condition_id,
        pmsi_id as encounter_id,
        
        -- ICD-10 code validation and standardization
        upper(trim(code_diagnostic)) as icd10_code,
        trim(libelle_diagnostic) as condition_text,
        
        -- Diagnosis classification
        case 
            when lower(trim(type_diagnostic)) in ('principal', 'primaire', 'primary') 
                then 'encounter-diagnosis'
            when lower(trim(type_diagnostic)) in ('secondaire', 'secondary', 'associe', 'associé')
                then 'billing-diagnosis'
            else coalesce(trim(type_diagnostic), 'encounter-diagnosis')
        end as diagnosis_type,
        
        -- Temporal information
        date_diagnostic,
        
        -- Sequencing
        case 
            when sequence_diagnostic > 0 then sequence_diagnostic
            else 1
        end as diagnosis_sequence,
        
        -- Data collection context
        date_recueil as data_collection_date,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where diagnostic_id is not null
      and pmsi_id is not null
      and code_diagnostic is not null
      and trim(code_diagnostic) != ''
),

validated as (
    select *
    from standardized
    where 
        -- Basic ICD-10 format validation (starts with letter, followed by digits)
        icd10_code ~ '^[A-Z][0-9]'
        -- Ensure reasonable sequence numbers
        and diagnosis_sequence between 1 and 99
)

select * from validated