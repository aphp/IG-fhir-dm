{{
    config(
        materialized='view',
        tags=['staging', 'medication_administration']
    )
}}

with source_administration as (
    select * from {{ source('ehr', 'administration') }}
),

cleaned_administration as (
    select
        administration_id,
        patient_id,
        prescription_id,  -- Can be null for unordered administrations
        
        -- Medication information
        trim(denomination) as denomination,
        trim(code_atc) as code_atc,
        voie_administration,
        
        -- Administration details
        quantite,
        trim(unite_quantite) as unite_quantite,
        date_heure_debut,
        date_heure_fin,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when denomination is not null and quantite is not null and date_heure_debut is not null then 'high'
            when denomination is not null and (quantite is not null or date_heure_debut is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR MedicationAdministration status mapping
        case 
            when date_heure_fin is not null and date_heure_fin <= current_timestamp then 'completed'
            when date_heure_debut is not null and date_heure_debut <= current_timestamp 
                 and (date_heure_fin is null or date_heure_fin > current_timestamp) then 'in-progress'
            when date_heure_debut is not null and date_heure_debut > current_timestamp then 'not-done'
            else 'unknown'
        end as fhir_status,
        
        -- ATC system
        case when code_atc is not null then 'http://www.whocc.no/atc' else null end as atc_system,
        
        -- Route system (French terminology)
        case when voie_administration is not null then 'https://smt.esante.gouv.fr/terminologie-standardterms' else null end as route_system,
        
        -- Distinguish between ordered and unordered administrations
        case when prescription_id is not null then 'with_order' else 'without_order' end as administration_type,
        
        -- Generate FHIR-compatible medication administration ID
        {{ dbt_utils.generate_surrogate_key(['administration_id']) }} as fhir_medication_administration_id
        
    from source_administration
    where patient_id is not null
)

select * from cleaned_administration