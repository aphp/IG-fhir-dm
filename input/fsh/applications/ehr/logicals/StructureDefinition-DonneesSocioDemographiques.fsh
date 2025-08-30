Logical: DonneesSocioDemographiques
Id: donnees-socio-demographiques
Title: "Données Socio-Démographiques"
Description: "Données socio-démographiques du patient incluant l'âge, le sexe et la résidence"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Patient Demographic Data"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"
* age 0..1 integer "Age du patient" "Age du patient au moment du recueil"
  * ^short = "Age en années"
  * ^definition = "Age du patient exprimé en années"
* dateRecueilAge 0..1 date "Date du recueil de l'âge" "Date du recueil de l'information d'âge"
  * ^short = "Date de collecte de l'âge"
  * ^definition = "Date à laquelle l'âge du patient a été collecté"
* sexe 0..1 string "Sexe du patient" "Sexe du patient: Homme/Femme"
  * ^short = "Sexe administratif"
  * ^definition = "Sexe administratif du patient (Homme/Femme)"
  * ^maxLength = 10
* codeGeographiqueResidence 0..1 string "Code géographique de résidence" "Code de la commune de résidence du patient selon la classification PMSI"
  * ^short = "Code commune de résidence"
  * ^definition = "Code de la commune de résidence selon la classification PMSI"
  * ^maxLength = 10
* dateRecueilResidence 0..1 date "Date du recueil de résidence" "Date du recueil de l'information de résidence"
  * ^short = "Date de collecte de la résidence"
  * ^definition = "Date à laquelle l'information de résidence a été collectée"
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"
* updatedAt 1..1 dateTime "Date de mise à jour" "Timestamp de dernière mise à jour"