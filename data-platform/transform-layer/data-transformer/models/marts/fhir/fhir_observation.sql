{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'observation'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['subject_patient_id']},
            {'columns': ['encounter_id']},
            {'columns': ['code_text']},
            {'columns': ['effective_date_time']},
            {'columns': ['categories_text']}
        ]
    )
}}

-- Union all observation sources: laboratory, vital signs, and lifestyle
with laboratory_observations as (
    select 
        biologie.*,
        p.fhir_patient_id,
        null as fhir_encounter_id  -- Laboratory tests not linked to specific encounters
    from {{ ref('stg_ehr__biologie') }} biologie
    inner join (
        select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
    ) p on biologie.patient_id = p.patient_id
),

vital_sign_observations as (
    select 
        dossier_soins.*,
        p.fhir_patient_id,
        null as fhir_encounter_id  -- Care measurements not linked to specific encounters
    from {{ ref('stg_ehr__dossier_soins') }} dossier_soins
    inner join (
        select patient_id, fhir_patient_id from {{ ref('int_patient_enriched') }}
    ) p on dossier_soins.patient_id = p.patient_id
),

lifestyle_observations as (
    select * from {{ ref('int_lifestyle_observations_split') }}
),

-- Transform laboratory observations
lab_obs_transformed as (
    select
        'lab-' || fhir_observation_id as id,
        current_timestamp as last_updated,
        
        -- Status
        fhir_status as status,
        
        -- Category
        json_build_array(json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://terminology.hl7.org/CodeSystem/observation-category',
                'code', 'laboratory',
                'display', 'Laboratory'
            ))
        )) as categories,
        'laboratory' as categories_text,
        
        -- Code
        case when code_loinc is not null then
            json_build_object(
                'coding', json_build_array(json_build_object(
                    'system', 'http://loinc.org',
                    'code', code_loinc
                )),
                'text', libelle_test
            )
        else null end as code,
        libelle_test as code_text,
        
        -- Identifiers
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/biologie-id',
            'value', biologie_id::text
        )) as identifiers,
        
        null::json as based_on_s,
        null::json as part_of_s,
        
        -- Subject
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Encounter (null for lab tests)
        null::json as encounter,
        null::text as encounter_id,
        
        null::json as focus_s,
        
        -- Effective timing
        case when date_prelevement is not null then
            json_build_object('valueDateTime', date_prelevement::text)
        else null::json end as effective_x,
        date_prelevement as effective_date_time,
        
        null::timestamp as issued,
        
        -- Performer
        case when laboratoire is not null then
            json_build_array(json_build_object(
                'display', laboratoire,
                'type', 'Organization'
            ))
        else null end as performers,
        laboratoire as performer_organization_text,
        
        -- Value
        case 
            when valeur is not null then
                json_build_object(
                    'value', valeur,
                    'unit', unite,
                    'system', 'http://unitsofmeasure.org',
                    'code', unite
                )
            when valeur_texte is not null then
                json_build_object('valueString', valeur_texte)
        else null end::json as value_x,
        valeur as value_quantity_value,
        unite as value_quantity_unit,
        
        null::json as data_absent_reason,
        null::json as interpretations,
        null::json as notes,
        null::json as body_site,
        null::json as method,
        null::json as specimen,
        null::json as device,
        
        -- Reference ranges
        case when borne_inf_normale is not null or borne_sup_normale is not null then
            json_build_array(json_build_object(
                'low', case when borne_inf_normale is not null then json_build_object(
                    'value', borne_inf_normale,
                    'unit', unite,
                    'system', 'http://unitsofmeasure.org',
                    'code', unite
                ) else null end,
                'high', case when borne_sup_normale is not null then json_build_object(
                    'value', borne_sup_normale,
                    'unit', unite,
                    'system', 'http://unitsofmeasure.org',
                    'code', unite
                ) else null end
            ))
        else null end as reference_ranges,
        case when borne_inf_normale is not null or borne_sup_normale is not null then
            'Low: ' || coalesce(borne_inf_normale::text, 'N/A') || ' High: ' || coalesce(borne_sup_normale::text, 'N/A')
        else null end as reference_ranges_value,
        
        null::json as has_members,
        null::json as derived_from_s,
        null::json as components,
        
        -- Source data reference
        'laboratory' as observation_source,
        biologie_id as source_id,
        patient_id as original_patient_id,
        code_loinc as loinc_code,
        data_quality_level,
        
        created_at,
        updated_at
        
    from laboratory_observations
),

