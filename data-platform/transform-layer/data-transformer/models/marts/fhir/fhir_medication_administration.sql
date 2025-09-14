{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'medication_administration'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['subject_patient_id']},
            {'columns': ['context_encounter_id']},
            {'columns': ['request_medication_request_id']},
            {'columns': ['effective_date_time']},
            {'columns': ['medication_text']}
        ]
    )
}}

with administration as (
    select * from {{ ref('stg_ehr__administration') }}
),

patient as (
    select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
),

medication_request as (
    select prescription_id, fhir_medication_request_id from {{ ref('int_medication_request_enriched') }}
),

administration_with_references as (
    select 
        a.*,
        p.fhir_patient_id,
        mr.fhir_medication_request_id
    from administration a
    inner join patient p on a.patient_id = p.patient_id
    left join medication_request mr on a.prescription_id = mr.prescription_id
),

fhir_medication_administration as (
    select
        -- FHIR Resource metadata
        fhir_medication_administration_id as id,
        current_timestamp as last_updated,
        
        -- MedicationAdministration core elements
        fhir_status as status,
        null as status_reasons,
        null as category,
        
        -- Identifiers
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/administration-id',
            'value', administration_id::text
        )) as identifiers,
        
        null as instantiates_s,
        null as part_of_s,
        
        -- Medication
        case when denomination is not null then
            json_build_object(
                'text', denomination,
                'coding', case when code_atc is not null then 
                    json_build_array(json_build_object(
                        'system', 'http://www.whocc.no/atc',
                        'code', code_atc
                    ))
                else null end
            )
        else null end as medication_x,
        denomination as medication_text,
        
        -- Subject
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Context (encounter - not available in source)
        null as context,
        null as context_encounter_id,
        
        null as supporting_informations,
        
        -- Effective timing
        case when date_heure_debut is not null or date_heure_fin is not null then
            json_build_object(
                'start', case when date_heure_debut is not null then date_heure_debut::text else null end,
                'end', case when date_heure_fin is not null then date_heure_fin::text else null end
            )
        else null end as effective_x,
        date_heure_debut as effective_date_time,
        
        null as performers,
        null as reason_codes,
        null as reason_references,
        
        -- Request reference (link to MedicationRequest if available)
        case when fhir_medication_request_id is not null then
            json_build_object(
                'reference', 'MedicationRequest/' || fhir_medication_request_id,
                'type', 'MedicationRequest'
            )
        else null end as request,
        fhir_medication_request_id as request_medication_request_id,
        
        null as devices,
        null as notes,
        
        -- Dosage
        case when quantite is not null or voie_administration is not null then
            json_build_object(
                'route', case when voie_administration is not null then json_build_object(
                    'coding', json_build_array(json_build_object(
                        'system', 'https://smt.esante.gouv.fr/terminologie-standardterms',
                        'code', voie_administration
                    ))
                ) else null end,
                'dose', case when quantite is not null then json_build_object(
                    'value', quantite,
                    'unit', case when unite_quantite is not null then unite_quantite else 'unit' end,
                    'system', 'http://unitsofmeasure.org',
                    'code', case when unite_quantite is not null then unite_quantite else 'unit' end
                ) else null end
            )
        else null end as dosage,
        voie_administration as dosage_route_text,
        quantite as dosage_dose_value,
        unite_quantite as dosage_dose_unit,
        
        null as event_history,
        
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', current_timestamp::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMMedicationAdministration')
        ) as meta,
        null as implicit_rules,
        'fr-FR' as resource_language,
        null as text_div,
        null as contained,
        null as extensions,
        null as modifier_extensions,
        
        -- Source reference data
        administration_id as original_administration_id,
        patient_id as original_patient_id,
        prescription_id as original_prescription_id,
        administration_type,
        data_quality_level,
        
        -- Audit fields
        created_at,
        updated_at
        
    from administration_with_references
)

select * from fhir_medication_administration