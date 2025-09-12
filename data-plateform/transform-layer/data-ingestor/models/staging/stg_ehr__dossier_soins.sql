{{
    config(
        materialized='view',
        tags=['staging', 'observation', 'vital_signs']
    )
}}

with source_dossier_soins as (
    select * from {{ source('ehr', 'dossier_soins') }}
),

cleaned_dossier_soins as (
    select
        soin_id,
        patient_id,
        
        -- Measurement information
        trim(code_loinc) as code_loinc,
        trim(libelle_test) as libelle_test,
        
        -- Values
        valeur,
        trim(unite) as unite,
        valeur_code,
        valeur_texte,
        
        -- Measurement context
        date_mesure,
        trim(unite_soins) as unite_soins,
        trim(professionnel) as professionnel,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when code_loinc is not null and (valeur is not null or valeur_texte is not null) and date_mesure is not null then 'high'
            when code_loinc is not null and (valeur is not null or valeur_texte is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR observation status - assume final for care measurements
        'final' as fhir_status,
        
        -- FHIR category - vital signs for care measurements
        'vital-signs' as fhir_category,
        
        -- LOINC system
        case when code_loinc is not null then 'http://loinc.org' else null end as code_system,
        
        -- Value type determination
        case 
            when valeur is not null then 'Quantity'
            when valeur_code is not null then 'CodeableConcept'
            when valeur_texte is not null then 'string'
            else null
        end as value_type,
        
        -- Generate FHIR-compatible observation ID
        {{ dbt_utils.generate_surrogate_key(['soin_id']) }} as fhir_observation_id
        
    from source_dossier_soins
    where patient_id is not null
)

select * from cleaned_dossier_soins