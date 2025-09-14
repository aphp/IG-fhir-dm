{{
    config(
        materialized='view',
        tags=['intermediate', 'patient']
    )
}}

with patient as (
    select * from {{ ref('stg_ehr__patient') }}
),

patient_address as (
    select * from {{ ref('stg_ehr__patient_adresse') }}
),

-- Aggregate address information per patient (take most recent)
patient_with_address as (
    select 
        p.*,
        pa.latitude,
        pa.longitude,
        pa.code_iris,
        pa.libelle_iris,
        pa.code_geographique_residence,
        pa.libelle_geographique_residence,
        pa.date_recueil as address_date_recueil,
        pa.has_coordinates,
        pa.has_iris,
        pa.has_pmsi_geo
    from patient p
    left join (
        select 
            *,
            row_number() over (partition by patient_id order by date_recueil desc nulls last, patient_adresse_id desc) as rn
        from patient_address
    ) pa on p.patient_id = pa.patient_id and pa.rn = 1
),

-- Add calculated fields and FHIR-specific transformations
enriched_patient as (
    select
        patient_id,
        fhir_patient_id,
        
        -- Identity information
        nom as family_name,
        prenom as given_name,
        nir,
        ins,
        
        -- Demographics
        date_naissance as birth_date,
        gender_fhir,
        gender_original,
        
        -- Death information
        date_deces as death_date,
        source_deces as death_source,
        case when date_deces is not null then true else false end as is_deceased,
        
        -- Multiple birth
        rang_gemellaire as birth_rank,
        case when rang_gemellaire is not null then true else false end as multiple_birth_info,
        
        -- Address information
        latitude,
        longitude,
        code_iris,
        libelle_iris,
        code_geographique_residence,
        libelle_geographique_residence,
        address_date_recueil,
        has_coordinates,
        has_iris,
        has_pmsi_geo,
        case when latitude is not null or longitude is not null or code_iris is not null or code_geographique_residence is not null then true else false end as has_location,
        
        -- Data quality
        data_quality_level,
        data_quality_score,
        has_nss,
        has_ins,
        
        -- FHIR identifiers array construction
        case 
            when ins is not null or nir is not null then
                json_build_array(
                    case when patient_id is not null then json_build_object(
                        'use', 'usual',
                        'type', json_build_object(
                            'coding', json_build_array(json_build_object(
                                'system', 'http://terminology.hl7.org/CodeSystem/v2-0203',
                                'code', 'PI',
                                'display', 'Patient Identifier'
                            ))
                        ),
                        'system', 'https://hospital.eu/ehr/patient-id',
                        'value', patient_id::text
                    ) end,
                    case when ins is not null then json_build_object(
                        'use', 'official',
                        'type', json_build_object(
                            'coding', json_build_array(json_build_object(
                                'system', 'https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-v2-0203',
                                'code', 'INS-NIR',
                                'display', 'NIR définitif'
                            ))
                        ),
                        'system', 'urn:oid:1.2.250.1.213.1.4.8',
                        'value', ins
                    ) end
                )
            else null
        end as identifiers_json,
        
        -- FHIR names array construction
        case 
            when nom is not null or prenom is not null then
                json_build_array(json_build_object(
                    'use', 'official',
                    'family', nom,
                    'given', case when prenom is not null then json_build_array(prenom) else null end
                ))
            else null
        end as names_json,
        
        -- FHIR address array construction
        case 
            when has_coordinates or has_iris or has_pmsi_geo then
                json_build_array(json_build_object(
                    'extension', 
                    json_build_array(
                        case when latitude is not null and longitude is not null then
                            json_build_object(
                                'url', 'http://hl7.org/fhir/StructureDefinition/geolocation',
                                'extension', json_build_array(
                                    json_build_object('url', 'latitude', 'valueDecimal', latitude),
                                    json_build_object('url', 'longitude', 'valueDecimal', longitude)
                                )
                            )
                        else null
                        end,
                        case when code_iris is not null or libelle_iris is not null then
                            json_build_object(
                                'url', 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-censusTract',
                                'valueString', 
                                case 
                                    when code_iris is not null and libelle_iris is not null then code_iris || ' - ' || libelle_iris
                                    else coalesce(code_iris, libelle_iris)
                                end
                            )
                        else null
                        end,
                        case when code_geographique_residence is not null then
                            json_build_object(
                                'url', 'https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/PmsiCodeGeo',
                                'valueCode', code_geographique_residence
                            )
                        else null
                        end
                    ),
                    'period', case when address_date_recueil is not null then json_build_object(
                        'start', address_date_recueil::text
                    ) else null end
                ))
            else null
        end as address_json,
        
        -- FHIR deceased information
        case 
            when date_deces is not null then json_build_object(
                'valueDateTime', date_deces::text,
                'extension', case when source_deces is not null then 
                    json_build_array(json_build_object(
                        'url', 'https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DeathSource',
                        'valueCode', source_deces
                    ))
                else null end
            )
            else json_build_object('valueBoolean', false)
        end as deceased_json,
        
        -- Audit fields
        created_at,
        updated_at,
        current_timestamp as transformed_at
        
    from patient_with_address
)

select * from enriched_patient