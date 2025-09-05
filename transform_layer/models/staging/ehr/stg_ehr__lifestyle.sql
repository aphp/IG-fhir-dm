{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'lifestyle']
) }}

-- Staging model for lifestyle observations and social history
-- Source-conformed with standardized lifestyle categories

with source as (
    select * from {{ source('ehr', 'style_vie') }}
),

standardized as (
    select
        -- Primary key
        style_vie_id as lifestyle_id,
        pmsi_id as encounter_id,
        patient_id,
        
        -- Tobacco use standardization
        case 
            when lower(trim(consommation_tabac)) in ('non', 'jamais', 'never', 'non-fumeur')
                then 'never'
            when lower(trim(consommation_tabac)) in ('oui', 'actuel', 'current', 'fumeur')
                then 'current'
            when lower(trim(consommation_tabac)) in ('ancien', 'ex-fumeur', 'former', 'sevré')
                then 'former'
            when lower(trim(consommation_tabac)) in ('inconnu', 'unknown', 'non renseigné')
                then 'unknown'
            else trim(consommation_tabac)
        end as tobacco_use,
        
        -- Alcohol use standardization
        case 
            when lower(trim(consommation_alcool)) in ('non', 'jamais', 'never', 'abstinent')
                then 'never'
            when lower(trim(consommation_alcool)) in ('oui', 'actuel', 'current', 'consommateur')
                then 'current'
            when lower(trim(consommation_alcool)) in ('ancien', 'ex-consommateur', 'former', 'sevré')
                then 'former'
            when lower(trim(consommation_alcool)) in ('occasionnel', 'occasional')
                then 'occasional'
            when lower(trim(consommation_alcool)) in ('inconnu', 'unknown', 'non renseigné')
                then 'unknown'
            else trim(consommation_alcool)
        end as alcohol_use,
        
        -- Other substance use standardization
        case 
            when lower(trim(consommation_autres_drogues)) in ('non', 'jamais', 'never')
                then 'never'
            when lower(trim(consommation_autres_drogues)) in ('oui', 'actuel', 'current')
                then 'current'
            when lower(trim(consommation_autres_drogues)) in ('ancien', 'former', 'sevré')
                then 'former'
            when lower(trim(consommation_autres_drogues)) in ('inconnu', 'unknown', 'non renseigné')
                then 'unknown'
            else trim(consommation_autres_drogues)
        end as substance_use,
        
        -- Physical activity standardization
        case 
            when lower(trim(activite_physique)) in ('sedentaire', 'sedentary', 'aucune', 'none')
                then 'sedentary'
            when lower(trim(activite_physique)) in ('faible', 'low', 'légère', 'legere')
                then 'low'
            when lower(trim(activite_physique)) in ('moderee', 'modérée', 'moderate')
                then 'moderate'
            when lower(trim(activite_physique)) in ('elevee', 'élevée', 'high', 'intense')
                then 'high'
            when lower(trim(activite_physique)) in ('inconnu', 'unknown', 'non renseigné')
                then 'unknown'
            else trim(activite_physique)
        end as physical_activity,
        
        -- Data collection context
        date_recueil as data_collection_date,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where style_vie_id is not null
      and pmsi_id is not null
      and patient_id is not null
),

validated as (
    select *
    from standardized
    where 
        -- Ensure we have at least one lifestyle observation
        (tobacco_use is not null or alcohol_use is not null 
         or substance_use is not null or physical_activity is not null)
        -- Validate data collection date
        and (data_collection_date is null or data_collection_date <= current_date)
)

select * from validated