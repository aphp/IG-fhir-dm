Logical: IdentitePatient
Id: identite-patient
Title: "Identité Patient"
Description: "Identitologie. Clé d'appariement unique pouvant permettre le chaînage direct du socle avec d'autres bases"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* nomPatient 0..1 string "Nom patient" "Nom patient"
* prenomPatient 0..1 string "Prénom patient" "Prénom patient"
* nir 0..1 string "NIR" "Numéro d'inscription au Répertoire (NIR) - Numéro unique attribué à chaque personne à sa naissance sur la base d'éléments d'état civil transmis par les mairies à l'INSEE"
* ins 0..1 string "INS" "Identité Nationale de Santé (INS) - Numéro d'identité unique, pérenne, partagée par l'ensemble des professionnels du monde de la santé"
* dateNaissance 0..1 date "Date de naissance" "Date de naissance des papiers d'identité utilisés pour la production de l'INS"
* dateDeces 0..1 date "Date de décès" "Date de décès à l'hopital, ou date de décès collectée par chaînage avec une base externe comme l'INSEE ou le CepiDc"
* sourceDateDeces 0..1 string "Source date décès" "Source de la date de décès: INSEE, CepiDc, SIH"
* rangGemellaire 0..1 integer "Rang gémellaire" "Rang gémellaire du bénéficiaire - Pour le régime général, il permet de distinguer les naissances gémellaires de même sexe"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"
* updatedAt 0..1 dateTime "Date de mise à jour" "Date de dernière mise à jour de l'enregistrement"