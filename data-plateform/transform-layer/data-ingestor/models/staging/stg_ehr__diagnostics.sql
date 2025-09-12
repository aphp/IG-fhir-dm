{{
    config(
        materialized='view',
        tags=['staging', 'condition']
    )
}}

with source_diagnostics as (
    select * from {{ source('ehr', 'diagnostics') }}
),

cleaned_diagnostics as (
    select
        diagnostic_id,
        patient_id,
        pmsi_id,
        
        -- Diagnostic information
        upper(trim(code_diagnostic)) as code_diagnostic,
        trim(type_diagnostic) as type_diagnostic,
        trim(libelle_diagnostic) as libelle_diagnostic,
        
        -- Collection date
        date_recueil,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality flags
        case when code_diagnostic is not null and libelle_diagnostic is not null then 'high'
             when code_diagnostic is not null or libelle_diagnostic is not null then 'medium'
             else 'low'
        end as data_quality_level,
        
        -- FHIR mapping helpers
        case 
            when code_diagnostic is not null then 'http://hl7.org/fhir/sid/icd-10'
            else null
        end as code_system,
        
        -- Clinical status (assume active for recorded diagnoses)
        'active' as fhir_clinical_status,
        
        -- Verification status (assume confirmed for coded diagnoses)
        case 
            when code_diagnostic is not null then 'confirmed'
            else 'provisional'
        end as fhir_verification_status,
        
        -- Category mapping - PMSI diagnoses are encounter diagnoses
        'encounter-diagnosis' as fhir_category,
        
        -- Generate FHIR-compatible condition ID
        {{ dbt_utils.generate_surrogate_key(['diagnostic_id']) }} as fhir_condition_id
        
    from source_diagnostics
    where patient_id is not null and pmsi_id is not null
)

select * from cleaned_diagnostics