{{
    config(
        materialized='view',
        tags=['staging', 'dosage']
    )
}}

with source_posologie as (
    select * from {{ source('ehr', 'posologie') }}
),

cleaned_posologie as (
    select
        posologie_id,
        prescription_id,
        
        -- Dosage information
        nombre_prises_par_jour,
        quantite,
        trim(unite_quantite) as unite_quantite,
        
        -- Timing
        date_heure_debut,
        date_heure_fin,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when quantite is not null and nombre_prises_par_jour is not null and unite_quantite is not null then 'high'
            when quantite is not null and (nombre_prises_par_jour is not null or unite_quantite is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- Generate surrogate key
        {{ dbt_utils.generate_surrogate_key(['posologie_id']) }} as fhir_dosage_id
        
    from source_posologie
    where prescription_id is not null
)

select * from cleaned_posologie