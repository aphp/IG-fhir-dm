-- Test to verify FHIR resource IDs are unique across all resource types
-- This test should return zero rows if all IDs are unique

with all_fhir_ids as (
    select id, resourceType from {{ ref('fhir_patient') }}
    union all
    select id, resourceType from {{ ref('fhir_encounter') }}
    union all
    select id, resourceType from {{ ref('fhir_condition') }}
    union all
    select id, resourceType from {{ ref('fhir_observation') }}
    union all
    select id, resourceType from {{ ref('fhir_procedure') }}
    union all
    select id, resourceType from {{ ref('fhir_medication_request') }}
),

duplicate_ids as (
    select
        id,
        count(*) as id_count,
        string_agg(resourceType, ', ') as resource_types
    from all_fhir_ids
    group by id
    having count(*) > 1
)

select
    id,
    id_count,
    resource_types,
    'Duplicate FHIR resource ID across multiple resource types' as issue
from duplicate_ids