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