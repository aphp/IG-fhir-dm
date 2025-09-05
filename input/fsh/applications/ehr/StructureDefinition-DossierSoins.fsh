Logical: DossierSoins
Id: dossier-soins
Title: "Dossier de Soins"
Description: "Dossiers de soins du patient"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* dateEnregistrement 0..1 dateTime "Date enregistrement" "Date d'enregistrement du dossier de soins"
* typeSoins 0..1 string "Type de soins" "Type de soins prodigués"
* descriptionSoins 0..1 string "Description soins" "Description détaillée des soins"
* professionnelId 0..1 string "Identifiant professionnel" "Identifiant du professionnel de santé"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"