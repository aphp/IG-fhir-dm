-- PostgreSQL Population Script for Questionnaire Usage Core
-- Generated from: input/resources/usages/core/QuestionnaireResponse-test-usage-core.json
-- Database: PostgreSQL
-- Generated on: 2025-08-29
-- 
-- This script populates the database with data extracted from a FHIR QuestionnaireResponse
-- that contains patient identity, demographic, and geographic information.

-- ==============================================================================
-- BEGIN TRANSACTION
-- ==============================================================================

BEGIN;

-- ==============================================================================
-- PATIENT IDENTITY INFORMATION
-- ==============================================================================

-- Insert patient identity data from the questionnaire response
-- Patient ID extracted from subject.identifier.value: "1"
-- Patient name: "john doe" (from subject.display)
-- Individual components extracted from questionnaire items:
-- - Nom patient: "doe" (linkId: 8605698058770)
-- - Prénom patient: "john" (linkId: 6214879623503)  
-- - NIR: "1234567890123" (linkId: 5711960356160)
-- - Date de naissance: "1948-07-16" (linkId: 5036133558154)

INSERT INTO identite_patient (
    patient_id,
    nom_patient,
    prenom_patient,
    nir,
    date_naissance,
    created_at,
    updated_at
) VALUES (
    '1',                          -- Patient ID from subject.identifier.value
    'doe',                        -- Nom patient from questionnaire answer
    'john',                       -- Prénom patient from questionnaire answer
    '1234567890123',              -- NIR from questionnaire answer
    '1948-07-16',                 -- Date de naissance from questionnaire answer
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- ==============================================================================
-- GEOCODING INFORMATION
-- ==============================================================================

-- Insert geocoding data from questionnaire response
-- Extracted from "Géocodage" section (linkId: 3816475533472):
-- - Latitude: 48.87034455842456 (linkId: 3709843054556)
-- - Longitude: 2.316708526257588 (linkId: 7651448032665)
-- - Date du recueil: "2025-03-27" (linkId: 1185653257776)

INSERT INTO geocodage (
    patient_id,
    latitude,
    longitude,
    date_recueil,
    created_at
) VALUES (
    '1',                          -- References identite_patient.patient_id
    48.87034455842456,            -- Latitude from questionnaire answer
    2.316708526257588,            -- Longitude from questionnaire answer
    '2025-03-27',                 -- Date du recueil from questionnaire answer
    CURRENT_TIMESTAMP
);

-- ==============================================================================
-- SOCIO-DEMOGRAPHIC DATA
-- ==============================================================================

-- Insert socio-demographic data from questionnaire response
-- Extracted from "Données PMSI" section (linkId: 2825244231605):
-- - Age: 76 (linkId: 8164976487070) with collection date "2025-03-27"
-- - Sexe: "Homme" with code "h" (linkId: 3894630481120)

INSERT INTO donnees_socio_demographiques (
    patient_id,
    age,
    date_recueil_age,
    sexe,
    created_at,
    updated_at
) VALUES (
    '1',                          -- References identite_patient.patient_id
    76,                           -- Age from questionnaire answer (valueInteger)
    '2025-03-27',                 -- Date du recueil from nested item
    'Homme',                      -- Sexe from questionnaire answer (valueCoding.display)
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- ==============================================================================
-- COMMIT TRANSACTION
-- ==============================================================================

COMMIT;

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- The following queries can be used to verify the data insertion:

/*
-- Verify patient identity data
SELECT 
    patient_id,
    nom_patient,
    prenom_patient,
    nir,
    date_naissance,
    created_at
FROM identite_patient 
WHERE patient_id = '1';

-- Verify geocoding data
SELECT 
    patient_id,
    latitude,
    longitude,
    date_recueil,
    created_at
FROM geocodage 
WHERE patient_id = '1';

-- Verify socio-demographic data
SELECT 
    patient_id,
    age,
    date_recueil_age,
    sexe,
    created_at
FROM donnees_socio_demographiques 
WHERE patient_id = '1';

-- Combined view of all patient data
SELECT 
    ip.patient_id,
    ip.nom_patient,
    ip.prenom_patient,
    ip.nir,
    ip.date_naissance,
    g.latitude,
    g.longitude,
    g.date_recueil as date_recueil_geocodage,
    dsd.age,
    dsd.date_recueil_age,
    dsd.sexe
FROM identite_patient ip
LEFT JOIN geocodage g ON ip.patient_id = g.patient_id
LEFT JOIN donnees_socio_demographiques dsd ON ip.patient_id = dsd.patient_id
WHERE ip.patient_id = '1';
*/

-- ==============================================================================
-- SUMMARY
-- ==============================================================================

/*
Data extracted and inserted from QuestionnaireResponse:

1. PATIENT IDENTITY (identite_patient table):
   - Patient ID: 1
   - Name: john doe
   - NIR: 1234567890123
   - Birth date: 1948-07-16

2. GEOCODING (geocodage table):
   - Latitude: 48.87034455842456
   - Longitude: 2.316708526257588
   - Collection date: 2025-03-27

3. SOCIO-DEMOGRAPHIC DATA (donnees_socio_demographiques table):
   - Age: 76 years (collected on 2025-03-27)
   - Gender: Homme (Male)

FOREIGN KEY RELATIONSHIPS:
- geocodage.patient_id → identite_patient.patient_id
- donnees_socio_demographiques.patient_id → identite_patient.patient_id

The script follows PostgreSQL best practices:
- Transaction wrapped (BEGIN/COMMIT)
- Proper data types and formatting
- Foreign key constraints respected
- Comments explaining data source mapping
- Verification queries provided
*/