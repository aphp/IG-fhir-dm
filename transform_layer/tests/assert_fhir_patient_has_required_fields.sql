-- Test to ensure FHIR Patient resources have required fields
-- according to FHIR R4 specification and DMPatient profile

select
    id,
    'Missing required field: id' as error_message
from {{ ref('fhir_patient') }}
where id is null

union all

select
    id,
    'Missing required field: active' as error_message  
from {{ ref('fhir_patient') }}
where active is null

union all

select
    id,
    'Missing required field: meta with profile' as error_message
from {{ ref('fhir_patient') }}
where meta is null
   or not (meta::jsonb ? 'profile')
   or not (meta->'profile' @> '["https://aphp.fr/ig/fhir/dm/StructureDefinition/DMPatient"]')

union all

select
    id,
    'Invalid gender value' as error_message
from {{ ref('fhir_patient') }}
where gender is not null
  and gender not in ('male', 'female', 'other', 'unknown')

union all

select
    id,
    'Birth date cannot be in the future' as error_message
from {{ ref('fhir_patient') }}
where birth_date > current_date