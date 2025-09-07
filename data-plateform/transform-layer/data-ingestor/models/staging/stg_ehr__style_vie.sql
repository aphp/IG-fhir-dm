{{
    config(
        materialized='view',
        tags=['staging', 'observation', 'lifestyle', 'social-determinants']
    )
}}

with source_data as (
    select
        style_vie_id,
        pmsi_id,
        patient_id,
        consommation_tabac,
        consommation_alcool,
        date_recueil,
        current_timestamp as extracted_at
    from {{ ref('style_vie_sample') }}
),

-- Unpivot the data to convert from wide to long format
unpivoted_data as (
    select
        style_vie_id,
        pmsi_id,
        patient_id,
        extracted_at,
        'tabac' as type_facteur,
        consommation_tabac as valeur,
        date_recueil as date_evaluation
    from source_data
    where consommation_tabac is not null
    
    union all
    
    select
        style_vie_id,
        pmsi_id,
        patient_id,
        extracted_at,
        'alcool' as type_facteur,
        consommation_alcool as valeur,
        date_recueil as date_evaluation
    from source_data
    where consommation_alcool is not null
),

cleaned_data as (
    select
        -- Primary keys
        style_vie_id,
        pmsi_id,
        patient_id,
        
        -- Lifestyle information
        trim(lower(type_facteur)) as lifestyle_factor_type,
        trim(valeur) as lifestyle_value,
        date_evaluation::date as assessment_date,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('observation_id_prefix') }}' || 'lifestyle-' || style_vie_id::text || '-' || type_facteur as fhir_observation_id,
        '{{ var('patient_id_prefix') }}' || patient_id::text as fhir_patient_id,
        
        -- FHIR observation status (assuming final if recorded)
        'final' as observation_status,
        
        -- FHIR observation category for social history
        'social-history' as observation_category,
        
        -- LOINC code mapping for lifestyle factors
        case
            when trim(lower(type_facteur)) in ('tabac', 'smoking', 'tobacco use', 'cigarette') then '72166-2'  -- Tobacco smoking status
            when trim(lower(type_facteur)) in ('alcool', 'alcohol', 'alcohol use', 'boisson alcoolisee') then '11331-6'  -- History of alcohol use
            when trim(lower(type_facteur)) in ('activite physique', 'physical activity', 'exercise', 'sport') then '68516-4'  -- Physical activity
            when trim(lower(type_facteur)) in ('alimentation', 'nutrition', 'diet', 'regime alimentaire') then '67504-6'  -- Dietary assessment
            when trim(lower(type_facteur)) in ('sommeil', 'sleep', 'sleep pattern') then '93832-4'  -- Sleep status
            when trim(lower(type_facteur)) in ('stress', 'anxiety', 'mental health') then '72133-2'  -- Perceived stress
            when trim(lower(type_facteur)) in ('profession', 'occupation', 'work', 'metier') then '11341-5'  -- History of occupation
            else null
        end as loinc_code,
        
        -- Display name in French
        case
            when trim(lower(type_facteur)) in ('tabac', 'smoking', 'tobacco use', 'cigarette') then 'Statut tabagique'
            when trim(lower(type_facteur)) in ('alcool', 'alcohol', 'alcohol use', 'boisson alcoolisee') then 'Consommation d''alcool'
            when trim(lower(type_facteur)) in ('activite physique', 'physical activity', 'exercise', 'sport') then 'Activité physique'
            when trim(lower(type_facteur)) in ('alimentation', 'nutrition', 'diet', 'regime alimentaire') then 'Habitudes alimentaires'
            when trim(lower(type_facteur)) in ('sommeil', 'sleep', 'sleep pattern') then 'Qualité du sommeil'
            when trim(lower(type_facteur)) in ('stress', 'anxiety', 'mental health') then 'Niveau de stress perçu'
            when trim(lower(type_facteur)) in ('profession', 'occupation', 'work', 'metier') then 'Profession'
            else trim(type_facteur)
        end as lifestyle_display_fr,
        
        -- Value type determination
        case 
            when valeur ~ '^[0-9]+\.?[0-9]*$' then 'Quantity'  -- Numeric value
            when lower(trim(valeur)) in ('oui', 'non', 'yes', 'no', 'true', 'false') then 'boolean'  -- Boolean
            else 'string'  -- Text value
        end as value_type,
        
        -- Boolean value extraction
        case 
            when lower(trim(valeur)) in ('oui', 'yes', 'true', '1') then true
            when lower(trim(valeur)) in ('non', 'no', 'false', '0') then false
            else null
        end as boolean_value,
        
        -- Numeric value extraction
        case 
            when valeur ~ '^[0-9]+\.?[0-9]*$' then valeur::decimal
            else null
        end as numeric_value,
        
        -- Smoking status standardization
        case
            when trim(lower(type_facteur)) in ('tabac', 'smoking', 'tobacco use') and lower(trim(valeur)) in ('jamais', 'never', 'non-fumeur') then '266919005'  -- Never smoker
            when trim(lower(type_facteur)) in ('tabac', 'smoking', 'tobacco use') and lower(trim(valeur)) in ('ancien', 'ex', 'ex-fumeur', 'former') then '8517006'  -- Former smoker
            when trim(lower(type_facteur)) in ('tabac', 'smoking', 'tobacco use') and lower(trim(valeur)) in ('actuel', 'current', 'fumeur') then '77176002'  -- Current smoker
            else null
        end as smoking_status_snomed,
        
        -- Data quality flags
        case when type_facteur is not null and length(trim(type_facteur)) > 0 then true else false end as has_lifestyle_factor,
        case when valeur is not null and length(trim(valeur)) > 0 then true else false end as has_lifestyle_value,
        case when date_evaluation is not null then true else false end as has_assessment_date
        
    from unpivoted_data
    where patient_id is not null  -- Only include lifestyle factors with valid patient reference
)

select * from cleaned_data