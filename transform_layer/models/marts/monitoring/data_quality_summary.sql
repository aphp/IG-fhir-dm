{{
    config(
        materialized='table',
        tags=['monitoring', 'data-quality']
    )
}}

-- Data quality summary across all FHIR resources
-- Provides comprehensive metrics for monitoring data pipeline health
with patient_quality as (
    select
        'Patient' as resource_type,
        count(*) as total_records,
        count(case when data_quality_level = 'high' then 1 end) as high_quality_count,
        count(case when data_quality_level = 'medium' then 1 end) as medium_quality_count,
        count(case when data_quality_level = 'low' then 1 end) as low_quality_count,
        avg(data_quality_score) as avg_quality_score,
        count(case when has_valid_nir then 1 end) as valid_nir_count,
        count(case when has_ins then 1 end) as ins_count,
        count(case when has_location then 1 end) as location_count,
        count(case when identifier is not null then 1 end) as identifier_count
    from {{ ref('fhir_patient') }}
),

encounter_quality as (
    select
        'Encounter' as resource_type,
        count(*) as total_records,
        count(case when status = 'finished' then 1 end) as completed_count,
        count(case when status = 'in-progress' then 1 end) as active_count,
        count(case when length_of_stay_days > 0 then 1 end) as valid_los_count,
        count(case when period is not null then 1 end) as valid_period_count,
        count(case when serviceType is not null then 1 end) as service_type_count,
        count(case when hospitalization is not null then 1 end) as hospitalization_count,
        avg(length_of_stay_days) as avg_length_of_stay,
        null::decimal as avg_quality_score,
        null::bigint as valid_nir_count,
        null::bigint as ins_count,
        null::bigint as location_count,
        count(*) as identifier_count
    from {{ ref('fhir_encounter') }}
),

condition_quality as (
    select
        'Condition' as resource_type,
        count(*) as total_records,
        count(case when clinicalStatus is not null then 1 end) as clinical_status_count,
        count(case when verificationStatus is not null then 1 end) as verification_status_count,
        count(case when icd10_code is not null then 1 end) as valid_code_count,
        count(case when onsetDateTime is not null then 1 end) as onset_date_count,
        count(case when category is not null then 1 end) as category_count,
        count(case when severity is not null then 1 end) as severity_count,
        null::decimal as avg_length_of_stay,
        null::decimal as avg_quality_score,
        null::bigint as valid_nir_count,
        null::bigint as ins_count,
        null::bigint as location_count,
        count(*) as identifier_count
    from {{ ref('fhir_condition') }}
),

observation_quality as (
    select
        'Observation' as resource_type,
        count(*) as total_records,
        count(case when status = 'final' then 1 end) as final_status_count,
        count(case when loinc_code is not null then 1 end) as valid_code_count,
        count(case when value is not null then 1 end) as has_value_count,
        count(case when effectiveDateTime is not null then 1 end) as effective_time_count,
        count(case when category is not null then 1 end) as category_count,
        count(case when performer is not null then 1 end) as performer_count,
        null::decimal as avg_length_of_stay,
        null::decimal as avg_quality_score,
        null::bigint as valid_nir_count,
        null::bigint as ins_count,
        null::bigint as location_count,
        count(*) as identifier_count
    from {{ ref('fhir_observation') }}
),

procedure_quality as (
    select
        'Procedure' as resource_type,
        count(*) as total_records,
        count(case when status = 'completed' then 1 end) as completed_count,
        count(case when ccam_code is not null then 1 end) as valid_code_count,
        count(case when performed is not null then 1 end) as performed_date_count,
        count(case when category is not null then 1 end) as category_count,
        count(case when performer is not null then 1 end) as performer_count,
        count(case when outcome is not null then 1 end) as outcome_count,
        null::decimal as avg_length_of_stay,
        null::decimal as avg_quality_score,
        null::bigint as valid_nir_count,
        null::bigint as ins_count,
        null::bigint as location_count,
        count(*) as identifier_count
    from {{ ref('fhir_procedure') }}
),

