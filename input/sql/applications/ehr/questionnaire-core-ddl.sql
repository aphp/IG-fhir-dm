-- ========================================================================
-- PostgreSQL 17.x DDL Script for FHIR Questionnaire Core Variables EDSH
-- Generated from: input/resources/usages/core/Questionnaire-UsageCore.json
-- 
-- This script creates an optimized schema for storing FHIR Questionnaire
-- responses related to core health data variables for EDSH.
-- 
-- Key optimizations:
-- - Consolidated laboratory results into single generic table
-- - Removed age columns (calculable from birth date and encounter date)  
-- - Consolidated patient information into single table
-- - All clinical tables linked to central PMSI encounter table
-- ========================================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS style_vie CASCADE;
DROP TABLE IF EXISTS posologie CASCADE;
DROP TABLE IF EXISTS dosage CASCADE;
DROP TABLE IF EXISTS dossier_soins CASCADE;
DROP TABLE IF EXISTS exposition_medicamenteuse CASCADE;
DROP TABLE IF EXISTS biologie CASCADE;
DROP TABLE IF EXISTS actes CASCADE;
DROP TABLE IF EXISTS diagnostics CASCADE;
DROP TABLE IF EXISTS donnees_pmsi CASCADE;
DROP TABLE IF EXISTS patient CASCADE;

-- ========================================================================
-- MAIN TABLES
-- ========================================================================

