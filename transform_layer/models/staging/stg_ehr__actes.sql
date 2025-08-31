{{
    config(
        materialized='view',
        tags=['staging', 'procedure', 'ccam']
    )
}}

with source_data as (
    select
        acte_id,
        pmsi_id,
        code_acte,
        libelle_acte,
        date_acte,
        current_timestamp as extracted_at
    from {{ ref('actes_sample') }}
),

cleaned_data as (
    select
        -- Primary keys
        acte_id,
        pmsi_id,
        
        -- Procedure information
        trim(upper(code_acte)) as ccam_code,
        trim(libelle_acte) as procedure_label_fr,
        date_acte::date as procedure_date,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('procedure_id_prefix') }}' || acte_id::text as fhir_procedure_id,
        '{{ var('encounter_id_prefix') }}' || pmsi_id::text as fhir_encounter_id,
        
        -- FHIR status mapping (assuming completed if recorded)
        'completed' as procedure_status,
        
        -- FHIR category mapping based on CCAM code structure
        case
            when trim(upper(code_acte)) like 'A%' then 'surgical'  -- Anesthesia
            when trim(upper(code_acte)) like 'E%' then 'therapeutic'  -- Examination
            when trim(upper(code_acte)) like 'F%' then 'surgical'  -- Functional exploration
            when trim(upper(code_acte)) like 'H%' then 'surgical'  -- Surgery
            when trim(upper(code_acte)) like 'L%' then 'diagnostic'  -- Laboratory
            when trim(upper(code_acte)) like 'P%' then 'therapeutic'  -- Pharmacy
            when trim(upper(code_acte)) like 'Z%' then 'diagnostic'  -- Radiology
            else 'therapeutic'
        end as procedure_category,
        
        -- Data quality flags
        case when code_acte is not null and length(trim(code_acte)) >= 7 then true else false end as has_valid_ccam_code,
        case when date_acte is not null then true else false end as has_procedure_date
        
    from source_data
    where pmsi_id is not null  -- Only include procedures with valid encounter reference
)

select * from cleaned_data