medication_request_quality as (
    select
        'MedicationRequest' as resource_type,
        count(*) as total_records,
        count(case when status = 'active' then 1 end) as active_count,
        count(case when atc_code is not null then 1 end) as valid_code_count,
        count(case when authoredOn is not null then 1 end) as authored_date_count,
        count(case when medication is not null then 1 end) as medication_count,
        count(case when dosageInstruction is not null then 1 end) as dosage_count,
        count(case when requester is not null then 1 end) as requester_count,
        null::decimal as avg_length_of_stay,
        null::decimal as avg_quality_score,
        null::bigint as valid_nir_count,
        null::bigint as ins_count,
        null::bigint as location_count,
        count(*) as identifier_count
    from {{ ref('fhir_medication_request') }}
),

unified_metrics as (
    select
        resource_type,
        total_records,
        high_quality_count as high_quality_records,
        medium_quality_count as medium_quality_records,
        low_quality_count as low_quality_records,
        avg_quality_score,
        valid_nir_count,
        ins_count,
        location_count,
        identifier_count,
        null::decimal as avg_length_of_stay
    from patient_quality
    
    union all
    
    select
        resource_type,
        total_records,
        completed_count as high_quality_records,
        active_count as medium_quality_records,
        total_records - coalesce(completed_count, 0) - coalesce(active_count, 0) as low_quality_records,
        avg_quality_score,
        valid_nir_count,
        ins_count,
        location_count,
        identifier_count,
        avg_length_of_stay
    from encounter_quality
    
    union all
    
    select
        resource_type,
        total_records,
        clinical_status_count as high_quality_records,
        verification_status_count as medium_quality_records,
        total_records - coalesce(clinical_status_count, 0) - coalesce(verification_status_count, 0) as low_quality_records,
        avg_quality_score,
        valid_nir_count,
        ins_count,
        location_count,
        identifier_count,
        avg_length_of_stay
    from condition_quality
    
    union all
    
    select
        resource_type,
        total_records,
        final_status_count as high_quality_records,
        valid_code_count as medium_quality_records,
        total_records - coalesce(final_status_count, 0) - coalesce(valid_code_count, 0) as low_quality_records,
        avg_quality_score,
        valid_nir_count,
        ins_count,
        location_count,
        identifier_count,
        avg_length_of_stay
    from observation_quality
    
    union all
    
    select
        resource_type,
        total_records,
        completed_count as high_quality_records,
        valid_code_count as medium_quality_records,
        total_records - coalesce(completed_count, 0) - coalesce(valid_code_count, 0) as low_quality_records,
        avg_quality_score,
        valid_nir_count,
        ins_count,
        location_count,
        identifier_count,
        avg_length_of_stay
    from procedure_quality
    
    union all
    
    select
        resource_type,
        total_records,
        active_count as high_quality_records,
        valid_code_count as medium_quality_records,
        total_records - coalesce(active_count, 0) - coalesce(valid_code_count, 0) as low_quality_records,
        avg_quality_score,
        valid_nir_count,
        ins_count,
        location_count,
        identifier_count,
        avg_length_of_stay
    from medication_request_quality
)

select
    resource_type,
    total_records,
    high_quality_records,
    round((high_quality_records::decimal / total_records * 100), 2) as high_quality_percentage,
    medium_quality_records,
    round((medium_quality_records::decimal / total_records * 100), 2) as medium_quality_percentage,
    low_quality_records,
    round((low_quality_records::decimal / total_records * 100), 2) as low_quality_percentage,
    round(avg_quality_score, 2) as avg_quality_score,
    identifier_count,
    round((identifier_count::decimal / total_records * 100), 2) as identifier_completeness_pct,
    valid_nir_count,
    case 
        when valid_nir_count is not null 
        then round((valid_nir_count::decimal / total_records * 100), 2)
        else null 
    end as nir_completeness_pct,
    ins_count,
    case 
        when ins_count is not null 
        then round((ins_count::decimal / total_records * 100), 2)
        else null 
    end as ins_completeness_pct,
    location_count,
    case 
        when location_count is not null 
        then round((location_count::decimal / total_records * 100), 2)
        else null 
    end as location_completeness_pct,
    round(avg_length_of_stay, 1) as avg_length_of_stay_days,
    current_timestamp as report_timestamp
from unified_metrics
order by 
    case resource_type
        when 'Patient' then 1
        when 'Encounter' then 2
        when 'Condition' then 3
        when 'Observation' then 4
        when 'Procedure' then 5
        when 'MedicationRequest' then 6
        else 99
    end