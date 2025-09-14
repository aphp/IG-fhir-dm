{{
    config(
        materialized='view',
        tags=['staging', 'encounter']
    )
}}

with source_donnees_pmsi as (
    select * from {{ source('ehr', 'donnees_pmsi') }}
),

cleaned_donnees_pmsi as (
    select
        pmsi_id,
        patient_id,
        
        -- Stay information
        trim(mode_sortie) as mode_sortie,
        trim(mode_entree) as mode_entree,
        age_admission,
        
        -- Stay dates
        date_debut_sejour,
        date_fin_sejour,
        
        -- Calculate length of stay
        case 
            when date_debut_sejour is not null and date_fin_sejour is not null
            then date_fin_sejour - date_debut_sejour
            else null
        end as length_of_stay_days,
        
        -- Organizational information
        trim(etablissement) as etablissement,
        trim(service) as service,
        trim(unite_fonctionnelle) as unite_fonctionnelle,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when date_debut_sejour is not null and date_fin_sejour is not null and etablissement is not null then 'high'
            when date_debut_sejour is not null and (date_fin_sejour is not null or etablissement is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR encounter status mapping
        case 
            when date_fin_sejour is not null then 'finished'
            when date_debut_sejour <= current_date and (date_fin_sejour is null or date_fin_sejour > current_date) then 'in-progress'
            when date_debut_sejour > current_date then 'planned'
            else 'unknown'
        end as fhir_status,
        
        -- Generate FHIR-compatible encounter ID
        {{ dbt_utils.generate_surrogate_key(['pmsi_id']) }} as fhir_encounter_id
        
    from source_donnees_pmsi
    where patient_id is not null
)

select * from cleaned_donnees_pmsi