{{ config(
    materialized='table',
    tags=['intermediate', 'ehr', 'fhir', 'patient', 'core']
) }}

-- Intermediate model transforming EHR patient data to FHIR Patient structure
-- Implements the TransformPatient group from the FML mapping

with source_patients as (
    select * from {{ ref('stg_ehr__patient') }}
),

fhir_patient_transform as (
    select
        -- FHIR Resource ID (following FML mapping src.patientId as id -> tgt.id = id)
        {{ generate_fhir_id('patient_id') }} as patient_id,
        
        -- FHIR Identifiers array - hospital ID + INS-NIR
        jsonb_build_array(
            -- Hospital patient ID identifier
            {{ create_fhir_identifier(
                "'https://hospital.eu/ehr/patient-id'", 
                'patient_id::text', 
                'usual'
            ) }},
            
            -- INS-NIR identifier (if available)
            case 
                when ins_nir_identifier is not null then
                    {{ create_fhir_identifier(
                        "'urn:oid:1.2.250.1.213.1.4.8'", 
                        'ins_nir_identifier', 
                        'official',
                        'INS-NIR',
                        'INS-NIR'
                    ) }}
                else null
            end,
            
            -- Alternative INS identifier (if available and different from NIR)
            case 
                when ins_identifier is not null 
                    and ins_identifier != ins_nir_identifier then
                    {{ create_fhir_identifier(
                        "'urn:oid:1.2.250.1.213.1.4.8'", 
                        'ins_identifier', 
                        'official',
                        'INS-NIR',
                        'INS-NIR'
                    ) }}
                else null
            end
        ) - null as identifiers,  -- Remove null values
        
        -- FHIR Names array
        case 
            when family_name is not null or given_name is not null then
                jsonb_build_array(
                    {{ create_fhir_human_name('family_name', 'given_name', 'official') }}
                )
            else null
        end as names,
        
        -- FHIR Gender (following FML mapping for gender transformation)
        case 
            when gender_code = 'M' then 'male'
            when gender_code = 'F' then 'female'  
            when gender_code = 'U' then 'unknown'
            else 'unknown'
        end as gender,
        
        -- FHIR Birth Date
        {{ to_fhir_date('birth_date') }} as birth_date,
        
        -- FHIR Deceased (following FML mapping src.dateDeces as deathDate where deathDate.exists() -> tgt.deceased)
        case 
            when deceased_date is not null then 
                {{ to_fhir_datetime('deceased_date::timestamp') }}
            else null
        end as deceased_date_time,
        
        -- FHIR Multiple Birth (following FML mapping src.rangGemellaire as twin -> tgt.multipleBirth)
        multiple_birth_rank as multiple_birth_integer,
        
        -- FHIR Addresses array
        case 
            when address_postal_code is not null 
                or address_city is not null then
                jsonb_build_array(
                    {{ create_fhir_address(
                        'null', 
                        'address_city', 
                        'address_postal_code', 
                        'FR', 
                        'home'
                    ) }}
                )
            else null
        end as addresses,
        
        -- FHIR Extensions for geographic coordinates (French extension pattern)
        case 
            when address_latitude is not null or address_longitude is not null then
                jsonb_build_array(
                    {{ create_fhir_extension(
                        'https://hl7.fr/ig/fhir/core/StructureDefinition/fr-patient-coordinates',
                        'valueString',
                        'concat(coalesce(address_latitude::text, \'\'), \',\', coalesce(address_longitude::text, \'\'))'
                    ) }}
                )
            else null
        end as extensions,
        
        -- FHIR Meta with DMPatient profile
        {{ create_fhir_meta('https://aphp.fr/ig/fhir/dm/StructureDefinition/DMPatient') }} as meta,
        
        -- Audit fields
        current_timestamp as last_updated,
        {{ add_fhir_audit_columns() }}
        
    from source_patients p
),

final as (
    select
        patient_id,
        identifiers,
        names,
        gender,
        birth_date,
        deceased_date_time,
        multiple_birth_integer,
        addresses,
        extensions,
        meta,
        current_timestamp as last_updated,
        created_at,
        fhir_version,
        source_environment
    from fhir_patient_transform
    where patient_id is not null
)

select * from final