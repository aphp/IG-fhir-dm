Logical: StyleVie
Id: style-vie
Title: "Style de Vie"
Description: "Informations sur le style de vie du patient (tabac, alcool, drogues, activité physique)"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Lifestyle Information"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

* dateRecueil 0..1 date "Date du recueil" "Date de collecte des informations de style de vie"
  * ^short = "Date de collecte"
  * ^definition = "Date à laquelle les informations sur le style de vie ont été recueillies"

// Tobacco consumption
* consommationTabac 0..1 string "Consommation de tabac" "Statut de consommation de tabac du patient"
  * ^short = "Statut tabagique"
  * ^definition = "Information sur l'usage du tabac (non-fumeur, fumeur actuel, ancien fumeur)"
  * ^maxLength = 50
* tabacDetails 0..1 string "Détails tabac" "Informations détaillées sur la consommation de tabac"
  * ^short = "Détails de consommation"
  * ^definition = "Description précise des habitudes tabagiques (quantité, durée, type de tabac)"

// Alcohol consumption
* consommationAlcool 0..1 string "Consommation d'alcool" "Statut de consommation d'alcool du patient"
  * ^short = "Statut alcool"
  * ^definition = "Information sur l'usage d'alcool (abstinent, consommation occasionnelle, régulière)"
  * ^maxLength = 50
* alcoolDetails 0..1 string "Détails alcool" "Informations détaillées sur la consommation d'alcool"
  * ^short = "Détails de consommation"
  * ^definition = "Description précise des habitudes de consommation d'alcool (fréquence, quantité, type)"

// Other drug consumption
* consommationDrogues 0..1 string "Consommation de drogues" "Statut de consommation d'autres substances psychoactives"
  * ^short = "Usage de substances"
  * ^definition = "Information sur l'usage d'autres drogues ou substances psychoactives"
  * ^maxLength = 50
* droguesDetails 0..1 string "Détails drogues" "Informations détaillées sur la consommation d'autres drogues"
  * ^short = "Détails de consommation"
  * ^definition = "Description précise de l'usage d'autres substances psychoactives"

// Physical activity
* activitePhysique 0..1 string "Activité physique" "Niveau d'activité physique du patient"
  * ^short = "Niveau d'activité"
  * ^definition = "Évaluation du niveau d'activité physique (sédentaire, modérée, intense)"
  * ^maxLength = 50
* activiteDetails 0..1 string "Détails activité physique" "Informations détaillées sur l'activité physique"
  * ^short = "Détails de l'activité"
  * ^definition = "Description précise des activités physiques pratiquées (type, fréquence, durée)"

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"