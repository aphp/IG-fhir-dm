-- ========================================================================
-- PostgreSQL 17.x DML Script for FHIR QuestionnaireResponse Test Data
-- Generated from: input/resources/usages/core/QuestionnaireResponse-test-usage-core-complet.json
-- 
-- This script inserts ALL test data from the QuestionnaireResponse into the
-- EHR database tables according to the optimized schema design.
-- 
-- Data Source: Patient "Doré, Jeanne" - Female, born 1959-07-07
-- NIR: 1590778035124, Complete clinical and laboratory data
-- ========================================================================

-- Begin transaction for data consistency
BEGIN;

-- Use a PL/pgSQL block to handle variable references
DO $$
DECLARE
    v_patient_id INTEGER;
    v_pmsi_id INTEGER;
    v_exposition1_id INTEGER;
    v_exposition2_id INTEGER;
BEGIN

-- ========================================================================
-- PATIENT DATA
-- linkId: "2958000860428" (Identité patient) + "3816475533472" (Géocodage)
-- + "3894630481120" (Sexe) from PMSI data
-- ========================================================================

INSERT INTO patient (
    nom,                    -- linkId: "8605698058770" (Nom patient)
    prenom,                 -- linkId: "6214879623503" (Prénom patient)  
    nir,                    -- linkId: "5711960356160" (NIR)
    ins,                    -- linkId: "3764723550987" (INS)
    date_naissance,         -- linkId: "5036133558154" (Date de naissance)
    sexe,                   -- linkId: "3894630481120" (Sexe - from PMSI)
    latitude,               -- linkId: "3709843054556" (Latitude)
    longitude,              -- linkId: "7651448032665" (Longitude)
    code_geographique_residence, -- linkId: "2446369196222" (Code géographique)
    libelle_geographique_residence
) VALUES (
    'Doré',                 -- From QuestionnaireResponse valueString
    'Jeanne',               -- From QuestionnaireResponse valueString
    '1590778035124',        -- From QuestionnaireResponse valueString (NIR)
    '1590778035124',        -- From QuestionnaireResponse valueString (INS)
    '1959-07-07',           -- From QuestionnaireResponse valueDate
    'F',                    -- From QuestionnaireResponse valueCoding.code (DpiGender system) - uppercase for constraint
    48.88067598033303,      -- From QuestionnaireResponse valueDecimal
    2.331871883929937,      -- From QuestionnaireResponse valueDecimal
    '75009',                -- From QuestionnaireResponse valueCoding.code
    'PARIS 9E ARRONDISSEMENT' -- From QuestionnaireResponse valueCoding.display
)
RETURNING patient_id INTO v_patient_id;

-- ========================================================================
-- PMSI ENCOUNTER DATA
-- linkId: "2825244231605" (Données PMSI)
-- ========================================================================

