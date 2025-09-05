{{
    config(
        materialized='table',
        unique_key='id',
        tags=['mart', 'fhir', 'patient']
    )
}}

-- FHIR Patient resource mart table
-- Compliant with FHIR R4 Patient resource structure
with patient_data as (
    select * from {{ ref('int_patient_identifiers') }}
    where has_valid_identifier = true
),

fhir_patient as (
    select
        -- FHIR Resource metadata
        fhir_patient_id as id,
        'Patient' as resourceType,
        fhir_meta as meta,
        
        -- Patient identifiers (INS-NIR French healthcare identifiers)
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'system', primary_identifier_system,
                'value', primary_identifier_value
            ) ||
            case when primary_identifier_system = 'urn:oid:1.2.250.1.213.1.4.10' 
                then jsonb_build_object('type', jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://interopsante.org/fhir/CodeSystem/fr-v2-0203',
                            'code', 'INS-C',
                            'display', 'Identifiant National de Santé Calculé'
                        )
                    )
                ))
                else jsonb_build_object('type', jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://interopsante.org/fhir/CodeSystem/fr-v2-0203',
                            'code', 'NIR',
                            'display', 'Numéro d''Inscription au Répertoire'
                        )
                    )
                ))
            end
        ) as identifier,
        
        -- Active status (assuming all patients are active)
        true as active,
        
        -- Patient name
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'family', family_name,
                'given', jsonb_build_array(given_name)
            )
        ) as name,
        
        -- Gender (FHIR administrative gender)
        gender,
        
        -- Birth date
        to_char(birth_date, 'YYYY-MM-DD') as birthDate,
        
        -- Address (if available)
        case 
            when fhir_address is not null 
            then jsonb_build_array(fhir_address)
            else null 
        end as address,
        
        -- Contact information (extension for position if available)
        case
            when fhir_position is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'url', 'http://hl7.org/fhir/StructureDefinition/geolocation',
                        'extension', jsonb_build_array(
                            jsonb_build_object(
                                'url', 'latitude',
                                'valueDecimal', (fhir_position->>'latitude')::decimal
                            ),
                            jsonb_build_object(
                                'url', 'longitude', 
                                'valueDecimal', (fhir_position->>'longitude')::decimal
                            )
                        )
                    )
                )
            else null
        end as extension,
        
        -- General practitioner or managing organization
        jsonb_build_array(
            jsonb_build_object(
                'reference', 'Organization/' || '{{ var("default_organization_id") }}',
                'display', 'AP-HP - Assistance Publique Hôpitaux de Paris'
            )
        ) as generalPractitioner,
        
        -- Managing organization
        jsonb_build_object(
            'reference', 'Organization/' || '{{ var("default_organization_id") }}',
            'display', 'AP-HP - Assistance Publique Hôpitaux de Paris'
        ) as managingOrganization,
        
        -- Data quality and audit fields
        data_quality_level,
        data_quality_score,
        case when nir_identifier is not null then true else false end as has_valid_nir,
        case when ins_identifier is not null then true else false end as has_ins,
        case when latitude is not null and longitude is not null then true else false end as has_location,
        extracted_at,
        current_timestamp as last_updated,
        
        -- Source identifiers for traceability
        patient_id as source_patient_id
        
    from patient_data
)

select 
    -- FHIR Resource structure
    id,
    resourceType,
    meta,
    identifier,
    active,
    name,
    gender,
    birthDate,
    address,
    extension,
    generalPractitioner,
    managingOrganization,
    
    -- Audit and quality fields
    data_quality_level,
    data_quality_score,
    has_valid_nir,
    has_ins,
    has_location,
    source_patient_id,
    extracted_at,
    last_updated
    
from fhir_patient