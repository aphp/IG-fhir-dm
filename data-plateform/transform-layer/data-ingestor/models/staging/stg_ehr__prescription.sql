{{
    config(
        materialized='view',
        tags=['staging', 'medication_request']
    )
}}

with source_prescription as (
    select * from {{ source('ehr', 'prescription') }}
),

cleaned_prescription as (
    select
        prescription_id,
        patient_id,
        
        -- Prescriber information
        trim(prescripteur) as prescripteur,
        
        -- Medication information
        trim(denomination) as denomination,
        trim(code_atc) as code_atc,
        voie_administration,
        
        -- Prescription dates
        date_prescription,
        date_debut_prescription,
        date_fin_prescription,
        
        -- Audit fields
        created_at,
        updated_at,
        
        -- Data quality assessment
        case 
            when denomination is not null and date_prescription is not null and prescripteur is not null then 'high'
            when denomination is not null and (date_prescription is not null or prescripteur is not null) then 'medium'
            else 'low'
        end as data_quality_level,
        
        -- FHIR MedicationRequest status mapping
        case 
            when date_fin_prescription is not null and date_fin_prescription < current_date then 'completed'
            when date_debut_prescription is not null and date_debut_prescription <= current_date 
                 and (date_fin_prescription is null or date_fin_prescription >= current_date) then 'active'
            when date_debut_prescription is not null and date_debut_prescription > current_date then 'draft'
            else 'unknown'
        end as fhir_status,
        
        -- Intent - assume order for prescriptions
        'order' as fhir_intent,
        
        -- ATC system
        case when code_atc is not null then 'http://www.whocc.no/atc' else null end as atc_system,
        
        -- Route system (French terminology)
        case when voie_administration is not null then 'https://smt.esante.gouv.fr/terminologie-standardterms' else null end as route_system,
        
        -- Generate FHIR-compatible medication request ID
        {{ dbt_utils.generate_surrogate_key(['prescription_id']) }} as fhir_medication_request_id
        
    from source_prescription
    where patient_id is not null
)

select * from cleaned_prescription