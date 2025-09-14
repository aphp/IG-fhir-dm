{{
    config(
        materialized='view',
        tags=['staging', 'patient']
    )
}}

with source_patient as (
    select * from {{ source('ehr', 'patient') }}
),

cleaned_patient as (
    select
        patient_id,
        
        -- Identity fields
        upper(trim(nom)) as nom,
        upper(trim(prenom)) as prenom,
        trim(nir) as nir,
        trim(ins) as ins,
        
        -- Demographics
        date_naissance,
        case 
            when lower(trim(sexe)) = 'h' then 'male'
            when lower(trim(sexe)) = 'f' then 'female'
            else 'unknown'
        end as gender_fhir,
        sexe as gender_original,
        
        -- Death information
        date_deces,
        trim(source_deces) as source_deces,
        
        -- Multiple birth
        rang_gemellaire,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality flags
        case 
            when nom is not null and prenom is not null and date_naissance is not null then 'high'
            when nom is not null and (prenom is not null or date_naissance is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- Calculate data quality score
        (
            case when patient_id is not null then 10 else 0 end +
            case when nom is not null then 15 else 0 end +
            case when prenom is not null then 15 else 0 end +
            case when date_naissance is not null then 20 else 0 end +
            case when sexe is not null then 10 else 0 end +
            case when ins is not null then 15 else 0 end +
            case when nir is not null then 15 else 0 end
        ) as data_quality_score,
        
        -- Identifier flags
        case when trim(nir) is not null and trim(nir) != '' then true else false end as has_nss,
        case when trim(ins) is not null and trim(ins) != '' then true else false end as has_ins,
        
        -- Generate FHIR-compatible UUID
        {{ dbt_utils.generate_surrogate_key(['patient_id']) }} as fhir_patient_id
        
    from source_patient
)

select * from cleaned_patient