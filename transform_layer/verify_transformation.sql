-- ========================================================================
-- Verification Queries for EHR to FHIR Transformation
-- ========================================================================
-- This script demonstrates how the DBT models transform EHR data into 
-- FHIR Semantic Layer resources following the FML mapping specification
-- ========================================================================

-- Set the schema (adjust based on your dbt configuration)
SET search_path TO dbt_dev, public;

-- ========================================================================
-- 1. VERIFY PATIENT TRANSFORMATION
-- ========================================================================
-- Source: patient table → Target: fhir_patient table

\echo '================================================'
\echo '1. PATIENT TRANSFORMATION (EHR → FHIR)'
\echo '================================================'

-- Show source EHR patient data
\echo '\n--- Source EHR Patient Data ---'
SELECT 
    patient_id,
    nom,
    prenom,
    nir,
    ins,
    date_naissance,
    sexe,
    date_deces
FROM patient
LIMIT 3;

-- Show transformed FHIR Patient resource
\echo '\n--- Transformed FHIR Patient Resource ---'
SELECT 
    id,
    ins_nir_identifier,
    family_name,
    given_names,
    gender,
    birth_date,
    deceased_date_time,
    jsonb_pretty(identifiers) as identifiers
FROM fhir_patient
WHERE id = '1';

-- ========================================================================
-- 2. VERIFY ENCOUNTER TRANSFORMATION
-- ========================================================================
-- Source: donnees_pmsi table → Target: fhir_encounter table

\echo '\n================================================'
\echo '2. ENCOUNTER TRANSFORMATION (PMSI → FHIR)'
\echo '================================================'

-- Show source PMSI data
\echo '\n--- Source PMSI Data ---'
SELECT 
    pmsi_id,
    patient_id,
    date_debut_sejour,
    date_fin_sejour,
    duree_sejour,
    etablissement,
    service,
    mode_entree,
    mode_sortie
FROM donnees_pmsi
LIMIT 3;

-- Show transformed FHIR Encounter resource
\echo '\n--- Transformed FHIR Encounter Resource ---'
SELECT 
    id,
    status,
    jsonb_pretty(class) as class,
    patient_id,
    period_start::date,
    period_end::date,
    jsonb_pretty(hospitalization) as hospitalization
FROM fhir_encounter
WHERE id = '1001';

-- ========================================================================
-- 3. VERIFY CONDITION TRANSFORMATION  
-- ========================================================================
-- Source: diagnostics table → Target: fhir_condition table

\echo '\n================================================'
\echo '3. CONDITION TRANSFORMATION (Diagnostics → FHIR)'
\echo '================================================'

-- Show source diagnostic data
\echo '\n--- Source Diagnostic Data ---'
SELECT 
    diagnostic_id,
    pmsi_id,
    code_diagnostic,
    type_diagnostic,
    libelle_diagnostic,
    date_diagnostic
FROM diagnostics
LIMIT 3;

-- Show transformed FHIR Condition resource
\echo '\n--- Transformed FHIR Condition Resource ---'
SELECT 
    id,
    subject_patient_id,
    encounter_id,
    recorded_date,
    jsonb_pretty(code) as icd10_code,
    jsonb_pretty(clinical_status) as clinical_status,
    jsonb_pretty(verification_status) as verification_status
FROM fhir_condition
WHERE id = '2001';

-- ========================================================================
-- 4. VERIFY LABORATORY OBSERVATION TRANSFORMATION
-- ========================================================================
-- Source: biologie table → Target: fhir_observation table (laboratory profile)

\echo '\n================================================'
\echo '4. LABORATORY OBSERVATION TRANSFORMATION'
\echo '================================================'

-- Show source laboratory data
\echo '\n--- Source Laboratory Data ---'
SELECT 
    biologie_id,
    patient_id,
    code_loinc,
    libelle_test,
    valeur,
    unite,
    borne_inf_normale,
    borne_sup_normale,
    date_prelevement
FROM biologie
LIMIT 3;

-- Show transformed FHIR Observation resource (laboratory)
\echo '\n--- Transformed FHIR Laboratory Observation ---'
SELECT 
    id,
    observation_profile,
    status,
    subject_patient_id,
    effective_date_time,
    jsonb_pretty(code) as loinc_code,
    jsonb_pretty(value_quantity) as result_value,
    jsonb_pretty(reference_ranges) as reference_range
FROM fhir_observation
WHERE observation_profile = 'laboratory'
AND id = '3001';

-- ========================================================================
-- 5. STATISTICS AND DATA QUALITY
-- ========================================================================

\echo '\n================================================'
\echo '5. TRANSFORMATION STATISTICS'
\echo '================================================'

\echo '\n--- Record Counts by Resource Type ---'
SELECT 
    'Patients' as resource_type,
    COUNT(*) as source_count,
    (SELECT COUNT(*) FROM fhir_patient) as fhir_count
