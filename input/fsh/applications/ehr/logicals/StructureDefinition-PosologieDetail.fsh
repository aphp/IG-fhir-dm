Logical: PosologieDetail
Id: posologie-detail
Title: "Posologie Détail"
Description: "Détails de posologie des médicaments prescrits"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Medication Dosage Details"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* expositionId 1..1 Reference(ExpositionMedicamenteuse) "Référence exposition médicamenteuse" "Référence vers l'exposition médicamenteuse"
  * ^short = "Lien vers l'exposition"
  * ^definition = "Référence vers la table exposition_medicamenteuse"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

// Dosage information
* doseUnitaire 0..1 decimal "Dose unitaire" "Quantité de médicament par unité de prise"
  * ^short = "Quantité par prise"
  * ^definition = "Dose de médicament administrée à chaque prise"
* uniteDose 0..1 string "Unité de la dose" "Unité de mesure de la dose (mg, ml, UI, etc.)"
  * ^short = "Unité de mesure"
  * ^definition = "Unité dans laquelle la dose est exprimée"
  * ^maxLength = 20
* frequenceAdministration 0..1 string "Fréquence d'administration" "Rythme d'administration du médicament"
  * ^short = "Fréquence de prise"
  * ^definition = "Fréquence à laquelle le médicament doit être administré (ex: 3 fois par jour, toutes les 8 heures)"
  * ^maxLength = 100
* dureeTraitement 0..1 integer "Durée du traitement" "Durée totale du traitement en jours"
  * ^short = "Durée en jours"
  * ^definition = "Nombre de jours pendant lesquels le traitement doit être administré"

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"