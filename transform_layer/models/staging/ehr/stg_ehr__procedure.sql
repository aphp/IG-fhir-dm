{{ config(
    materialized='view',
    tags=['staging', 'ehr', 'procedure']
) }}

-- Staging model for medical procedures and acts
-- Source-conformed with CCAM code validation and performer information

with source as (
    select * from {{ source('ehr', 'actes') }}
),

standardized as (
    select
        -- Primary key
        acte_id as procedure_id,
        pmsi_id as encounter_id,
        
        -- CCAM code standardization
        upper(trim(code_acte)) as ccam_code,
        trim(libelle_acte) as procedure_text,
        
        -- Temporal information
        date_acte as performed_datetime,
        
        -- Performer information
        trim(executant) as performer_name,
        
        -- Sequencing
        case 
            when sequence_acte > 0 then sequence_acte
            else 1
        end as procedure_sequence,
        
        -- Data collection context
        date_recueil as data_collection_date,
        
        -- Audit fields
        coalesce(updated_at, created_at, current_timestamp) as last_updated
        
    from source
    where acte_id is not null
      and pmsi_id is not null
      and code_acte is not null
      and trim(code_acte) != ''
),

validated as (
    select *
    from standardized
    where 
        -- Basic CCAM code format validation
        ccam_code ~ '^[A-Z]{4}[0-9]{3}$|^[A-Z]{3}[0-9]{4}$|^[0-9A-Z]+$'
        -- Ensure reasonable sequence numbers
        and procedure_sequence between 1 and 99
        -- Validate performed datetime is not in future
        and (performed_datetime is null or performed_datetime <= current_timestamp)
)

select * from validated