-- Transform vital sign observations
vital_obs_transformed as (
    select
        'vital-' || fhir_observation_id as id,
        current_timestamp as last_updated,
        
        -- Status
        fhir_status as status,
        
        -- Category
        json_build_array(json_build_object(
            'coding', json_build_array(json_build_object(
                'system', 'http://terminology.hl7.org/CodeSystem/observation-category',
                'code', 'vital-signs',
                'display', 'Vital Signs'
            ))
        )) as categories,
        'vital-signs' as categories_text,
        
        -- Code
        case when code_loinc is not null then
            json_build_object(
                'coding', json_build_array(json_build_object(
                    'system', 'http://loinc.org',
                    'code', code_loinc
                )),
                'text', libelle_test
            )
        else null end as code,
        libelle_test as code_text,
        
        -- Identifiers
        json_build_array(json_build_object(
            'system', 'https://hospital.eu/ehr/soin-id',
            'value', soin_id::text
        )) as identifiers,
        
        null::json as based_on_s,
        null::json as part_of_s,
        
        -- Subject
        json_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'type', 'Patient'
        ) as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Encounter (null for vital signs)
        null::json as encounter,
        null::text as encounter_id,
        
        null::json as focus_s,
        
        -- Effective timing
        case when date_mesure is not null then
            json_build_object('valueDateTime', date_mesure::text)
        else null::json end as effective_x,
        date_mesure::timestamp as effective_date_time,
        
        null::timestamp as issued,
        
        -- Performer (not detailed in source)
        null::json as performers,
        null::text as performer_organization_text,
        
        -- Value
        case 
            when valeur is not null then
                json_build_object(
                    'value', valeur,
                    'unit', unite,
                    'system', 'http://unitsofmeasure.org',
                    'code', unite
                )
            when valeur_texte is not null then
                json_build_object('valueString', valeur_texte)
        else null end::json as value_x,
        valeur as value_quantity_value,
        unite as value_quantity_unit,
        
        null::json as data_absent_reason,
        null::json as interpretations,
        null::json as notes,
        null::json as body_site,
        null::json as method,
        null::json as specimen,
        null::json as device,
        null::json as reference_ranges,
        null::text as reference_ranges_value,
        null::json as has_members,
        null::json as derived_from_s,
        null::json as components,
        
        -- Source data reference
        'vital-signs' as observation_source,
        soin_id as source_id,
        patient_id as original_patient_id,
        code_loinc as loinc_code,
        data_quality_level,
        
        created_at,
        updated_at
        
    from vital_sign_observations
),

-- Transform lifestyle observations
lifestyle_obs_transformed as (
    select
        'lifestyle-' || fhir_observation_id as id,
        current_timestamp as last_updated,
        
        -- Status
        fhir_status as status,
        
        -- Category
        categories_json::json as categories,
        'social-history' as categories_text,
        
        -- Code
        code_json::json as code,
        loinc_display as code_text,
        
        -- Identifiers
        identifiers_json::json as identifiers,
        
        null::json as based_on_s,
        null::json as part_of_s,
        
        -- Subject
        subject_json::json as subject,
        fhir_patient_id as subject_patient_id,
        
        -- Encounter (null for lifestyle)
        null::json as encounter,
        null::text as encounter_id,
        
        null::json as focus_s,
        
        -- Effective timing
        effective_json::json as effective_x,
        effective_date::timestamp as effective_date_time,
        
        null::timestamp as issued,
        null::json as performers,
        null::text as performer_organization_text,
        
        -- Value
        value_json::json as value_x,
        null::numeric as value_quantity_value,
        null::text as value_quantity_unit,
        
        null::json as data_absent_reason,
        null::json as interpretations,
        null::json as notes,
        null::json as body_site,
        null::json as method,
        null::json as specimen,
        null::json as device,
        null::json as reference_ranges,
        null::text as reference_ranges_value,
        null::json as has_members,
        null::json as derived_from_s,
        null::json as components,
        
        -- Source data reference
        'lifestyle' as observation_source,
        style_vie_id as source_id,
        patient_id as original_patient_id,
        loinc_code,
        data_quality_level,
        
        created_at,
        updated_at
        
    from lifestyle_observations
),

-- Combine all observation types
fhir_observation as (
    select 
        *,
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', last_updated::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMObservation')
        ) as meta,
        null::text as implicit_rules,
        'fr-FR' as resource_language,
        null::text as text_div,
        null::json as contained,
        null::json as extensions,
        null::json as modifier_extensions,
        
        current_timestamp as final_updated_at
    from (
        select * from lab_obs_transformed
        union all
        select * from vital_obs_transformed  
        union all
        select * from lifestyle_obs_transformed
    ) all_observations
)

select * from fhir_observation