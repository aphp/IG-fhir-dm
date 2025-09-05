Logical: Dosage
Id: dosage
Title: "Dosage"
Description: "Dosages individuels administrés"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* expositionId 1..1 integer "Identifiant exposition" "Référence vers exposition_medicamenteuse"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* dateAdministration 0..1 dateTime "Date administration" "Date et heure d'administration"
* doseAdministree 0..1 decimal "Dose administrée" "Dose administrée"
* uniteDose 0..1 string "Unité dose" "Unité de la dose administrée"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"