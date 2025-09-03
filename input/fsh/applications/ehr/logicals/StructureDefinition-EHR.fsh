// ========================================================================
// FHIR Shorthand Logical Model for EHR Data Model
// Generated from: input/sql/applications/ehr/questionnaire-core-ddl.sql
// 
// This logical model represents the comprehensive EHR data structure
// optimized for EDSH core variables, including patient demographics,
// clinical encounters, diagnostics, procedures, laboratory results,
// medication exposures, clinical observations, and lifestyle factors.
// ========================================================================

Logical: EHR
Id: ehr
Title: "Electronic Health Record Data Model"
Description: """
Comprehensive logical model representing the Electronic Health Record (EHR) data structure
for the EDSH (Entrepôt de Données de Santé Hospitalisé) core variables.

This model consolidates all healthcare dimensions into a unified structure supporting:
- Patient demographics and identity management
- Healthcare encounters and administrative data  
- Clinical diagnostics and procedures
- Laboratory results and biological examinations
- Medication exposures and prescriptions
- Clinical care measurements and vital signs
- Lifestyle and behavioral factors

The model is optimized for healthcare data interoperability, research, and clinical analytics
while maintaining alignment with FHIR standards and French healthcare requirements.
"""

* id 0..1 id "bundle logical id"
// ========================================================================
// PATIENT TABLE
// ========================================================================

* patient 1..1 BackboneElement "Patient Demographics and Identity" """
Patient information consolidating identity data and geographic information.
Based on FHIR Questionnaire linkIds: 2958000860428 (Patient Identity) and 3816475533472 (Geocoding).
Maps to SQL table: patient
"""
  * patientId 1..1 id "Patient Identifier" "Unique patient identifier (patient_id)"
  * nom 0..1 string "Last Name" "Patient last name - linkId: 8605698058770"
  * prenom 0..1 string "First Name" "Patient first name - linkId: 6214879623503"
  * nir 0..1 string "NIR" "Numéro inscription au Répertoire (linkId: 5711960356160)"
  * ins 0..1 string "INS" "Identité Nationale de Santé (linkId: 3764723550987)"
  * dateNaissance 0..1 date "Birth Date" "Date of birth (date_naissance) - linkId: 5036133558154"
  * sexe 0..1 code "Gender" "Gender consolidated from PMSI - linkId: 3894630481120"
  * dateDeces 0..1 date "Death Date" "Date of death (date_deces) - linkId: 5633552097315"
  * sourceDeces 0..1 string "Death Source" "Source of death date (source_deces) - linkId: 9098810065693"
  * rangGemellaire 0..1 integer "Twin Rank" "Twin ranking (rang_gemellaire) - linkId: 6931296968515"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// PATIENT_ADDRESSE TABLE
// ========================================================================
* patientAddresse 0..* BackboneElement "Adresses des patients" "Depuis la table patient_addresse"
  * patientAddresseId 1..1 id "Patient address identifier" "Unique identifier"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * latitude 0..1 decimal "Latitude" "Latitude - linkId: 3709843054556"
  * longitude 0..1 decimal "Longitude" "Longitude - linkId: 7651448032665"
  * codeIris 0..1 string "IRIS Code" "INSEE IRIS code (code_iris)"
  * libelleIris 0..1 string "IRIS Label" "INSEE IRIS label (libelle_iris)"
  * codeGeographiqueResidence 0..1 string "Residence Code" "Geographic code of residence (code_geographique_residence)"
  * libelleGeographiqueResidence 0..1 string "Residence Label" "Geographic label of residence (libelle_geographique_residence)"
  * dateRecueil 0..1 date "Date de recueil" "Date de recueil"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"


// ========================================================================
// DONNEES_PMSI TABLE
// ========================================================================

* donneesPmsi 0..* BackboneElement "PMSI Data" """
Healthcare encounters and administrative data from PMSI.
Central linking entity for all clinical data. Based on linkId: 2825244231605.
Maps to SQL table: donnees_pmsi
"""
  * pmsiId 1..1 id "PMSI ID" "Unique PMSI identifier (pmsi_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * modeSortie 0..1 string "Discharge Mode" "Mode de sortie (mode_sortie)"
  * ageAdmission 0..1 integer "Age du patient au début de la prise en charge" "Au cas ou la date de naissance n'est pas connue"  // à mettre dans une observation le cas échéant.
  * dureeSejour 0..1 integer "Stay Duration" "Durée de séjour en jours (duree_sejour)"
  * dateDebutSejour 0..1 date "Start Date" "Date début séjour (date_debut_sejour)"
  * dateFinSejour 0..1 date "End Date" "Date fin séjour (date_fin_sejour)"
  * modeEntree 0..1 string "Admission Mode" "Mode d'entrée (mode_entree)"
  * etablissement 0..1 string "Facility" "Établissement"
  * uniteFonctionnelle 0..1 string "Functional Unit" "Unité fonctionnelle (unite_fonctionnelle)"
  * service 0..1 string "Service" "Service"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// DIAGNOSTICS TABLE
