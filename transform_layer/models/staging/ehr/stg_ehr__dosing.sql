{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'dosing']
) }}

-- Staging model for medication dosing information
-- Source-conformed with dose calculations and administration timing

with posologie_source as (
    select * from {{ source('ehr', 'posologie') }}
),

dosage_source as (
    select * from {{ source('ehr', 'dosage') }}
),

posologie_standardized as (
    select
        -- Primary key - use posologie_id with prefix
        'pos_' || posologie_id::text as dosing_id,
        exposition_id as medication_exposure_id,
        patient_id,
        
        -- Dosing schedule from posologie
        date_debut_prescription as dosing_start_date,
        date_fin_prescription as dosing_end_date,
        
        case 
            when nombre_prises_par_jour > 0 and nombre_prises_par_jour <= 24
            then nombre_prises_par_jour
            else null
        end as doses_per_day,
        
        -- No quantity info in posologie
        null::decimal(10,3) as administered_quantity,
        null::varchar as quantity_unit,
        null::timestamp as administration_start_datetime,
        null::timestamp as administration_end_datetime,
        
        -- Source indicator
        'posologie' as source_type,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from posologie_source
    where posologie_id is not null
      and exposition_id is not null
      and patient_id is not null
),

dosage_standardized as (
    select
        -- Primary key - use dosage_id with prefix
        'dos_' || dosage_id::text as dosing_id,
        exposition_id as medication_exposure_id,
        patient_id,
        
        -- No schedule info in dosage
        null::date as dosing_start_date,
        null::date as dosing_end_date,
        null::integer as doses_per_day,
        
        -- Quantity information from dosage
        case 
            when quantite_administree > 0
            then quantite_administree::decimal(10,3)
            else null
        end as administered_quantity,
        
        trim(unite_quantite) as quantity_unit,
        
        -- Administration timing
        date_heure_debut as administration_start_datetime,
        date_heure_fin as administration_end_datetime,
        
        -- Source indicator
        'dosage' as source_type,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from dosage_source
    where dosage_id is not null
      and exposition_id is not null
      and patient_id is not null
),

combined as (
    select * from posologie_standardized
    union all
    select * from dosage_standardized
),

validated as (
    select
        dosing_id,
        medication_exposure_id,
        patient_id,
        dosing_start_date,
        dosing_end_date,
        doses_per_day,
        administered_quantity,
        quantity_unit,
        administration_start_datetime,
        administration_end_datetime,
        source_type,
        last_updated
    from combined
    where 
        -- Validate date consistency
        (dosing_start_date is null or dosing_end_date is null 
         or dosing_start_date <= dosing_end_date)
        -- Validate administration timing
        and (administration_start_datetime is null or administration_end_datetime is null 
             or administration_start_datetime <= administration_end_datetime)
        -- Validate doses per day range
        and (doses_per_day is null or doses_per_day between 1 and 24)
        -- Validate administered quantity
        and (administered_quantity is null or administered_quantity > 0)
        -- Validate dates are not in future
        and (dosing_start_date is null or dosing_start_date <= current_date)
        and (administration_start_datetime is null or administration_start_datetime <= current_timestamp)
)

select * from validated