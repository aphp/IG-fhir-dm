-- Test to ensure FHIR Observation resources have at least one value
-- according to FHIR R4 specification

select
    id,
    observation_profile,
    'Observation must have at least one value or data absent reason' as error_message
from {{ ref('fhir_observation') }}
where status = 'final'
  and value_quantity is null
  and value_codeable_concept is null
  and value_string is null
  and value_boolean is null
  and value_integer is null
  and value_range is null
  and value_ratio is null
  and value_sampled_data is null
  and value_time is null
  and value_date_time is null
  and value_period is null
  and data_absent_reason is null

union all

select
    id,
    observation_profile,
    'Laboratory observations must have laboratory category' as error_message
from {{ ref('fhir_observation') }}
where observation_profile = 'laboratory'
  and (categories is null 
       or not (categories::text like '%"laboratory"%'))

union all

select
    id,
    observation_profile,
    'Vital sign observations must have vital-signs category' as error_message
from {{ ref('fhir_observation') }}
where observation_profile = 'vital-signs'
  and (categories is null 
       or not (categories::text like '%"vital-signs"%'))