{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'encounter']
) }}

-- Staging model for healthcare encounters from PMSI data
-- Source-conformed with period calculations and status standardization

with source as (
    select * from {{ source('ehr', 'donnees_pmsi') }}
),

standardized as (
    select
        -- Primary key
        pmsi_id as encounter_id,
        patient_id,
        
        -- Status standardization - assume finished for historical PMSI data
        case 
            when date_fin_sejour is not null then 'finished'
            when date_debut_sejour is not null and date_fin_sejour is null then 'in-progress'
            else 'unknown'
        end as encounter_status,
        
        -- Class - assume inpatient for PMSI data with length of stay
        case 
            when duree_sejour is not null and duree_sejour > 0 then 'inpatient'
            when duree_sejour = 0 then 'outpatient'
            else 'inpatient'
        end as encounter_class,
        
        -- Period information
        date_debut_sejour::timestamp as period_start,
        date_fin_sejour::timestamp as period_end,
        
        -- Length of stay validation
        case 
            when duree_sejour >= 0 then duree_sejour
            when date_debut_sejour is not null and date_fin_sejour is not null then
                date_fin_sejour - date_debut_sejour
            else null
        end as length_of_stay_days,
        
        -- Administrative details
        trim(mode_entree) as admission_mode,
        trim(mode_sortie) as discharge_mode,
        trim(statut_administratif) as administrative_status,
        
        -- Location information
        trim(etablissement) as facility_name,
        trim(unite_fonctionnelle) as functional_unit,
        trim(service) as clinical_service,
        
        -- Geographic context at encounter time
        trim(code_geographique_residence) as residence_code,
        trim(libelle_geographique_residence) as residence_label,
        
        -- Data collection
        date_recueil as data_collection_date,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where pmsi_id is not null
      and patient_id is not null
),

validated as (
    select *
    from standardized
    where 
        -- Validate period consistency
        (period_start is null or period_end is null or period_start <= period_end)
        -- Validate length of stay
        and (length_of_stay_days is null or length_of_stay_days >= 0)
)

select * from validated