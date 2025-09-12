{{
    config(
        materialized='view',
        tags=['intermediate', 'observation', 'lifestyle']
    )
}}

with lifestyle as (
    select * from {{ ref('stg_ehr__style_vie') }}
),

patient as (
    select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
),

lifestyle_with_patient as (
    select 
        l.*,
        p.fhir_patient_id
    from lifestyle l
    inner join patient p on l.patient_id = p.patient_id
),

-- Create separate rows for each lifestyle element following FML mapping
lifestyle_split as (
    -- Tobacco consumption observations
    select
        style_vie_id,
        patient_id,
        fhir_patient_id,
        date_recueil,
        fhir_status,
        fhir_category,
        data_quality_level,
        created_at,
        updated_at,
        
        'tobacco' as lifestyle_type,
        '72166-2' as loinc_code,
        'Tobacco smoking status' as loinc_display,
        consommation_tabac as lifestyle_value,
        fhir_base_observation_id || '-tobacco' as fhir_observation_id,
        
        -- FHIR code construction for tobacco
        json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://loinc.org',
                'code', '72166-2',
                'display', 'Tobacco smoking status'
            ))
        ) as code_json,
        
        -- FHIR value construction
        case when consommation_tabac is not null then
            json_build_object('text', consommation_tabac)
        else null end as value_json
        
    from lifestyle_with_patient
    where has_tobacco_data = true
    
    union all
    
    -- Alcohol consumption observations  
    select
        style_vie_id,
        patient_id,
        fhir_patient_id,
        date_recueil,
        fhir_status,
        fhir_category,
        data_quality_level,
        created_at,
        updated_at,
        
        'alcohol' as lifestyle_type,
        '11331-6' as loinc_code,
        'History of alcohol use' as loinc_display,
        consommation_alcool as lifestyle_value,
        fhir_base_observation_id || '-alcohol' as fhir_observation_id,
        
        -- FHIR code construction for alcohol
        json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://loinc.org',
                'code', '11331-6',
                'display', 'History of alcohol use'
            ))
        ) as code_json,
        
        -- FHIR value construction
        case when consommation_alcool is not null then
            json_build_object('text', consommation_alcool)
        else null end as value_json
        
    from lifestyle_with_patient
    where has_alcohol_data = true
    
    union all
    
    -- Drug consumption observations
    select
        style_vie_id,
        patient_id,
        fhir_patient_id,
        date_recueil,
        fhir_status,
        fhir_category,
        data_quality_level,
        created_at,
        updated_at,
        
        'drugs' as lifestyle_type,
        '11342-3' as loinc_code,
        'History of drug use' as loinc_display,
        consommation_autres_drogues as lifestyle_value,
        fhir_base_observation_id || '-drugs' as fhir_observation_id,
        
        -- FHIR code construction for drugs
        json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://loinc.org',
                'code', '11342-3',
                'display', 'History of drug use'
            ))
        ) as code_json,
        
        -- FHIR value construction
        case when consommation_autres_drogues is not null then
            json_build_object('text', consommation_autres_drogues)
        else null end as value_json
        
    from lifestyle_with_patient
    where has_drug_data = true
    
    union all
    
    -- Physical activity observations
    select
        style_vie_id,
        patient_id,
        fhir_patient_id,
        date_recueil,
        fhir_status,
        fhir_category,
        data_quality_level,
        created_at,
        updated_at,
        
        'physical_activity' as lifestyle_type,
        '67504-6' as loinc_code,
        'Exercise activity' as loinc_display,
        activite_physique as lifestyle_value,
        fhir_base_observation_id || '-physical' as fhir_observation_id,
        
        -- FHIR code construction for physical activity
        json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://loinc.org',
                'code', '67504-6',
                'display', 'Exercise activity'
            ))
        ) as code_json,
        
        -- FHIR value construction
        case when activite_physique is not null then
            json_build_object('text', activite_physique)
        else null end as value_json
        
    from lifestyle_with_patient
    where has_physical_activity_data = true
),

enriched_lifestyle_observations as (
    select
        style_vie_id,
        patient_id,
        fhir_patient_id,
        fhir_observation_id,
        lifestyle_type,
        lifestyle_value,
        
        -- LOINC code information
        loinc_code,
        loinc_display,
        
        -- FHIR elements
        fhir_status,
        fhir_category,
        
        -- Date information
        date_recueil as effective_date,
        
        -- JSON constructions
        code_json,
        value_json,
        
        -- FHIR identifier construction
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/lifestyle-id',
            'value', fhir_observation_id
        )) as identifiers_json,
        
        -- FHIR category construction
        json_build_array(json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://terminology.hl7.org/CodeSystem/observation-category',
                'code', 'social-history',
                'display', 'Social History'
            ))
        )) as categories_json,
        
        -- FHIR subject reference construction
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject_json,
        
        -- FHIR effective construction
        case when date_recueil is not null then
            json_build_object('valueDateTime', date_recueil::text)
        else null end as effective_json,
        
        -- Data quality
        data_quality_level,
        
        -- Audit fields
        created_at,
        updated_at,
        current_timestamp as transformed_at
        
    from lifestyle_split
)

select * from enriched_lifestyle_observations