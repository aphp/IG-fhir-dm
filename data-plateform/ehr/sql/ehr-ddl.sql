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
    date_naissance DATE, -- NOT NULL,  ça peut être null
    sexe VARCHAR(20),  -- c'était dans PMSI, c'est pas plus mal là.
    date_deces DATE,
    source_deces VARCHAR(50),
    rang_gemellaire INTEGER,
    
    -- Geocoding fields (linkId: 3816475533472)
--    latitude DECIMAL(10,7),  -- problème de gestion de la cardinalité et de la date de recueil
--    longitude DECIMAL(10,7), -- problème de gestion de la cardinalité et de la date de recueil
--    code_iris VARCHAR(20), -- problème de gestion de la cardinalité et de la date de recueil
--    libelle_iris VARCHAR(200), -- problème de gestion de la cardinalité et de la date de recueil
    
    -- Geographic residence
--    code_geographique_residence VARCHAR(10),  -- il s'agit d'une donnée PMSI, liée à une prise en charge PMSI.
--    libelle_geographique_residence VARCHAR(200),
    
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
--    statut_administratif VARCHAR(50), je ne sais pas ce que c'est ?!
    
    -- Healthcare facility information <- pas prévu dans le socle. Le niveau établissement pourquoi pas, le reste c'est superfaitatoire. 
    etablissement VARCHAR(255),
    service VARCHAR(255),
    unite_fonctionnelle VARCHAR(255),
    -- Link to data collection context
--    date_recueil DATE,  -- j'ai simplifié age et déplacé la géographie donc cette colonne n'est plus nécessaire
    
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
--    date_diagnostic DATE,   c'est pas dans le socle et c'est compliqué
    
    -- Sequencing information for multiple diagnoses
