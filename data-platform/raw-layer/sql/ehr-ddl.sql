-- ========================================================================
-- PostgreSQL DDL Script for FHIR Questionnaire Core Variables EDSH
-- Generated from: input/resources/usages/core/Questionnaire-UsageCore.json
-- 
-- This script creates an optimized schema for storing FHIR Questionnaire
-- responses related to core health data variables for EDSH.
--
-- ========================================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS style_vie CASCADE;
DROP TABLE IF EXISTS posologie CASCADE;
DROP TABLE IF EXISTS administration CASCADE;
DROP TABLE IF EXISTS dossier_soins CASCADE;
DROP TABLE IF EXISTS prescription CASCADE;
DROP TABLE IF EXISTS biologie CASCADE;
DROP TABLE IF EXISTS actes CASCADE;
DROP TABLE IF EXISTS diagnostics CASCADE;
DROP TABLE IF EXISTS donnees_pmsi CASCADE;
DROP TABLE IF EXISTS patient_adresse CASCADE;
DROP TABLE IF EXISTS patient CASCADE;

-- ========================================================================
-- TABLES
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
    date_naissance DATE, -- NOT NULL,  ça peut être null
    sexe VARCHAR(20),  -- c'était dans PMSI, c'est pas plus mal là.
    date_deces DATE,
    source_deces VARCHAR(50),
    rang_gemellaire INTEGER,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patient_adresse (
    patient_adresse_id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL,

    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    code_iris VARCHAR(20),
    libelle_iris VARCHAR(200),
    code_geographique_residence VARCHAR(10),
    libelle_geographique_residence VARCHAR(200),
    date_recueil DATE,

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
--    duree_sejour INTEGER, 
    age_admission INTEGER, --nécessaire si on n'a pas de date de naissance
    
    -- Stay dates and administrative data
    date_debut_sejour DATE,
    date_fin_sejour DATE,
    mode_entree VARCHAR(100),
    
    -- Healthcare facility information <- pas prévu dans le socle. Le niveau établissement pourquoi pas, le reste c'est superfaitatoire. 
    etablissement VARCHAR(255),
    service VARCHAR(255),
    unite_fonctionnelle VARCHAR(255),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: diagnostics
-- Diagnostic codes and information linked to PMSI encounters
CREATE TABLE diagnostics (
    diagnostic_id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    pmsi_id BIGINT NOT NULL,
    
    -- Diagnostic information (linkId: 9391816419630)
    code_diagnostic VARCHAR(20) NOT NULL,
    type_diagnostic VARCHAR(50),
    libelle_diagnostic TEXT,
    
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
    patient_id BIGINT NOT NULL,
    pmsi_id BIGINT NOT NULL,
    
    -- Act/procedure information (linkId: 591926901726)
    code_acte VARCHAR(20) NOT NULL,
    libelle_acte TEXT,
    date_acte TIMESTAMP,
    executant VARCHAR(255),  -- c'est pas dans le socle
    
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
--    pmsi_id BIGINT NOT NULL,  -- implique qu'on n'a que de la bio durant une prise en charge PMSI.
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
    
    laboratoire VARCHAR(255),  -- pas dans le socle
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: dossier_soins  
-- Clinical care measurements and observations
-- Based on linkId: 305831246173 (Dossier de soins) - repeats=true
CREATE TABLE dossier_soins (
    soin_id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    
    -- Physical measurements (linkId: 305831246173)
    code_loinc VARCHAR(20),
    libelle_test VARCHAR(255),

    valeur DECIMAL(15,6),
    unite VARCHAR(50),
    valeur_code VARCHAR(50),
    valeur_texte TEXT,

    date_mesure DATE,
    
    -- Measurement context
    unite_soins VARCHAR(255),  -- pas dans le socle 
    professionnel VARCHAR(255),  -- pas dans le socle 
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE prescription (
    prescription_id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    
    prescripteur VARCHAR(50),
    -- Medication identification (linkId: 817801935685)
    denomination VARCHAR(255),
    code_atc VARCHAR(20),
    
    -- Administration details
    voie_administration VARCHAR(100),
        
    -- Temporal information
    date_prescription DATE,  -- pas dans le socle
    date_debut_prescription DATE,
    date_fin_prescription DATE,

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: posologie
-- Detailed dosing information (linkId: 6348237104421)
CREATE TABLE posologie (  
    posologie_id BIGSERIAL PRIMARY KEY,
    prescription_id BIGINT NOT NULL,
    
    -- Posology details, à enrichir+++
    nombre_prises_par_jour INTEGER,
    quantite DECIMAL(10,3),
    unite_quantite VARCHAR(20),
    date_heure_debut TIMESTAMP,
    date_heure_fin TIMESTAMP,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE administration (
    administration_id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    prescription_id BIGINT,
    
    -- Medication identification (linkId: 817801935685)
    denomination VARCHAR(255),
    code_atc VARCHAR(20),
    
    -- Administration details
    voie_administration VARCHAR(100),
    
    -- Quantity information
    quantite DECIMAL(10,3),
    unite_quantite VARCHAR(20),

    -- Temporal information
    date_heure_debut TIMESTAMP,
    date_heure_fin TIMESTAMP,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: style_vie
-- Consolidated lifestyle information (linkId: 1693164086678)
CREATE TABLE style_vie (  -- vu le Questionnaire, il pouvait pas faire beaucoup mieux...
    style_vie_id BIGSERIAL PRIMARY KEY,
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
ALTER TABLE patient_adresse 
ADD CONSTRAINT fk_patient_patient_adresse
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE donnees_pmsi 
ADD CONSTRAINT fk_donnees_pmsi_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE diagnostics 
ADD CONSTRAINT fk_diagnostics_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;
ALTER TABLE diagnostics 
ADD CONSTRAINT fk_diagnostics_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE actes 
ADD CONSTRAINT fk_actes_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;
ALTER TABLE actes 
ADD CONSTRAINT fk_actes_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE biologie 
ADD CONSTRAINT fk_biologie_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE dossier_soins 
ADD CONSTRAINT fk_dossier_soins_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE prescription 
ADD CONSTRAINT fk_prescription_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE posologie 
ADD CONSTRAINT fk_posologie_prescription 
FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id) ON DELETE CASCADE;

ALTER TABLE administration 
ADD CONSTRAINT fk_administration_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE administration 
ADD CONSTRAINT fk_administration_prescription 
FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id);

ALTER TABLE style_vie 
ADD CONSTRAINT fk_style_vie_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

-- Check constraints for data quality
ALTER TABLE patient 
ADD CONSTRAINT chk_patient_sexe 
CHECK (sexe IN ('h', 'f'));

ALTER TABLE patient 
ADD CONSTRAINT chk_patient_date_naissance 
CHECK (date_naissance <= CURRENT_DATE AND date_naissance >= '1900-01-01');

ALTER TABLE patient 
ADD CONSTRAINT chk_patient_date_deces 
CHECK (date_deces IS NULL OR (date_deces >= date_naissance AND date_deces <= CURRENT_DATE));

ALTER TABLE patient 
ADD CONSTRAINT chk_patient_nir_format 
CHECK (nir IS NULL OR (nir ~ '^[0-9]{13,15}$'));

ALTER TABLE patient 
ADD CONSTRAINT chk_patient_rang_gemellaire 
CHECK (rang_gemellaire IS NULL OR rang_gemellaire BETWEEN 1 AND 10);

ALTER TABLE patient_adresse
ADD CONSTRAINT chk_patient_latitude 
CHECK (latitude BETWEEN -90 AND 90);

ALTER TABLE patient_adresse
ADD CONSTRAINT chk_patient_longitude 
CHECK (longitude BETWEEN -180 AND 180);

ALTER TABLE donnees_pmsi 
ADD CONSTRAINT chk_pmsi_dates 
CHECK (date_fin_sejour >= date_debut_sejour);

ALTER TABLE biologie 
ADD CONSTRAINT chk_biologie_bornes 
CHECK (borne_sup_normale IS NULL OR borne_inf_normale IS NULL OR borne_sup_normale >= borne_inf_normale);

ALTER TABLE biologie
ADD CONSTRAINT chk_biologie_type_examen
CHECK (type_examen IN ('fonction_renale', 'bilan_hepatique', 'hemogramme', 'autres'));

ALTER TABLE biologie
ADD CONSTRAINT chk_biologie_valeur_positive
CHECK (valeur IS NULL OR valeur >= 0);

ALTER TABLE biologie
ADD CONSTRAINT chk_biologie_date_prelevement
CHECK (date_prelevement IS NULL OR date_prelevement <= CURRENT_TIMESTAMP);

ALTER TABLE biologie
ADD CONSTRAINT chk_biologie_statut_validation
CHECK (statut_validation IS NULL OR statut_validation IN ('en_attente', 'valide', 'rejete', 'en_cours'));  -- c'est marrant, il met coag et métabolisme qui est pertinent pour certaines analyse mais qui n'existe pas dans le questionnaire

ALTER TABLE prescription
ADD CONSTRAINT chk_prescription_dates
CHECK (date_fin_prescription IS NULL OR date_debut_prescription IS NULL OR date_fin_prescription >= date_debut_prescription);

ALTER TABLE administration
ADD CONSTRAINT chk_administration_dates
CHECK (date_heure_fin IS NULL OR date_heure_debut IS NULL OR date_heure_fin >= date_heure_debut);

ALTER TABLE administration
ADD CONSTRAINT chk_administration_quantite
CHECK (quantite IS NULL OR quantite > 0);

ALTER TABLE donnees_pmsi
ADD CONSTRAINT chk_pmsi_age_admission
CHECK (age_admission IS NULL OR age_admission BETWEEN 0 AND 150);

ALTER TABLE posologie
ADD CONSTRAINT chk_posologie_prises_jour
CHECK (nombre_prises_par_jour IS NULL OR nombre_prises_par_jour BETWEEN 1 AND 24);

ALTER TABLE posologie
ADD CONSTRAINT chk_posologie_quantite
CHECK (quantite IS NULL OR quantite > 0);

ALTER TABLE posologie
ADD CONSTRAINT chk_posologie_dates
CHECK (date_heure_fin IS NULL OR date_heure_debut IS NULL OR date_heure_fin >= date_heure_debut);

ALTER TABLE dossier_soins
ADD CONSTRAINT chk_soins_valeur_positive
CHECK (valeur IS NULL OR valeur >= 0);

ALTER TABLE dossier_soins
ADD CONSTRAINT chk_soins_date_mesure
CHECK (date_mesure IS NULL OR date_mesure <= CURRENT_DATE);

ALTER TABLE style_vie
ADD CONSTRAINT chk_style_vie_date_recueil
CHECK (date_recueil IS NULL OR date_recueil <= CURRENT_DATE);

-- Additional validation constraints
ALTER TABLE diagnostics
ADD CONSTRAINT chk_diagnostics_code_format
CHECK (code_diagnostic IS NULL OR LENGTH(code_diagnostic) BETWEEN 3 AND 20);

ALTER TABLE diagnostics
ADD CONSTRAINT chk_diagnostics_date_recueil
CHECK (date_recueil IS NULL OR date_recueil <= CURRENT_DATE);

ALTER TABLE actes
ADD CONSTRAINT chk_actes_code_format
CHECK (code_acte IS NULL OR LENGTH(code_acte) BETWEEN 4 AND 20);

ALTER TABLE actes
ADD CONSTRAINT chk_actes_date_acte
CHECK (date_acte IS NULL OR date_acte <= CURRENT_TIMESTAMP);

ALTER TABLE actes
ADD CONSTRAINT chk_actes_date_recueil
CHECK (date_recueil IS NULL OR date_recueil <= CURRENT_DATE);

-- ========================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ========================================================================

-- Primary lookup indexes on patient table
CREATE INDEX idx_patient_nir ON patient(nir) WHERE nir IS NOT NULL;
CREATE INDEX idx_patient_ins ON patient(ins) WHERE ins IS NOT NULL;
CREATE INDEX idx_patient_nom_prenom ON patient(nom, prenom);
CREATE INDEX idx_patient_date_naissance ON patient(date_naissance);

-- donnees_PMSI indexes  
CREATE INDEX idx_pmsi_patient_id ON donnees_pmsi(patient_id);
CREATE INDEX idx_pmsi_date_debut ON donnees_pmsi(date_debut_sejour);
CREATE INDEX idx_pmsi_date_fin ON donnees_pmsi(date_fin_sejour);
CREATE INDEX idx_pmsi_etablissement ON donnees_pmsi(etablissement);
--CREATE INDEX idx_pmsi_unite_fonctionnelle ON donnees_pmsi(unite_fonctionnelle);

-- Diagnostic indexes
CREATE INDEX idx_diagnostics_pmsi_id ON diagnostics(pmsi_id);
CREATE INDEX idx_diagnostics_code ON diagnostics(code_diagnostic);
CREATE INDEX idx_diagnostics_type ON diagnostics(type_diagnostic);

-- Procedure/acts indexes
CREATE INDEX idx_actes_pmsi_id ON actes(pmsi_id);
CREATE INDEX idx_actes_code ON actes(code_acte);
CREATE INDEX idx_actes_date ON actes(date_acte);
CREATE INDEX idx_actes_date_recueil ON actes(date_recueil);

-- Laboratory results indexes - optimized for consolidated table
CREATE INDEX idx_biologie_patient_id ON biologie(patient_id);
CREATE INDEX idx_biologie_code_loinc ON biologie(code_loinc);
CREATE INDEX idx_biologie_type_examen ON biologie(type_examen);
CREATE INDEX idx_biologie_date_prelevement ON biologie(date_prelevement);
CREATE INDEX idx_biologie_statut_validation ON biologie(statut_validation);

-- Prescription indexes
CREATE INDEX idx_prescription_patient_id ON prescription(patient_id);
CREATE INDEX idx_prescription_code_atc ON prescription(code_atc);
CREATE INDEX idx_prescription_date_prescription ON prescription(date_prescription);

-- Administration indexes
CREATE INDEX idx_administration_patient_id ON administration(patient_id);
CREATE INDEX idx_administration_code_atc ON administration(code_atc);
CREATE INDEX idx_administration_denomination ON administration(denomination);
CREATE INDEX idx_administration_date_heure_debut ON administration(date_heure_debut);

-- Clinical care indexes
CREATE INDEX idx_soins_patient_id ON dossier_soins(patient_id);
CREATE INDEX idx_soins_loinc ON dossier_soins(code_loinc);
CREATE INDEX idx_soins_date_mesure ON dossier_soins(date_mesure);

-- Composite indexes for common queries
CREATE INDEX idx_biologie_patient_loinc ON biologie(patient_id, code_loinc);
CREATE INDEX idx_biologie_patient_type ON biologie(patient_id, type_examen);
CREATE INDEX idx_prescription_patient_atc ON prescription(patient_id, code_atc);
CREATE INDEX idx_pmsi_patient_date ON donnees_pmsi(patient_id, date_debut_sejour);
CREATE INDEX idx_diagnostics_pmsi_code ON diagnostics(pmsi_id, code_diagnostic);
CREATE INDEX idx_actes_pmsi_code ON actes(pmsi_id, code_acte);

-- Geographic/spatial indexes optimized for PostgreSQL 17.x
CREATE INDEX idx_patient_coords_gist ON patient_adresse USING gist(point(longitude, latitude)) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
CREATE INDEX idx_patient_adresse_iris ON patient_adresse(code_iris) WHERE code_iris IS NOT NULL;
CREATE INDEX idx_patient_adresse_date ON patient_adresse(patient_id, date_recueil DESC);

-- Partial indexes for performance
CREATE INDEX idx_biologie_valeur_non_null ON biologie(valeur) WHERE valeur IS NOT NULL;
CREATE INDEX idx_prescription_active ON prescription(patient_id, date_debut_prescription, date_fin_prescription) 
WHERE date_debut_prescription IS NOT NULL;

-- Additional performance indexes for PostgreSQL 17.x
CREATE INDEX CONCURRENTLY idx_patient_search ON patient USING gin(to_tsvector('french', COALESCE(nom, '') || ' ' || COALESCE(prenom, '')));
CREATE INDEX idx_biologie_date_patient ON biologie(date_prelevement DESC, patient_id) WHERE date_prelevement IS NOT NULL;
CREATE INDEX idx_pmsi_duree_sejour ON donnees_pmsi((date_fin_sejour - date_debut_sejour)) WHERE date_debut_sejour IS NOT NULL AND date_fin_sejour IS NOT NULL;
CREATE INDEX idx_diagnostics_patient_code ON diagnostics(patient_id, code_diagnostic, date_recueil);
CREATE INDEX idx_actes_patient_code ON actes(patient_id, code_acte, date_acte);
CREATE INDEX idx_prescription_period ON prescription(date_debut_prescription, date_fin_prescription) WHERE date_debut_prescription IS NOT NULL;
CREATE INDEX idx_administration_timeline ON administration(patient_id, date_heure_debut DESC) WHERE date_heure_debut IS NOT NULL;
CREATE INDEX idx_dossier_soins_timeline ON dossier_soins(patient_id, date_mesure DESC) WHERE date_mesure IS NOT NULL;

-- Hash indexes for exact lookups (PostgreSQL 17.x optimization)
CREATE INDEX idx_patient_nir_hash ON patient USING hash(nir) WHERE nir IS NOT NULL;
CREATE INDEX idx_patient_ins_hash ON patient USING hash(ins) WHERE ins IS NOT NULL;
CREATE INDEX idx_biologie_loinc_hash ON biologie USING hash(code_loinc) WHERE code_loinc IS NOT NULL;
CREATE INDEX idx_prescription_atc_hash ON prescription USING hash(code_atc) WHERE code_atc IS NOT NULL;
CREATE INDEX idx_administration_atc_hash ON administration USING hash(code_atc) WHERE code_atc IS NOT NULL;

-- Covering indexes for common queries
CREATE INDEX idx_biologie_covering ON biologie(patient_id, code_loinc, date_prelevement) INCLUDE (valeur, unite, valeur_texte);
CREATE INDEX idx_prescription_covering ON prescription(patient_id, code_atc) INCLUDE (denomination, date_debut_prescription, date_fin_prescription);
CREATE INDEX idx_pmsi_covering ON donnees_pmsi(patient_id, date_debut_sejour) INCLUDE (date_fin_sejour, etablissement, service);

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
COMMENT ON COLUMN patient_adresse.latitude IS 'Latitude du domicile patient (linkId: 3709843054556)';
COMMENT ON COLUMN patient_adresse.longitude IS 'Longitude du domicile patient (linkId: 7651448032665)';

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

COMMENT ON TABLE prescription IS 'Medication prescription data with ATC coding for pharmacovigilance and clinical research, supporting  prescribed medications (linkId: 817801935685)';

COMMENT ON TABLE administration IS 'Medication exposure data with ATC coding for pharmacovigilance and clinical research, supporting administered medications (linkId: 817801935685)';

COMMENT ON TABLE dossier_soins IS 'Clinical care measurements and observations including vital signs, physical measurements, and nursing care data (linkId: 305831246173)';

COMMENT ON TABLE posologie IS 'Detailed dosing information for medications (linkId: 6348237104421)';

COMMENT ON TABLE style_vie IS 'Consolidated lifestyle information including tobacco, alcohol, drugs, and physical activity (linkId: 1693164086678)';

-- ==============================================================================
-- END OF OPTIMIZED DDL SCRIPT FOR POSTGRESQL
-- ==============================================================================
