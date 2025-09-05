{{
    config(
        materialized='table',
        unique_key='id',
        tags=['mart', 'fhir', 'condition']
    )
}}

-- FHIR Condition resource mart table
-- Compliant with FHIR R4 Condition resource structure
with condition_data as (
    select * from {{ ref('int_condition_mapping') }}
    where is_valid_condition = true
),

fhir_condition as (
    select
        -- FHIR Resource metadata
        fhir_condition_id as id,
        'Condition' as resourceType,
        fhir_meta as meta,
        
        -- Condition identifiers
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'system', 'http://aphp.fr/fhir/NamingSystem/diagnostic-id',
                'value', diagnostic_id::text
            )
        ) as identifier,
        
        -- Clinical status
        fhir_clinical_status as clinicalStatus,
        
        -- Verification status
        fhir_verification_status as verificationStatus,
        
        -- Category
        fhir_category as category,
        
        -- Severity (basic implementation based on diagnosis type)
        case
            when condition_severity = 'severe' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '24484000',
                            'display', 'Severe'
                        )
                    )
                )
            when condition_severity = 'moderate' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '6736007',
                            'display', 'Moderate'
                        )
                    )
                )
            when condition_severity = 'mild' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '255604002',
                            'display', 'Mild'
                        )
                    )
                )
            else null
        end as severity,
        
        -- Condition code (ICD-10)
        fhir_code as code,
        
        -- Body site (could be enhanced based on ICD-10 mapping)
        case
            when icd10_chapter = 'Circulatory system' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '113257007',
                                'display', 'Cardiovascular system structure'
                            )
                        )
                    )
                )
            when icd10_chapter = 'Respiratory system' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '20139000',
                                'display', 'Respiratory system structure'
                            )
                        )
                    )
                )
            when icd10_chapter = 'Digestive system' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '86762007',
                                'display', 'Digestive system structure'
                            )
                        )
                    )
                )
            else null
        end as bodySite,
        
        -- Patient reference
        jsonb_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'display', 'Patient ' || fhir_patient_id
        ) as subject,
        
        -- Subject ID for relationships
        fhir_patient_id as subject_id,
        
        -- Encounter reference
        jsonb_build_object(
            'reference', 'Encounter/' || fhir_encounter_id,
            'display', 'Encounter ' || fhir_encounter_id
        ) as encounter,
        
        -- Encounter ID for relationships  
        fhir_encounter_id as encounter_id,
        
        -- Onset information
        fhir_onset as onsetDateTime,
        
        -- Recorded date
        case 
            when diagnosis_date is not null then
                to_char(diagnosis_date, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
            else
                to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
        end as recordedDate,
        
        -- Recorder (could reference the practitioner who made the diagnosis)
        jsonb_build_object(
            'reference', 'Practitioner/pmsi-recorder',
            'display', 'PMSI Recorder'
        ) as recorder,
        
        -- Asserter (who asserted this condition)
        jsonb_build_object(
            'reference', 'Practitioner/attending-physician',
            'display', 'Attending Physician'
        ) as asserter,
        
        -- Stage (if applicable - could be enhanced for cancer diagnoses)
        case
            when icd10_code ~ '^C' and condition_severity = 'severe' then
                jsonb_build_array(
                    jsonb_build_object(
                        'summary', jsonb_build_object(
                            'coding', jsonb_build_array(
                                jsonb_build_object(
                                    'system', 'http://snomed.info/sct',
                                    'code', '261663004',
                                    'display', 'Severe stage'
                                )
                            )
                        )
                    )
                )
            else null
        end as stage,
        
        -- Evidence (linking to observations or diagnostic reports)
        case
            when condition_category = 'encounter-diagnosis' then
                jsonb_build_array(
                    jsonb_build_object(
                        'code', jsonb_build_array(
                            jsonb_build_object(
                                'coding', jsonb_build_array(
                                    jsonb_build_object(
                                        'system', 'http://snomed.info/sct',
                                        'code', '439401001',
                                        'display', 'Diagnosis'
                                    )
                                )
                            )
                        )
                    )
                )
            else null
        end as evidence,
        
        -- Note (additional clinical notes)
        case
            when diagnosis_label_fr != icd10_code then
                jsonb_build_array(
                    jsonb_build_object(
                        'text', 'Diagnostic: ' || diagnosis_label_fr || ' (Code: ' || icd10_code || ')',
                        'time', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                    )
                )
            else null
        end as note,
        
        -- Audit and source fields
        icd10_code,
        diagnosis_type,
        diagnosis_label_fr,
        icd10_chapter,
        condition_severity,
        extracted_at,
        current_timestamp as last_updated,
        
        -- Source identifiers for traceability
        diagnostic_id as source_diagnostic_id,
        pmsi_id as source_pmsi_id
        
    from condition_data
)

select 
    -- FHIR Resource structure
    id,
    resourceType,
    meta,
    identifier,
    clinicalStatus,
    verificationStatus,
    category,
    severity,
    code,
    bodySite,
    subject,
    subject_id,
    encounter,
    encounter_id,
    onsetDateTime,
    recordedDate,
    recorder,
    asserter,
    stage,
    evidence,
    note,
    
    -- Audit and source fields
    icd10_code,
    diagnosis_type,
    diagnosis_label_fr,
    icd10_chapter,
    condition_severity,
    source_diagnostic_id,
    source_pmsi_id,
    extracted_at,
    last_updated
    
from fhir_condition