--    sequence_diagnostic INTEGER, je ne sais pas d'ou ça sort, ça ne me semble pas avoir d'intéret (ni pour l'usage, ni dans le cadre du pmsi)
    
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
    
    -- Sequencing information for multiple acts
--    sequence_acte INTEGER,  je ne sais pas d'ou ça sort, ça ne me semble pas avoir d'intéret
    
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
    
    -- Quality information
--    commentaire TEXT,  -- pas dans le socle
--    methode_analyse VARCHAR(255), -- pas dans le socle, plus ou moins dans LOINC
    laboratoire VARCHAR(255),  -- pas dans le socle
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: exposition_medicamenteuse
-- Medication exposure data linked to encounters and patients
-- Based on linkId: 817801935685 (Exposition médicamenteuse) - repeats=true
/*CREATE TABLE exposition_medicamenteuse (  -- cette partie n'est pas aboutie dans le socle, ce qui explique a mon avis un peu que ce soit la bazard dans le résultat de l'ia.
    exposition_id BIGSERIAL PRIMARY KEY,
--    pmsi_id BIGINT NOT NULL,  -- implique qu'on n'a que des exposition médicamenteuse durant une prise en charge PMSI.
    patient_id BIGINT NOT NULL,
    
    -- Medication identification (linkId: 817801935685)
    code_atc VARCHAR(20),
    denomination VARCHAR(255),
    forme_pharmaceutique VARCHAR(100),  -- je sais pas trop ce que ça recouvre, mais pour voie d'administration, faute de simple, il y a tous les Standard Terms, c'est peut être lié.
    
    -- Administration details
    voie_administration VARCHAR(100),
    
    -- Prescription context
    type_prescription VARCHAR(50),
    prescripteur VARCHAR(255),  -- pas dans le socle
    
    -- Temporal information  -- doublonne des champs de la table posologie
    date_debut DATE,
    date_fin DATE,
    date_prescription DATE,  -- pas dans le socle
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);*/

-- Table: dossier_soins  
-- Clinical care measurements and observations
-- Based on linkId: 305831246173 (Dossier de soins) - repeats=true
CREATE TABLE dossier_soins (  --il aurait pu génériciser, comme pour la bio...
    soin_id BIGSERIAL PRIMARY KEY,
--    pmsi_id BIGINT NOT NULL,  -- implique qu'on n'a ces infos que durant une prise en charge PMSI.
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
--    type_mesure VARCHAR(100),  -- pas dans le socle (je sais pas ce que ça peut être du reste)
    unite_soins VARCHAR(255),  -- pas dans le socle 
    professionnel VARCHAR(255),  -- pas dans le socle 
    
    -- Additional clinical data
--    commentaire TEXT,  -- pas dans le socle 
    
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
--    patient_id BIGINT NOT NULL,
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

/*-- Table: dosage 
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
);*/

-- Table: style_vie
-- Consolidated lifestyle information (linkId: 1693164086678)
CREATE TABLE style_vie (  -- vu le Questionnaire, il pouvait pas faire beaucoup mieux...
    style_vie_id BIGSERIAL PRIMARY KEY,
--    pmsi_id BIGINT NOT NULL,  -- idem
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

ALTER TABLE actes 
ADD CONSTRAINT fk_actes_pmsi 
FOREIGN KEY (pmsi_id) REFERENCES donnees_pmsi(pmsi_id) ON DELETE CASCADE;

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

ALTER TABLE posologie 
ADD CONSTRAINT fk_posologie_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE administration 
ADD CONSTRAINT fk_prescription_patient 
FOREIGN KEY (patient_id) REFERENCES patient(patient_id) ON DELETE CASCADE;

ALTER TABLE administration 
ADD CONSTRAINT fk_posologie_prescription 
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
CHECK (date_naissance <= CURRENT_DATE);

ALTER TABLE patient_adresse
ADD CONSTRAINT chk_patient_latitude 
CHECK (latitude BETWEEN -90 AND 90);

ALTER TABLE patient_adresse
ADD CONSTRAINT chk_patient_longitude 
CHECK (longitude BETWEEN -180 AND 180);

/*ALTER TABLE donnees_pmsi 
ADD CONSTRAINT chk_pmsi_duree_sejour 
CHECK (duree_sejour >= 0);*/

ALTER TABLE donnees_pmsi 
ADD CONSTRAINT chk_pmsi_dates 
CHECK (date_fin_sejour >= date_debut_sejour);

/*ALTER TABLE donnees_pmsi -- il y a pas de champ sexe dans la table PMSI 
ADD CONSTRAINT chk_pmsi_sexe 
CHECK (sexe IN ('M', 'F', '1', '2', '9'));*/

ALTER TABLE biologie 
ADD CONSTRAINT chk_biologie_bornes 
CHECK (borne_sup_normale IS NULL OR borne_inf_normale IS NULL OR borne_sup_normale >= borne_inf_normale);

ALTER TABLE biologie
ADD CONSTRAINT chk_biologie_type_examen
CHECK (type_examen IN ('fonction_renale', 'bilan_hepatique', 'hemogramme', 'autres'));  -- c'est marrant, il met coag et métabolisme qui est pertinent pour certaines analyse mais qui n'existe pas dans le questionnaire

ALTER TABLE prescription
ADD CONSTRAINT chk_prescription_dates
CHECK (date_fin_prescription IS NULL OR date_debut_prescription IS NULL OR date_fin_prescription >= date_debut_prescription);

ALTER TABLE administration
ADD CONSTRAINT chk_administration_dates
CHECK (date_heure_fin IS NULL OR date_heure_debut IS NULL);

/*ALTER TABLE exposition_medicamenteuse
ADD CONSTRAINT chk_exposition_type
CHECK (type_prescription IN ('prescrit', 'administré'));*/

/*ALTER TABLE exposition_medicamenteuse
ADD CONSTRAINT chk_exposition_duree
CHECK (duree_traitement IS NULL OR duree_traitement > 0);  -- ce champ n'existe pas */

/*ALTER TABLE dossier_soins 
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
CHECK (pression_diastolique IS NULL OR (pression_diastolique > 0 AND pression_diastolique < 200));*/

-- ========================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ========================================================================

-- Primary lookup indexes on patient table
CREATE INDEX idx_patient_nir ON patient(nir) WHERE nir IS NOT NULL;
CREATE INDEX idx_patient_ins ON patient(ins) WHERE ins IS NOT NULL;
CREATE INDEX idx_patient_nom_prenom ON patient(nom, prenom);
CREATE INDEX idx_patient_date_naissance ON patient(date_naissance);
-- CREATE INDEX idx_patient_code_postal ON patient(code_postal);
--CREATE INDEX idx_patient_commune ON patient(commune);

-- Primary lookup index on patient_location table
CREATE INDEX idx_patient_adresse_iris ON patient_adresse(code_iris) WHERE code_iris IS NOT NULL;

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
--CREATE INDEX idx_diagnostics_date ON diagnostics(date_diagnostic);

-- Procedure/acts indexes
CREATE INDEX idx_actes_pmsi_id ON actes(pmsi_id);
CREATE INDEX idx_actes_code ON actes(code_acte);
CREATE INDEX idx_actes_date ON actes(date_acte);
CREATE INDEX idx_actes_date_recueil ON actes(date_recueil);

-- Laboratory results indexes - optimized for consolidated table
--CREATE INDEX idx_biologie_pmsi_id ON biologie(pmsi_id);
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
--CREATE INDEX idx_soins_pmsi_id ON dossier_soins(pmsi_id);
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

-- Geographic/spatial indexes
CREATE INDEX idx_patient_coords ON patient_adresse(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
--CREATE INDEX idx_patient_iris ON patient(code_iris) WHERE code_iris IS NOT NULL;

-- Partial indexes for performance
CREATE INDEX idx_biologie_valeur_non_null ON biologie(valeur) WHERE valeur IS NOT NULL;
CREATE INDEX idx_exposition_active ON prescription(patient_id, date_debut_prescription, date_fin_prescription) 
WHERE date_debut_prescription IS NOT NULL;

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

--COMMENT ON TABLE dosage IS 'Specific dosage administration details (linkId: 5720103839343)';

COMMENT ON TABLE style_vie IS 'Consolidated lifestyle information including tobacco, alcohol, drugs, and physical activity (linkId: 1693164086678)';

-- ==============================================================================
-- END OF DDL SCRIPT
-- ==============================================================================
