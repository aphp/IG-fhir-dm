{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'patient']
) }}

-- Staging model for patient demographics and identity information
-- Source-conformed with basic data type casting and standardization

with source as (
    select * from {{ source('ehr', 'patient') }}
),

standardized as (
    select
        -- Primary key
        patient_id,
        
        -- Name standardization
        trim(upper(nom)) as family_name,
        trim(initcap(prenom)) as given_name,
        
        -- Identifier cleaning and validation
        case 
            when nir is not null and length(trim(nir)) = 13 
                and trim(nir) ~ '^[0-9]{13}$'
            then trim(nir)
            else null
        end as ins_nir_identifier,
        
        case 
            when ins is not null and trim(ins) != ''
            then trim(ins)
            else null
        end as ins_identifier,
        
        -- Demographics
        date_naissance as birth_date,
        
        -- Gender standardization
        case 
            when upper(trim(sexe)) in ('M', 'MASCULIN', '1') then 'M'
            when upper(trim(sexe)) in ('F', 'FEMININ', 'FÉMININ', '2') then 'F'
            when upper(trim(sexe)) in ('INDETERMINE', 'INDÉTERMINÉ', '9') then 'U'
            else 'U'
        end as gender_code,
        
        -- Death information
        date_deces as deceased_date,
        trim(source_deces) as deceased_source,
        
        -- Multiple birth
        rang_gemellaire as multiple_birth_rank,
        
        -- Address/geographic information
        case 
            when latitude between -90 and 90 then latitude::decimal(10,7)
            else null
        end as address_latitude,
        
        case 
            when longitude between -180 and 180 then longitude::decimal(10,7)
            else null
        end as address_longitude,
        
        trim(code_iris) as address_iris_code,
        trim(libelle_iris) as address_iris_label,
        trim(code_geographique_residence) as address_postal_code,
        trim(libelle_geographique_residence) as address_city,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where patient_id is not null
      and date_naissance is not null
      and date_naissance <= current_date
)

select * from standardized