INSERT INTO donnees_pmsi (
    patient_id,
    date_debut_sejour,      -- linkId: "5991443718282" (Date de début de séjour)
    date_fin_sejour,        -- linkId: "6114780320846" (Date de fin de séjour)
    mode_entree,            -- linkId: "6172398101212" (Mode d'entrée du séjour)
    mode_sortie,            -- linkId: "3354867075704" (Mode de sortie du séjour)
    code_geographique_residence, -- linkId: "2446369196222" (Code géographique)
    libelle_geographique_residence,
    date_recueil            -- From geocoding data collection context
) VALUES (
    v_patient_id,           -- References patient.patient_id from INSERT above
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    'Domicile',             -- From QuestionnaireResponse valueCoding.display (code "8")
    'Domicile',             -- From QuestionnaireResponse valueCoding.display (code "8")
    '75009',                -- From QuestionnaireResponse valueCoding.code
    'PARIS 9E ARRONDISSEMENT', -- From QuestionnaireResponse valueCoding.display
    '2025-08-22'            -- From geocoding collection date (linkId: "1185653257776")
)
RETURNING pmsi_id INTO v_pmsi_id;

-- ========================================================================
-- DIAGNOSTIC DATA - Multiple entries
-- linkId: "9391816419630" (Diagnostics) - 3 occurrences in QuestionnaireResponse
-- ========================================================================

-- Diagnostic 1: E119 - Diabète sucré de type 2, sans complication (DP)
INSERT INTO diagnostics (
    pmsi_id,
    code_diagnostic,        -- linkId: "5505101189372" (Diagnostique)
    type_diagnostic,        -- linkId: "6427586743735" (Type de diagnostic)
    libelle_diagnostic,
    date_recueil,          -- linkId: "7114466839467" (Date du recueil)
    sequence_diagnostic
) VALUES (
    v_pmsi_id,              -- References donnees_pmsi.pmsi_id from INSERT above
    'E119',                 -- From QuestionnaireResponse valueCoding.code
    'DP',                   -- From QuestionnaireResponse valueCoding.display
    'Diabète sucré de type 2, sans complication', -- From valueCoding.display
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    1                       -- First diagnostic
);

-- Diagnostic 2: E6604 - Obésité (DAS)
INSERT INTO diagnostics (
    pmsi_id,
    code_diagnostic,
    type_diagnostic,
    libelle_diagnostic,
    date_recueil,
    sequence_diagnostic
) VALUES (
    v_pmsi_id,              -- References donnees_pmsi.pmsi_id from INSERT above
    'E6604',                -- From QuestionnaireResponse valueCoding.code
    'DAS',                  -- From QuestionnaireResponse valueCoding.display
    'Obésité, sans précision', -- From valueCoding.display
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    2                       -- Second diagnostic
);

-- Diagnostic 3: N183 - Maladie rénale chronique, stade 3a (DAS)
INSERT INTO diagnostics (
    pmsi_id,
    code_diagnostic,
    type_diagnostic,
    libelle_diagnostic,
    date_recueil,
    sequence_diagnostic
) VALUES (
    v_pmsi_id,              -- References donnees_pmsi.pmsi_id from INSERT above
    'N183',                 -- From QuestionnaireResponse valueCoding.code
    'DAS',                  -- From QuestionnaireResponse valueCoding.display
    'Maladie rénale chronique, stade 3a', -- From valueCoding.display
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    3                       -- Third diagnostic
);

-- ========================================================================
-- MEDICAL ACTS DATA - Multiple entries
-- linkId: "591926901726" (Actes) - 2 occurrences in QuestionnaireResponse
-- ========================================================================

-- Act 1: DEQP003 - Électrocardiographie
INSERT INTO actes (
    pmsi_id,
    code_acte,             -- linkId: "7758110033600" (Acte)
    libelle_acte,
    date_acte,             -- linkId: "5066866286682" (Date de l'acte)
    date_recueil,          -- linkId: "9436509453137" (Date du recueil)
    sequence_acte
) VALUES (
    v_pmsi_id,              -- References donnees_pmsi.pmsi_id from INSERT above
    'DEQP003',              -- From QuestionnaireResponse valueCoding.code (CCAM system)
    'Électrocardiographie sur au moins 12 dérivations', -- From valueCoding.display
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    1                       -- First act
);

-- Act 2: BGQP002 - Examen du fond d'oeil
INSERT INTO actes (
    pmsi_id,
    code_acte,
    libelle_acte,
    date_acte,
    date_recueil,
    sequence_acte
) VALUES (
    v_pmsi_id,              -- References donnees_pmsi.pmsi_id from INSERT above
    'BGQP002',              -- From QuestionnaireResponse valueCoding.code (CCAM system)
    'Examen du fond d''oeil par biomicroscopie avec verre de contact', -- From valueCoding.display
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    '2025-08-22',           -- From QuestionnaireResponse valueDate
    2                       -- Second act
);

-- ========================================================================
-- LABORATORY RESULTS - RENAL FUNCTION
-- linkId: "5241323453538" (Fonction rénale) - 3 tests
-- ========================================================================

-- Créatinine sérique (linkId: "8344055298045")
INSERT INTO biologie (
    pmsi_id,
    patient_id,
    code_loinc,            -- linkId: "8712072639576" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "8090296522764" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "4087208615207" (Borne inférieure)
    borne_sup_normale      -- linkId: "4646498915453" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '2160-0',              -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Créatinine [Masse/Volume] Sérum/Plasma ; Numérique',
    'fonction_renale',
    87,                    -- From QuestionnaireResponse valueQuantity.value
    'µmol/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z', -- From QuestionnaireResponse valueDateTime
    45,                    -- From QuestionnaireResponse valueQuantity.value
    84                     -- From QuestionnaireResponse valueQuantity.value
);

-- DFG/CKD-EPI (linkId: "6627906107678") 
INSERT INTO biologie (
    pmsi_id,
    patient_id,
    code_loinc,            -- linkId: "977768150991" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "4141872208228" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "1948319621290" (Borne inférieure)
    borne_sup_normale      -- linkId: "952959648127" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '62238-1',             -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'DFG/CKD-EPI.créatinine',
    'fonction_renale',
    57,                    -- From QuestionnaireResponse valueQuantity.value
    'mL/min/1.73m2',       -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    60,                    -- From QuestionnaireResponse valueQuantity.value
    120                    -- From QuestionnaireResponse valueQuantity.value
);

-- Clairance (linkId: "2522344648988")
INSERT INTO biologie (
    pmsi_id,
    patient_id,
    code_loinc,            -- linkId: "974417569313" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "4267447651337" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "9648652863906" (Borne inférieure)
    borne_sup_normale      -- linkId: "8928925853627" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '33914-3',             -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'DFG/1.73 m² [Volume/Temps/Surface] Rénal ; Créatinine ; Estimation',
    'fonction_renale',
    62,                    -- From QuestionnaireResponse valueQuantity.value
    'mL/min/1.73m2',       -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    70,                    -- From QuestionnaireResponse valueQuantity.value
    120                    -- From QuestionnaireResponse valueQuantity.value
);

-- ========================================================================
-- LABORATORY RESULTS - HEMOGRAM
-- linkId: "419282985970" (Hémogramme) - 10 tests
-- ========================================================================

-- Leucocytes (linkId: "1719798551455")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "695484403752" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "678322866025" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "453039749618" (Borne inférieure)
    borne_sup_normale      -- linkId: "178062486522" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '6690-2',              -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Leucocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    7.5,                   -- From QuestionnaireResponse valueQuantity.value
    '10*9/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    4,                     -- From QuestionnaireResponse valueQuantity.value
    10                     -- From QuestionnaireResponse valueQuantity.value
);

-- Hématies (linkId: "9695773577965")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "597082091886" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "668846754669" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "638925966445" (Borne inférieure)
    borne_sup_normale      -- linkId: "851879668451" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '789-8',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Érythrocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    4.5,                   -- From QuestionnaireResponse valueQuantity.value
    '10*12/L',             -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    3.8,                   -- From QuestionnaireResponse valueQuantity.value
    5.4                    -- From QuestionnaireResponse valueQuantity.value
);

