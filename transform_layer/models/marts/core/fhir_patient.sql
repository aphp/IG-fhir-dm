{{
  config(
    materialized='incremental',
    unique_key='id',
    on_schema_change='sync_all_columns',
    tags=['mart', 'fhir', 'patient', 'core'],
    indexes=[
      {'columns': ['ins_nir_identifier'], 'type': 'btree'},
      {'columns': ['family_name'], 'type': 'btree'},
      {'columns': ['birth_date'], 'type': 'btree'},
      {'columns': ['gender'], 'type': 'btree'},
      {'columns': ['identifiers'], 'type': 'gin'},
      {'columns': ['names'], 'type': 'gin'}
    ]
  )
}}

-- FHIR Patient resources following the DMPatient profile
-- Ready for loading into the FHIR Semantic Layer database

with source_patients as (
    select * from {{ ref('int_ehr__patient_fhir') }}
    {{ handle_late_arriving_data('last_updated') }}
),

fhir_patients as (
    select
        -- FHIR Patient resource structure
        patient_id as id,
        {{ add_fhir_versioning('patient_id') }},
        last_updated,
        
        -- Patient active status (default true)
        true as active,
        
        -- FHIR Identifiers
        identifiers,
        
        -- Extract INS-NIR identifier for indexing performance
        case 
            when identifiers is not null then
                (
                    select i->>'value'
                    from jsonb_array_elements(identifiers) as i
                    where i->>'system' = 'urn:oid:1.2.250.1.213.1.4.8'
                    limit 1
                )
            else null
        end as ins_nir_identifier,
        
        -- Extract NSS identifier for indexing (alternative identifier)
        case 
            when identifiers is not null then
                (
                    select i->>'value'
                    from jsonb_array_elements(identifiers) as i
                    where i->>'system' = 'https://hospital.eu/ehr/patient-id'
                    limit 1
                )
            else null
        end as nss_identifier,
        
        -- FHIR Names
        names,
        
        -- Extract family name for indexing performance
        case 
            when names is not null then
                (
                    select n->>'family'
                    from jsonb_array_elements(names) as n
                    limit 1
                )
            else null
        end as family_name,
        
        -- Extract given names for indexing performance
        case 
            when names is not null then
                (
                    select string_agg(given_name.value, ' ')
                    from jsonb_array_elements(names) as n,
                         jsonb_array_elements_text(n->'given') as given_name(value)
                    limit 1
                )
            else null
        end as given_names,
        
        -- FHIR Demographics
        gender,
        birth_date::date,
        
        -- FHIR Deceased information
        case 
            when deceased_date_time is not null then false
            else null
        end as deceased_boolean,
        deceased_date_time::timestamp with time zone,
        
        -- FHIR Multiple Birth
        case 
            when multiple_birth_integer is not null then false
            else null
        end as multiple_birth_boolean,
        multiple_birth_integer,
        
        -- FHIR Addresses
        addresses,
        
        -- FHIR Contact information (telecoms) - placeholder for future enhancement
        null::jsonb as telecoms,
        
        -- FHIR Extensions (geographic coordinates, etc.)
        extensions,
        
        -- FHIR Meta
        meta,
        
        -- Additional fields for optimization
        null as implicit_rules,
        'fr' as language,
        null as text_div,
        null::jsonb as contained,
        null::jsonb as modifier_extensions,
        
        -- French Core extensions - extracted for indexing
        null as birth_place,
        'FR' as nationality,
        
        -- Audit fields
        created_at,
        fhir_version,
        source_environment
        
    from source_patients
),

final as (
    select
        id,
        version_id,
        last_updated,
        active,
        identifiers,
        ins_nir_identifier,
        nss_identifier,
        names,
        family_name,
        given_names,
        gender,
        birth_date,
        deceased_boolean,
        deceased_date_time,
        multiple_birth_boolean,
        multiple_birth_integer,
        addresses,
        telecoms,
        extensions,
        birth_place,
        nationality,
        meta,
        implicit_rules,
        language,
        text_div,
        contained,
        modifier_extensions,
        created_at,
        fhir_version,
        source_environment
    from fhir_patients
    where id is not null
)

select * from final