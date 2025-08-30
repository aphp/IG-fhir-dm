Logical: Actes
Id: actes
Title: "Actes"
Description: "Actes et procédures médicales du patient"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - PMSI Procedures"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"
* sejourId 0..1 string "Identifiant du séjour" "Identifiant unique du séjour hospitalier"
  * ^short = "ID du séjour"
  * ^definition = "Identifiant du séjour dans lequel l'acte a été réalisé"
  * ^maxLength = 50
* dateRecueil 0..1 date "Date du recueil" "Date du recueil de l'information d'acte"
  * ^short = "Date de collecte de l'acte"
  * ^definition = "Date à laquelle l'information sur l'acte médical a été collectée"
* codeActe 0..1 string "Code de l'acte médical" "Code de l'acte selon la classification en vigueur"
  * ^short = "Code de l'acte"
  * ^definition = "Code de l'acte médical selon la Classification Commune des Actes Médicaux (CCAM) ou autre classification"
  * ^maxLength = 20
* libelleActe 0..1 string "Libellé de l'acte médical" "Description textuelle de l'acte médical"
  * ^short = "Description de l'acte"
  * ^definition = "Libellé descriptif de l'acte médical en texte libre"
  * ^maxLength = 500
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"