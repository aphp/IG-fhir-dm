{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'procedure'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['subject_patient_id']},
            {'columns': ['encounter_id']},
            {'columns': ['status']},
            {'columns': ['performed_date_time']},
            {'columns': ['code_text']}
        ]
    )
}}

with actes as (
    select * from {{ ref('stg_ehr__actes') }}
),

encounter as (
    select pmsi_id, fhir_encounter_id from {{ ref('int_encounter_enriched') }}
),

patient as (
    select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
),

actes_with_references as (
    select 
        a.*,
        p.fhir_patient_id,
        e.fhir_encounter_id
    from actes a
    inner join patient p on a.patient_id = p.patient_id
    left join encounter e on a.pmsi_id = e.pmsi_id
),

fhir_procedure as (
    select
        -- FHIR Resource metadata
        fhir_procedure_id as id,
        current_timestamp as last_updated,
        
        null as instantiates_canonical_s,
        null as instantiates_uri_s,
        
        -- Procedure core elements
        fhir_status as status,
        null as status_reason,
        null as category,
        
        -- Code (CCAM)
        case when code_acte is not null then
            json_build_object(
                'coding', json_build_array(json_build_object(
                    'system', 'https://interop.aphp.fr/ig/fhir/dm/CodeSystem/Ccam',
                    'code', code_acte,
                    'display', libelle_acte
                )),
                'text', libelle_acte
            )
        else null end as code,
        libelle_acte as code_text,
        
        -- Identifiers
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/acte-id',
            'value', acte_id::text
        )) as identifiers,
        
        null as based_on_s,
        null as part_of_s,
        
        -- Subject
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
        
        -- Performed date/time
        case when date_acte is not null then
            json_build_object('valueDateTime', date_acte::text)
        else null end as performed_x,
        date_acte as performed_date_time,
        
        null as recorder,
        null as asserter,
        
        -- Performers
        case when executant is not null then
            json_build_array(json_build_object(
                'actor', json_build_object(
                    'display', executant,
                    'type', 'Practitioner'
                ),
                'function', json_build_object('text', 'Exécutant')
            ))
        else null end as performers,
        executant as performer_actor_practitioner_text,
        
        null as location,
        null as reason_codes,
        null as reason_references,
        null as body_sites,
        null as outcome,
        null as reports,
        null as complications,
        null as complication_details,
        null as follow_up_s,
        null as notes,
        null as focal_devices,
        null as used_references,
        null as used_codes,
        
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', current_timestamp::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMProcedure')
        ) as meta,
        null as implicit_rules,
        'fr-FR' as resource_language,
        null as text_div,
        null as contained,
        null as extensions,
        null as modifier_extensions,
        
        -- Source reference data
        acte_id as original_acte_id,
        patient_id as original_patient_id,
        pmsi_id as original_pmsi_id,
        code_acte as ccam_code,
        data_quality_level,
        
        -- Audit fields
        created_at,
        updated_at
        
    from actes_with_references
)

select * from fhir_procedure