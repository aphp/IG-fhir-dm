Logical: Geocodage
Id: geocodage
Title: "Géocodage"
Description: "Coordonnées géographiques (latitude et longitude) de l'adresse du patient"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Geocoding Information"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"
* latitude 0..1 decimal "Latitude" "Latitude des coordonnées géographiques de l'adresse du patient"
  * ^short = "Latitude géographique"
  * ^definition = "Coordonnée géographique de latitude avec précision de 8 décimales"
* longitude 0..1 decimal "Longitude" "Longitude des coordonnées géographiques de l'adresse du patient"
  * ^short = "Longitude géographique"
  * ^definition = "Coordonnée géographique de longitude avec précision de 8 décimales"
* dateRecueil 0..1 date "Date du recueil" "Date du recueil de l'information géographique"
  * ^short = "Date de collecte des coordonnées"
  * ^definition = "Date à laquelle les coordonnées géographiques ont été collectées"
* irisCode 0..1 string "Code IRIS" "Code IRIS de la zone géographique"
  * ^short = "Code de la zone IRIS"
  * ^definition = "Code IRIS (Îlots Regroupés pour l'Information Statistique) de la zone géographique"
  * ^maxLength = 20
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"