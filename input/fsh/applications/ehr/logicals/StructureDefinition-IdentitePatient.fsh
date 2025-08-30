Logical: IdentitePatient
Id: identite-patient
Title: "Identité Patient"
Description: "Identitologie. Clé d'appariement unique pouvant permettre le chaînage direct du socle avec d'autres bases"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Patient Identity Information"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
  * ^short = "Identifiant unique du patient"
  * ^definition = "Identifiant unique permettant de lier toutes les informations du patient"
* nomPatient 0..1 string "Nom patient" "Nom de famille du patient"
* prenomPatient 0..1 string "Prénom patient" "Prénom du patient"
* nir 0..1 string "Numéro d'inscription au Répertoire (NIR)" "Numéro unique attribué à chaque personne à sa naissance sur la base d'éléments d'état civil transmis par les mairies à l'INSEE"
  * ^maxLength = 15
* ins 0..1 string "Identité Nationale de Santé (INS)" "Numéro d'identité unique, pérenne, partagée par l'ensemble des professionnels du monde de la santé"
  * ^maxLength = 50
* dateNaissance 0..1 date "Date de naissance" "Date de naissance des papiers d'identité utilisés pour la production de l'INS"
* dateDeces 0..1 date "Date de décès" "Date de décès à l'hopital, ou date de décès collectée par chaînage avec une base externe comme l'INSEE ou le CepiDc"
* sourceDateDeces 0..1 string "Source de la date de décès" "Source de la date de décès: INSEE, CepiDc, SIH"
  * ^maxLength = 10
* rangGemellaire 0..1 integer "Rang gémellaire" "Rang gémellaire du bénéficiaire - Pour le régime général, il permet de distinguer les naissances gémellaires de même sexe"
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"
* updatedAt 1..1 dateTime "Date de mise à jour" "Timestamp de dernière mise à jour"