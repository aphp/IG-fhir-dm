Logical: DonneesSocioDemographiques
Id: donnees-socio-demographiques
Title: "Données Socio-Démographiques"
Description: "Données socio-démographiques du patient"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* age 0..1 integer "Âge" "Age du patient"
* dateRecueilAge 0..1 date "Date recueil âge" "Date du recueil de l'information d'âge"
* sexe 0..1 string "Sexe" "Sexe du patient: Homme/Femme"
* codeGeographiqueResidence 0..1 string "Code géographique résidence" "Code de la commune de résidence du patient selon la classification PMSI"
* dateRecueilResidence 0..1 date "Date recueil résidence" "Date du recueil de l'information de résidence"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"
* updatedAt 0..1 dateTime "Date de mise à jour" "Date de dernière mise à jour de l'enregistrement"