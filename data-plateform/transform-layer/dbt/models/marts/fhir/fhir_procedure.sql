{{
    config(
        materialized='table',
        unique_key='id',
        tags=['mart', 'fhir', 'procedure']
    )
}}

-- FHIR Procedure resource mart table
-- Compliant with FHIR R4 Procedure resource structure
with procedure_base as (
    select * from {{ ref('stg_ehr__actes') }}
    where has_valid_ccam_code = true
),

encounter_ref as (
    select 
        pmsi_id,
        fhir_patient_id,
        fhir_encounter_id,
        is_valid_encounter
    from {{ ref('int_encounter_episodes') }}
),

procedure_data as (
    select
        p.*,
        e.fhir_patient_id as patient_fhir_patient_id,
        e.fhir_encounter_id as encounter_fhir_encounter_id,
        e.is_valid_encounter
    from procedure_base p
    left join encounter_ref e on p.pmsi_id = e.pmsi_id
    where e.is_valid_encounter = true
),

fhir_procedure as (
    select
        -- FHIR Resource metadata
        fhir_procedure_id as id,
        'Procedure' as resourceType,
        jsonb_build_object(
            'versionId', '1',
            'lastUpdated', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'source', 'pmsi-system',
            'profile', array['http://interopsante.org/fhir/StructureDefinition/FrProcedure']
        ) as meta,
        
        -- Procedure identifiers
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'system', 'http://aphp.fr/fhir/NamingSystem/procedure-id',
                'value', acte_id::text
            )
        ) as identifier,
        
        -- Instance URI (optional)
        'http://aphp.fr/fhir/Procedure/' || fhir_procedure_id as instantiatesUri,
        
        -- Based on (optional - could reference protocols)
        case
            when procedure_category = 'surgical' then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'PlanDefinition/surgical-protocol',
                        'display', 'Surgical Procedure Protocol'
                    )
                )
            else null
        end as basedOn,
        
        -- Part of (if this is a sub-procedure)
        case
            when length(ccam_code) > 7 then  -- Extended CCAM codes might indicate sub-procedures
                jsonb_build_object(
                    'reference', 'Procedure/main-' || substring(ccam_code, 1, 7),
                    'display', 'Main procedure'
                )
            else null
        end as partOf,
        
        -- Procedure status
        procedure_status as status,
        
        -- Status reason (if not completed)
        case
            when procedure_status != 'completed' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '182840001',
                            'display', 'Drug treatment unknown'
                        )
                    )
                )
            else null
        end as statusReason,
        
        -- Category
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://snomed.info/sct',
                    'code', case procedure_category
                        when 'surgical' then '387713003'  -- Surgical procedure
                        when 'therapeutic' then '277132007'  -- Therapeutic procedure
                        when 'diagnostic' then '103693007'  -- Diagnostic procedure
                        else '71388002'  -- Procedure
                    end,
                    'display', case procedure_category
                        when 'surgical' then 'Surgical procedure'
                        when 'therapeutic' then 'Therapeutic procedure'
                        when 'diagnostic' then 'Diagnostic procedure'
                        else 'Procedure'
                    end
                )
            )
        ) as category,
        
        -- Procedure code (CCAM)
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'https://www.atih.sante.fr/plateformes-de-transmission-et-logiciels/logiciels-espace-de-telechargement/id_lot/456',
                    'code', ccam_code,
                    'display', procedure_label_fr
                )
            ),
            'text', procedure_label_fr
        ) as code,
        
        -- Patient reference
        jsonb_build_object(
            'reference', 'Patient/' || patient_fhir_patient_id,
            'display', 'Patient ' || patient_fhir_patient_id
        ) as subject,
        
        -- Subject ID for relationships
        patient_fhir_patient_id as subject_id,
        
        -- Encounter reference
        jsonb_build_object(
            'reference', 'Encounter/' || encounter_fhir_encounter_id,
            'display', 'Encounter ' || encounter_fhir_encounter_id
        ) as encounter,
        
        -- Encounter ID for relationships
        encounter_fhir_encounter_id as encounter_id,
        
        -- Performed date/time
        case
            when procedure_date is not null then
                jsonb_build_object(
                    'performedDateTime', to_char(procedure_date, 'YYYY-MM-DD')
                )
            else null
        end as performed,
        
        -- Recorder (who recorded this procedure)
        jsonb_build_object(
            'reference', 'Practitioner/pmsi-recorder',
            'display', 'PMSI Recorder'
        ) as recorder,
        
        -- Asserter (who asserted this procedure was performed)
        jsonb_build_object(
            'reference', 'Practitioner/performing-physician',
            'display', 'Performing Physician'
        ) as asserter,
        
        -- Performer (who performed the procedure)
        jsonb_build_array(
            jsonb_build_object(
                'function', jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', case procedure_category
                                when 'surgical' then '304292004'  -- Surgeon
                                when 'diagnostic' then '56545009'  -- Radiologist
                                else '158965000'  -- Medical practitioner
                            end,
                            'display', case procedure_category
                                when 'surgical' then 'Surgeon'
                                when 'diagnostic' then 'Radiologist'
                                else 'Medical practitioner'
                            end
                        )
                    )
                ),
                'actor', jsonb_build_object(
                    'reference', 'Practitioner/performer-' || acte_id,
                    'display', 'Procedure Performer'
                )
            )
        ) as performer,
        
        -- Location where performed
        jsonb_build_object(
            'reference', 'Location/' || '{{ var("default_facility_id") }}',
            'display', 'Hospital Facility'
        ) as location,
        
        -- Reason code (could be linked to conditions)
        case
            when procedure_category = 'diagnostic' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '103693007',
                                'display', 'Diagnostic procedure'
                            )
                        )
                    )
                )
            when procedure_category = 'therapeutic' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '277132007',
                                'display', 'Therapeutic procedure'
                            )
                        )
                    )
                )
            else null
        end as reasonCode,
        
        -- Body site (based on CCAM code structure)
        case
            when ccam_code ~ '^H[A-Z][A-Z][A-Z]' then  -- Surgery codes starting with H
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '38266002',
                                'display', 'Entire body as a whole'
                            )
                        )
                    )
                )
            else null
        end as bodySite,
        
        -- Outcome (assuming successful if recorded as completed)
        case
            when procedure_status = 'completed' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '385669000',
                            'display', 'Successful'
                        )
                    )
                )
            else null
        end as outcome,
        
        -- Report (could reference diagnostic reports)
        case
            when procedure_category = 'diagnostic' then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'DiagnosticReport/report-' || acte_id,
                        'display', 'Diagnostic Report'
                    )
                )
            else null
        end as report,
        
        -- Complication (basic implementation - would need additional data)
        case
            when procedure_status = 'stopped' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '116223007',
                                'display', 'Complication'
                            )
                        )
                    )
                )
            else null
        end as complication,
        
        -- Follow up (basic implementation)
        case
            when procedure_category = 'surgical' then
                jsonb_build_array(
                    jsonb_build_object(
                        'coding', jsonb_build_array(
                            jsonb_build_object(
                                'system', 'http://snomed.info/sct',
                                'code', '18949003',
                                'display', 'Change of dressing'
                            )
                        )
                    )
                )
            else null
        end as followUp,
        
        -- Note (additional information)
        case
            when procedure_label_fr != ccam_code then
                jsonb_build_array(
                    jsonb_build_object(
                        'text', 'Procédure: ' || procedure_label_fr || ' (Code CCAM: ' || ccam_code || ')',
                        'time', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                    )
                )
            else null
        end as note,
        
        -- Focal device (for implant procedures - would need additional data)
        case
            when lower(procedure_label_fr) like '%implant%' or lower(procedure_label_fr) like '%prothèse%' then
                jsonb_build_array(
                    jsonb_build_object(
                        'action', jsonb_build_object(
                            'coding', jsonb_build_array(
                                jsonb_build_object(
                                    'system', 'http://snomed.info/sct',
                                    'code', '129304002',
                                    'display', 'Implantation - action'
                                )
                            )
                        ),
                        'manipulated', jsonb_build_object(
                            'reference', 'Device/device-' || acte_id,
                            'display', 'Implanted device'
                        )
                    )
                )
            else null
        end as focalDevice,
        
        -- Used reference (equipment or medications used)
        case
            when procedure_category = 'surgical' then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'Device/surgical-equipment',
                        'display', 'Surgical equipment'
                    )
                )
            else null
        end as usedReference,
        
        -- Audit and source fields
        ccam_code,
        procedure_label_fr,
        procedure_category,
        procedure_date,
        extracted_at,
        current_timestamp as last_updated,
        
        -- Source identifiers for traceability
        acte_id as source_acte_id,
        pmsi_id as source_pmsi_id
        
    from procedure_data
)

select 
    -- FHIR Resource structure
    id,
    resourceType,
    meta,
    identifier,
    instantiatesUri,
    basedOn,
    partOf,
    status,
    statusReason,
    category,
    code,
    subject,
    subject_id,
    encounter,
    encounter_id,
    performed,
    recorder,
    asserter,
    performer,
    location,
    reasonCode,
    bodySite,
    outcome,
    report,
    complication,
    followUp,
    note,
    focalDevice,
    usedReference,
    
    -- Audit and source fields
    ccam_code,
    procedure_label_fr,
    procedure_category,
    procedure_date,
    source_acte_id,
    source_pmsi_id,
    extracted_at,
    last_updated
    
from fhir_procedure