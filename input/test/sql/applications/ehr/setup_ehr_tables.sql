-- Quick setup script to create EHR tables and load test data
-- Run this with: psql -U postgres -d fhir_dm -f setup_ehr_tables.sql

\echo 'Creating EHR source tables...'
\i ../input/sql/applications/ehr/questionnaire-core-ddl.sql

\echo 'Loading test data into EHR tables...'

-- Insert test patient data
INSERT INTO patient (patient_id, nom, prenom, nir, ins, date_naissance, sexe, date_deces, source_deces, rang_gemellaire, latitude, longitude, code_iris, libelle_iris, code_geographique_residence, libelle_geographique_residence, created_at, updated_at)
VALUES 
(1, 'Dupont', 'Jean', '1850399100042', 'INS-1850399100042', '1985-03-15', 'M', NULL, NULL, NULL, 48.8566, 2.3522, '75102014', 'Paris 2e', '75102', 'Paris 2e Arrondissement', '2024-01-01 10:00:00', '2024-01-01 10:00:00'),
(2, 'Martin', 'Marie', '2940675200321', 'INS-2940675200321', '1994-06-15', 'F', NULL, NULL, NULL, 48.8534, 2.3488, '75103015', 'Paris 3e', '75103', 'Paris 3e Arrondissement', '2024-01-02 11:00:00', '2024-01-02 11:00:00'),
(3, 'Bernard', 'Pierre', '1780299300054', 'INS-1780299300054', '1978-02-28', 'M', '2024-03-15', 'INSERM', NULL, 48.8584, 2.2945, '75116001', 'Paris 16e', '75116', 'Paris 16e Arrondissement', '2024-01-03 12:00:00', '2024-03-15 14:00:00');

-- Insert test PMSI data
INSERT INTO donnees_pmsi (pmsi_id, patient_id, mode_sortie, duree_sejour, date_debut_sejour, date_fin_sejour, mode_entree, statut_administratif, etablissement, unite_fonctionnelle, service, code_geographique_residence, libelle_geographique_residence, date_recueil, created_at, updated_at)
VALUES 
(1001, 1, 'Domicile', 5, '2024-01-10', '2024-01-15', 'Urgences', 'Hospitalisation complète', 'AP-HP Pitié-Salpêtrière', 'Cardiologie', 'Service de Cardiologie', '75102', 'Paris 2e Arrondissement', '2024-01-15', '2024-01-15 16:00:00', '2024-01-15 16:00:00'),
(1002, 2, 'Domicile', 3, '2024-02-01', '2024-02-04', 'Consultation', 'Hospitalisation complète', 'AP-HP Cochin', 'Gynécologie', 'Service de Gynécologie', '75103', 'Paris 3e Arrondissement', '2024-02-04', '2024-02-04 14:00:00', '2024-02-04 14:00:00'),
(1003, 3, 'Décès', 10, '2024-03-05', '2024-03-15', 'Urgences', 'Réanimation', 'AP-HP Bichat', 'Réanimation', 'Service de Réanimation', '75116', 'Paris 16e Arrondissement', '2024-03-15', '2024-03-15 14:00:00', '2024-03-15 14:00:00');

-- Insert test diagnostics
INSERT INTO diagnostics (diagnostic_id, pmsi_id, code_diagnostic, type_diagnostic, libelle_diagnostic, date_diagnostic, sequence_diagnostic, date_recueil, created_at, updated_at)
VALUES 
(2001, 1001, 'I21.0', 'Principal', 'Infarctus aigu du myocarde de la paroi antérieure', '2024-01-10', 1, '2024-01-15', '2024-01-15 16:00:00', '2024-01-15 16:00:00'),
(2002, 1001, 'E11.9', 'Associé', 'Diabète de type 2 sans complication', '2024-01-10', 2, '2024-01-15', '2024-01-15 16:00:00', '2024-01-15 16:00:00'),
(2003, 1002, 'O80.0', 'Principal', 'Accouchement spontané par voie basse', '2024-02-02', 1, '2024-02-04', '2024-02-04 14:00:00', '2024-02-04 14:00:00'),
(2004, 1003, 'J44.0', 'Principal', 'BPCO avec infection respiratoire aiguë', '2024-03-05', 1, '2024-03-15', '2024-03-15 14:00:00', '2024-03-15 14:00:00');

-- Insert test biology data
INSERT INTO biologie (biologie_id, pmsi_id, patient_id, code_loinc, libelle_test, type_examen, valeur, unite, valeur_texte, date_prelevement, statut_validation, borne_inf_normale, borne_sup_normale, commentaire, methode_analyse, laboratoire, created_at, updated_at)
VALUES 
(3001, 1001, 1, '2160-0', 'Créatinine sérique', 'fonction_renale', 95, 'umol/L', NULL, '2024-01-10 08:00:00', 'VALIDE', 62, 106, NULL, 'Enzymatique', 'Laboratoire Central AP-HP', '2024-01-10 12:00:00', '2024-01-10 12:00:00'),
(3002, 1001, 1, '33914-3', 'DFG estimé', 'fonction_renale', 75, 'mL/min/1.73m2', NULL, '2024-01-10 08:00:00', 'VALIDE', 90, 120, NULL, 'CKD-EPI', 'Laboratoire Central AP-HP', '2024-01-10 12:00:00', '2024-01-10 12:00:00'),
(3003, 1001, 1, '2345-7', 'Glucose sérique', 'metabolisme', 8.5, 'mmol/L', NULL, '2024-01-10 08:00:00', 'VALIDE', 3.9, 5.8, 'Hyperglycémie', 'Hexokinase', 'Laboratoire Central AP-HP', '2024-01-10 12:00:00', '2024-01-10 12:00:00'),
(3004, 1002, 2, '718-7', 'Hémoglobine', 'hemogramme', 11.2, 'g/dL', NULL, '2024-02-01 07:30:00', 'VALIDE', 12.0, 16.0, 'Anémie légère', 'Spectrophotométrie', 'Laboratoire Central AP-HP', '2024-02-01 10:00:00', '2024-02-01 10:00:00');

\echo 'EHR tables created and populated with test data!'
\echo 'You can now run: dbt run'