-- Hémoglobine (linkId: "814599251677")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "814457693114" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "531188329902" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "476467525637" (Borne inférieure)
    borne_sup_normale      -- linkId: "319764681516" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '718-7',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Hémoglobine [Masse/Volume] Sang ; Numérique',
    'hemogramme',
    13.5,                  -- From QuestionnaireResponse valueQuantity.value
    'g/dL',                -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    11.5,                  -- From QuestionnaireResponse valueQuantity.value
    16                     -- From QuestionnaireResponse valueQuantity.value
);

-- Hématocrite (linkId: "2316619788901")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "274747215145" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "853609426439" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "547491149124" (Borne inférieure)
    borne_sup_normale      -- linkId: "838239924282" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '4544-3',              -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Hématocrite [Fraction volumique] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    40,                    -- From QuestionnaireResponse valueQuantity.value
    '%',                   -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    35,                    -- From QuestionnaireResponse valueQuantity.value
    47                     -- From QuestionnaireResponse valueQuantity.value
);

-- VGM (linkId: "2829915513959")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "117718572179" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "766800452654" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "472419988966" (Borne inférieure)
    borne_sup_normale      -- linkId: "781499407274" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '30428-7',             -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Volume globulaire moyen [Volume d''entité] Érythrocytes ; Numérique',
    'hemogramme',
    92,                    -- From QuestionnaireResponse valueQuantity.value
    'fL',                  -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    80,                    -- From QuestionnaireResponse valueQuantity.value
    100                    -- From QuestionnaireResponse valueQuantity.value
);

-- Plaquettes (linkId: "794156787471")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "555876654291" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "504411027287" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "491138393211" (Borne inférieure)
    borne_sup_normale      -- linkId: "859081902103" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '777-3',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Plaquettes [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    225,                   -- From QuestionnaireResponse valueQuantity.value
    '10*9/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    150,                   -- From QuestionnaireResponse valueQuantity.value
    400                    -- From QuestionnaireResponse valueQuantity.value
);

-- Neutrophiles (linkId: "961905168477")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "971737782589" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "985816648321" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "853418774421" (Borne inférieure)
    borne_sup_normale      -- linkId: "511648773162" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '751-8',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Polynucléaires neutrophiles [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    4.2,                   -- From QuestionnaireResponse valueQuantity.value
    '10*9/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    1.8,                   -- From QuestionnaireResponse valueQuantity.value
    7.5                    -- From QuestionnaireResponse valueQuantity.value
);

