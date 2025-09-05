-- PostgreSQL DDL Schema for Questionnaire Usage Core (CORRECTED VERSION)
-- Generated from: input/resources/usages/core/Questionnaire-UsageCore.json
-- Description: Variables socles pour les EDSH (Core variables for Health Data Warehouses)
-- Database: PostgreSQL

-- ==============================================================================
-- PATIENT IDENTITY INFORMATION
-- ==============================================================================

CREATE TABLE identite_patient (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) UNIQUE NOT NULL, -- Link to main patient table
    nom_patient VARCHAR(255),
    prenom_patient VARCHAR(255),
    nir VARCHAR(15) CHECK (nir ~ '^[0-9]{13}$|^[0-9]{15}$'), -- NIR format validation
    ins VARCHAR(50),
    date_naissance DATE CHECK (date_naissance <= CURRENT_DATE),
    date_deces DATE CHECK (date_deces >= date_naissance AND date_deces <= CURRENT_DATE),
    source_date_deces VARCHAR(10) CHECK (source_date_deces IN ('INSEE', 'CepiDc', 'SIH')),
    rang_gemellaire INTEGER CHECK (rang_gemellaire > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Comments for identite_patient table and columns
COMMENT ON TABLE identite_patient IS 'Identitologie. Clé d''appariement unique pouvant permettre le chaînage direct du socle avec d''autres bases';
COMMENT ON COLUMN identite_patient.nom_patient IS 'Nom patient';
COMMENT ON COLUMN identite_patient.prenom_patient IS 'Prénom patient';
COMMENT ON COLUMN identite_patient.nir IS 'Numéro d''inscription au Répertoire (NIR) - Numéro unique attribué à chaque personne à sa naissance sur la base d''éléments d''état civil transmis par les mairies à l''INSEE';
COMMENT ON COLUMN identite_patient.ins IS 'Identité Nationale de Santé (INS) - Numéro d''identité unique, pérenne, partagée par l''ensemble des professionnels du monde de la santé';
COMMENT ON COLUMN identite_patient.date_naissance IS 'Date de naissance des papiers d''identité utilisés pour la production de l''INS';
COMMENT ON COLUMN identite_patient.date_deces IS 'Date de décès à l''hopital, ou date de décès collectée par chaînage avec une base externe comme l''INSEE ou le CepiDc';
COMMENT ON COLUMN identite_patient.source_date_deces IS 'Source de la date de décès: INSEE, CepiDc, SIH';
COMMENT ON COLUMN identite_patient.rang_gemellaire IS 'Rang gémellaire du bénéficiaire - Pour le régime général, il permet de distinguer les naissances gémellaires de même sexe';

-- ==============================================================================
-- GEOCODING INFORMATION (REPEATABLE)
-- ==============================================================================

CREATE TABLE geocodage (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) CHECK (latitude BETWEEN -90 AND 90),
    longitude DECIMAL(11,8) CHECK (longitude BETWEEN -180 AND 180),
    date_recueil DATE CHECK (date_recueil <= CURRENT_DATE),
    iris_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE geocodage IS 'Coordonnées géographiques (latitude et longitude) de l''adresse du patient';
COMMENT ON COLUMN geocodage.latitude IS 'Latitude des coordonnées géographiques de l''adresse du patient';
COMMENT ON COLUMN geocodage.longitude IS 'Longitude des coordonnées géographiques de l''adresse du patient';
COMMENT ON COLUMN geocodage.date_recueil IS 'Date du recueil de l''information géographique';
COMMENT ON COLUMN geocodage.iris_code IS 'Code IRIS de la zone géographique';

-- ==============================================================================
-- PATIENT DEMOGRAPHIC DATA
-- ==============================================================================

CREATE TABLE donnees_socio_demographiques (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    age INTEGER CHECK (age >= 0 AND age <= 150),
    date_recueil_age DATE CHECK (date_recueil_age <= CURRENT_DATE),
    sexe VARCHAR(10) CHECK (sexe IN ('Homme', 'Femme', 'Inconnu')),
    code_geographique_residence VARCHAR(10),
    date_recueil_residence DATE CHECK (date_recueil_residence <= CURRENT_DATE),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON COLUMN donnees_socio_demographiques.age IS 'Age du patient';
COMMENT ON COLUMN donnees_socio_demographiques.date_recueil_age IS 'Date du recueil de l''information d''âge';
COMMENT ON COLUMN donnees_socio_demographiques.sexe IS 'Sexe du patient: Homme/Femme';
COMMENT ON COLUMN donnees_socio_demographiques.code_geographique_residence IS 'Code de la commune de résidence du patient selon la classification PMSI';
COMMENT ON COLUMN donnees_socio_demographiques.date_recueil_residence IS 'Date du recueil de l''information de résidence';

-- ==============================================================================
-- PMSI STAY INFORMATION (moved before diagnostics for referential integrity)
-- ==============================================================================

CREATE TABLE donnees_pmsi (
    id SERIAL PRIMARY KEY,
    sejour_id VARCHAR(50) UNIQUE NOT NULL, -- Added unique constraint
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    date_debut_sejour DATE CHECK (date_debut_sejour <= CURRENT_DATE),
    date_fin_sejour DATE CHECK (date_fin_sejour >= date_debut_sejour),
    mode_entree VARCHAR(10),
    mode_sortie VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE donnees_pmsi IS 'Description générale du patient et de la venue à l''hôpital, dans les différents PMSI (MCO, SSR, HAD, Psy)';
COMMENT ON COLUMN donnees_pmsi.date_debut_sejour IS 'Date de début de séjour';
COMMENT ON COLUMN donnees_pmsi.date_fin_sejour IS 'Date de fin de séjour';
COMMENT ON COLUMN donnees_pmsi.mode_entree IS 'Mode d''entrée du séjour';
COMMENT ON COLUMN donnees_pmsi.mode_sortie IS 'Mode de sortie pendant le séjour';

-- ==============================================================================
-- PMSI DIAGNOSTICS (REPEATABLE)
-- ==============================================================================

CREATE TABLE diagnostics (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    sejour_id VARCHAR(50) REFERENCES donnees_pmsi(sejour_id), -- Proper foreign key
    date_recueil DATE CHECK (date_recueil <= CURRENT_DATE),
    type_diagnostic VARCHAR(10) CHECK (type_diagnostic IN ('DP', 'DAS', 'DR')),
    code_diagnostic VARCHAR(20) CHECK (code_diagnostic ~ '^[A-Z][0-9]{2}(\.[0-9])?$'), -- Basic CIM-10 format
    libelle_diagnostic VARCHAR(1000), -- Increased size for complex diagnoses
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE diagnostics IS 'Diagnostics du patient dans le contexte PMSI';
COMMENT ON COLUMN diagnostics.sejour_id IS 'Identifiant du séjour';
COMMENT ON COLUMN diagnostics.date_recueil IS 'Date du recueil de l''information diagnostique';
COMMENT ON COLUMN diagnostics.type_diagnostic IS 'Type de diagnostic: DP (Principal), DAS (Associé significatif), DR (Relié)';
COMMENT ON COLUMN diagnostics.code_diagnostic IS 'Code diagnostique (CIM-10)';
COMMENT ON COLUMN diagnostics.libelle_diagnostic IS 'Libellé du diagnostic';

-- ==============================================================================
-- PMSI PROCEDURES (REPEATABLE)
-- ==============================================================================

CREATE TABLE actes (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    sejour_id VARCHAR(50) REFERENCES donnees_pmsi(sejour_id),
    date_recueil DATE CHECK (date_recueil <= CURRENT_DATE),
    code_acte VARCHAR(20),
    libelle_acte VARCHAR(1000), -- Increased size
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE actes IS 'Actes et procédures médicales du patient';
COMMENT ON COLUMN actes.sejour_id IS 'Identifiant du séjour';
COMMENT ON COLUMN actes.date_recueil IS 'Date du recueil de l''information d''acte';
COMMENT ON COLUMN actes.code_acte IS 'Code de l''acte médical';
COMMENT ON COLUMN actes.libelle_acte IS 'Libellé de l''acte médical';

-- ==============================================================================
-- RENAL FUNCTION BIOLOGY TESTS
-- ==============================================================================

CREATE TABLE fonction_renale (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    
    -- Urea
    uree_valeur DECIMAL(10,3) CHECK (uree_valeur >= 0),
    uree_code_loinc VARCHAR(20),
    uree_date_prelevement TIMESTAMP WITH TIME ZONE,
    uree_statut_validation VARCHAR(50),
    uree_borne_inf DECIMAL(10,3) CHECK (uree_borne_inf >= 0),
    uree_borne_sup DECIMAL(10,3) CHECK (uree_borne_sup >= uree_borne_inf),
    
    -- Creatinine
    creatinine_valeur DECIMAL(10,3) CHECK (creatinine_valeur >= 0),
    creatinine_code_loinc VARCHAR(20),
    creatinine_date_prelevement TIMESTAMP WITH TIME ZONE,
    creatinine_statut_validation VARCHAR(50),
    creatinine_borne_inf DECIMAL(10,3) CHECK (creatinine_borne_inf >= 0),
    creatinine_borne_sup DECIMAL(10,3) CHECK (creatinine_borne_sup >= creatinine_borne_inf),
    
    -- GFR (Glomerular Filtration Rate)
    dfg_valeur DECIMAL(10,3) CHECK (dfg_valeur >= 0),
    dfg_code_loinc VARCHAR(20),
    dfg_date_prelevement TIMESTAMP WITH TIME ZONE,
    dfg_statut_validation VARCHAR(50),
    dfg_borne_inf DECIMAL(10,3) CHECK (dfg_borne_inf >= 0),
    dfg_borne_sup DECIMAL(10,3) CHECK (dfg_borne_sup >= dfg_borne_inf),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE fonction_renale IS 'Dosage sanguin de l''urée qui permet d''évaluer la fonction rénale';

-- ==============================================================================
-- COMPLETE HEPATIC ASSESSMENT (FIXED)
-- ==============================================================================

CREATE TABLE bilan_hepatique (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(50) NOT NULL REFERENCES identite_patient(patient_id) ON DELETE CASCADE,
    
    -- AST (Aspartate aminotransferase)
    ast_valeur DECIMAL(10,3) CHECK (ast_valeur >= 0),
    ast_code_loinc VARCHAR(20),
    ast_date_prelevement TIMESTAMP WITH TIME ZONE,
    ast_statut_validation VARCHAR(50),
    ast_borne_inf DECIMAL(10,3),
    ast_borne_sup DECIMAL(10,3),
    
    -- ALT (Alanine aminotransferase)
    alt_valeur DECIMAL(10,3) CHECK (alt_valeur >= 0),
    alt_code_loinc VARCHAR(20),
    alt_date_prelevement TIMESTAMP WITH TIME ZONE,
    alt_statut_validation VARCHAR(50),
    alt_borne_inf DECIMAL(10,3),
    alt_borne_sup DECIMAL(10,3),
    
    -- Bilirubin total
    bilirubine_totale_valeur DECIMAL(10,3) CHECK (bilirubine_totale_valeur >= 0),
    bilirubine_totale_code_loinc VARCHAR(20),
    bilirubine_totale_date_prelevement TIMESTAMP WITH TIME ZONE,
    bilirubine_totale_statut_validation VARCHAR(50),
    bilirubine_totale_borne_inf DECIMAL(10,3),
    bilirubine_totale_borne_sup DECIMAL(10,3),
    
    -- Alkaline Phosphatase
    phosphatases_alcalines_valeur DECIMAL(10,3) CHECK (phosphatases_alcalines_valeur >= 0),
    phosphatases_alcalines_code_loinc VARCHAR(20),
    phosphatases_alcalines_date_prelevement TIMESTAMP WITH TIME ZONE,
    phosphatases_alcalines_statut_validation VARCHAR(50),
    phosphatases_alcalines_borne_inf DECIMAL(10,3),
    phosphatases_alcalines_borne_sup DECIMAL(10,3),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE bilan_hepatique IS 'Bilan hépatique - tests de fonction hépatique incluant AST, ALT, bilirubine et phosphatases alcalines';

-- ==============================================================================
-- ENHANCED INDEXES FOR PERFORMANCE
-- ==============================================================================

-- Primary patient reference indexes
CREATE INDEX idx_geocodage_patient_id ON geocodage(patient_id);
CREATE INDEX idx_donnees_socio_patient_id ON donnees_socio_demographiques(patient_id);
CREATE INDEX idx_diagnostics_patient_id ON diagnostics(patient_id);
CREATE INDEX idx_actes_patient_id ON actes(patient_id);
CREATE INDEX idx_fonction_renale_patient_id ON fonction_renale(patient_id);
CREATE INDEX idx_bilan_hepatique_patient_id ON bilan_hepatique(patient_id);

-- Composite indexes for common query patterns
CREATE INDEX idx_diagnostics_patient_type ON diagnostics(patient_id, type_diagnostic);
CREATE INDEX idx_diagnostics_patient_date ON diagnostics(patient_id, date_recueil);
CREATE INDEX idx_actes_patient_date ON actes(patient_id, date_recueil);

-- Date indexes for temporal queries
CREATE INDEX idx_diagnostics_date_recueil ON diagnostics(date_recueil);
CREATE INDEX idx_actes_date_recueil ON actes(date_recueil);

-- Clinical code indexes
CREATE INDEX idx_diagnostics_code ON diagnostics(code_diagnostic);
CREATE INDEX idx_actes_code ON actes(code_acte);

-- Demographics indexes
CREATE INDEX idx_donnees_socio_sexe ON donnees_socio_demographiques(sexe);
CREATE INDEX idx_donnees_socio_age ON donnees_socio_demographiques(age);

-- LOINC code indexes for biological data
CREATE INDEX idx_fonction_renale_uree_loinc ON fonction_renale(uree_code_loinc) WHERE uree_code_loinc IS NOT NULL;
CREATE INDEX idx_fonction_renale_creat_loinc ON fonction_renale(creatinine_code_loinc) WHERE creatinine_code_loinc IS NOT NULL;
CREATE INDEX idx_bilan_hepatique_ast_loinc ON bilan_hepatique(ast_code_loinc) WHERE ast_code_loinc IS NOT NULL;

-- ==============================================================================
-- SECURITY CONSIDERATIONS (RECOMMENDATIONS)
-- ==============================================================================

-- Create a dedicated schema for sensitive data
-- CREATE SCHEMA edsh_secure;

-- For production: Consider using row-level security (RLS) for patient data
-- ALTER TABLE identite_patient ENABLE ROW LEVEL SECURITY;

-- For production: Consider encrypting NIR and INS fields
-- Consider using PostgreSQL's pgcrypto extension for field-level encryption

-- ==============================================================================
-- END OF CORRECTED DDL SCRIPT
-- ==============================================================================