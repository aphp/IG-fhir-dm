{{
    config(
        materialized='view',
        tags=['intermediate', 'encounter']
    )
}}

with encounter as (
    select * from {{ ref('stg_ehr__donnees_pmsi') }}
),

patient as (
    select * from {{ ref('int_patient_enriched') }}
),

encounter_with_patient as (
    select 
        e.*,
        p.fhir_patient_id
    from encounter e
    inner join patient p on e.patient_id = p.patient_id
),

enriched_encounter as (
    select
        pmsi_id,
        patient_id,
        fhir_encounter_id,
        fhir_patient_id,
        
        -- Stay information
        mode_sortie,
        mode_entree, 
        age_admission,
        
        -- Stay dates and duration
        date_debut_sejour as period_start,
        date_fin_sejour as period_end,
        length_of_stay_days,
        
        -- Organizational information
        etablissement,
        service,
        unite_fonctionnelle,
        
        -- FHIR status and class
        fhir_status,
        'IMP' as fhir_class_code,  -- Inpatient encounter for PMSI data
        'inpatient encounter' as fhir_class_display,
        'http://terminology.hl7.org/CodeSystem/v3-ActCode' as fhir_class_system,
        
        -- Data quality
        data_quality_level,
        
        -- FHIR identifier construction
        json_build_array(json_build_object(
            'type', json_build_object(
                'coding', json_build_array(json_build_object(
                    'system', 'https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-identifier-type',
                    'code', 'VN',
                    'display', 'Visit Number'
                ))
            ),
            'system', 'https://hospital.eu/ehr/pmsi-id',
            'value', pmsi_id::text
        )) as identifiers_json,
        
        -- FHIR class construction
        json_build_object(
            'system', 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
            'code', 'IMP',
            'display', 'inpatient encounter'
        ) as class_json,
        
        -- FHIR subject reference construction
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject_json,
        
        -- FHIR period construction
        case 
            when date_debut_sejour is not null or date_fin_sejour is not null then
                json_build_object(
                    'start', case when date_debut_sejour is not null then date_debut_sejour::text else null end,
                    'end', case when date_fin_sejour is not null then date_fin_sejour::text else null end
                )
            else null
        end as period_json,
        
        -- FHIR length construction
        case 
            when length_of_stay_days is not null then
                json_build_object(
                    'value', length_of_stay_days,
                    'unit', 'd',
                    'system', 'http://unitsofmeasure.org',
                    'code', 'd'
                )
            else null
        end as length_json,
        
        -- FHIR hospitalization construction
        case 
            when mode_entree is not null or mode_sortie is not null then
                json_build_object(
                    'admitSource', case when mode_entree is not null then json_build_object(
                        'text', mode_entree
                    ) else null end,
                    'dischargeDisposition', case when mode_sortie is not null then json_build_object(
                        'text', mode_sortie
                    ) else null end
                )
            else null
        end as hospitalization_json,
        
        -- FHIR service provider construction (organization)
        case 
            when etablissement is not null or service is not null or unite_fonctionnelle is not null then
                json_build_object(
                    'display', coalesce(
                        unite_fonctionnelle, 
                        service, 
                        etablissement
                    )
                )
            else null
        end as service_provider_json,
        
        -- Audit fields
        created_at,
        updated_at,
        current_timestamp as transformed_at
        
    from encounter_with_patient
)

select * from enriched_encounter