// ========================================================================

* diagnostics 0..* BackboneElement "Diagnostics" """
Diagnostic codes and information using ICD-10/CIM-10 classifications.
Based on linkId: 9391816419630. Maps to SQL table: diagnostics
"""
  * diagnosticId 1..1 id "Diagnostic ID" "Unique diagnostic identifier (diagnostic_id)"
  * pmsiId 1..1 id "PMSI ID" "Foreign key to donnees_pmsi (pmsi_id)"
  * codeDiagnostic 1..1 string "Diagnostic Code" "Code diagnostic ICD-10/CIM-10 (code_diagnostic)"
  * typeDiagnostic 0..1 string "Diagnostic Type" "Type de diagnostic (type_diagnostic)"
  * libelleDiagnostic 0..1 string "Diagnostic Label" "Libellé du diagnostic (libelle_diagnostic)"
  * dateRecueil 0..1 date "Collection Date" "Date recueil (date_recueil)"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// ACTES TABLE
// ========================================================================

* actes 0..* BackboneElement "Medical Acts" """
Medical procedures and acts using CCAM classifications.
Based on linkId: 591926901726. Maps to SQL table: actes
"""
  * acteId 1..1 id "Act ID" "Unique act identifier (acte_id)"
  * pmsiId 1..1 id "PMSI ID" "Foreign key to donnees_pmsi (pmsi_id)"
  * codeActe 1..1 string "Act Code" "Code acte CCAM (code_acte)"
  * libelleActe 0..1 string "Act Label" "Libellé de l'acte (libelle_acte)"
  * dateActe 0..1 dateTime "Act Date" "Date acte (date_acte)"
  * executant 0..1 string "Performer" "Exécutant"
  * dateRecueil 0..1 date "Collection Date" "Date recueil (date_recueil)"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// BIOLOGIE TABLE
// ========================================================================

* biologie 0..* BackboneElement "Laboratory Results" """
Consolidated laboratory test results for all biological examinations.
Based on linkId: 7702944131447. Maps to SQL table: biologie
"""
  * biologieId 1..1 id "Biology ID" "Unique biology identifier (biologie_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * codeLoinc 0..1 string "LOINC Code" "Code LOINC (code_loinc)"
  * libelleTest 0..1 string "Test Label" "Libellé du test (libelle_test)"
  * typeExamen 0..1 code "Exam Type" "Type examen (type_examen)"
  * valeur 0..1 decimal "Value" "Valeur numérique"
  * unite 0..1 string "Unit" "Unité"
  * valeurTexte 0..1 string "Text Value" "Valeur texte (valeur_texte)"
  * datePrelevement 0..1 dateTime "Collection Date" "Date prélèvement (date_prelevement)"
  * statutValidation 0..1 string "Validation Status" "Statut validation (statut_validation)"
  * borneInfNormale 0..1 decimal "Lower Bound" "Borne inférieure normale (borne_inf_normale)"
  * borneSupNormale 0..1 decimal "Upper Bound" "Borne supérieure normale (borne_sup_normale)"
  * laboratoire 0..1 string "Laboratory" "Laboratoire"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// PRESCRIPTION TABLE
// ========================================================================

* prescription 0..* BackboneElement "Prescription médicamenteuse" """
Prescription data with ATC coding.
Based on linkId: 817801935685. Maps to SQL table: prescription
"""
  * prescriptionId 1..1 id "Prescription ID" "Unique prescription identifier (prescription_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * denomination 0..1 string "Denomination" "Dénomination"
  * codeAtc 0..1 string "médicament prescrit" "Codé en ATC"
  * voieAdministration 0..1 string "Voie administration" "Codé avec un Standard Term"
  * prescripteur 0..1 string "Prescriber" "Prescripteur"
  * datePrescription 0..1 date "Prescription Date" "Date prescription (date_prescription)"
  * dateDebutPrescription 0..1 date "Start Date" "Date début (date_debut)"
  * dateFinPrescription 0..1 date "End Date" "Date fin (date_fin)"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// POSOLOGIE TABLE
