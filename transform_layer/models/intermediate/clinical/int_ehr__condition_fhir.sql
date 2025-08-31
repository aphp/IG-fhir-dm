{{ config(
    materialized='table',
    tags=['intermediate', 'ehr', 'fhir', 'condition', 'clinical']
) }}

-- Intermediate model transforming EHR diagnostics to FHIR Condition structure  
-- Implements the TransformCondition group from the FML mapping

with source_conditions as (
    select * from {{ ref('stg_ehr__condition') }}
),

source_encounters as (
    select encounter_id from {{ ref('stg_ehr__encounter') }}
),

fhir_condition_transform as (
    select
        -- FHIR Resource ID (following FML mapping src.diagnosticId as id -> tgt.id = id)
        {{ generate_fhir_id('condition_id') }} as condition_id,
        
        -- FHIR Patient Reference (derived from encounter)
        concat('Patient/', c.encounter_id) as patient_reference_id,
        {{ create_fhir_reference('concat(\'Patient/\', c.encounter_id)') }} as patient_reference,
        
        -- FHIR Encounter Reference (following FML mapping src.pmsiId -> tgt.encounter)
        {{ create_fhir_reference('concat(\'Encounter/\', c.encounter_id)') }} as encounter_reference,
        
        -- FHIR Identifiers array - diagnostic ID
        jsonb_build_array(
            {{ create_fhir_identifier(
                "'https://hospital.eu/ehr/diagnostic-id'", 
                'condition_id', 
                'official'
            ) }}
        ) as identifiers,
        
        -- FHIR Clinical Status (following FML mapping - assume active for recorded diagnoses)
        {{ create_fhir_codeable_concept(
            "'active'",
            "'http://terminology.hl7.org/CodeSystem/condition-clinical'",
            "'Active'"
        ) }} as clinical_status,
        
        -- FHIR Verification Status (following FML mapping - assume confirmed for coded diagnoses)
        {{ create_fhir_codeable_concept(
            "'confirmed'",
            "'http://terminology.hl7.org/CodeSystem/condition-ver-status'",
            "'Confirmed'"
        ) }} as verification_status,
        
        -- FHIR Categories array (following FML mapping src.typeDiagnostic -> tgt.category)
        jsonb_build_array(
            case 
                when diagnosis_type = 'encounter-diagnosis' then
                    {{ create_fhir_codeable_concept(
                        "'encounter-diagnosis'",
                        "'http://terminology.hl7.org/CodeSystem/condition-category'",
                        "'Encounter Diagnosis'"
                    ) }}
                when diagnosis_type = 'billing-diagnosis' then
                    {{ create_fhir_codeable_concept(
                        "'billing'",
                        "'http://terminology.hl7.org/CodeSystem/condition-category'",
                        "'Billing'"
                    ) }}
                else
                    {{ create_fhir_codeable_concept(
                        "'encounter-diagnosis'",
                        "'http://terminology.hl7.org/CodeSystem/condition-category'",
                        "'Encounter Diagnosis'"
                    ) }}
            end
        ) as categories,
        
        -- FHIR Code with ICD-10 (following FML mapping src.codeDiagnostic -> tgt.code)
        {{ create_fhir_codeable_concept(
            'icd10_code',
            "'http://hl7.org/fhir/sid/icd-10'",
            'condition_text',
            'condition_text'
        ) }} as code,
        
        -- FHIR Recorded Date (following FML mapping src.dateDiagnostic -> tgt.recordedDate)
        {{ to_fhir_date('date_diagnostic') }} as recorded_date,
        
        -- Additional context
        diagnosis_sequence,
        data_collection_date,
        
        -- FHIR Meta with DMCondition profile
        {{ create_fhir_meta('https://aphp.fr/ig/fhir/dm/StructureDefinition/DMCondition') }} as meta,
        
        -- Audit fields
        c.last_updated,
        {{ add_fhir_audit_columns() }}
        
    from source_conditions c
    inner join source_encounters e on c.encounter_id = e.encounter_id
),

final as (
    select
        condition_id,
        patient_reference,
        encounter_reference,
        identifiers,
        clinical_status,
        verification_status,
        categories,
        code,
        recorded_date,
        meta,
        current_timestamp as last_updated,
        created_at,
        fhir_version,
        source_environment
    from fhir_condition_transform
    where condition_id is not null
      and patient_reference is not null
      and code is not null
)

select * from final