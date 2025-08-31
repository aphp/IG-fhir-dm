{{
    config(
        materialized='view',
        tags=['staging', 'encounter', 'pmsi']
    )
}}

with source_data as (
    select
        pmsi_id,
        patient_id,
        mode_sortie,
        duree_sejour,
        date_debut_sejour,
        date_fin_sejour,
        mode_entree,
        etablissement,
        service,
        current_timestamp as extracted_at
    from {{ ref('donnees_pmsi_sample') }}
),

cleaned_data as (
    select
        -- Primary keys
        pmsi_id,
        patient_id,
        
        -- Encounter details
        trim(mode_sortie) as discharge_disposition,
        duree_sejour::integer as length_of_stay_days,
        date_debut_sejour::timestamp as admission_datetime,
        coalesce(date_fin_sejour::timestamp, date_debut_sejour::timestamp + interval '1 day' * duree_sejour) as discharge_datetime,
        trim(mode_entree) as admission_type,
        trim(etablissement) as facility_name,
        trim(service) as service_department,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('encounter_id_prefix') }}' || pmsi_id::text as fhir_encounter_id,
        '{{ var('patient_id_prefix') }}' || patient_id::text as fhir_patient_id,
        
        -- Status determination
        case 
            when date_fin_sejour is not null then 'finished'
            when date_debut_sejour <= current_date then 'in-progress'
            else 'planned'
        end as encounter_status,
        
        -- Class mapping for FHIR encounter class
        case
            when trim(lower(mode_entree)) like '%urgence%' then 'EMER'  -- Emergency
            when trim(lower(service)) like '%ambulatoire%' then 'AMB'   -- Ambulatory
            else 'IMP'  -- Inpatient
        end as encounter_class,
        
        -- Data quality flags
        case when date_debut_sejour is not null then true else false end as has_admission_date,
        case when duree_sejour > 0 then true else false end as has_valid_length_of_stay
        
    from source_data
    where patient_id is not null  -- Only include encounters with valid patient reference
)

select * from cleaned_data