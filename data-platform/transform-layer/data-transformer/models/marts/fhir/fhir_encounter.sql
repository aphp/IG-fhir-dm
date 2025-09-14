{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'encounter'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['subject_patient_id']},
            {'columns': ['period_start', 'period_end']},
            {'columns': ['status']}
        ]
    )
}}

with enriched_encounter as (
    select * from {{ ref('int_encounter_enriched') }}
),

fhir_encounter as (
    select
        -- FHIR Resource metadata
        fhir_encounter_id as id,
        current_timestamp as last_updated,
        
        -- Encounter core elements
        fhir_status as status,
        null as status_history,
        class_json as class,
        fhir_class_display as class_display,
        null as class_history,
        null as types,
        null as service_type,
        null as priority,
        
        -- Identifiers
        identifiers_json as identifiers,
        
        -- Patient reference
        subject_json as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Episode of care (not available in source data)
        null as episodes_of_care,
        null as based_on_s,
        
        -- Participants (not available in source data)
        null as participants,
        null as appointments,
        
        -- Period and duration
        period_start,
        period_end,
        period_json as period,
        length_json as length,
        length_of_stay_days as length_number_of_day,
        
        -- Reason (not available in source data)
        null as reason_codes,
        null as reason_references,
        
        -- Diagnoses (will be linked through conditions)
        null as diagnoses,
        null as account,
        
        -- Hospitalization
        hospitalization_json as hospitalization,
        mode_entree as admit_source_text,
        mode_sortie as discharge_disposition_text,
        
        -- Locations (not available in source data)
        null as locations,
        
        -- Service provider
        service_provider_json as service_provider,
        coalesce(unite_fonctionnelle, service, etablissement) as service_provider_organization_display,
        
        -- Part of (not available in source data)
        null as part_of,
        
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', current_timestamp::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMEncounter')
        ) as meta,
        null as implicit_rules,
        'fr-FR' as resource_language,
        null as text_div,
        null as contained,
        null as extensions,
        null as modifier_extensions,
        
        -- Source reference data
        pmsi_id as original_encounter_id,
        patient_id as original_patient_id,
        data_quality_level,
        
        -- Audit fields
        transformed_at as created_at,
        current_timestamp as updated_at
        
    from enriched_encounter
)

select * from fhir_encounter