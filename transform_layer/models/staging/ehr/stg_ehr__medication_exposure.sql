{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'medication']
) }}

-- Staging model for medication exposures and prescriptions
-- Source-conformed with ATC code validation and administration details

with source as (
    select * from {{ source('ehr', 'exposition_medicamenteuse') }}
),

standardized as (
    select
        -- Primary key
        exposition_id as medication_exposure_id,
        pmsi_id as encounter_id,
        patient_id,
        
        -- Medication identification
        upper(trim(code_atc)) as atc_code,
        trim(denomination) as medication_name,
        trim(forme_pharmaceutique) as pharmaceutical_form,
        trim(voie_administration) as administration_route,
        
        -- Prescription details
        case 
            when lower(trim(type_prescription)) in ('prescrit', 'prescribed') 
                then 'order'
            when lower(trim(type_prescription)) in ('administre', 'administered', 'administré')
                then 'instance-order'
            else coalesce(trim(type_prescription), 'order')
        end as prescription_type,
        
        trim(prescripteur) as prescriber_name,
        
        -- Temporal information
        date_debut as start_date,
        date_fin as end_date,
        date_prescription as prescription_date,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where exposition_id is not null
      and pmsi_id is not null
      and patient_id is not null
),

validated as (
    select *
    from standardized
    where 
        -- Ensure we have medication identification (ATC code or name)
        (atc_code is not null or medication_name is not null)
        -- Validate date consistency
        and (start_date is null or end_date is null or start_date <= end_date)
        -- Validate prescription date is not in future
        and (prescription_date is null or prescription_date <= current_date)
        -- Basic ATC code format validation (if provided)
        and (atc_code is null or atc_code ~ '^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$|^[A-Z][0-9]{2}[A-Z]{1,2}[0-9]{0,2}$')
)

select * from validated