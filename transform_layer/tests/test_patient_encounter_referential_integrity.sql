-- Test to verify all encounters reference valid patients
-- This test should return zero rows if all encounters have valid patient references

select
    encounter_id,
    patient_reference,
    'Missing patient reference' as issue
from (
    select 
        id as encounter_id,
        (subject->>'reference') as patient_reference
    from {{ ref('fhir_encounter') }}
) encounters
left join (
    select 
        'Patient/' || id as patient_ref_id
    from {{ ref('fhir_patient') }}
) patients on encounters.patient_reference = patients.patient_ref_id
where patients.patient_ref_id is null