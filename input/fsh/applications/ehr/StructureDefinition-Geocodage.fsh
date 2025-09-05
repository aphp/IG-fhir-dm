Logical: Geocodage
Id: geocodage
Title: "Géocodage"
Description: "Coordonnées géographiques (latitude et longitude) de l'adresse du patient"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* latitude 0..1 decimal "Latitude" "Latitude des coordonnées géographiques de l'adresse du patient"
* longitude 0..1 decimal "Longitude" "Longitude des coordonnées géographiques de l'adresse du patient"
* dateRecueil 0..1 date "Date de recueil" "Date du recueil de l'information géographique"
* irisCode 0..1 string "Code IRIS" "Code IRIS de la zone géographique"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"