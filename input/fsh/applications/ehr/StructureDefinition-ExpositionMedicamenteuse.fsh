Logical: ExpositionMedicamenteuse
Id: exposition-medicamenteuse
Title: "Exposition Médicamenteuse"
Description: "Exposition médicamenteuse du patient"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* medicamentPrescrit 0..1 string "Médicament prescrit" "Médicament prescrit"
* codificationAtc 0..1 string "Code ATC" "Codification ATC du médicament"
* voieAdministration 0..1 string "Voie d'administration" "Voie d'administration du médicament"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"