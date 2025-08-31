{{
    config(
        materialized='table',
        tags=['intermediate', 'encounter', 'episodes']
    )
}}

-- Intermediate model to process hospital encounters and episodes of care
-- with French PMSI-specific transformations
with encounter_base as (
    select * from {{ ref('stg_ehr__donnees_pmsi') }}
),

patient_ref as (
    select 
        patient_id,
        fhir_patient_id,
        has_valid_identifier
    from {{ ref('int_patient_identifiers') }}
),

encounter_processing as (
    select
        e.pmsi_id,
        e.patient_id,
        e.fhir_encounter_id,
        p.fhir_patient_id,
        e.discharge_disposition,
        e.length_of_stay_days,
        e.admission_datetime,
        e.discharge_datetime,
        e.admission_type,
        e.facility_name,
        e.service_department,
        e.encounter_status,
        e.encounter_class,
        e.extracted_at,
        p.has_valid_identifier as patient_has_valid_id,
        
        -- Period calculation for FHIR
        jsonb_build_object(
            'start', to_char(e.admission_datetime, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'end', case 
                when e.discharge_datetime is not null 
                then to_char(e.discharge_datetime, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                else null 
            end
        ) as fhir_period,
        
        -- Hospitalization details for FHIR
        jsonb_build_object(
            'admitSource', jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'https://www.atih.sante.fr/sites/default/files/public/content/2665/mco_2019_cmd_fiche_technique.pdf',
                        'code', case 
                            when lower(e.admission_type) like '%urgence%' then '8'
                            when lower(e.admission_type) like '%programme%' then '6'
                            when lower(e.admission_type) like '%mutation%' then '7'
                            else '8'  -- Default to emergency
                        end,
                        'display', e.admission_type
                    )
                )
            ),
            'dischargeDisposition', jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'https://www.atih.sante.fr/sites/default/files/public/content/2665/mco_2019_cmd_fiche_technique.pdf',
                        'code', case 
                            when lower(e.discharge_disposition) like '%domicile%' then '6'
                            when lower(e.discharge_disposition) like '%transfert%' then '2'
                            when lower(e.discharge_disposition) like '%deces%' then '9'
                            else '6'  -- Default to home
                        end,
                        'display', e.discharge_disposition
                    )
                )
            )
        ) as fhir_hospitalization,
        
        -- Location hierarchy for FHIR
        jsonb_build_array(
            jsonb_build_object(
                'location', jsonb_build_object(
                    'reference', 'Location/' || '{{ var("default_facility_id") }}',
                    'display', e.facility_name
                ),
                'status', 'active'
            ),
            case 
                when e.service_department is not null then
                    jsonb_build_object(
                        'location', jsonb_build_object(
                            'reference', 'Location/' || lower(replace(e.service_department, ' ', '-')),
                            'display', e.service_department
                        ),
                        'status', 'active'
                    )
                else null
            end
        ) as fhir_location,
        
        -- Service type mapping for FHIR
        case
            when lower(e.service_department) like '%cardiologie%' then '394579002'
            when lower(e.service_department) like '%pneumologie%' then '418112009'
            when lower(e.service_department) like '%gastroenterologie%' then '394584008'
            when lower(e.service_department) like '%neurologie%' then '394591006'
            when lower(e.service_department) like '%orthopédie%' then '394583002'
            when lower(e.service_department) like '%urgence%' then '773568002'
            else '408478003'  -- Critical care medicine
        end as service_type_snomed,
        
        -- Priority mapping
        case
            when e.encounter_class = 'EMER' then 'urgent'
            when lower(e.admission_type) like '%urgence%' then 'urgent' 
            else 'routine'
        end as encounter_priority,
        
        -- FHIR meta information
        jsonb_build_object(
            'versionId', '1',
            'lastUpdated', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'source', 'pmsi-system',
            'profile', array['http://interopsante.org/fhir/StructureDefinition/FrEncounter']
        ) as fhir_meta,
        
        -- Data quality flags
        case when e.admission_datetime is not null then true else false end as has_valid_period,
        case when e.length_of_stay_days > 0 then true else false end as has_valid_los,
        case when e.service_department is not null then true else false end as has_service_info
        
    from encounter_base e
    left join patient_ref p on e.patient_id = p.patient_id
    where p.fhir_patient_id is not null  -- Only include encounters for valid patients
)

select 
    *,
    -- Final validation
    case when has_valid_period and patient_has_valid_id then true else false end as is_valid_encounter
from encounter_processing