-- Table: patient
-- Consolidated patient information combining identity and geocoding data
-- Based on linkId: 2958000860428 (Identité patient) and 5491974639955 (Géocodage)
-- Includes sexe from linkId: 3894630481120 (consolidated from PMSI data)
CREATE TABLE patient (
    patient_id BIGSERIAL PRIMARY KEY,
    
    -- Identity fields (linkId: 2958000860428)
    nom VARCHAR(255),
    prenom VARCHAR(255),
    nir VARCHAR(15),
    ins VARCHAR(50),
    date_naissance DATE NOT NULL,
    sexe VARCHAR(20),
    date_deces DATE,
    source_deces VARCHAR(50),
    rang_gemellaire INTEGER,
    
    -- Geocoding fields (linkId: 3816475533472)
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    code_iris VARCHAR(20),
    libelle_iris VARCHAR(200),
    
    -- Geographic residence
    code_geographique_residence VARCHAR(10),
    libelle_geographique_residence VARCHAR(200),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: donnees_pmsi  
-- Main encounter/stay data - central table linking to all other clinical data
-- Based on linkId: 2825244231605 (Données PMSI) - repeats=true
-- Note: age column removed per optimization requirements
CREATE TABLE donnees_pmsi (
    pmsi_id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    
    -- Core PMSI fields (age removed - calculated from patient.date_naissance)
    mode_sortie VARCHAR(100),
    duree_sejour INTEGER,
    
    -- Stay dates and administrative data
    date_debut_sejour DATE,
    date_fin_sejour DATE,
    mode_entree VARCHAR(100),
    statut_administratif VARCHAR(50),
    
    -- Healthcare facility information
    etablissement VARCHAR(255),
    unite_fonctionnelle VARCHAR(255),
    service VARCHAR(255),
    
    -- Geographic context at time of encounter (from linkId: 2446369196222)
    code_geographique_residence VARCHAR(10),
    libelle_geographique_residence VARCHAR(200),
    
    -- Link to data collection context
    date_recueil DATE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: diagnostics
-- Diagnostic codes and information linked to PMSI encounters
CREATE TABLE diagnostics (
    diagnostic_id BIGSERIAL PRIMARY KEY,
    pmsi_id BIGINT NOT NULL,
    
    -- Diagnostic information (linkId: 9391816419630)
    code_diagnostic VARCHAR(20) NOT NULL,
    type_diagnostic VARCHAR(50),
    libelle_diagnostic TEXT,
    date_diagnostic DATE,
    
    -- Sequencing information for multiple diagnoses
    sequence_diagnostic INTEGER,
    
    -- Data collection context
    date_recueil DATE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: actes
-- Medical procedures and acts linked to PMSI encounters  
CREATE TABLE actes (
    acte_id BIGSERIAL PRIMARY KEY,
    pmsi_id BIGINT NOT NULL,
    
    -- Act/procedure information (linkId: 591926901726)
    code_acte VARCHAR(20) NOT NULL,
    libelle_acte TEXT,
    date_acte TIMESTAMP,
    executant VARCHAR(255),
    
    -- Sequencing information for multiple acts
    sequence_acte INTEGER,
    
    -- Data collection context
    date_recueil DATE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: biologie
-- Consolidated laboratory results table for all biological examinations
-- Optimized generic table using LOINC codes to differentiate test types
-- Combines: Fonction rénale, Bilan hépatique, Hémogramme, Biologie autres
CREATE TABLE biologie (
    biologie_id BIGSERIAL PRIMARY KEY,
    pmsi_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    
    -- Test identification - consolidated biology table
    code_loinc VARCHAR(20),
    libelle_test VARCHAR(255),
    type_examen VARCHAR(100),
    
    -- Test results
    valeur DECIMAL(15,6),
    unite VARCHAR(50),
    valeur_texte TEXT,
    
    -- Test context and timing
    date_prelevement TIMESTAMP WITH TIME ZONE,
    statut_validation VARCHAR(50),
    
    -- Reference ranges
    borne_inf_normale DECIMAL(15,6),
    borne_sup_normale DECIMAL(15,6),
    
    -- Quality information
    commentaire TEXT,
    methode_analyse VARCHAR(255),
    laboratoire VARCHAR(255),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: exposition_medicamenteuse
-- Medication exposure data linked to encounters and patients
-- Based on linkId: 817801935685 (Exposition médicamenteuse) - repeats=true
CREATE TABLE exposition_medicamenteuse (
    exposition_id BIGSERIAL PRIMARY KEY,
    pmsi_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    
    -- Medication identification (linkId: 817801935685)
    code_atc VARCHAR(20),
    denomination VARCHAR(255),
    forme_pharmaceutique VARCHAR(100),
    
    -- Administration details
    voie_administration VARCHAR(100),
    
    -- Prescription context
    type_prescription VARCHAR(50),
    prescripteur VARCHAR(255),
    
    -- Temporal information
    date_debut DATE,
    date_fin DATE,
    date_prescription DATE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: dossier_soins  
-- Clinical care measurements and observations
-- Based on linkId: 305831246173 (Dossier de soins) - repeats=true
CREATE TABLE dossier_soins (
    soins_id BIGSERIAL PRIMARY KEY,
    pmsi_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    
    -- Physical measurements (linkId: 305831246173)
    taille DECIMAL(5,2),
    date_mesure_taille DATE,
    
    poids DECIMAL(6,2),
    date_mesure_poids DATE,
    
    -- Vital signs
    pression_systolique DECIMAL(5,2),
    date_mesure_ps DATE,
    
    pression_diastolique DECIMAL(5,2),
    date_mesure_pd DATE,
    
    -- Measurement context
    type_mesure VARCHAR(100),
    unite_soins VARCHAR(255),
    professionnel VARCHAR(255),
    
    -- Additional clinical data
    commentaire TEXT,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: posologie
-- Detailed dosing information (linkId: 6348237104421)
CREATE TABLE posologie (
    posologie_id BIGSERIAL PRIMARY KEY,
    exposition_id BIGINT NOT NULL,
    pmsi_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    
    -- Posology details
    date_debut_prescription DATE,
    date_fin_prescription DATE,
    nombre_prises_par_jour INTEGER,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: dosage 
-- Dosage details (linkId: 5720103839343)
CREATE TABLE dosage (
    dosage_id BIGSERIAL PRIMARY KEY,
    exposition_id BIGINT NOT NULL,
    pmsi_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    
    -- Dosage information
    quantite_administree DECIMAL(10,3),
    unite_quantite VARCHAR(20),
    date_heure_debut TIMESTAMP,
    date_heure_fin TIMESTAMP,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: style_vie
-- Consolidated lifestyle information (linkId: 1693164086678)
CREATE TABLE style_vie (
    style_vie_id BIGSERIAL PRIMARY KEY,
    pmsi_id BIGINT NOT NULL,
    patient_id BIGINT NOT NULL,
    
    -- Lifestyle factors
    consommation_tabac VARCHAR(100),
    consommation_alcool VARCHAR(100),
    consommation_autres_drogues VARCHAR(100),
    activite_physique VARCHAR(100),
    
    -- Data collection context
    date_recueil DATE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================================
-- CONSTRAINTS AND FOREIGN KEYS
-- ========================================================================

-- Foreign key constraints
ALTER TABLE donnees_pmsi 
ADD CONSTRAINT fk_donnees_pmsi_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE diagnostics 
ADD CONSTRAINT fk_diagnostics_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE actes 
ADD CONSTRAINT fk_actes_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE biologie 
ADD CONSTRAINT fk_biologie_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE biologie 
ADD CONSTRAINT fk_biologie_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE exposition_medicamenteuse 
ADD CONSTRAINT fk_exposition_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE exposition_medicamenteuse 
ADD CONSTRAINT fk_exposition_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE dossier_soins 
ADD CONSTRAINT fk_dossier_soins_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE dossier_soins 
ADD CONSTRAINT fk_dossier_soins_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE posologie 
ADD CONSTRAINT fk_posologie_exposition 
FOREIGN KEY (exposition_id) REFERENCES exposition_medicamenteuse(exposition_id) ON DELETE CASCADE;

ALTER TABLE posologie 
ADD CONSTRAINT fk_posologie_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE posologie 
ADD CONSTRAINT fk_posologie_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE dosage 
ADD CONSTRAINT fk_dosage_exposition 
FOREIGN KEY (exposition_id) REFERENCES exposition_medicamenteuse(exposition_id) ON DELETE CASCADE;

ALTER TABLE dosage 
ADD CONSTRAINT fk_dosage_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE dosage 
ADD CONSTRAINT fk_dosage_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE style_vie 
ADD CONSTRAINT fk_style_vie_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

ALTER TABLE style_vie 
ADD CONSTRAINT fk_style_vie_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

-- Check constraints for data quality
ALTER TABLE patient 
ADD CONSTRAINT chk_patient_sexe 
CHECK (sexe IN ('M', 'F', 'Masculin', 'Féminin', 'Indéterminé', '1', '2', '9'));

ALTER TABLE patient 
ADD CONSTRAINT chk_patient_date_naissance 
CHECK (date_naissance <= CURRENT_DATE);

ALTER TABLE patient
ADD CONSTRAINT chk_patient_latitude 
CHECK (latitude BETWEEN -90 AND 90);

ALTER TABLE patient
ADD CONSTRAINT chk_patient_longitude 
CHECK (longitude BETWEEN -180 AND 180);

ALTER TABLE donnees_pmsi 
ADD CONSTRAINT chk_pmsi_duree_sejour 
CHECK (duree_sejour >= 0);

ALTER TABLE donnees_pmsi 
ADD CONSTRAINT chk_pmsi_dates 
CHECK (date_fin_sejour >= date_debut_sejour);

ALTER TABLE donnees_pmsi 
ADD CONSTRAINT chk_pmsi_sexe 
CHECK (sexe IN ('M', 'F', '1', '2', '9'));

ALTER TABLE biologie 
ADD CONSTRAINT chk_biologie_bornes 
CHECK (borne_sup_normale IS NULL OR borne_inf_normale IS NULL OR borne_sup_normale >= borne_inf_normale);

ALTER TABLE biologie
ADD CONSTRAINT chk_biologie_type_examen
CHECK (type_examen IN ('fonction_renale', 'bilan_hepatique', 'hemogramme', 'autres', 'coagulation', 'metabolisme'));

ALTER TABLE exposition_medicamenteuse
ADD CONSTRAINT chk_exposition_dates
CHECK (date_fin IS NULL OR date_debut IS NULL OR date_fin >= date_debut);

ALTER TABLE exposition_medicamenteuse
ADD CONSTRAINT chk_exposition_type
CHECK (type_prescription IN ('prescrit', 'administré'));

ALTER TABLE exposition_medicamenteuse
ADD CONSTRAINT chk_exposition_duree
CHECK (duree_traitement IS NULL OR duree_traitement > 0);

ALTER TABLE dossier_soins 
ADD CONSTRAINT chk_soins_taille 
CHECK (taille IS NULL OR (taille > 0 AND taille < 300));

ALTER TABLE dossier_soins 
ADD CONSTRAINT chk_soins_poids 
CHECK (poids IS NULL OR (poids > 0 AND poids < 1000));

ALTER TABLE dossier_soins 
ADD CONSTRAINT chk_soins_pression_systolique 
CHECK (pression_systolique IS NULL OR (pression_systolique > 0 AND pression_systolique < 300));

ALTER TABLE dossier_soins 
ADD CONSTRAINT chk_soins_pression_diastolique 
CHECK (pression_diastolique IS NULL OR (pression_diastolique > 0 AND pression_diastolique < 200));

-- ========================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ========================================================================

-- Primary lookup indexes on patient table
CREATE INDEX idx_patient_nir ON patient(nir) WHERE nir IS NOT NULL;
CREATE INDEX idx_patient_ins ON patient(ins) WHERE ins IS NOT NULL;
CREATE INDEX idx_patient_nom_prenom ON patient(nom, prenom);
CREATE INDEX idx_patient_date_naissance ON patient(date_naissance);
CREATE INDEX idx_patient_code_postal ON patient(code_postal);
CREATE INDEX idx_patient_commune ON patient(commune);

-- PMSI encounter indexes  
CREATE INDEX idx_pmsi_patient_id ON donnees_pmsi(patient_id);
CREATE INDEX idx_pmsi_date_debut ON donnees_pmsi(date_debut_sejour);
CREATE INDEX idx_pmsi_date_fin ON donnees_pmsi(date_fin_sejour);
CREATE INDEX idx_pmsi_etablissement ON donnees_pmsi(etablissement);
CREATE INDEX idx_pmsi_unite_fonctionnelle ON donnees_pmsi(unite_fonctionnelle);

-- Diagnostic indexes
CREATE INDEX idx_diagnostics_pmsi_id ON diagnostics(pmsi_id);
CREATE INDEX idx_diagnostics_code ON diagnostics(code_diagnostic);
CREATE INDEX idx_diagnostics_type ON diagnostics(type_diagnostic);
CREATE INDEX idx_diagnostics_date ON diagnostics(date_diagnostic);

-- Procedure/acts indexes
CREATE INDEX idx_actes_pmsi_id ON actes(pmsi_id);
CREATE INDEX idx_actes_code ON actes(code_acte);
CREATE INDEX idx_actes_date ON actes(date_acte);
CREATE INDEX idx_actes_date_recueil ON actes(date_recueil);

-- Laboratory results indexes - optimized for consolidated table
CREATE INDEX idx_biologie_pmsi_id ON biologie(pmsi_id);
CREATE INDEX idx_biologie_patient_id ON biologie(patient_id);
CREATE INDEX idx_biologie_code_loinc ON biologie(code_loinc);
CREATE INDEX idx_biologie_type_examen ON biologie(type_examen);
CREATE INDEX idx_biologie_date_prelevement ON biologie(date_prelevement);
CREATE INDEX idx_biologie_statut_validation ON biologie(statut_validation);

-- Medication exposure indexes
CREATE INDEX idx_exposition_pmsi_id ON exposition_medicamenteuse(pmsi_id);
CREATE INDEX idx_exposition_patient_id ON exposition_medicamenteuse(patient_id);
CREATE INDEX idx_exposition_code_atc ON exposition_medicamenteuse(code_atc);
CREATE INDEX idx_exposition_date_debut ON exposition_medicamenteuse(date_debut);
CREATE INDEX idx_exposition_date_prescription ON exposition_medicamenteuse(date_prescription);
CREATE INDEX idx_exposition_type_prescription ON exposition_medicamenteuse(type_prescription);

-- Clinical care indexes
CREATE INDEX idx_soins_pmsi_id ON dossier_soins(pmsi_id);
CREATE INDEX idx_soins_patient_id ON dossier_soins(patient_id);
CREATE INDEX idx_soins_date_mesure_taille ON dossier_soins(date_mesure_taille);
CREATE INDEX idx_soins_date_mesure_poids ON dossier_soins(date_mesure_poids);

-- Composite indexes for common queries
CREATE INDEX idx_biologie_patient_loinc ON biologie(patient_id, code_loinc);
CREATE INDEX idx_biologie_patient_type ON biologie(patient_id, type_examen);
CREATE INDEX idx_exposition_patient_atc ON exposition_medicamenteuse(patient_id, code_atc);
CREATE INDEX idx_pmsi_patient_date ON donnees_pmsi(patient_id, date_debut_sejour);
CREATE INDEX idx_diagnostics_pmsi_code ON diagnostics(pmsi_id, code_diagnostic);
CREATE INDEX idx_actes_pmsi_code ON actes(pmsi_id, code_acte);

-- Geographic/spatial indexes
CREATE INDEX idx_patient_coords ON patient(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
CREATE INDEX idx_patient_iris ON patient(code_iris) WHERE code_iris IS NOT NULL;

-- Partial indexes for performance
CREATE INDEX idx_biologie_valeur_non_null ON biologie(valeur) WHERE valeur IS NOT NULL;
CREATE INDEX idx_exposition_active ON exposition_medicamenteuse(patient_id, date_debut, date_fin) 
WHERE date_debut IS NOT NULL;

-- ========================================================================
-- COLUMN COMMENTS
-- ========================================================================

-- Patient table column comments
COMMENT ON COLUMN patient.nom IS 'Nom patient (linkId: 8605698058770)';
COMMENT ON COLUMN patient.prenom IS 'Prénom patient (linkId: 6214879623503)';
COMMENT ON COLUMN patient.nir IS 'Numéro inscription au Répertoire - NIR (linkId: 5711960356160)';
COMMENT ON COLUMN patient.ins IS 'Identité Nationale de Santé - INS (linkId: 3764723550987)';
COMMENT ON COLUMN patient.date_naissance IS 'Date de naissance (linkId: 5036133558154)';
COMMENT ON COLUMN patient.sexe IS 'Sexe consolidé depuis PMSI (linkId: 3894630481120)';
COMMENT ON COLUMN patient.date_deces IS 'Date de décès (linkId: 5633552097315)';
COMMENT ON COLUMN patient.source_deces IS 'Source de la date de décès (linkId: 9098810065693)';
COMMENT ON COLUMN patient.rang_gemellaire IS 'Rang gémellaire du bénéficiaire (linkId: 6931296968515)';
COMMENT ON COLUMN patient.latitude IS 'Latitude du domicile patient (linkId: 3709843054556)';
COMMENT ON COLUMN patient.longitude IS 'Longitude du domicile patient (linkId: 7651448032665)';

-- Biology table column comments
COMMENT ON COLUMN biologie.code_loinc IS 'Code LOINC identifiant le test biologique';
COMMENT ON COLUMN biologie.type_examen IS 'Type examen: fonction_renale, bilan_hepatique, hemogramme, autres';
COMMENT ON COLUMN biologie.date_prelevement IS 'Date et heure du prélèvement';
COMMENT ON COLUMN biologie.borne_inf_normale IS 'Borne inférieure de normalité';
COMMENT ON COLUMN biologie.borne_sup_normale IS 'Borne supérieure de normalité';

-- ========================================================================
-- COMMENTS ON TABLES
-- ========================================================================

COMMENT ON TABLE patient IS 'Consolidated patient demographics and identity information combining FHIR Questionnaire items for patient identity and geocoding (linkId: 2958000860428, 3816475533472)';

COMMENT ON TABLE donnees_pmsi IS 'Main healthcare encounter data from PMSI (Programme de médicalisation des systèmes information) - central linking table for all clinical data (linkId: 2825244231605)';

COMMENT ON TABLE diagnostics IS 'Diagnostic codes and information linked to healthcare encounters using ICD-10/CIM-10 classifications (linkId: 9391816419630)';

COMMENT ON TABLE actes IS 'Medical procedures and acts performed during healthcare encounters using CCAM and other standard classifications (linkId: 591926901726)';

COMMENT ON TABLE biologie IS 'Consolidated laboratory test results for all biological examinations, differentiated by LOINC codes and test types including renal function, hepatic panel, complete blood count, and other tests (linkId: 7702944131447)';

COMMENT ON TABLE exposition_medicamenteuse IS 'Medication exposure and prescription data with ATC coding for pharmacovigilance and clinical research, supporting both prescribed and administered medications (linkId: 817801935685)';

COMMENT ON TABLE dossier_soins IS 'Clinical care measurements and observations including vital signs, physical measurements, and nursing care data (linkId: 305831246173)';

COMMENT ON TABLE posologie IS 'Detailed dosing information for medications (linkId: 6348237104421)';

COMMENT ON TABLE dosage IS 'Specific dosage administration details (linkId: 5720103839343)';

COMMENT ON TABLE style_vie IS 'Consolidated lifestyle information including tobacco, alcohol, drugs, and physical activity (linkId: 1693164086678)';

-- ========================================================================
-- SCHEMA CREATION COMPLETED
-- 
-- This optimized schema provides:
-- 1. Consolidated laboratory results in single biologie table using LOINC codes
-- 2. Age calculation capability from date_naissance and encounter dates
-- 3. Single patient table with consolidated demographics and geographic data
-- 4. All clinical tables properly linked via foreign keys to PMSI and patient tables
-- 5. Comprehensive indexing strategy for optimal query performance
-- 6. Data quality constraints and validation rules
-- 7. Support for temporal queries and longitudinal analysis
-- ========================================================================
=======
-- PostgreSQL DDL Schema for Questionnaire Usage Core
-- Generated from: input/resources/usages/core/Questionnaire-UsageCore.json
-- Description: Variables socles pour les EDSH (Core variables for Health Data Warehouses)
-- Database: PostgreSQL

-- ==============================================================================
-- PATIENT IDENTITY INFORMATION
-- ==============================================================================

CREATE TABLE identite_patient (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) UNIQUE NOT NULL, -- Link to main patient table
    nom_patient VARCHAR(255) COMMENT 'Nom patient',
    prenom_patient VARCHAR(255) COMMENT 'Prénom patient',
    nir VARCHAR(15) COMMENT 'Numéro d''inscription au Répertoire (NIR) - Numéro unique attribué à chaque personne à sa naissance sur la base d''éléments d''état civil transmis par les mairies à l''INSEE',
    ins VARCHAR(50) COMMENT 'Identité Nationale de Santé (INS) - Numéro d''identité unique, pérenne, partagée par l''ensemble des professionnels du monde de la santé',
    date_naissance DATE COMMENT 'Date de naissance des papiers d''identité utilisés pour la production de l''INS',
    date_deces DATE COMMENT 'Date de décès à l''hopital, ou date de décès collectée par chaînage avec une base externe comme l''INSEE ou le CepiDc',
    source_date_deces VARCHAR(10) COMMENT 'Source de la date de décès: INSEE, CepiDc, SIH',
    rang_gemellaire INTEGER COMMENT 'Rang gémellaire du bénéficiaire - Pour le régime général, il permet de distinguer les naissances gémellaires de même sexe',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE identite_patient IS 'Identitologie. Clé d''appariement unique pouvant permettre le chaînage direct du socle avec d''autres bases';

-- ==============================================================================
-- GEOCODING INFORMATION (REPEATABLE)
-- ==============================================================================

CREATE TABLE geocodage (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    latitude DECIMAL(10,8) COMMENT 'Latitude des coordonnées géographiques de l''adresse du patient',
    longitude DECIMAL(11,8) COMMENT 'Longitude des coordonnées géographiques de l''adresse du patient',
    date_recueil DATE COMMENT 'Date du recueil de l''information géographique',
    iris_code VARCHAR(20) COMMENT 'Code IRIS de la zone géographique',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE geocodage IS 'Coordonnées géographiques (latitude et longitude) de l''adresse du patient';

-- ==============================================================================
-- PATIENT DEMOGRAPHIC DATA
-- ==============================================================================

CREATE TABLE donnees_socio_demographiques (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    age INTEGER COMMENT 'Age du patient',
    date_recueil_age DATE COMMENT 'Date du recueil de l''information d''âge',
    sexe VARCHAR(10) COMMENT 'Sexe du patient: Homme/Femme',
    code_geographique_residence VARCHAR(10) COMMENT 'Code de la commune de résidence du patient selon la classification PMSI',
    date_recueil_residence DATE COMMENT 'Date du recueil de l''information de résidence',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- PMSI DIAGNOSTICS (REPEATABLE)
-- ==============================================================================

CREATE TABLE diagnostics (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    sejour_id VARCHAR(50) COMMENT 'Identifiant du séjour',
    date_recueil DATE COMMENT 'Date du recueil de l''information diagnostique',
    type_diagnostic VARCHAR(10) COMMENT 'Type de diagnostic: DP (Principal), DAS (Associé significatif), DR (Relié)',
    code_diagnostic VARCHAR(20) COMMENT 'Code diagnostique (CIM-10)',
    libelle_diagnostic VARCHAR(500) COMMENT 'Libellé du diagnostic',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE diagnostics IS 'Diagnostics du patient dans le contexte PMSI';

-- ==============================================================================
-- PMSI PROCEDURES (REPEATABLE)
-- ==============================================================================

CREATE TABLE actes (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    sejour_id VARCHAR(50) COMMENT 'Identifiant du séjour',
    date_recueil DATE COMMENT 'Date du recueil de l''information d''acte',
    code_acte VARCHAR(20) COMMENT 'Code de l''acte médical',
    libelle_acte VARCHAR(500) COMMENT 'Libellé de l''acte médical',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE actes IS 'Actes et procédures médicales du patient';

-- ==============================================================================
-- PMSI STAY INFORMATION
-- ==============================================================================

CREATE TABLE donnees_pmsi (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    date_debut_sejour DATE COMMENT 'Date de début de séjour',
    date_fin_sejour DATE COMMENT 'Date de fin de séjour',
    mode_entree VARCHAR(10) COMMENT 'Mode d''entrée du séjour',
    mode_sortie VARCHAR(10) COMMENT 'Mode de sortie pendant le séjour',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE donnees_pmsi IS 'Description générale du patient et de la venue à l''hôpital, dans les différents PMSI (MCO, SSR, HAD, Psy)';

-- ==============================================================================
-- RENAL FUNCTION BIOLOGY TESTS
-- ==============================================================================

CREATE TABLE fonction_renale (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    -- Urea
    uree_valeur DECIMAL(15,6) COMMENT 'Valeur du dosage de l''urée dans le sang',
    uree_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour l''urée',
    uree_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement d''urée',
    uree_statut_validation VARCHAR(50) COMMENT 'Statut de validation du résultat d''urée',
    uree_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure de normalité pour l''urée',
    uree_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure de normalité pour l''urée',
    
    -- Creatinine
    creatinine_valeur DECIMAL(15,6) COMMENT 'Valeur de la créatininémie',
    creatinine_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour la créatinine',
    creatinine_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement de créatinine',
    creatinine_statut_validation VARCHAR(50) COMMENT 'Statut de validation du résultat de créatinine',
    creatinine_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure de normalité pour la créatinine',
    creatinine_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure de normalité pour la créatinine',
    
    -- GFR (Glomerular Filtration Rate)
    dfg_valeur DECIMAL(15,6) COMMENT 'Valeur du débit de filtration glomérulaire',
    dfg_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour le DFG',
    dfg_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement pour DFG',
    dfg_statut_validation VARCHAR(50) COMMENT 'Statut de validation du résultat de DFG',
    dfg_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure de normalité pour le DFG',
    dfg_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure de normalité pour le DFG',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE fonction_renale IS 'Dosage sanguin de l''urée qui permet d''évaluer la fonction rénale';

-- ==============================================================================
-- BLOOD COUNT TESTS (HEMOGRAMME)
-- ==============================================================================

CREATE TABLE hemogramme (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    -- White blood cells
    leucocytes_valeur DECIMAL(15,6) COMMENT 'Valeur des leucocytes',
    leucocytes_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour les leucocytes',
    leucocytes_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement leucocytes',
    leucocytes_statut_validation VARCHAR(50) COMMENT 'Statut de validation leucocytes',
    leucocytes_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité leucocytes',
    leucocytes_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité leucocytes',
    
    -- Hemoglobin
    hemoglobine_valeur DECIMAL(15,6) COMMENT 'Valeur de l''hémoglobine',
    hemoglobine_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour l''hémoglobine',
    hemoglobine_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement hémoglobine',
    hemoglobine_statut_validation VARCHAR(50) COMMENT 'Statut de validation hémoglobine',
    hemoglobine_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité hémoglobine',
    hemoglobine_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité hémoglobine',
    
    -- Hematocrit
    hematocrite_valeur DECIMAL(15,6) COMMENT 'Volume occupé par les globules rouges dans le sang',
    hematocrite_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour l''hématocrite',
    hematocrite_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement hématocrite',
    hematocrite_statut_validation VARCHAR(50) COMMENT 'Statut de validation hématocrite',
    hematocrite_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité hématocrite',
    hematocrite_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité hématocrite',
    
    -- Red blood cells
    globules_rouges_valeur DECIMAL(15,6) COMMENT 'Dosage sanguin des globules rouges',
    globules_rouges_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour les globules rouges',
    globules_rouges_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement globules rouges',
    globules_rouges_statut_validation VARCHAR(50) COMMENT 'Statut de validation globules rouges',
    globules_rouges_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité globules rouges',
    globules_rouges_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité globules rouges',
    
    -- Mean Corpuscular Volume
    vgm_valeur DECIMAL(15,6) COMMENT 'Volume moyen des globules rouges, valeur centrale pour le diagnostic des anémies',
    vgm_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour le VGM',
    vgm_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement VGM',
    vgm_statut_validation VARCHAR(50) COMMENT 'Statut de validation VGM',
    vgm_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité VGM',
    vgm_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité VGM',
    
    -- Platelets
    plaquettes_valeur DECIMAL(15,6) COMMENT 'Dosage sanguin des plaquettes, utile pour toute pathologie faisant intervenir le système immunitaire/hématologique',
    plaquettes_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour les plaquettes',
    plaquettes_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement plaquettes',
    plaquettes_statut_validation VARCHAR(50) COMMENT 'Statut de validation plaquettes',
    plaquettes_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité plaquettes',
    plaquettes_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité plaquettes',
    
    -- Neutrophils
    neutrophiles_valeur DECIMAL(15,6) COMMENT 'Dosage sanguin des neutrophiles',
    neutrophiles_code_loinc VARCHAR(20) COMMENT 'Code LOINC pour les neutrophiles',
    neutrophiles_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement neutrophiles',
    neutrophiles_statut_validation VARCHAR(50) COMMENT 'Statut de validation neutrophiles',
    neutrophiles_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure normalité neutrophiles',
    neutrophiles_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure normalité neutrophiles',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE hemogramme IS 'Hémogramme - examens sanguins de base incluant leucocytes, hémoglobine, hématocrite, globules rouges, VGM, plaquettes et neutrophiles';

-- ==============================================================================
-- HEPATIC ASSESSMENT
-- ==============================================================================

CREATE TABLE bilan_hepatique (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    -- This would contain hepatic function tests
    -- Fields would be similar to other biology tables with _valeur, _code_loinc, _date_prelevement, etc.
    -- Specific tests would include: AST, ALT, Bilirubin, Alkaline Phosphatase, etc.
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE bilan_hepatique IS 'Bilan hépatique - tests de fonction hépatique';

-- ==============================================================================
-- OTHER BIOLOGY TESTS
-- ==============================================================================

CREATE TABLE biologie_autres (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    -- Generic structure for other biology tests
    test_name VARCHAR(255) COMMENT 'Nom du test biologique',
    test_valeur DECIMAL(15,6) COMMENT 'Valeur du test',
    test_code_loinc VARCHAR(20) COMMENT 'Code LOINC du test',
    test_date_prelevement TIMESTAMP COMMENT 'Date et heure du prélèvement',
    test_statut_validation VARCHAR(50) COMMENT 'Statut de validation',
    test_borne_inf DECIMAL(15,6) COMMENT 'Borne inférieure de normalité',
    test_borne_sup DECIMAL(15,6) COMMENT 'Borne supérieure de normalité',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE biologie_autres IS 'Autres examens biologiques non catégorisés';

-- ==============================================================================
-- MEDICATION EXPOSURE (REPEATABLE)
-- ==============================================================================

CREATE TABLE exposition_medicamenteuse (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    medicament_prescrit VARCHAR(500) COMMENT 'Médicament prescrit',
    codification_atc VARCHAR(20) COMMENT 'Codification ATC du médicament',
    voie_administration VARCHAR(100) COMMENT 'Voie d''administration du médicament',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE exposition_medicamenteuse IS 'Exposition médicamenteuse du patient';

-- ==============================================================================
-- MEDICATION DOSAGE DETAILS (REPEATABLE)
-- ==============================================================================

CREATE TABLE posologie_detail (
    id SERIAL PRIMARY KEY,
    exposition_id INTEGER NOT NULL REFERENCES exposition_medicamenteuse(id),
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    -- Dosage information
    dose_unitaire DECIMAL(15,6) COMMENT 'Dose unitaire du médicament',
    unite_dose VARCHAR(20) COMMENT 'Unité de la dose',
    frequence_administration VARCHAR(100) COMMENT 'Fréquence d''administration',
    duree_traitement INTEGER COMMENT 'Durée du traitement en jours',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE posologie_detail IS 'Détails de posologie des médicaments prescrits';

-- ==============================================================================
-- INDIVIDUAL DOSAGES (REPEATABLE)
-- ==============================================================================

CREATE TABLE dosage (
    id SERIAL PRIMARY KEY,
    exposition_id INTEGER NOT NULL REFERENCES exposition_medicamenteuse(id),
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    date_administration TIMESTAMP COMMENT 'Date et heure d''administration',
    dose_administree DECIMAL(15,6) COMMENT 'Dose administrée',
    unite_dose VARCHAR(20) COMMENT 'Unité de la dose administrée',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dosage IS 'Dosages individuels administrés';

-- ==============================================================================
-- CLINICAL EXAMINATION - CARE RECORDS (REPEATABLE)
-- ==============================================================================

CREATE TABLE dossier_soins (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    date_enregistrement TIMESTAMP COMMENT 'Date d''enregistrement du dossier de soins',
    type_soins VARCHAR(100) COMMENT 'Type de soins prodigués',
    description_soins TEXT COMMENT 'Description détaillée des soins',
    professionnel_id VARCHAR(50) COMMENT 'Identifiant du professionnel de santé',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dossier_soins IS 'Dossiers de soins du patient';

-- ==============================================================================
-- LIFESTYLE INFORMATION (REPEATABLE)
-- ==============================================================================

CREATE TABLE style_vie (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id),
    
    date_recueil DATE COMMENT 'Date du recueil des informations de style de vie',
    
    -- Tobacco consumption
    consommation_tabac VARCHAR(50) COMMENT 'Statut de consommation de tabac',
    tabac_details TEXT COMMENT 'Détails sur la consommation de tabac',
    
    -- Alcohol consumption
    consommation_alcool VARCHAR(50) COMMENT 'Statut de consommation d''alcool',
    alcool_details TEXT COMMENT 'Détails sur la consommation d''alcool',
    
    -- Other drug consumption
    consommation_drogues VARCHAR(50) COMMENT 'Consommation d''autres drogues',
    drogues_details TEXT COMMENT 'Détails sur la consommation d''autres drogues',
    
    -- Physical activity
    activite_physique VARCHAR(50) COMMENT 'Niveau d''activité physique',
    activite_details TEXT COMMENT 'Détails sur l''activité physique',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE style_vie IS 'Informations sur le style de vie du patient (tabac, alcool, drogues, activité physique)';

-- ==============================================================================
-- INDEXES FOR PERFORMANCE
-- ==============================================================================

-- Primary patient reference indexes
CREATE INDEX idx_geocodage_patient_id ON geocodage(patient_id);
CREATE INDEX idx_donnees_socio_patient_id ON donnees_socio_demographiques(patient_id);
CREATE INDEX idx_diagnostics_patient_id ON diagnostics(patient_id);
CREATE INDEX idx_actes_patient_id ON actes(patient_id);
CREATE INDEX idx_fonction_renale_patient_id ON fonction_renale(patient_id);
CREATE INDEX idx_hemogramme_patient_id ON hemogramme(patient_id);
CREATE INDEX idx_bilan_hepatique_patient_id ON bilan_hepatique(patient_id);
CREATE INDEX idx_biologie_autres_patient_id ON biologie_autres(patient_id);
CREATE INDEX idx_exposition_medicamenteuse_patient_id ON exposition_medicamenteuse(patient_id);
CREATE INDEX idx_posologie_detail_patient_id ON posologie_detail(patient_id);
CREATE INDEX idx_dosage_patient_id ON dosage(patient_id);
CREATE INDEX idx_dossier_soins_patient_id ON dossier_soins(patient_id);
CREATE INDEX idx_style_vie_patient_id ON style_vie(patient_id);

-- Date indexes for temporal queries
CREATE INDEX idx_diagnostics_date_recueil ON diagnostics(date_recueil);
CREATE INDEX idx_actes_date_recueil ON actes(date_recueil);
CREATE INDEX idx_exposition_medicamenteuse_created_at ON exposition_medicamenteuse(created_at);
CREATE INDEX idx_dosage_date_administration ON dosage(date_administration);

-- Clinical code indexes
CREATE INDEX idx_diagnostics_code ON diagnostics(code_diagnostic);
CREATE INDEX idx_actes_code ON actes(code_acte);
CREATE INDEX idx_exposition_medicamenteuse_atc ON exposition_medicamenteuse(codification_atc);

-- ==============================================================================
-- END OF DDL SCRIPT
-- ==============================================================================
