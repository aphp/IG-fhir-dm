Logical: Dosage
Id: dosage
Title: "Dosage"
Description: "Dosages individuels administrés"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Individual Dosages"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* expositionId 1..1 Reference(ExpositionMedicamenteuse) "Référence exposition médicamenteuse" "Référence vers l'exposition médicamenteuse"
  * ^short = "Lien vers l'exposition"
  * ^definition = "Référence vers la table exposition_medicamenteuse"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

* dateAdministration 0..1 dateTime "Date d'administration" "Date et heure précises d'administration du médicament"
  * ^short = "Moment de l'administration"
  * ^definition = "Timestamp de l'administration effective du médicament"
* doseAdministree 0..1 decimal "Dose administrée" "Quantité de médicament effectivement administrée"
  * ^short = "Quantité administrée"
  * ^definition = "Dose réelle de médicament qui a été administrée au patient"
* uniteDose 0..1 string "Unité de la dose" "Unité de mesure de la dose administrée"
  * ^short = "Unité de mesure"
  * ^definition = "Unité dans laquelle la dose administrée est exprimée (mg, ml, UI, etc.)"
  * ^maxLength = 20

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"