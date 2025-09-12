{{
    config(
        materialized='view',
        tags=['intermediate', 'medication_request']
    )
}}

with prescription as (
    select * from {{ ref('stg_ehr__prescription') }}
),

posologie as (
    select * from {{ ref('stg_ehr__posologie') }}
),

patient as (
    select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
),

-- Combine prescription with dosage information
prescription_with_dosage as (
    select 
        p.*,
        pt.fhir_patient_id,
        pos.nombre_prises_par_jour,
        pos.quantite,
        pos.unite_quantite,
        pos.date_heure_debut as posologie_debut,
        pos.date_heure_fin as posologie_fin,
        pos.data_quality_level as posologie_quality
    from prescription p
    inner join patient pt on p.patient_id = pt.patient_id
    left join posologie pos on p.prescription_id = pos.prescription_id
),

enriched_medication_request as (
    select
        prescription_id,
        patient_id,
        fhir_medication_request_id,
        fhir_patient_id,
        
        -- Prescriber information
        prescripteur,
        
        -- Medication information
        denomination,
        code_atc,
        voie_administration,
        
        -- Prescription dates
        date_prescription,
        date_debut_prescription,
        date_fin_prescription,
        
        -- Dosage information
        nombre_prises_par_jour,
        quantite,
        unite_quantite,
        posologie_debut,
        posologie_fin,
        
        -- FHIR status and intent
        fhir_status,
        fhir_intent,
        
        -- Data quality
        data_quality_level,
        posologie_quality,
        
        -- FHIR identifier construction
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/prescription-id',
            'value', prescription_id::text
        )) as identifiers_json,
        
        -- FHIR subject reference construction
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject_json,
        
        -- FHIR medication construction
        json_build_object(
            'text', denomination,
            'coding', case when code_atc is not null then 
                json_build_array(json_build_object(
                    'system', 'http://www.whocc.no/atc',
                    'code', code_atc
                ))
            else null end
        ) as medication_json,
        
        -- FHIR requester construction
        case when prescripteur is not null then
            json_build_object(
                'display', prescripteur,
                'type', 'Practitioner'
            )
        else null end as requester_json,
        
        -- FHIR dosage instruction construction
        case when quantite is not null or nombre_prises_par_jour is not null or voie_administration is not null then
            json_build_array(json_build_object(
                'text', 
                'Prendre' ||
                case when quantite is not null then ' ' || quantite::text else ' 1' end ||
                case when unite_quantite is not null then ' ' || unite_quantite else ' comprimé' end ||
                case when nombre_prises_par_jour is not null then ' ' || nombre_prises_par_jour::text || ' fois par jour' else ' selon prescription' end,
                'route', case when voie_administration is not null then json_build_object(
                    'coding', json_build_array(json_build_object(
                        'system', 'https://smt.esante.gouv.fr/terminologie-standardterms',
                        'code', voie_administration
                    ))
                ) else null end,
                'timing', case when nombre_prises_par_jour is not null or date_debut_prescription is not null or date_fin_prescription is not null then
                    json_build_object(
                        'repeat', json_build_object(
                            'bounds', case when date_debut_prescription is not null or date_fin_prescription is not null then
                                json_build_object(
                                    'start', case when date_debut_prescription is not null then date_debut_prescription::text else null end,
                                    'end', case when date_fin_prescription is not null then date_fin_prescription::text else null end
                                )
                            else null end,
                            'frequency', case when nombre_prises_par_jour is not null then nombre_prises_par_jour else null end,
                            'period', case when nombre_prises_par_jour is not null then 1 else null end,
                            'periodUnit', case when nombre_prises_par_jour is not null then 'd' else null end
                        )
                    )
                else null end,
                'doseAndRate', case when quantite is not null then
                    json_build_array(json_build_object(
                        'dose', json_build_object(
                            'value', quantite,
                            'unit', case when unite_quantite is not null then unite_quantite else 'unit' end,
                            'system', 'http://unitsofmeasure.org',
                            'code', case when unite_quantite is not null then unite_quantite else 'unit' end
                        )
                    ))
                else null end
            ))
        else null end as dosage_instructions_json,
        
        -- Audit fields
        created_at,
        updated_at,
        current_timestamp as transformed_at
        
    from prescription_with_dosage
)

select * from enriched_medication_request