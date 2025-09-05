-- Macros for incremental loading utilities

-- Get incremental filter for updated_at based models
{% macro get_incremental_filter(updated_at_column='updated_at', lookback_days=none) %}
  {% if is_incremental() %}
    {% set lookback = lookback_days or var('incremental_lookback_days', 7) %}
    
    where {{ updated_at_column }} >= (
      select coalesce(
        max({{ updated_at_column }}) - interval '{{ lookback }} days',
        '1900-01-01'::timestamp
      )
      from {{ this }}
    )
  {% endif %}
{% endmacro %}

-- Get incremental filter for date-based partitioned models
{% macro get_date_incremental_filter(date_column, lookback_days=none) %}
  {% if is_incremental() %}
    {% set lookback = lookback_days or var('incremental_lookback_days', 7) %}
    
    where {{ date_column }} >= (
      select coalesce(
        max({{ date_column }}) - interval '{{ lookback }} days',
        '1900-01-01'::date
      )
      from {{ this }}
    )
  {% endif %}
{% endmacro %}

-- Macro for handling late-arriving data in incremental models
{% macro handle_late_arriving_data(updated_at_column='updated_at', date_column=none, lookback_days=none) %}
  {% if is_incremental() %}
    {% set lookback = lookback_days or var('incremental_lookback_days', 7) %}
    
    where {{ updated_at_column }} >= (
      select coalesce(
        max({{ updated_at_column }}) - interval '{{ lookback }} days',
        '1900-01-01'::timestamp
      )
      from {{ this }}
    )
    
    {% if date_column %}
    or {{ date_column }} >= (
      select coalesce(
        max({{ date_column }}) - interval '{{ lookback }} days',
        '1900-01-01'::date  
      )
      from {{ this }}
    )
    {% endif %}
  {% endif %}
{% endmacro %}

-- Generate merge statement for incremental FHIR resources
{% macro fhir_incremental_merge(unique_key, updated_at_column='last_updated') %}
  {% if is_incremental() %}
    -- Delete existing records that will be updated
    delete from {{ this }}
    where {{ unique_key }} in (
      select {{ unique_key }} from ({{ sql }}) as new_data
    );
  {% endif %}
{% endmacro %}

-- Macro for incremental strategy on FHIR resources with proper deduplication
{% macro fhir_incremental_strategy() %}
  {% if is_incremental() %}
    {{
      config(
        incremental_strategy='delete+insert',
        on_schema_change='sync_all_columns'
      )
    }}
  {% endif %}
{% endmacro %}

-- Helper macro to get max updated timestamp from target table
{% macro get_max_updated_at(table, column='last_updated') %}
  {% set query %}
    select max({{ column }})
    from {{ table }}
  {% endset %}
  
  {% if execute %}
    {% set results = run_query(query) %}
    {% if results.rows %}
      {{ return(results.rows[0][0]) }}
    {% else %}
      {{ return('1900-01-01') }}
    {% endif %}
  {% else %}
    {{ return('1900-01-01') }}
  {% endif %}
{% endmacro %}

-- Macro to create audit columns for FHIR resources
{% macro add_fhir_audit_columns() %}
  {{ current_timestamp() }} as created_at,
  {{ current_timestamp() }} as last_updated,
  '{{ var("fhir_version", "4.0.1") }}' as fhir_version,
  '{{ target.name }}' as source_environment
{% endmacro %}

-- Macro to add FHIR resource versioning
{% macro add_fhir_versioning(resource_id_column) %}
  concat(
    {{ resource_id_column }}, 
    '-v', 
    row_number() over (
      partition by {{ resource_id_column }} 
      order by last_updated desc
    )
  ) as version_id
{% endmacro %}