{{
    config(
        materialized='view',
        tags=['staging', 'observation', 'lifestyle']
    )
}}

with source_style_vie as (
    select * from {{ source('ehr', 'style_vie') }}
),

cleaned_style_vie as (
    select
        style_vie_id,
        patient_id,
        
        -- Lifestyle factors
        trim(consommation_tabac) as consommation_tabac,
        trim(consommation_alcool) as consommation_alcool,
        trim(consommation_autres_drogues) as consommation_autres_drogues,
        trim(activite_physique) as activite_physique,
        
        -- Collection date
        date_recueil,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when (consommation_tabac is not null or consommation_alcool is not null or 
                  consommation_autres_drogues is not null or activite_physique is not null) 
                 and date_recueil is not null then 'high'
            when consommation_tabac is not null or consommation_alcool is not null or 
                 consommation_autres_drogues is not null or activite_physique is not null then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR observation status - assume final for lifestyle data
        'final' as fhir_status,
        
        -- FHIR category - social history for lifestyle observations
        'social-history' as fhir_category,
        
        -- Flags for individual lifestyle elements
        case when consommation_tabac is not null and trim(consommation_tabac) != '' then true else false end as has_tobacco_data,
        case when consommation_alcool is not null and trim(consommation_alcool) != '' then true else false end as has_alcohol_data,
        case when consommation_autres_drogues is not null and trim(consommation_autres_drogues) != '' then true else false end as has_drug_data,
        case when activite_physique is not null and trim(activite_physique) != '' then true else false end as has_physical_activity_data,
        
        -- Generate base FHIR observation ID (will be modified for each lifestyle element)
        {{ dbt_utils.generate_surrogate_key(['style_vie_id']) }} as fhir_base_observation_id
        
    from source_style_vie
    where patient_id is not null
)

select * from cleaned_style_vie