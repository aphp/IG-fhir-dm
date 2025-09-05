{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'laboratory']
) }}

-- Staging model for laboratory test results
-- Source-conformed with value standardization and reference ranges

with source as (
    select * from {{ source('ehr', 'biologie') }}
),

standardized as (
    select
        -- Primary key
        biologie_id as laboratory_id,
        pmsi_id as encounter_id,
        patient_id,
        
        -- Test identification
        upper(trim(code_loinc)) as loinc_code,
        trim(libelle_test) as test_name,
        
        -- Test categorization
        case 
            when lower(trim(type_examen)) = 'fonction_renale' then 'renal-function'
            when lower(trim(type_examen)) = 'bilan_hepatique' then 'hepatic-panel'  
            when lower(trim(type_examen)) = 'hemogramme' then 'complete-blood-count'
            when lower(trim(type_examen)) = 'coagulation' then 'coagulation'
            when lower(trim(type_examen)) = 'metabolisme' then 'metabolism'
            when lower(trim(type_examen)) = 'autres' then 'other'
            else 'laboratory'
        end as test_category,
        
        -- Result values with validation
        case 
            when valeur is not null and valeur::text ~ '^-?[0-9]+\.?[0-9]*$'
            then valeur::decimal(15,6)
            else null
        end as numeric_value,
        
        case 
            when valeur_texte is not null and trim(valeur_texte) != ''
            then trim(valeur_texte)
            else null
        end as text_value,
        
        -- Units standardization
        trim(unite) as unit_of_measure,
        
        -- Temporal information
        date_prelevement as collection_datetime,
        
        -- Validation status standardization
        case 
            when upper(trim(statut_validation)) in ('VALIDE', 'VALIDATED', 'FINAL')
                then 'final'
            when upper(trim(statut_validation)) in ('PROVISOIRE', 'PRELIMINARY')
                then 'preliminary'
            when upper(trim(statut_validation)) in ('CORRIGE', 'CORRECTED', 'AMENDED')
                then 'amended'
            when upper(trim(statut_validation)) in ('ANNULE', 'CANCELLED')
                then 'cancelled'
            else 'final'
        end as validation_status,
        
        -- Reference ranges with validation
        case 
            when borne_inf_normale is not null 
                and borne_inf_normale::text ~ '^-?[0-9]+\.?[0-9]*$'
            then borne_inf_normale::decimal(15,6)
            else null
        end as reference_range_low,
        
        case 
            when borne_sup_normale is not null 
                and borne_sup_normale::text ~ '^-?[0-9]+\.?[0-9]*$'
            then borne_sup_normale::decimal(15,6)
            else null
        end as reference_range_high,
        
        -- Laboratory information
        trim(laboratoire) as laboratory_name,
        trim(methode_analyse) as analysis_method,
        
        -- Comments
        trim(commentaire) as result_comment,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where biologie_id is not null
      and pmsi_id is not null
      and patient_id is not null
),

validated as (
    select *
    from standardized
    where 
        -- Ensure we have either numeric or text value
        (numeric_value is not null or text_value is not null)
        -- Validate reference ranges
        and (reference_range_low is null or reference_range_high is null 
             or reference_range_low <= reference_range_high)
        -- Validate collection datetime
        and (collection_datetime is null or collection_datetime <= current_timestamp)
)

select * from validated