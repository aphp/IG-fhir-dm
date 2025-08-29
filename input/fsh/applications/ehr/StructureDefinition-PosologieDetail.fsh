Logical: PosologieDetail
Id: posologie-detail
Title: "Posologie Détail"
Description: "Détails de posologie des médicaments prescrits"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* expositionId 1..1 integer "Identifiant exposition" "Référence vers exposition_medicamenteuse"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* doseUnitaire 0..1 decimal "Dose unitaire" "Dose unitaire du médicament"
* uniteDose 0..1 string "Unité dose" "Unité de la dose"
* frequenceAdministration 0..1 string "Fréquence administration" "Fréquence d'administration"
* dureeTraitement 0..1 integer "Durée traitement" "Durée du traitement en jours"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"