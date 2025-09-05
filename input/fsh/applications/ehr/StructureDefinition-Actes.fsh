Logical: Actes
Id: actes
Title: "Actes"
Description: "Actes et procédures médicales du patient"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* sejourId 0..1 string "Identifiant séjour" "Identifiant du séjour"
* dateRecueil 0..1 date "Date de recueil" "Date du recueil de l'information d'acte"
* codeActe 0..1 string "Code acte" "Code de l'acte médical"
* libelleActe 0..1 string "Libellé acte" "Libellé de l'acte médical"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"