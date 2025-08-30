Logical: DossierSoins
Id: dossier-soins
Title: "Dossier de Soins"
Description: "Dossiers de soins du patient"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Clinical Examination - Care Records"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

* dateEnregistrement 0..1 dateTime "Date d'enregistrement" "Date et heure de création du dossier de soins"
  * ^short = "Moment d'enregistrement"
  * ^definition = "Timestamp de création de l'entrée dans le dossier de soins"
* typeSoins 0..1 string "Type de soins" "Catégorie ou nature des soins prodigués"
  * ^short = "Catégorie de soins"
  * ^definition = "Classification du type de soins dispensés au patient"
  * ^maxLength = 100
* descriptionSoins 0..1 string "Description des soins" "Description détaillée des soins réalisés"
  * ^short = "Détail des soins"
  * ^definition = "Description narrative complète des soins prodigués au patient"
* professionnelId 0..1 string "Identifiant du professionnel" "Identifiant unique du professionnel de santé"
  * ^short = "ID du soignant"
  * ^definition = "Identifiant du professionnel de santé ayant réalisé ou supervisé les soins"
  * ^maxLength = 50

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"