-- Lymphocytes (linkId: "6936313719558")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "663015267867" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "821881643517" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "491764548638" (Borne inférieure)
    borne_sup_normale      -- linkId: "614147487488" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '731-0',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Lymphocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    2.1,                   -- From QuestionnaireResponse valueQuantity.value
    '10*9/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    1.2,                   -- From QuestionnaireResponse valueQuantity.value
    3.4                    -- From QuestionnaireResponse valueQuantity.value
);

-- Monocytes (linkId: "1739916754687")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "283372872777" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "853926468452" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "211881748564" (Borne inférieure)
    borne_sup_normale      -- linkId: "421683878522" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '742-7',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Monocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    0.5,                   -- From QuestionnaireResponse valueQuantity.value
    '10*9/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    0.2,                   -- From QuestionnaireResponse valueQuantity.value
    1                      -- From QuestionnaireResponse valueQuantity.value
);

-- Éosinophiles (linkId: "5419737615479")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "651849853076" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "211846488546" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "851844668413" (Borne inférieure)
    borne_sup_normale      -- linkId: "616658477879" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '711-2',               -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Polynucléaires éosinophiles [Nombre/Volume] Sang ; Numérique ; Comptage automate',
    'hemogramme',
    0.15,                  -- From QuestionnaireResponse valueQuantity.value
    '10*9/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    0.04,                  -- From QuestionnaireResponse valueQuantity.value
    0.5                    -- From QuestionnaireResponse valueQuantity.value
);

-- ========================================================================
-- LABORATORY RESULTS - OTHER TESTS
-- linkId: "334039497382" (Biologie - Autres) - 2 tests
-- ========================================================================

-- HbA1c (linkId: "541984638731")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "398039571990" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "161477881185" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "381844812668" (Borne inférieure)
    borne_sup_normale      -- linkId: "268845718846" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '4548-4',              -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Hémoglobine A1c/Hémoglobine.totale [Fraction massique] Sang ; Numérique',
    'autres',
    7.2,                   -- From QuestionnaireResponse valueQuantity.value
    '%',                   -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    4,                     -- From QuestionnaireResponse valueQuantity.value
    6                      -- From QuestionnaireResponse valueQuantity.value
);

-- Glycémie (linkId: "4813448476118")
INSERT INTO biologie (
    pmsi_id, patient_id,
    code_loinc,            -- linkId: "305948197507" (code loinc)
    libelle_test,
    type_examen,
    valeur,
    unite,
    date_prelevement,      -- linkId: "865182447156" (Date et heure du prélèvement)
    borne_inf_normale,     -- linkId: "468428485445" (Borne inférieure)
    borne_sup_normale      -- linkId: "871684548451" (Borne supérieure)
) VALUES (
    v_pmsi_id, v_patient_id,
    '2339-0',              -- From QuestionnaireResponse valueCoding.code (LOINC system)
    'Glucose [Masse/Volume] Plasma ; Numérique',
    'autres',
    6.8,                   -- From QuestionnaireResponse valueQuantity.value
    'mmol/L',              -- From QuestionnaireResponse valueQuantity.unit
    '2025-08-22T06:12:32.000Z',
    3.9,                   -- From QuestionnaireResponse valueQuantity.value
    5.6                    -- From QuestionnaireResponse valueQuantity.value
);

-- ========================================================================
-- MEDICATION EXPOSURE DATA
-- linkId: "817801935685" (Exposition médicamenteuse) - 2 medications
-- ========================================================================

