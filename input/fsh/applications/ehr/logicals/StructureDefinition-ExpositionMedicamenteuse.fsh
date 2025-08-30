Logical: ExpositionMedicamenteuse
Id: exposition-medicamenteuse
Title: "Exposition Médicamenteuse"
Description: "Exposition médicamenteuse du patient"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Medication Exposure"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"
* medicamentPrescrit 0..1 string "Médicament prescrit" "Nom ou description du médicament prescrit"
  * ^short = "Nom du médicament"
  * ^definition = "Dénomination commerciale ou générique du médicament prescrit"
  * ^maxLength = 500
* codificationAtc 0..1 string "Codification ATC" "Code ATC (Anatomical Therapeutic Chemical) du médicament"
  * ^short = "Code ATC"
  * ^definition = "Classification ATC permettant l'identification standardisée du médicament selon ses propriétés thérapeutiques et chimiques"
  * ^maxLength = 20
* voieAdministration 0..1 string "Voie d'administration" "Modalité d'administration du médicament"
  * ^short = "Route d'administration"
  * ^definition = "Voie par laquelle le médicament est administré (orale, intraveineuse, intramusculaire, etc.)"
  * ^maxLength = 100
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"