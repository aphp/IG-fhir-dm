{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'condition'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['subject_patient_id']},
            {'columns': ['encounter_id']},
            {'columns': ['code_text']},
            {'columns': ['recorded_date']}
        ]
    )
}}

with diagnostics as (
    select * from {{ ref('stg_ehr__diagnostics') }}
),

encounter as (
    select pmsi_id, fhir_encounter_id from {{ ref('int_encounter_enriched') }}
),

patient as (
    select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
),

diagnostics_with_references as (
    select 
        d.*,
        p.fhir_patient_id,
        e.fhir_encounter_id
    from diagnostics d
    inner join patient p on d.patient_id = p.patient_id
    left join encounter e on d.pmsi_id = e.pmsi_id
),

fhir_condition as (
    select
        -- FHIR Resource metadata
        fhir_condition_id as id,
        current_timestamp as last_updated,
        
        -- Condition core elements
        json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://terminology.hl7.org/CodeSystem/condition-clinical',
                'code', fhir_clinical_status
            ))
        ) as clinical_status,
        fhir_clinical_status as clinical_status_text,
        
        json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://terminology.hl7.org/CodeSystem/condition-ver-status',
                'code', fhir_verification_status
            ))
        ) as verification_status,
        fhir_verification_status as verification_status_text,
        
        -- Category - PMSI diagnoses are encounter diagnoses
        json_build_array(
            json_build_object(
                'coding', json_build_array(json_build_object(
                    'system', 'http://terminology.hl7.org/CodeSystem/condition-category',
                    'code', 'encounter-diagnosis',
                    'display', 'Encounter Diagnosis'
                ))
            ),
            case when type_diagnostic is not null then
                json_build_object('text', type_diagnostic)
            else null end
        ) as categories,
        'encounter-diagnosis, ' || coalesce(type_diagnostic, '') as categories_text,
        
        null as severity,
        
        -- Code (ICD-10)
        case when code_diagnostic is not null then
            json_build_object(
                'coding', json_build_array(json_build_object(
                    'system', 'http://hl7.org/fhir/sid/icd-10',
                    'code', code_diagnostic,
                    'display', libelle_diagnostic
                )),
                'text', libelle_diagnostic
            )
        else null end as code,
        libelle_diagnostic as code_text,
        
        null as body_sites,
        
        -- Identifiers
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/diagnostic-id',
            'value', diagnostic_id::text
        )) as identifiers,
        
        -- Patient reference
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Encounter reference
        case when fhir_encounter_id is not null then
            json_build_object(
                'reference', 'Encounter/' || fhir_encounter_id,
                'type', 'Encounter'
            )
        else null end as encounter,
        fhir_encounter_id as encounter_id,
        
        -- Onset and abatement (not available in source data)
        null as onset_x,
        null as abatement_x,
        
        -- Recording information
        date_recueil as recorded_date,
        null as recorder,
        null as asserter,
        
        -- Stage and evidence (not available in source data)
        null as stages,
        null as evidences,
        null as notes,
        
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', current_timestamp::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMCondition')
        ) as meta,
        null as implicit_rules,
        'fr-FR' as resource_language,
        null as text_div,
        null as contained,
        null as extensions,
        null as modifier_extensions,
        
        -- Source reference data
        diagnostic_id as original_diagnostic_id,
        patient_id as original_patient_id,
        pmsi_id as original_pmsi_id,
        code_diagnostic as icd10_code,
        data_quality_level,
        
        -- Audit fields
        created_at,
        updated_at
        
    from diagnostics_with_references
)

select * from fhir_condition