-- Medication 1: Glucophage (Metformin)
INSERT INTO exposition_medicamenteuse (
    pmsi_id,
    patient_id,
    denomination,          -- From QuestionnaireResponse valueString
    code_atc,             -- linkId: "1923143398283" (codification)
    voie_administration,  -- linkId: "387026794874" (Voie d'administration)
    date_debut,
    date_fin
) VALUES (
    v_pmsi_id, v_patient_id,
    'Glucophage 1g 2/j',  -- From QuestionnaireResponse valueString
    'A10BA02',            -- From QuestionnaireResponse valueCoding.code (ATC system)
    'Voie orale',         -- From QuestionnaireResponse valueCoding.display
    '2025-08-22',         -- From posology section
    '2025-11-22'          -- From posology section
)
RETURNING exposition_id INTO v_exposition1_id;

-- Medication 2: Forxiga (Dapagliflozin)
INSERT INTO exposition_medicamenteuse (
    pmsi_id,
    patient_id,
    denomination,
    code_atc,             -- linkId: "1923143398283" (codification)
    voie_administration,  -- linkId: "387026794874" (Voie d'administration)
    date_debut,
    date_fin
) VALUES (
    v_pmsi_id, v_patient_id,
    'forxiga 10mg/j',     -- From QuestionnaireResponse valueString
    'A10BK01',            -- From QuestionnaireResponse valueCoding.code (ATC system)
    'Voie orale',         -- From QuestionnaireResponse valueCoding.display
    '2025-08-22',         -- From posology section
    '2025-11-22'          -- From posology section
)
RETURNING exposition_id INTO v_exposition2_id;

-- ========================================================================
-- POSOLOGY DATA
-- linkId: "6348237104421" (Posologie) - Details for both medications
-- ========================================================================

-- Posology for Glucophage
INSERT INTO posologie (
    exposition_id,
    pmsi_id,
    patient_id,
    date_debut_prescription,  -- linkId: "316347573327" (Date de début de la prescription)
    date_fin_prescription     -- linkId: "429570775935" (Date de fin de la prescription)
) VALUES (
    v_exposition1_id,
    v_pmsi_id,
    v_patient_id,
    '2025-08-22',             -- From QuestionnaireResponse valueDate
    '2025-11-22'              -- From QuestionnaireResponse valueDate
);

-- Posology for Forxiga
INSERT INTO posologie (
    exposition_id,
    pmsi_id,
    patient_id,
    date_debut_prescription,
    date_fin_prescription
) VALUES (
    v_exposition2_id,
    v_pmsi_id,
    v_patient_id,
    '2025-08-22',             -- From QuestionnaireResponse valueDate
    '2025-11-22'              -- From QuestionnaireResponse valueDate
);

-- ========================================================================
-- CLINICAL CARE DATA
-- linkId: "305831246173" (Dossier de soins)
-- ========================================================================

INSERT INTO dossier_soins (
    pmsi_id,
    patient_id,
    taille,                   -- linkId: "4846902346416" (Taille)
    date_mesure_taille,       -- linkId: "941821315470" (Date de la mesure)
    poids,                    -- linkId: "451513217936" (Poids)
    date_mesure_poids,        -- linkId: "111587238478" (Date de la mesure)
    pression_systolique,      -- linkId: "3648911616318" (Tension artérielle systolique)
    pression_diastolique,     -- linkId: "5916218467151" (Tension artérielle diastolique)
    date_mesure_ps,           -- linkId: "4118671348187" (Date de la mesure)
    date_mesure_pd
) VALUES (
    v_pmsi_id,
    v_patient_id,
    1.65,                     -- From QuestionnaireResponse valueQuantity.value
    '2025-08-22',             -- From QuestionnaireResponse valueDate
    78,                       -- From QuestionnaireResponse valueQuantity.value
    '2025-08-22',             -- From QuestionnaireResponse valueDate
    135,                      -- From QuestionnaireResponse valueQuantity.value
    85,                       -- From QuestionnaireResponse valueQuantity.value
    '2025-08-22',             -- From QuestionnaireResponse valueDate
    '2025-08-22'
);

END $$;

-- ========================================================================
-- DATA VERIFICATION QUERIES (Optional - Can be run to verify insertions)
-- ========================================================================

-- Summary of inserted data
-- SELECT 'Patient records' as entity, COUNT(*) as count FROM patient
-- UNION ALL
-- SELECT 'PMSI encounters', COUNT(*) FROM donnees_pmsi
-- UNION ALL
-- SELECT 'Diagnostics', COUNT(*) FROM diagnostics
-- UNION ALL
-- SELECT 'Medical acts', COUNT(*) FROM actes
-- UNION ALL
-- SELECT 'Lab results', COUNT(*) FROM biologie
-- UNION ALL
-- SELECT 'Medications', COUNT(*) FROM exposition_medicamenteuse
-- UNION ALL
-- SELECT 'Posologies', COUNT(*) FROM posologie
-- UNION ALL
-- SELECT 'Clinical care', COUNT(*) FROM dossier_soins;

-- ========================================================================
-- COMMIT TRANSACTION
-- ========================================================================

COMMIT;