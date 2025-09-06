{{
    config(
        materialized='view',
        tags=['staging', 'patient', 'demographics']
    )
}}

with source_data as (
    select
        patient_id,
        nom,
        prenom,
        nir,
        ins,
        date_naissance,
        sexe,
        latitude,
        longitude,
        code_geographique_residence,
        libelle_geographique_residence,
        current_timestamp as extracted_at
    from {{ ref('patient_sample') }}
),

cleaned_data as (
    select
        -- Primary key
        patient_id,
        
        -- Name components
        trim(upper(nom)) as family_name,
        trim(initcap(prenom)) as given_name,
        
        -- French healthcare identifiers
        trim(nir::text) as nir,  -- National insurance number
        trim(ins) as ins,  -- National health insurance identifier
        
        -- Demographics
        date_naissance::date as birth_date,
        case 
            when upper(trim(sexe)) = 'M' then 'male'
            when upper(trim(sexe)) = 'F' then 'female'
            else 'unknown'
        end as gender,
        
        -- Geographic information
        latitude::decimal(10,8) as latitude,
        longitude::decimal(11,8) as longitude,
        trim(code_geographique_residence::text) as postal_code,
        trim(libelle_geographique_residence) as city,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('patient_id_prefix') }}' || patient_id::text as fhir_patient_id,
        
        -- Data quality flags
        case when nir is not null and length(trim(nir::text)) > 0 then true else false end as has_nir,
        case when ins is not null and length(trim(ins::text)) > 0 then true else false end as has_ins,
        case when latitude is not null and longitude is not null then true else false end as has_location
        
    from source_data
)

select * from cleaned_data