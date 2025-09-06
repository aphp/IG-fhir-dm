{{
    config(
        materialized='view',
        tags=['staging', 'observation', 'laboratory', 'loinc']
    )
}}

with source_data as (
    select
        biologie_id,
        pmsi_id,
        patient_id,
        code_loinc,
        libelle_test,
        valeur,
        unite,
        laboratoire,
        date_prelevement,
        current_timestamp as extracted_at
    from {{ ref('biologie_sample') }}
),

cleaned_data as (
    select
        -- Primary keys
        biologie_id,
        pmsi_id,
        patient_id,
        
        -- Laboratory test information
        trim(code_loinc) as loinc_code,
        trim(libelle_test) as test_name_fr,
        trim(valeur::text) as test_value,
        trim(unite) as test_unit,
        trim(laboratoire) as laboratory_name,
        date_prelevement::date as collection_date,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('observation_id_prefix') }}' || 'lab-' || biologie_id::text as fhir_observation_id,
        '{{ var('encounter_id_prefix') }}' || pmsi_id::text as fhir_encounter_id,
        '{{ var('patient_id_prefix') }}' || patient_id::text as fhir_patient_id,
        
        -- FHIR observation status (assuming final if recorded)
        'final' as observation_status,
        
        -- FHIR observation category for laboratory tests
        'laboratory' as observation_category,
        
        -- Value type determination
        case 
            when valeur::text ~ '^[0-9]+\.?[0-9]*$' then 'Quantity'  -- Numeric value
            when valeur::text ~ '^[<>]=?' then 'Quantity'  -- Comparison operators
            else 'string'  -- Text value
        end as value_type,
        
        -- Numeric value extraction for quantities
        case 
            when valeur::text ~ '^[0-9]+\.?[0-9]*$' then valeur::decimal
            when valeur::text ~ '^[<>]=?([0-9]+\.?[0-9]*)' then 
                regexp_replace(valeur::text, '^[<>]=?([0-9]+\.?[0-9]*).*', '\1')::decimal
            else null
        end as numeric_value,
        
        -- Comparator extraction for quantities
        case 
            when valeur::text ~ '^<' then '<'
            when valeur::text ~ '^>' then '>'
            when valeur::text ~ '^<=' then '<='
            when valeur::text ~ '^>=' then '>='
            else null
        end as value_comparator,
        
        -- Data quality flags
        case when code_loinc is not null and length(trim(code_loinc)) > 0 then true else false end as has_loinc_code,
        case when valeur is not null and length(trim(valeur::text)) > 0 then true else false end as has_test_value,
        case when date_prelevement is not null then true else false end as has_collection_date
        
    from source_data
    where patient_id is not null  -- Only include lab results with valid patient reference
)

select * from cleaned_data