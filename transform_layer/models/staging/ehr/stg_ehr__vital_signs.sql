{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'vital-signs']
) }}

-- Staging model for vital signs and physical measurements
-- Source-conformed with measurement validation and units standardization

with source as (
    select * from {{ source('ehr', 'dossier_soins') }}
),

standardized as (
    select
        -- Primary key
        soins_id as vital_signs_id,
        pmsi_id as encounter_id,
        patient_id,
        
        -- Height measurements with validation
        case 
            when taille is not null 
                and taille between 10 and 300  -- reasonable height range in cm
            then taille::decimal(5,2)
            else null
        end as height_cm,
        date_mesure_taille as height_measurement_date,
        
        -- Weight measurements with validation
        case 
            when poids is not null 
                and poids between 0.5 and 1000  -- reasonable weight range in kg
            then poids::decimal(6,2)
            else null
        end as weight_kg,
        date_mesure_poids as weight_measurement_date,
        
        -- Blood pressure measurements with validation
        case 
            when pression_systolique is not null 
                and pression_systolique between 50 and 300  -- reasonable systolic BP range
            then pression_systolique::decimal(5,2)
            else null
        end as systolic_bp_mmhg,
        date_mesure_ps as systolic_bp_measurement_date,
        
        case 
            when pression_diastolique is not null 
                and pression_diastolique between 20 and 200  -- reasonable diastolic BP range
            then pression_diastolique::decimal(5,2)
            else null
        end as diastolic_bp_mmhg,
        date_mesure_pd as diastolic_bp_measurement_date,
        
        -- Measurement context
        trim(type_mesure) as measurement_type,
        trim(unite_soins) as care_unit,
        trim(professionnel) as healthcare_professional,
        
        -- Comments
        trim(commentaire) as measurement_comment,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where soins_id is not null
      and pmsi_id is not null
      and patient_id is not null
),

validated as (
    select *
    from standardized
    where 
        -- Ensure we have at least one measurement
        (height_cm is not null or weight_kg is not null 
         or systolic_bp_mmhg is not null or diastolic_bp_mmhg is not null)
        -- Validate blood pressure consistency
        and (systolic_bp_mmhg is null or diastolic_bp_mmhg is null 
             or systolic_bp_mmhg > diastolic_bp_mmhg)
        -- Validate measurement dates are not in future
        and (height_measurement_date is null or height_measurement_date <= current_date)
        and (weight_measurement_date is null or weight_measurement_date <= current_date)
        and (systolic_bp_measurement_date is null or systolic_bp_measurement_date <= current_date)
        and (diastolic_bp_measurement_date is null or diastolic_bp_measurement_date <= current_date)
)

select * from validated