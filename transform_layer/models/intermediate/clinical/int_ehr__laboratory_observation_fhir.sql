{{ config(
    materialized='table',
    tags=['intermediate', 'ehr', 'fhir', 'observation', 'laboratory', 'clinical']
) }}

-- Intermediate model transforming EHR laboratory results to FHIR Observation structure
-- Implements the TransformLabObservation group from the FML mapping

with source_laboratory as (
    select * from {{ ref('stg_ehr__laboratory') }}
),

source_encounters as (
    select encounter_id, patient_id from {{ ref('stg_ehr__encounter') }}
),

fhir_laboratory_transform as (
    select
        -- FHIR Resource ID (following FML mapping src.biologieId as id -> tgt.id = id)
        {{ generate_fhir_id('laboratory_id') }} as observation_id,
        
        -- FHIR Patient Reference (following FML mapping patientId -> tgt.subject)
        {{ create_fhir_reference('concat(\'Patient/\', e.patient_id)') }} as patient_reference,
        
        -- FHIR Encounter Reference (following FML mapping src.pmsiId -> tgt.encounter)
        {{ create_fhir_reference('concat(\'Encounter/\', l.encounter_id)') }} as encounter_reference,
        
        -- FHIR Identifiers array - laboratory ID
        jsonb_build_array(
            {{ create_fhir_identifier(
                "'https://hospital.eu/ehr/biologie-id'", 
                'laboratory_id', 
                'official'
            ) }}
        ) as identifiers,
        
        -- FHIR Status (following FML mapping - map validation status)
        case 
            when validation_status = 'final' then 'final'
            when validation_status = 'preliminary' then 'preliminary'
            when validation_status = 'amended' then 'amended'
            when validation_status = 'cancelled' then 'cancelled'
            else 'final'
        end as status,
        
        -- FHIR Categories array (following FML mapping - laboratory category)
        jsonb_build_array(
            {{ create_fhir_codeable_concept(
                "'laboratory'",
                "'http://terminology.hl7.org/CodeSystem/observation-category'",
                "'Laboratory'",
                "'Laboratory'"
            ) }}
        ) as categories,
        
        -- FHIR Code with LOINC (following FML mapping src.codeLoinc -> tgt.code)
        case 
            when loinc_code is not null then
                {{ create_fhir_codeable_concept(
                    'loinc_code',
                    "'http://loinc.org'",
                    'test_name',
                    'test_name'
                ) }}
            else
                {{ create_fhir_codeable_concept(
                    'laboratory_id',
                    "'https://hospital.eu/ehr/test-codes'",
                    'test_name',
                    'test_name'
                ) }}
        end as code,
        
        -- FHIR Effective DateTime (following FML mapping src.datePrelevement -> tgt.effective)
        case 
            when collection_datetime is not null then
                {{ to_fhir_datetime('collection_datetime') }}
            else null
        end as effective_date_time,
        
        -- FHIR Value Quantity (following FML mapping src.valeur -> tgt.valueQuantity)
        case 
            when numeric_value is not null then
                {{ create_fhir_quantity(
                    'numeric_value',
                    'coalesce(unit_of_measure, \'1\')',
                    'http://unitsofmeasure.org',
                    'coalesce(unit_of_measure, \'1\')'
                ) }}
            else null
        end as value_quantity,
        
        -- FHIR Value String (following FML mapping src.valeurTexte -> tgt.valueString)
        case 
            when text_value is not null and numeric_value is null then
                text_value
            else null
        end as value_string,
        
        -- FHIR Reference Ranges (following FML mapping for reference ranges)
        case 
            when reference_range_low is not null or reference_range_high is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'low', case 
                            when reference_range_low is not null then
                                {{ create_fhir_quantity(
                                    'reference_range_low',
                                    'coalesce(unit_of_measure, \'1\')',
                                    'http://unitsofmeasure.org',
                                    'coalesce(unit_of_measure, \'1\')'
                                ) }}
                            else null
                        end,
                        'high', case 
                            when reference_range_high is not null then
                                {{ create_fhir_quantity(
                                    'reference_range_high',
                                    'coalesce(unit_of_measure, \'1\')',
                                    'http://unitsofmeasure.org',
                                    'coalesce(unit_of_measure, \'1\')'
                                ) }}
                            else null
                        end
                    )
                )
            else null
        end as reference_ranges,
        
        -- FHIR Performers array (following FML mapping src.laboratoire -> tgt.performer)
        case 
            when laboratory_name is not null then
                jsonb_build_array(
                    {{ create_fhir_reference(
                        'concat(\'Organization/\', replace(laboratory_name, \' \', \'-\'))', 
                        'laboratory_name'
                    ) }}
                )
            else null
        end as performers,
        
        -- FHIR Notes array (following FML mapping src.commentaire -> tgt.note)
        case 
            when result_comment is not null then
                jsonb_build_array(
                    {{ create_fhir_annotation('result_comment') }}
                )
            else null
        end as notes,
        
        -- Additional context
        test_category,
        analysis_method,
        
        -- FHIR Meta with DMObservationLaboratory profile
        {{ create_fhir_meta('https://aphp.fr/ig/fhir/dm/StructureDefinition/DMObservationLaboratory') }} as meta,
        
        -- Audit fields
        current_timestamp as last_updated,
        {{ add_fhir_audit_columns() }}
        
    from source_laboratory l
    inner join source_encounters e on l.encounter_id = e.encounter_id
),

final as (
    select
        observation_id,
        patient_reference,
        encounter_reference,
        identifiers,
        status,
        categories,
        code,
        effective_date_time,
        value_quantity,
        value_string,
        reference_ranges,
        performers,
        notes,
        meta,
        current_timestamp as last_updated,
        created_at,
        fhir_version,
        source_environment
    from fhir_laboratory_transform t
    where observation_id is not null
      and patient_reference is not null
      and code is not null
      and (value_quantity is not null or value_string is not null)
)

select * from final