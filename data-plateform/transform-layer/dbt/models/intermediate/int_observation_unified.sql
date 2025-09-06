{{
    config(
        materialized='table',
        tags=['intermediate', 'observation', 'unified', 'loinc']
    )
}}

-- Intermediate model to unify all observation types (lab, vital signs, lifestyle)
-- into a consistent FHIR observation structure
with lab_observations as (
    select
        fhir_observation_id,
        fhir_patient_id,
        fhir_encounter_id,
        observation_status,
        observation_category,
        loinc_code,
        test_name_fr as display_name_fr,
        collection_date as effective_date,
        null::timestamp as effective_datetime,
        value_type,
        numeric_value,
        test_value as string_value,
        null::boolean as boolean_value,
        test_unit as value_unit,
        value_comparator,
        'laboratory' as observation_source,
        laboratory_name as performer_name,
        extracted_at
    from {{ ref('stg_ehr__biologie') }}
    where has_loinc_code = true
),

vital_observations as (
    select
        fhir_observation_id,
        fhir_patient_id,
        fhir_encounter_id,
        observation_status,
        observation_category,
        loinc_code,
        measurement_display_fr as display_name_fr,
        measurement_datetime::date as effective_date,
        measurement_datetime as effective_datetime,
        case when numeric_value is not null then 'Quantity' else 'string' end as value_type,
        numeric_value,
        measurement_value as string_value,
        null::boolean as boolean_value,
        standardized_unit as value_unit,
        null as value_comparator,
        'vital-signs' as observation_source,
        'Service de soins' as performer_name,
        extracted_at
    from {{ ref('stg_ehr__dossier_soins') }}
    where loinc_code is not null
),

lifestyle_observations as (
    select
        fhir_observation_id,
        fhir_patient_id,
        null as fhir_encounter_id,  -- Lifestyle factors not tied to specific encounter
        observation_status,
        observation_category,
        loinc_code,
        lifestyle_display_fr as display_name_fr,
        assessment_date as effective_date,
        null::timestamp as effective_datetime,
        value_type,
        numeric_value,
        case when value_type = 'string' then lifestyle_value else null end as string_value,
        boolean_value,
        null as value_unit,
        null as value_comparator,
        'social-history' as observation_source,
        'Équipe médicale' as performer_name,
        extracted_at
    from {{ ref('stg_ehr__style_vie') }}
    where loinc_code is not null
),

all_observations as (
    select * from lab_observations
    union all
    select * from vital_observations
    union all
    select * from lifestyle_observations
),

observation_processing as (
    select
        fhir_observation_id,
        fhir_patient_id,
        fhir_encounter_id,
        observation_status,
        observation_category,
        loinc_code,
        display_name_fr,
        effective_date,
        effective_datetime,
        value_type,
        numeric_value,
        string_value,
        boolean_value,
        value_unit,
        value_comparator,
        observation_source,
        performer_name,
        extracted_at,
        
        -- FHIR code structure
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://loinc.org',
                    'code', loinc_code,
                    'display', display_name_fr
                )
            ),
            'text', display_name_fr
        ) as fhir_code,
        
        -- FHIR category structure
        jsonb_build_array(
            jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'http://terminology.hl7.org/CodeSystem/observation-category',
                        'code', observation_category,
                        'display', case observation_category
                            when 'laboratory' then 'Laboratory'
                            when 'vital-signs' then 'Vital Signs'
                            when 'social-history' then 'Social History'
                            else 'Unknown'
                        end
                    )
                )
            )
        ) as fhir_category,
        
        -- FHIR value structure based on type
        case 
            when value_type = 'Quantity' and numeric_value is not null then
                jsonb_build_object(
                    'valueQuantity', jsonb_build_object(
                        'value', numeric_value,
                        'unit', coalesce(value_unit, '1'),
                        'system', 'http://unitsofmeasure.org',
                        'code', coalesce(value_unit, '1')
                    ) || case 
                        when value_comparator is not null 
                        then jsonb_build_object('comparator', value_comparator)
                        else '{}'::jsonb
                    end
                )
            when value_type = 'boolean' and boolean_value is not null then
                jsonb_build_object(
                    'valueBoolean', boolean_value
                )
            when string_value is not null then
                jsonb_build_object(
                    'valueString', string_value
                )
            else null
        end as fhir_value,
        
        -- FHIR effective period/datetime
        case
            when effective_datetime is not null then
                jsonb_build_object(
                    'effectiveDateTime', to_char(effective_datetime, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                )
            when effective_date is not null then
                jsonb_build_object(
                    'effectiveDateTime', to_char(effective_date, 'YYYY-MM-DD')
                )
            else null
        end as fhir_effective,
        
        -- Reference ranges for numeric values (basic implementation)
        case
            when observation_category = 'vital-signs' and loinc_code = '8480-6' then  -- Systolic BP
                jsonb_build_array(
                    jsonb_build_object(
                        'low', jsonb_build_object('value', 90, 'unit', 'mm[Hg]'),
                        'high', jsonb_build_object('value', 140, 'unit', 'mm[Hg]'),
                        'text', 'Normale: 90-140 mmHg'
                    )
                )
            when observation_category = 'vital-signs' and loinc_code = '8462-4' then  -- Diastolic BP
                jsonb_build_array(
                    jsonb_build_object(
                        'low', jsonb_build_object('value', 60, 'unit', 'mm[Hg]'),
                        'high', jsonb_build_object('value', 90, 'unit', 'mm[Hg]'),
                        'text', 'Normale: 60-90 mmHg'
                    )
                )
            when observation_category = 'vital-signs' and loinc_code = '8867-4' then  -- Heart rate
                jsonb_build_array(
                    jsonb_build_object(
                        'low', jsonb_build_object('value', 60, 'unit', '/min'),
                        'high', jsonb_build_object('value', 100, 'unit', '/min'),
                        'text', 'Normale: 60-100 /min'
                    )
                )
            else null
        end as fhir_reference_range,
        
        -- FHIR meta information
        jsonb_build_object(
            'versionId', '1',
            'lastUpdated', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'source', observation_source,
            'profile', array['http://interopsante.org/fhir/StructureDefinition/FrObservation']
        ) as fhir_meta,
        
        -- Data quality flags
        case when loinc_code is not null then true else false end as has_valid_coding,
        case when (numeric_value is not null or string_value is not null or boolean_value is not null) then true else false end as has_valid_value,
        case when effective_date is not null or effective_datetime is not null then true else false end as has_effective_time
        
    from all_observations
)

select 
    *,
    -- Final validation
    case when has_valid_coding and has_valid_value and has_effective_time then true else false end as is_valid_observation
from observation_processing