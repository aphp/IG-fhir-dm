{{
    config(
        materialized='table',
        unique_key='id',
        tags=['mart', 'fhir', 'medication']
    )
}}

-- FHIR MedicationRequest resource mart table
-- Compliant with FHIR R4 MedicationRequest resource structure
with medication_base as (
    select * from {{ ref('stg_ehr__exposition_medicamenteuse') }}
    where has_valid_atc_code = true
),

encounter_ref as (
    select 
        pmsi_id,
        fhir_encounter_id,
        fhir_patient_id,
        is_valid_encounter
    from {{ ref('int_encounter_episodes') }}
),

medication_data as (
    select
        m.*,
        e.fhir_encounter_id as encounter_encounter_fhir_encounter_id,
        e.fhir_patient_id as encounter_fhir_patient_id,
        e.is_valid_encounter
    from medication_base m
    left join encounter_ref e on m.pmsi_id = e.pmsi_id
    where m.fhir_patient_id is not null  -- Include both encounter and non-encounter medications
),

fhir_medication_request as (
    select
        -- FHIR Resource metadata
        fhir_medication_request_id as id,
        'MedicationRequest' as resourceType,
        jsonb_build_object(
            'versionId', '1',
            'lastUpdated', to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
            'source', 'pmsi-system',
            'profile', array['http://interopsante.org/fhir/StructureDefinition/FrMedicationRequest']
        ) as meta,
        
        -- MedicationRequest identifiers
        jsonb_build_array(
            jsonb_build_object(
                'use', 'official',
                'system', 'http://aphp.fr/fhir/NamingSystem/medication-request-id',
                'value', exposition_id::text
            )
        ) as identifier,
        
        -- Status
        medication_request_status as status,
        
        -- Status reason (if not active)
        case
            when medication_request_status != 'active' then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://terminology.hl7.org/CodeSystem/medicationrequest-status-reason',
                            'code', 'clarif',
                            'display', 'Prescription requires clarification'
                        )
                    )
                )
            else null
        end as statusReason,
        
        -- Intent
        medication_request_intent as intent,
        
        -- Category (inpatient vs outpatient based on encounter)
        jsonb_build_array(
            jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'http://terminology.hl7.org/CodeSystem/medicationrequest-category',
                        'code', case when encounter_encounter_fhir_encounter_id is not null then 'inpatient' else 'outpatient' end,
                        'display', case when encounter_encounter_fhir_encounter_id is not null then 'Inpatient' else 'Outpatient' end
                    )
                )
            )
        ) as category,
        
        -- Priority (based on encounter context)
        case
            when encounter_encounter_fhir_encounter_id is not null then 'routine'
            else 'routine'
        end as priority,
        
        -- Do not perform (always false for valid prescriptions)
        false as doNotPerform,
        
        -- Reported (assuming all are reported by healthcare providers)
        false as reportedBoolean,
        
        -- Medication (using ATC code and name)
        jsonb_build_object(
            'concept', jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'http://www.whocc.no/atc',
                        'code', atc_code,
                        'display', medication_name
                    )
                ),
                'text', medication_name
            )
        ) as medication,
        
        -- Patient reference
        jsonb_build_object(
            'reference', 'Patient/' || fhir_patient_id,
            'display', 'Patient ' || fhir_patient_id
        ) as subject,
        
        -- Subject ID for relationships
        fhir_patient_id as subject_id,
        
        -- Informational source (who provided the information)
        case
            when encounter_encounter_fhir_encounter_id is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'Practitioner/prescribing-physician',
                        'display', 'Prescribing Physician'
                    )
                )
            else
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'Patient/' || fhir_patient_id,
                        'display', 'Patient reported'
                    )
                )
        end as informationSource,
        
        -- Encounter reference (if applicable)
        case
            when encounter_encounter_fhir_encounter_id is not null then
                jsonb_build_object(
                    'reference', 'Encounter/' || encounter_encounter_fhir_encounter_id,
                    'display', 'Encounter ' || encounter_encounter_fhir_encounter_id
                )
            else null
        end as encounter,
        
        -- Encounter ID for relationships
        encounter_encounter_fhir_encounter_id as encounter_id,
        
        -- Supporting information (could reference conditions)
        case
            when encounter_encounter_fhir_encounter_id is not null then
                jsonb_build_array(
                    jsonb_build_object(
                        'reference', 'Condition/related-condition',
                        'display', 'Related condition'
                    )
                )
            else null
        end as supportingInformation,
        
        -- Authored on (prescription date)
        case
            when prescription_date is not null then
                to_char(prescription_date, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
            else
                to_char(current_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
        end as authoredOn,
        
        -- Requester (prescribing physician)
        jsonb_build_object(
            'reference', 'Practitioner/prescriber-' || exposition_id,
            'display', 'Prescribing Physician'
        ) as requester,
        
        -- Performer (who will administer/dispense)
        case
            when encounter_encounter_fhir_encounter_id is not null then
                jsonb_build_object(
                    'reference', 'PractitionerRole/nurse',
                    'display', 'Nursing Staff'
                )
            else
                jsonb_build_object(
                    'reference', 'Organization/pharmacy',
                    'display', 'Hospital Pharmacy'
                )
        end as performer,
        
        -- Performer type
        case
            when encounter_encounter_fhir_encounter_id is not null then
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '106292003',
                            'display', 'Professional nurse'
                        )
                    )
                )
            else
                jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '46255001',
                            'display', 'Pharmacist'
                        )
                    )
                )
        end as performerType,
        
        -- Recorder (who recorded the prescription)
        jsonb_build_object(
            'reference', 'Practitioner/prescriber-' || exposition_id,
            'display', 'Prescribing Physician'
        ) as recorder,
        
        -- Reason code (therapeutic category from ATC)
        jsonb_build_array(
            jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'http://www.whocc.no/atc',
                        'code', substring(atc_code, 1, 1),
                        'display', atc_therapeutic_category_fr
                    )
                ),
                'text', atc_therapeutic_category_fr
            )
        ) as reasonCode,
        
        -- Course of therapy type (based on medication category)
        jsonb_build_object(
            'coding', jsonb_build_array(
                jsonb_build_object(
                    'system', 'http://terminology.hl7.org/CodeSystem/medicationrequest-course-of-therapy',
                    'code', case
                        when atc_therapeutic_category_fr like '%Anti-infectieux%' then 'acute'
                        when atc_therapeutic_category_fr like '%Système cardiovasculaire%' then 'continuous'
                        when atc_therapeutic_category_fr like '%Système nerveux%' then 'continuous'
                        else 'acute'
                    end,
                    'display', case
                        when atc_therapeutic_category_fr like '%Anti-infectieux%' then 'Short course (acute) therapy'
                        when atc_therapeutic_category_fr like '%Système cardiovasculaire%' then 'Continuous long term therapy'
                        when atc_therapeutic_category_fr like '%Système nerveux%' then 'Continuous long term therapy'
                        else 'Short course (acute) therapy'
                    end
                )
            )
        ) as courseOfTherapyType,
        
        -- Dosage instruction (basic implementation - would need more detailed dosage data)
        jsonb_build_array(
            jsonb_build_object(
                'text', 'Administrer selon prescription médicale',
                'timing', jsonb_build_object(
                    'repeat', jsonb_build_object(
                        'frequency', 1,
                        'period', 1,
                        'periodUnit', 'd'
                    )
                ),
                'route', jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', route_snomed_code,
                            'display', route_display_fr
                        )
                    )
                ),
                'method', jsonb_build_object(
                    'coding', jsonb_build_array(
                        jsonb_build_object(
                            'system', 'http://snomed.info/sct',
                            'code', '738995006',
                            'display', 'Swallow - dosing instruction imperative'
                        )
                    )
                )
            )
        ) as dosageInstruction,
        
        -- Dispense request (for outpatient prescriptions)
        case
            when encounter_encounter_fhir_encounter_id is null then
                jsonb_build_object(
                    'validityPeriod', jsonb_build_object(
                        'start', to_char(prescription_date, 'YYYY-MM-DD'),
                        'end', to_char(prescription_date + interval '30 days', 'YYYY-MM-DD')
                    ),
                    'numberOfRepeatsAllowed', 0,
                    'quantity', jsonb_build_object(
                        'value', 30,
                        'unit', 'dose',
                        'system', 'http://terminology.hl7.org/CodeSystem/v3-orderableDrugForm',
                        'code', 'DOSE'
                    ),
                    'expectedSupplyDuration', jsonb_build_object(
                        'value', 30,
                        'unit', 'days',
                        'system', 'http://unitsofmeasure.org',
                        'code', 'd'
                    ),
                    'performer', jsonb_build_object(
                        'reference', 'Organization/hospital-pharmacy',
                        'display', 'Hospital Pharmacy'
                    )
                )
            else null
        end as dispenseRequest,
        
        -- Substitution (allow generic substitution)
        jsonb_build_object(
            'allowedBoolean', true,
            'reason', jsonb_build_object(
                'coding', jsonb_build_array(
                    jsonb_build_object(
                        'system', 'http://terminology.hl7.org/CodeSystem/v3-ActReason',
                        'code', 'FP',
                        'display', 'formulary policy'
                    )
                )
            )
        ) as substitution,
        
        -- Prior prescription (if this is a renewal - would need additional data)
        case
            when medication_request_status = 'active' then
                jsonb_build_object(
                    'reference', 'MedicationRequest/prior-' || exposition_id,
                    'display', 'Prior prescription'
                )
            else null
        end as priorPrescription,
        
        -- Detection issue (for drug interactions - would need additional logic)
        case
            when atc_code in ('N02AA01', 'N02AA05') then  -- Example: opioid interactions
                jsonb_build_array(
                    jsonb_build_object(
                        'severity', jsonb_build_object(
                            'coding', jsonb_build_array(
                                jsonb_build_object(
                                    'system', 'http://terminology.hl7.org/CodeSystem/detectedissue-severity',
                                    'code', 'moderate',
                                    'display', 'Moderate'
                                )
                            )
                        ),
                        'code', jsonb_build_object(
                            'coding', jsonb_build_array(
                                jsonb_build_object(
                                    'system', 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
                                    'code', 'DRG',
                                    'display', 'Drug interaction'
                                )
                            )
                        )
                    )
                )
            else null
        end as detectedIssue,
        
        -- Event history (prescriptions events)
        jsonb_build_array(
            jsonb_build_object(
                'reference', 'Provenance/prescription-' || exposition_id,
                'display', 'Prescription creation'
            )
        ) as eventHistory,
        
        -- Audit and source fields
        atc_code,
        medication_name,
        route_of_administration,
        route_display_fr,
        atc_therapeutic_category_fr,
        prescription_date,
        extracted_at,
        current_timestamp as last_updated,
        
        -- Source identifiers for traceability
        exposition_id as source_exposition_id,
        pmsi_id as source_pmsi_id
        
    from medication_data
)

select 
    -- FHIR Resource structure
    id,
    resourceType,
    meta,
    identifier,
    status,
    statusReason,
    intent,
    category,
    priority,
    doNotPerform,
    reportedBoolean,
    medication,
    subject,
    subject_id,
    informationSource,
    encounter,
    encounter_id,
    supportingInformation,
    authoredOn,
    requester,
    performer,
    performerType,
    recorder,
    reasonCode,
    courseOfTherapyType,
    dosageInstruction,
    dispenseRequest,
    substitution,
    priorPrescription,
    detectedIssue,
    eventHistory,
    
    -- Audit and source fields
    atc_code,
    medication_name,
    route_of_administration,
    route_display_fr,
    atc_therapeutic_category_fr,
    prescription_date,
    source_exposition_id,
    source_pmsi_id,
    extracted_at,
    last_updated
    
from fhir_medication_request