{{ config(
    materialized='table',
    tags=['intermediate', 'ehr', 'fhir', 'procedure', 'clinical']
) }}

-- Intermediate model transforming EHR acts to FHIR Procedure structure
-- Implements the TransformProcedure group from the FML mapping

with source_procedures as (
    select * from {{ ref('stg_ehr__procedure') }}
),

source_encounters as (
    select encounter_id, patient_id from {{ ref('stg_ehr__encounter') }}
),

fhir_procedure_transform as (
    select
        -- FHIR Resource ID (following FML mapping src.acteId as id -> tgt.id = id)
        {{ generate_fhir_id('procedure_id') }} as procedure_id,
        
        -- FHIR Patient Reference (following FML mapping patientId -> tgt.subject)
        {{ create_fhir_reference('concat(\'Patient/\', e.patient_id)') }} as patient_reference,
        
        -- FHIR Encounter Reference (following FML mapping src.pmsiId -> tgt.encounter)
        {{ create_fhir_reference('concat(\'Encounter/\', p.encounter_id)') }} as encounter_reference,
        
        -- FHIR Identifiers array - procedure ID
        jsonb_build_array(
            {{ create_fhir_identifier(
                "'https://hospital.eu/ehr/acte-id'", 
                'procedure_id', 
                'official'
            ) }}
        ) as identifiers,
        
        -- FHIR Status (following FML mapping - assume completed for historical data)
        'completed' as status,
        
        -- FHIR Code with CCAM (following FML mapping src.codeActe -> tgt.code)
        {{ create_fhir_codeable_concept(
            'ccam_code',
            "'https://mos.esante.gouv.fr/NOS/TRE_R38-ActesCCAM/FHIR/TRE-R38-ActesCCAM'",
            'procedure_text',
            'procedure_text'
        ) }} as code,
        
        -- FHIR Performed DateTime (following FML mapping src.dateActe -> tgt.performed)
        case 
            when performed_datetime is not null then
                {{ to_fhir_datetime('performed_datetime') }}
            else null
        end as performed_date_time,
        
        -- FHIR Performers array (following FML mapping src.executant -> tgt.performer)
        case 
            when performer_name is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'actor', {{ create_fhir_reference(
                            'concat(\'Practitioner/\', replace(performer_name, \' \', \'-\'))', 
                            'performer_name'
                        ) }}
                    )
                )
            else null
        end as performers,
        
        -- Additional context
        procedure_sequence,
        data_collection_date,
        
        -- FHIR Meta with DMProcedure profile
        {{ create_fhir_meta('https://aphp.fr/ig/fhir/dm/StructureDefinition/DMProcedure') }} as meta,
        
        -- Audit fields
        current_timestamp as last_updated,
        {{ add_fhir_audit_columns() }}
        
    from source_procedures p
    inner join source_encounters e on p.encounter_id = e.encounter_id
),

final as (
    select
        procedure_id,
        patient_reference,
        encounter_reference,
        identifiers,
        status,
        code,
        performed_date_time,
        performers,
        meta,
        current_timestamp as last_updated,
        created_at,
        fhir_version,
        source_environment
    from fhir_procedure_transform
    where procedure_id is not null
      and patient_reference is not null
      and code is not null
)

select * from final