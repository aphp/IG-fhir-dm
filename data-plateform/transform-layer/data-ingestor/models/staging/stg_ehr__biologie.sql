{{
    config(
        materialized='view',
        tags=['staging', 'observation', 'laboratory']
    )
}}

with source_biologie as (
    select * from {{ source('ehr', 'biologie') }}
),

cleaned_biologie as (
    select
        biologie_id,
        patient_id,
        
        -- Laboratory test information
        trim(code_loinc) as code_loinc,
        trim(libelle_test) as libelle_test,
        trim(type_examen) as type_examen,
        
        -- Test values
        valeur,
        trim(unite) as unite,
        valeur_texte,
        
        -- Test timing and validation
        date_prelevement,
        trim(statut_validation) as statut_validation,
        
        -- Reference ranges
        borne_inf_normale,
        borne_sup_normale,
        
        -- Laboratory information
        trim(laboratoire) as laboratoire,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when code_loinc is not null and (valeur is not null or valeur_texte is not null) and date_prelevement is not null then 'high'
            when code_loinc is not null and (valeur is not null or valeur_texte is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR observation status mapping
        case 
            when lower(trim(statut_validation)) = 'valide' then 'final'
            when lower(trim(statut_validation)) = 'en_cours' then 'preliminary'
            when lower(trim(statut_validation)) = 'rejete' then 'cancelled'
            when lower(trim(statut_validation)) = 'en_attente' then 'registered'
            else 'final'  -- Default for historical data
        end as fhir_status,
        
        -- FHIR category - laboratory observations
        'laboratory' as fhir_category,
        
        -- LOINC system
        case when code_loinc is not null then 'http://loinc.org' else null end as code_system,
        
        -- Value type determination
        case 
            when valeur is not null then 'Quantity'
            when valeur_texte is not null then 'string'
            else null
        end as value_type,
        
        -- Generate FHIR-compatible observation ID
        {{ dbt_utils.generate_surrogate_key(['biologie_id']) }} as fhir_observation_id
        
    from source_biologie
    where patient_id is not null
)

select * from cleaned_biologie