{{
    config(
        materialized='view',
        tags=['staging', 'medication', 'atc']
    )
}}

with source_data as (
    select
        exposition_id,
        pmsi_id,
        patient_id,
        code_atc,
        denomination,
        voie_administration,
        date_prescription,
        current_timestamp as extracted_at
    from {{ ref('exposition_medicamenteuse_sample') }}
),

cleaned_data as (
    select
        -- Primary keys
        exposition_id,
        pmsi_id,
        patient_id,
        
        -- Medication information
        trim(upper(code_atc)) as atc_code,
        trim(denomination) as medication_name,
        trim(voie_administration) as route_of_administration,
        date_prescription::date as prescription_date,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('medication_request_id_prefix') }}' || exposition_id::text as fhir_medication_request_id,
        '{{ var('encounter_id_prefix') }}' || pmsi_id::text as fhir_encounter_id,
        '{{ var('patient_id_prefix') }}' || patient_id::text as fhir_patient_id,
        
        -- FHIR medication request status (assuming active if recorded)
        'active' as medication_request_status,
        
        -- FHIR medication request intent
        'order' as medication_request_intent,
        
        -- Route of administration mapping to SNOMED CT codes
        case
            when lower(trim(voie_administration)) in ('orale', 'oral', 'per os', 'po') then '26643006'  -- Oral
            when lower(trim(voie_administration)) in ('intraveineuse', 'iv', 'intravenous') then '47625008'  -- Intravenous
            when lower(trim(voie_administration)) in ('intramusculaire', 'im', 'intramuscular') then '78421000'  -- Intramuscular
            when lower(trim(voie_administration)) in ('inhalation', 'inhaled') then '26643006'  -- Inhalation
            when lower(trim(voie_administration)) in ('topique', 'topical') then '359540000'  -- Topical
            when lower(trim(voie_administration)) in ('rectale', 'rectal') then '12130007'  -- Rectal
            else '26643006'  -- Default to oral
        end as route_snomed_code,
        
        -- Route display name in French
        case
            when lower(trim(voie_administration)) in ('orale', 'oral', 'per os', 'po') then 'Voie orale'
            when lower(trim(voie_administration)) in ('intraveineuse', 'iv', 'intravenous') then 'Voie intraveineuse'
            when lower(trim(voie_administration)) in ('intramusculaire', 'im', 'intramuscular') then 'Voie intramusculaire'
            when lower(trim(voie_administration)) in ('inhalation', 'inhaled') then 'Inhalation'
            when lower(trim(voie_administration)) in ('topique', 'topical') then 'Application topique'
            when lower(trim(voie_administration)) in ('rectale', 'rectal') then 'Voie rectale'
            else trim(voie_administration)
        end as route_display_fr,
        
        -- ATC therapeutic category (first character)
        case
            when substring(trim(upper(code_atc)), 1, 1) = 'A' then 'Digestif et métabolisme'
            when substring(trim(upper(code_atc)), 1, 1) = 'B' then 'Sang et organes hématopoïétiques'
            when substring(trim(upper(code_atc)), 1, 1) = 'C' then 'Système cardiovasculaire'
            when substring(trim(upper(code_atc)), 1, 1) = 'D' then 'Dermatologie'
            when substring(trim(upper(code_atc)), 1, 1) = 'G' then 'Système génito-urinaire et hormones sexuelles'
            when substring(trim(upper(code_atc)), 1, 1) = 'H' then 'Hormones systémiques'
            when substring(trim(upper(code_atc)), 1, 1) = 'J' then 'Anti-infectieux généraux à usage systémique'
            when substring(trim(upper(code_atc)), 1, 1) = 'L' then 'Antinéoplasiques et immunomodulateurs'
            when substring(trim(upper(code_atc)), 1, 1) = 'M' then 'Système musculo-squelettique'
            when substring(trim(upper(code_atc)), 1, 1) = 'N' then 'Système nerveux'
            when substring(trim(upper(code_atc)), 1, 1) = 'P' then 'Antiparasitaires, insecticides et répulsifs'
            when substring(trim(upper(code_atc)), 1, 1) = 'R' then 'Système respiratoire'
            when substring(trim(upper(code_atc)), 1, 1) = 'S' then 'Organes sensoriels'
            when substring(trim(upper(code_atc)), 1, 1) = 'V' then 'Divers'
            else 'Inconnu'
        end as atc_therapeutic_category_fr,
        
        -- Data quality flags
        case when code_atc is not null and length(trim(code_atc)) >= 7 then true else false end as has_valid_atc_code,
        case when denomination is not null and length(trim(denomination)) > 0 then true else false end as has_medication_name,
        case when date_prescription is not null then true else false end as has_prescription_date
        
    from source_data
    where patient_id is not null  -- Only include medications with valid patient reference
)

select * from cleaned_data