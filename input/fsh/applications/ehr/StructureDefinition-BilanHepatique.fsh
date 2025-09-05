Logical: BilanHepatique
Id: bilan-hepatique
Title: "Bilan Hépatique"
Description: "Bilan hépatique - tests de fonction hépatique"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"