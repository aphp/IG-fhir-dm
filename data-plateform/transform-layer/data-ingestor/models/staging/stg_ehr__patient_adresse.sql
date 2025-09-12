{{
    config(
        materialized='view',
        tags=['staging', 'address']
    )
}}

with source_patient_adresse as (
    select * from {{ source('ehr', 'patient_adresse') }}
),

cleaned_patient_adresse as (
    select
        patient_adresse_id,
        patient_id,
        
        -- Geographic coordinates
        latitude,
        longitude,
        
        -- IRIS information
        trim(code_iris) as code_iris,
        trim(libelle_iris) as libelle_iris,
        
        -- PMSI geographic codes
        trim(code_geographique_residence) as code_geographique_residence,
        trim(libelle_geographique_residence) as libelle_geographique_residence,
        
        -- Collection date
        date_recueil,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Location availability flags
        case when latitude is not null and longitude is not null then true else false end as has_coordinates,
        case when code_iris is not null or libelle_iris is not null then true else false end as has_iris,
        case when code_geographique_residence is not null then true else false end as has_pmsi_geo,
        
        -- Generate surrogate key
        {{ dbt_utils.generate_surrogate_key(['patient_adresse_id']) }} as fhir_address_id
        
    from source_patient_adresse
    where patient_id is not null
)

select * from cleaned_patient_adresse