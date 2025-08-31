-- Test to ensure FHIR Encounter resources have valid patient references
-- and maintain referential integrity

select
    id,
    'Patient reference does not exist in fhir_patient table' as error_message
from {{ ref('fhir_encounter') }} e
left join {{ ref('fhir_patient') }} p on e.patient_id = p.id
where e.patient_id is not null
  and p.id is null

union all

select
    id,
    'Encounter period end cannot be before start' as error_message
from {{ ref('fhir_encounter') }}
where period_start is not null
  and period_end is not null
  and period_start > period_end

union all

select
    id,
    'Invalid encounter status' as error_message
from {{ ref('fhir_encounter') }}
where status not in (
    'planned', 'arrived', 'triaged', 'in-progress', 
    'onleave', 'finished', 'cancelled', 'entered-in-error', 'unknown'
)