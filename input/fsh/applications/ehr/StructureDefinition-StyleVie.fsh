Logical: StyleVie
Id: style-vie
Title: "Style de Vie"
Description: "Informations sur le style de vie du patient (tabac, alcool, drogues, activité physique)"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* dateRecueil 0..1 date "Date de recueil" "Date du recueil des informations de style de vie"

* consommationTabac 0..1 string "Consommation tabac" "Statut de consommation de tabac"
* tabacDetails 0..1 string "Détails tabac" "Détails sur la consommation de tabac"

* consommationAlcool 0..1 string "Consommation alcool" "Statut de consommation d'alcool"
* alcoolDetails 0..1 string "Détails alcool" "Détails sur la consommation d'alcool"

* consommationDrogues 0..1 string "Consommation drogues" "Consommation d'autres drogues"
* droguesDetails 0..1 string "Détails drogues" "Détails sur la consommation d'autres drogues"

* activitePhysique 0..1 string "Activité physique" "Niveau d'activité physique"
* activiteDetails 0..1 string "Détails activité" "Détails sur l'activité physique"

* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"