// ========================================================================

* posologie 0..* BackboneElement "Posology" """
Detailed dosing information. Based on linkId: 6348237104421.
Maps to SQL table: posologie
"""
  * posologieId 1..1 id "Posology ID" "Unique posology identifier (posologie_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * prescriptionId 1..1 id "Prescription ID" "Foreign key to prescription (prescription_id)"
  * nombrePrisesParJour 0..1 integer "Daily Intakes" "Nombre prises par jour (nombre_prises_par_jour)"
  * quantite 0..1 decimal "quantité de médicament prise" "à correler avec l'unité"
  * uniteQuantite 0..1 string "Unité de la quantité" "Si possible en UCUM, sinon en Standard terms"
  * dateHeureDebut 0..1 dateTime "DateHeure de début de prise" "Date de la prise si prise 'instantanée'"
  * dateHeureFin 0..1 dateTime "DateHeure de fin de prise"  "DateHeure de fin de prise"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// ADMINISTRATION TABLE
// ========================================================================

* administration 0..* BackboneElement "Administration" """
Administration
Maps to SQL table: administration
"""
  * administrationId 1..1 id "Administration ID" "Unique administration identifier (administration_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * prescriptionId 0..1 id "Prescription ID" "Foreign key to prescription (prescription_id)"
  * denomination 0..1 string "Médicament administré" "DCI si possible"
  * codeAtc 0..1 string "Classe thérapeutique du médicament administré" "codé en ATC"
  * voieAdministration 0..1 string "Voie administration" "Codé avec un Standard Term"
  * quantite 0..1 decimal "Administered Quantity" "Quantité administrée (quantite_administree)"
  * uniteQuantite 0..1 string "Quantity Unit" "codé en UCUM, subsidiairement en Standard Term"
  * dateHeureDebut 0..1 dateTime "Start DateTime" "Date heure début (date_heure_debut)"
  * dateHeureFin 0..1 dateTime "End DateTime" "Date heure fin (date_heure_fin)"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// DOSSIER_SOINS TABLE
// ========================================================================

* dossierSoins 0..* BackboneElement "Care Record" """
Clinical care measurements and observations.
Based on linkId: 305831246173. Maps to SQL table: dossier_soins
"""
  * soinsId 1..1 id "Care ID" "Unique care identifier (soins_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * codeLoinc 0..1 string "Observation" "codé avec LOINC"
  * libelleTest 0..1 string "Libellé métier de l'observation" "Libellé métier de l'observation"
  * valeur 0..1 decimal "Valeur de l'observation" "si quantitative"
  * unite 0..1 string "Unité de la valeur" "idéalement en UCUM"
  * valeurCode 0..1 string "Valeur de l'observation" "si qualitative"
  * valeurTexte 0..1 string "Valeur de l'observation" "si textuelle"
  * dateMesure 0..1 date "Date de mesure" "Date de mesure"
  * uniteSoins 0..1 string "Care Unit" "Unité soins (unite_soins)"
  * professionnel 0..1 string "Professional" "Professionnel"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"

// ========================================================================
// STYLE_VIE TABLE
// ========================================================================

* styleVie 0..* BackboneElement "Lifestyle" """
Consolidated lifestyle information.
Based on linkId: 1693164086678. Maps to SQL table: style_vie
"""
  * styleVieId 1..1 id "Lifestyle ID" "Unique lifestyle identifier (style_vie_id)"
  * patientId 1..1 id "Patient ID" "Foreign key to patient (patient_id)"
  * consommationTabac 0..1 string "Tobacco Use" "Consommation tabac (consommation_tabac)"
  * consommationAlcool 0..1 string "Alcohol Use" "Consommation alcool (consommation_alcool)"
  * consommationAutresDrogues 0..1 string "Other Drugs" "Consommation autres drogues (consommation_autres_drogues)"
  * activitePhysique 0..1 string "Physical Activity" "Activité physique (activite_physique)"
  * dateRecueil 0..1 date "Collection Date" "Date recueil (date_recueil)"
  * createdAt 1..1 dateTime "Created At" "Record creation timestamp (created_at)"
  * updatedAt 1..1 dateTime "Updated At" "Record update timestamp (updated_at)"