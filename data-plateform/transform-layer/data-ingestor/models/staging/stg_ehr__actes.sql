{{
    config(
        materialized='view',
        tags=['staging', 'procedure']
    )
}}

with source_actes as (
    select * from {{ source('ehr', 'actes') }}
),

cleaned_actes as (
    select
        acte_id,
        patient_id,
        pmsi_id,
        
        -- Procedure information
        upper(trim(code_acte)) as code_acte,
        trim(libelle_acte) as libelle_acte,
        date_acte,
        trim(executant) as executant,
        
        -- Collection date
        date_recueil,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when code_acte is not null and libelle_acte is not null and date_acte is not null then 'high'
            when code_acte is not null and (libelle_acte is not null or date_acte is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR mapping helpers
        case 
            when code_acte is not null then 'https://interop.aphp.fr/ig/fhir/dm/CodeSystem/Ccam'
            else null
        end as code_system,
        
        -- Status mapping - assume completed for historical procedures
        case 
            when date_acte is not null and date_acte <= current_timestamp then 'completed'
            when date_acte is not null and date_acte > current_timestamp then 'preparation'
            else 'unknown'
        end as fhir_status,
        
        -- Generate FHIR-compatible procedure ID
        {{ dbt_utils.generate_surrogate_key(['acte_id']) }} as fhir_procedure_id
        
    from source_actes
    where patient_id is not null and pmsi_id is not null
)

select * from cleaned_actes