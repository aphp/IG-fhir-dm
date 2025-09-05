{{
    config(
        materialized='view',
        tags=['staging', 'observation', 'vital-signs']
    )
}}

with source_data as (
    select
        soins_id,
        pmsi_id,
        patient_id,
        taille,
        poids,
        date_mesure_taille,
        date_mesure_poids,
        current_timestamp as extracted_at
    from {{ ref('dossier_soins_sample') }}
),

-- Unpivot the data to convert from wide to long format
unpivoted_data as (
    select
        soins_id,
        pmsi_id,
        patient_id,
        extracted_at,
        'taille' as type_mesure,
        taille::text as valeur,
        'cm' as unite,
        date_mesure_taille as date_mesure
    from source_data
    where taille is not null
    
    union all
    
    select
        soins_id,
        pmsi_id,
        patient_id,
        extracted_at,
        'poids' as type_mesure,
        poids::text as valeur,
        'kg' as unite,
        date_mesure_poids as date_mesure
    from source_data
    where poids is not null
),

cleaned_data as (
    select
        -- Primary keys
        soins_id,
        pmsi_id,
        patient_id,
        
        -- Vital signs information
        trim(lower(type_mesure)) as measurement_type,
        trim(valeur) as measurement_value,
        trim(unite) as measurement_unit,
        date_mesure::timestamp as measurement_datetime,
        
        -- System fields
        extracted_at,
        
        -- Calculated fields for FHIR
        '{{ var('observation_id_prefix') }}' || 'vs-' || soins_id::text || '-' || type_mesure as fhir_observation_id,
        '{{ var('encounter_id_prefix') }}' || pmsi_id::text as fhir_encounter_id,
        '{{ var('patient_id_prefix') }}' || patient_id::text as fhir_patient_id,
        
        -- FHIR observation status (assuming final if recorded)
        'final' as observation_status,
        
        -- FHIR observation category for vital signs
        'vital-signs' as observation_category,
        
        -- LOINC code mapping for vital signs
        case
            when trim(lower(type_mesure)) in ('tension arterielle systolique', 'systolic blood pressure', 'pas') then '8480-6'
            when trim(lower(type_mesure)) in ('tension arterielle diastolique', 'diastolic blood pressure', 'pad') then '8462-4'
            when trim(lower(type_mesure)) in ('frequence cardiaque', 'heart rate', 'fc', 'pouls') then '8867-4'
            when trim(lower(type_mesure)) in ('temperature', 'température corporelle', 'temp') then '8310-5'
            when trim(lower(type_mesure)) in ('frequence respiratoire', 'respiratory rate', 'fr') then '9279-1'
            when trim(lower(type_mesure)) in ('saturation oxygene', 'spo2', 'sat o2') then '2708-6'
            when trim(lower(type_mesure)) in ('poids', 'weight', 'masse corporelle') then '29463-7'
            when trim(lower(type_mesure)) in ('taille', 'height', 'size') then '8302-2'
            when trim(lower(type_mesure)) in ('imc', 'bmi', 'body mass index') then '39156-5'
            when trim(lower(type_mesure)) in ('glycemie', 'glucose', 'blood glucose') then '2339-0'
            else null
        end as loinc_code,
        
        -- Display name in French
        case
            when trim(lower(type_mesure)) in ('tension arterielle systolique', 'systolic blood pressure', 'pas') then 'Pression artérielle systolique'
            when trim(lower(type_mesure)) in ('tension arterielle diastolique', 'diastolic blood pressure', 'pad') then 'Pression artérielle diastolique'
            when trim(lower(type_mesure)) in ('frequence cardiaque', 'heart rate', 'fc', 'pouls') then 'Fréquence cardiaque'
            when trim(lower(type_mesure)) in ('temperature', 'température corporelle', 'temp') then 'Température corporelle'
            when trim(lower(type_mesure)) in ('frequence respiratoire', 'respiratory rate', 'fr') then 'Fréquence respiratoire'
            when trim(lower(type_mesure)) in ('saturation oxygene', 'spo2', 'sat o2') then 'Saturation en oxygène'
            when trim(lower(type_mesure)) in ('poids', 'weight', 'masse corporelle') then 'Poids corporel'
            when trim(lower(type_mesure)) in ('taille', 'height', 'size') then 'Taille'
            when trim(lower(type_mesure)) in ('imc', 'bmi', 'body mass index') then 'Indice de masse corporelle'
            when trim(lower(type_mesure)) in ('glycemie', 'glucose', 'blood glucose') then 'Glycémie'
            else trim(type_mesure)
        end as measurement_display_fr,
        
        -- Standardized unit mapping
        case
            when trim(lower(unite)) in ('mmhg', 'mm hg') then 'mm[Hg]'
            when trim(lower(unite)) in ('bpm', '/min', 'min-1') then '/min'
            when trim(lower(unite)) in ('°c', 'celsius', 'degc') then 'Cel'
            when trim(lower(unite)) in ('%', 'percent') then '%'
            when trim(lower(unite)) in ('kg', 'kilogram') then 'kg'
            when trim(lower(unite)) in ('cm', 'centimeter') then 'cm'
            when trim(lower(unite)) in ('kg/m2', 'kg/m²') then 'kg/m2'
            when trim(lower(unite)) in ('mg/dl', 'mg/dl') then 'mg/dL'
            when trim(lower(unite)) in ('mmol/l', 'mmol/l') then 'mmol/L'
            else trim(unite)
        end as standardized_unit,
        
        -- Numeric value extraction
        case 
            when valeur ~ '^[0-9]+\.?[0-9]*$' then valeur::decimal
            else null
        end as numeric_value,
        
        -- Data quality flags
        case when type_mesure is not null and length(trim(type_mesure)) > 0 then true else false end as has_measurement_type,
        case when valeur is not null and length(trim(valeur)) > 0 then true else false end as has_measurement_value,
        case when date_mesure is not null then true else false end as has_measurement_datetime
        
    from unpivoted_data
    where patient_id is not null  -- Only include vital signs with valid patient reference
)

select * from cleaned_data