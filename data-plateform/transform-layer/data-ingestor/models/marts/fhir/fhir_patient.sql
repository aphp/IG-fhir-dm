{{
    config(
        materialized='table',
        tags=['marts', 'fhir', 'patient'],
        indexes=[
            {'columns': ['id'], 'unique': true},
            {'columns': ['ins_nir_identifier'], 'unique': true},
            {'columns': ['nss_identifier']},
            {'columns': ['birth_date']},
            {'columns': ['gender']}
        ]
    )
}}

with enriched_patient as (
    select * from {{ ref('int_patient_enriched') }}
),

fhir_patient as (
    select
        -- FHIR Resource metadata
        fhir_patient_id as id,
        current_timestamp as last_updated,
        
        -- Patient active status (assume true for EHR data)
        true as active,
        
        -- Identifiers
        identifiers_json as identifiers,
        ins as ins_nir_identifier,
        nir as nss_identifier,
        
        -- Names
        names_json as names,
        case when family_name is not null or given_name is not null then
            family_name || case when given_name is not null then ', ' || given_name else '' end
        else null end as full_names,
        
        -- Demographics
        gender_fhir as gender,
        birth_date,
        deceased_json as deceased_x,
        death_date as deceased_date_time,
        death_source as deceased_extension_death_source,
        null as marital_status,  -- Not available in source data
        
        -- Address
        address_json as address,
        latitude as address_extension_geolocation_latitude,
        longitude as address_extension_geolocation_longitude,
        case 
            when code_iris is not null and libelle_iris is not null then code_iris || ' - ' || libelle_iris
            else coalesce(code_iris, libelle_iris)
        end as address_extension_census_tract,
        address_date_recueil as address_period_start,
        null as address_extension_pmsi_code_geo,  -- Could be added from code_geographique_residence
        code_geographique_residence as address_extension_pmsi_code_geo_code,
        
        -- Contact information (not available in source data)
        null as telecoms,
        null as contacts,
        null as communications,
        null as preferred_communication_languages,
        
        -- Multiple birth
        multiple_birth_info as multiple_birth_x,
        birth_rank as multiple_birth_integer,
        
        -- Care providers (not available in source data)
        null as general_practitioners,
        null as managing_organization,
        
        -- Patient linking (not available in source data)
        null as links,
        
        -- FHIR metadata
        json_build_object(
            'versionId', '1',
            'lastUpdated', current_timestamp::text,
            'profile', json_build_array('https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMPatient')
        ) as meta,
        null as implicit_rules,
        'fr-FR' as resource_language,
        null as text_div,
        null as contained,
        
        -- Extensions
        case when death_source is not null then
            json_build_array(json_build_object(
                'url', 'https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DeathSource',
                'valueCode', death_source
            ))
        else null end as extensions,
        null as modifier_extensions,
        
        -- Data quality indicators
        data_quality_level,
        data_quality_score,
        has_nss,
        has_ins,
        has_location,
        patient_id as identifier,  -- Original source identifier for reference
        
        -- Audit fields
        transformed_at as created_at,
        current_timestamp as updated_at
        
    from enriched_patient
)

select * from fhir_patient