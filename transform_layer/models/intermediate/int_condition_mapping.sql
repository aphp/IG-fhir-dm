{{
    config(
        materialized='table',
        tags=['intermediate', 'condition', 'icd10', 'terminology']
    )
}}

-- Intermediate model to map diagnostic codes to FHIR conditions
-- with ICD-10 terminology and French healthcare context
with condition_base as (
    select * from {{ ref('stg_ehr__diagnostics') }}
),

encounter_ref as (
    select 
        pmsi_id,
        fhir_encounter_id,
        fhir_patient_id,
        is_valid_encounter
    from {{ ref('int_encounter_episodes') }}
),

condition_processing as (
    select
        c.diagnostic_id,
        c.pmsi_id,
        c.fhir_condition_id,
        e.fhir_encounter_id,
        e.fhir_patient_id,
        c.icd10_code,
        c.diagnosis_type,
        c.diagnosis_label_fr,
        c.diagnosis_date,
        c.condition_category,
        c.verification_status,
        c.clinical_status,
        c.extracted_at,
        e.is_valid_encounter,
        
        -- ICD-10 coding for FHIR
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://hl7.org/fhir/sid/icd-10',
                    'code', c.icd10_code,
                    'display', c.diagnosis_label_fr
                )
            ),
            'text', c.diagnosis_label_fr
        ) as fhir_code,
        
        -- Category coding for FHIR
        jsonb_build_array(
            jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'http://terminology.hl7.org/CodeSystem/condition-category',
                        'code', c.condition_category,
                        'display', case c.condition_category
                            when 'encounter-diagnosis' then 'Encounter Diagnosis'
                            when 'problem-list-item' then 'Problem List Item'
                            else 'Unknown'
                        end
                    )
                )
            )
        ) as fhir_category,
        
        -- Verification status for FHIR
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://terminology.hl7.org/CodeSystem/condition-ver-status',
                    'code', c.verification_status,
                    'display', case c.verification_status
                        when 'confirmed' then 'Confirmed'
                        when 'provisional' then 'Provisional'
                        else 'Unknown'
                    end
                )
            )
        ) as fhir_verification_status,
        
        -- Clinical status for FHIR
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://terminology.hl7.org/CodeSystem/condition-clinical',
                    'code', c.clinical_status,
                    'display', case c.clinical_status
                        when 'active' then 'Active'
                        when 'inactive' then 'Inactive'
                        when 'resolved' then 'Resolved'
                        else 'Unknown'
                    end
                )
            )
        ) as fhir_clinical_status,
        
        -- Onset information
        case
            when c.diagnosis_date is not null then
                jsonb_build_object(
                    'onsetDateTime', to_char(c.diagnosis_date, 'YYYY-MM-DD')
                )
            else null
        end as fhir_onset,
        
        -- Body system classification based on ICD-10 chapter
        case
            when c.icd10_code ~ '^A|^B' then 'Infectious and parasitic diseases'
            when c.icd10_code ~ '^C|^D[0-4]' then 'Neoplasms'
            when c.icd10_code ~ '^D[5-8]' then 'Blood and immune system'
            when c.icd10_code ~ '^E' then 'Endocrine, nutritional and metabolic diseases'
            when c.icd10_code ~ '^F' then 'Mental and behavioural disorders'
            when c.icd10_code ~ '^G' then 'Nervous system'
            when c.icd10_code ~ '^H[0-5]' then 'Eye and adnexa'
            when c.icd10_code ~ '^H[6-9]' then 'Ear and mastoid process'
            when c.icd10_code ~ '^I' then 'Circulatory system'
            when c.icd10_code ~ '^J' then 'Respiratory system'
            when c.icd10_code ~ '^K' then 'Digestive system'
            when c.icd10_code ~ '^L' then 'Skin and subcutaneous tissue'
            when c.icd10_code ~ '^M' then 'Musculoskeletal system'
            when c.icd10_code ~ '^N' then 'Genitourinary system'
            when c.icd10_code ~ '^O' then 'Pregnancy, childbirth and puerperium'
            when c.icd10_code ~ '^P' then 'Perinatal period'
            when c.icd10_code ~ '^Q' then 'Congenital malformations'
            when c.icd10_code ~ '^R' then 'Symptoms, signs and abnormal findings'
            when c.icd10_code ~ '^S|^T' then 'Injury, poisoning and external causes'
            when c.icd10_code ~ '^V|^W|^X|^Y' then 'External causes of morbidity'
            when c.icd10_code ~ '^Z' then 'Health status and contact with health services'
            else 'Unknown'
        end as icd10_chapter,
        
        -- Severity assessment based on diagnosis type
        case
            when lower(c.diagnosis_type) like '%principal%' then 'severe'
            when lower(c.diagnosis_type) like '%secondaire%' then 'moderate'
            else 'mild'
        end as condition_severity,
        
        -- FHIR meta information
        jsonb_build_object(
            'versionId', '1',
            'lastUpdated', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'source', 'pmsi-system',
            'profile', array['http://interopsante.org/fhir/StructureDefinition/FrCondition']
        ) as fhir_meta,
        
        -- Data quality flags
        case when c.has_valid_icd10_code then true else false end as has_valid_coding,
        case when c.has_diagnosis_date then true else false end as has_onset_info
        
    from condition_base c
    left join encounter_ref e on c.pmsi_id = e.pmsi_id
    where e.is_valid_encounter = true  -- Only include conditions for valid encounters
)

select 
    *,
    -- Final validation
    case when has_valid_coding and is_valid_encounter then true else false end as is_valid_condition
from condition_processing