FROM patient
UNION ALL
SELECT 
    'Encounters',
    COUNT(*),
    (SELECT COUNT(*) FROM fhir_encounter)
FROM donnees_pmsi
UNION ALL
SELECT 
    'Conditions',
    COUNT(*),
    (SELECT COUNT(*) FROM fhir_condition)
FROM diagnostics
UNION ALL
SELECT 
    'Lab Observations',
    COUNT(*),
    (SELECT COUNT(*) FROM fhir_observation WHERE observation_profile = 'laboratory')
FROM biologie;

\echo '\n--- Data Quality Check: Required Fields ---'
SELECT 
    'fhir_patient' as table_name,
    COUNT(*) as total_records,
    COUNT(id) as has_id,
    COUNT(ins_nir_identifier) as has_ins_nir,
    COUNT(family_name) as has_family_name,
    COUNT(birth_date) as has_birth_date
FROM fhir_patient
UNION ALL
SELECT 
    'fhir_encounter',
    COUNT(*),
    COUNT(id),
    COUNT(patient_id),
    COUNT(status),
    COUNT(period_start)
FROM fhir_encounter;

-- ========================================================================
-- 6. REFERENTIAL INTEGRITY VERIFICATION
-- ========================================================================

\echo '\n================================================'
\echo '6. REFERENTIAL INTEGRITY'
\echo '================================================'

\echo '\n--- Cross-Resource References ---'
SELECT 
    'Encounters → Patients' as reference_type,
    COUNT(DISTINCT e.patient_id) as distinct_references,
    COUNT(DISTINCT p.id) as valid_references,
    CASE 
        WHEN COUNT(DISTINCT e.patient_id) = COUNT(DISTINCT p.id) 
        THEN 'VALID ✓'
        ELSE 'INVALID ✗'
    END as status
FROM fhir_encounter e
LEFT JOIN fhir_patient p ON e.patient_id = p.id
UNION ALL
SELECT 
    'Conditions → Encounters',
    COUNT(DISTINCT c.encounter_id),
    COUNT(DISTINCT e.id),
    CASE 
        WHEN COUNT(DISTINCT c.encounter_id) = COUNT(DISTINCT e.id)
        THEN 'VALID ✓'
        ELSE 'INVALID ✗'
    END
FROM fhir_condition c
LEFT JOIN fhir_encounter e ON c.encounter_id = e.id
WHERE c.encounter_id IS NOT NULL;

-- ========================================================================
-- 7. SAMPLE FHIR BUNDLE GENERATION
-- ========================================================================

\echo '\n================================================'
\echo '7. SAMPLE FHIR BUNDLE (JSON)'
\echo '================================================'

\echo '\n--- FHIR Bundle with Patient and Related Resources ---'
WITH bundle_entries AS (
    -- Patient entry
    SELECT 
        1 as sort_order,
        jsonb_build_object(
            'fullUrl', 'urn:uuid:' || id,
            'resource', jsonb_build_object(
                'resourceType', 'Patient',
                'id', id,
                'identifier', identifiers,
                'name', names,
                'gender', gender,
                'birthDate', birth_date
            )
        ) as entry
    FROM fhir_patient
    WHERE id = '1'
    
    UNION ALL
    
    -- Encounter entries
    SELECT 
        2 as sort_order,
        jsonb_build_object(
            'fullUrl', 'urn:uuid:' || id,
            'resource', jsonb_build_object(
                'resourceType', 'Encounter',
                'id', id,
                'status', status,
                'class', class,
                'subject', jsonb_build_object(
                    'reference', 'Patient/' || patient_id
                ),
                'period', jsonb_build_object(
                    'start', period_start,
                    'end', period_end
                )
            )
        )
    FROM fhir_encounter
    WHERE patient_id = '1'
    
    UNION ALL
    
    -- Observation entries
    SELECT 
        3 as sort_order,
        jsonb_build_object(
            'fullUrl', 'urn:uuid:' || id,
            'resource', jsonb_build_object(
                'resourceType', 'Observation',
                'id', id,
                'status', status,
                'code', code,
                'subject', jsonb_build_object(
                    'reference', 'Patient/' || subject_patient_id
                ),
                'effectiveDateTime', effective_date_time,
                'valueQuantity', value_quantity
            )
        )
    FROM fhir_observation
    WHERE subject_patient_id = '1'
    AND observation_profile = 'laboratory'
    LIMIT 2
)
SELECT jsonb_pretty(
    jsonb_build_object(
        'resourceType', 'Bundle',
        'type', 'collection',
        'timestamp', now(),
        'entry', jsonb_agg(entry ORDER BY sort_order)
    )
) as fhir_bundle
FROM bundle_entries;

\echo '\n================================================'
\echo 'Transformation Verification Complete'
\echo '================================================'