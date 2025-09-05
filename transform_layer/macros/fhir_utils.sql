-- Macros for FHIR utility functions and transformations

-- Generate FHIR-compliant ID from source ID
{% macro generate_fhir_id(source_id, resource_type='') %}
  case 
    when {{ source_id }} is not null then
      {% if resource_type %}
        '{{ resource_type }}-' || 
      {% endif %}
      replace(
        replace(
          replace({{ source_id }}::text, ' ', '-'), 
          '/', '-'
        ), 
        '_', '-'
      )
    else null
  end
{% endmacro %}

-- Create FHIR Reference object
{% macro create_fhir_reference(reference_value, display_value=none) %}
  jsonb_build_object(
    'reference', {{ reference_value }}
    {% if display_value %}
    , 'display', {{ display_value }}
    {% endif %}
  )
{% endmacro %}

-- Create FHIR Identifier object
{% macro create_fhir_identifier(system, value, use='official', type_code=none, type_display=none) %}
  jsonb_build_object(
    'use', '{{ use }}',
    'system', {{ system }},
    'value', {{ value }}
    {% if type_code %}
    , 'type', jsonb_build_object(
        'coding', jsonb_build_array(
          jsonb_build_object(
            'code', '{{ type_code }}'
            {% if type_display %}
            , 'display', '{{ type_display }}'
            {% endif %}
          )
        )
      )
    {% endif %}
  )
{% endmacro %}

-- Create FHIR CodeableConcept
{% macro create_fhir_codeable_concept(code, system, display=none, text=none) %}
  jsonb_build_object(
    'coding', jsonb_build_array(
      jsonb_build_object(
        'system', {{ system }},
        'code', {{ code }}
        {% if display %}
        , 'display', {{ display }}
        {% endif %}
      )
    )
    {% if text %}
    , 'text', {{ text }}
    {% endif %}
  )
{% endmacro %}

-- Create FHIR Coding
{% macro create_fhir_coding(code, system, display=none, version=none) %}
  jsonb_build_object(
    'system', {{ system }},
    'code', {{ code }}
    {% if version %}
    , 'version', {{ version }}
    {% endif %}
    {% if display %}
    , 'display', {{ display }}
    {% endif %}
  )
{% endmacro %}

-- Create FHIR Quantity
{% macro create_fhir_quantity(value, unit, system='http://unitsofmeasure.org', code=none) %}
  jsonb_build_object(
    'value', {{ value }},
    'unit', {{ unit }},
    'system', '{{ system }}'
    {% if code %}
    , 'code', {{ code }}
    {% else %}
    , 'code', {{ unit }}
    {% endif %}
  )
{% endmacro %}

-- Create FHIR Period
{% macro create_fhir_period(start_date, end_date) %}
  jsonb_build_object(
    {% if start_date %}
    'start', {{ start_date }}::text
    {% endif %}
    {% if start_date and end_date %}
    ,
    {% endif %}
    {% if end_date %}
    'end', {{ end_date }}::text
    {% endif %}
  )
{% endmacro %}

-- Create FHIR HumanName
{% macro create_fhir_human_name(family, given, use='official', prefix=none, suffix=none) %}
  jsonb_build_object(
    'use', '{{ use }}'
    {% if family %}
    , 'family', {{ family }}
    {% endif %}
    {% if given %}
    , 'given', jsonb_build_array({{ given }})
    {% endif %}
    {% if prefix %}
    , 'prefix', jsonb_build_array({{ prefix }})
    {% endif %}
    {% if suffix %}
    , 'suffix', jsonb_build_array({{ suffix }})
    {% endif %}
  )
{% endmacro %}

-- Create FHIR Address
{% macro create_fhir_address(line=none, city=none, postal_code=none, country='FR', use='home') %}
  jsonb_build_object(
    'use', '{{ use }}'
    {% if line %}
    , 'line', jsonb_build_array({{ line }})
    {% endif %}
    {% if city %}
    , 'city', {{ city }}
    {% endif %}
    {% if postal_code %}
    , 'postalCode', {{ postal_code }}
    {% endif %}
    , 'country', '{{ country }}'
  )
{% endmacro %}

-- Create FHIR Meta object with profile
{% macro create_fhir_meta(profile, version_id=none, last_updated=none, tag=none) %}
  jsonb_build_object(
    'profile', jsonb_build_array('{{ profile }}')
    {% if version_id %}
    , 'versionId', {{ version_id }}
    {% endif %}
    {% if last_updated %}
    , 'lastUpdated', {{ last_updated }}::timestamp with time zone
    {% endif %}
    {% if tag %}
    , 'tag', jsonb_build_array({{ tag }})
    {% endif %}
  )
{% endmacro %}

-- Convert date to FHIR date format
{% macro to_fhir_date(date_column) %}
  case 
    when {{ date_column }} is not null 
    then to_char({{ date_column }}, 'YYYY-MM-DD')
    else null
  end
{% endmacro %}

-- Convert datetime to FHIR datetime format  
{% macro to_fhir_datetime(datetime_column, timezone='UTC') %}
  case 
    when {{ datetime_column }} is not null 
    then to_char({{ datetime_column }} at time zone '{{ timezone }}', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    else null
  end
{% endmacro %}

-- Convert instant to FHIR instant format
{% macro to_fhir_instant(instant_column, timezone='UTC') %}
  case 
    when {{ instant_column }} is not null 
    then to_char({{ instant_column }} at time zone '{{ timezone }}', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
    else null
  end
{% endmacro %}

-- Validate and clean FHIR ID
{% macro validate_fhir_id(id_column, max_length=64) %}
  case 
    when {{ id_column }} is not null 
      and length({{ id_column }}::text) <= {{ max_length }}
      and {{ id_column }}::text ~ '^[A-Za-z0-9\-\.]{1,{{ max_length }}}$'
    then {{ id_column }}::text
    else null
  end
{% endmacro %}

-- Create FHIR Extension
{% macro create_fhir_extension(url, value_type, value) %}
  jsonb_build_object(
    'url', '{{ url }}',
    '{{ value_type }}', {{ value }}
  )
{% endmacro %}

-- Create FHIR ContactPoint (telecom)
{% macro create_fhir_contact_point(system, value, use=none, rank=none) %}
  jsonb_build_object(
    'system', '{{ system }}',
    'value', {{ value }}
    {% if use %}
    , 'use', '{{ use }}'
    {% endif %}
    {% if rank %}
    , 'rank', {{ rank }}
    {% endif %}
  )
{% endmacro %}

-- Create FHIR Annotation (note)
{% macro create_fhir_annotation(text, author_string=none, time=none) %}
  jsonb_build_object(
    'text', {{ text }}
    {% if author_string %}
    , 'authorString', {{ author_string }}
    {% endif %}
    {% if time %}
    , 'time', {{ time }}
    {% endif %}
  )
{% endmacro %}

-- Macro to update last_updated field for incremental models
{% macro update_last_modified() %}
  {% if this %}
    update {{ this }}
    set last_updated = current_timestamp
    where id in (
      select id from ({{ sql }}) as new_data
    )
  {% endif %}
{% endmacro %}