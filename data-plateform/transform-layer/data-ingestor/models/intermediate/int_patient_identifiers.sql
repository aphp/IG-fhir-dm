{{
    config(
        materialized='table',
        tags=['intermediate', 'patient', 'identifiers']
    )
}}

-- Intermediate model to consolidate and validate patient identifiers
-- according to French healthcare standards (INS-NIR)
with patient_base as (
    select * from {{ ref('stg_ehr__patient') }}
),

identifier_processing as (
    select
        patient_id,
        fhir_patient_id,
        family_name,
        given_name,
        birth_date,
        gender,
        latitude,
        longitude,
        postal_code,
        city,
        extracted_at,
        
        -- French healthcare identifiers processing
        -- INS (Identifiant National de Santé) - primary identifier
        case 
            when has_ins and length(ins) > 0 then ins
            else null
        end as ins_nir_identifier,
        
        -- NIR (Numéro d'Inscription au Répertoire) - secondary identifier
        case 
            when has_nir and length(nir) > 0 then nir
            else null
        end as nss_identifier,
        
        -- Address components for FHIR
        case 
            when postal_code is not null and city is not null then
                jsonb_build_object(
                    'use', 'home',
                    'type', 'physical',
                    'city', city,
                    'postalCode', postal_code,
                    'country', 'FR'
                )
            else null
        end as fhir_address,
        
        -- Geographic position for FHIR
        case 
            when has_location then
                jsonb_build_object(
                    'longitude', longitude,
                    'latitude', latitude
                )
            else null
        end as fhir_position,
        
        -- Data quality scoring
        (
            case when has_ins then 3 else 0 end +
            case when has_nir then 2 else 0 end +
            case when family_name is not null then 1 else 0 end +
            case when given_name is not null then 1 else 0 end +
            case when birth_date is not null then 1 else 0 end +
            case when gender != 'unknown' then 1 else 0 end +
            case when has_location then 1 else 0 end
        ) as data_quality_score,
        
        -- FHIR meta information
        jsonb_build_object(
            'lastUpdated', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'source', 'ehr-system',
            'profile', array['https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DMPatient']
        ) as fhir_meta
        
    from patient_base
)

select 
    *,
    -- Final validation flags
    case when ins_nir_identifier is not null then true else false end as has_valid_identifier,
    case when data_quality_score >= 5 then 'high' 
         when data_quality_score >= 3 then 'medium' 
         else 'low' 
    end as data_quality_level
from identifier_processing