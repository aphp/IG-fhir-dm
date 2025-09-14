{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'medication_request'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['subject_patient_id']},
            {'columns': ['status']},
            {'columns': ['authored_on']},
            {'columns': ['medication_text']}
        ]
    )
}}

with enriched_medication_request as (
    select * from {{ ref('int_medication_request_enriched') }}
),

fhir_medication_request as (
    select
        -- FHIR Resource metadata
        fhir_medication_request_id as id,
        current_timestamp as last_updated,
        
        -- MedicationRequest core elements
        fhir_status as status,
        null as status_reason,
        fhir_intent as intent,
        null as categories,
        null as priority,
        false as do_not_perform,
        
        -- Identifiers
        identifiers_json as identifiers,
        
        null as based_on_s,
        null as reported_x,
        null as group_identifier,
        null as course_of_therapy_type,
        null as insurances,
        null as notes,
        
        -- Medication
        medication_json as medication_x,
        denomination as medication_text,
        
        -- Subject
        subject_json as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Encounter (not available in source)
        null as encounter,
        null as encounter_id,
        
        null as supporting_informations,
        
        -- Authored date
        date_prescription as authored_on,
        
        -- Requester
        requester_json as requester,
        prescripteur as requester_practitioner_display,
        
        null as performer,
        null as performer_type,
        null as recorder,
        null as reason_codes,
        null as reason_references,
        null as instantiates_canonical_s,
        null as instantiates_uri_s,
        
        -- Dosage instructions
        dosage_instructions_json as dosage_instructions,
        voie_administration as dosage_instruction_route_text,
        quantite as dosage_instruction_dose_quantity_value,
        unite_quantite as dosage_instruction_dose_quantity_unit,
        date_debut_prescription as dosage_instruction_timing_bounds_period_start,
        date_fin_prescription as dosage_instruction_timing_bounds_period_end,
        
        null as dispense_request,
        null as substitution,
        null as prior_prescription,
        null as detected_issues,
        null as event_history,
        
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', current_timestamp::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMMedicationRequest')
        ) as meta,
        null as implicit_rules,
        'fr-FR' as resource_language,
        null as text_div,
        null as contained,
        null as extensions,
        null as modifier_extensions,
        
        -- Source reference data
        prescription_id as original_prescription_id,
        patient_id as original_patient_id,
        code_atc as atc_code,
        data_quality_level,
        
        -- Audit fields
        transformed_at as created_at,
        current_timestamp as updated_at
        
    from enriched_medication_request
)

select * from fhir_medication_request