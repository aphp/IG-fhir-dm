Logical: DonneesPmsi
Id: donnees-pmsi
Title: "Données PMSI"
Description: "Description générale du patient et de la venue à l'hôpital, dans les différents PMSI (MCO, SSR, HAD, Psy)"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* dateDebutSejour 0..1 date "Date début séjour" "Date de début de séjour"
* dateFinSejour 0..1 date "Date fin séjour" "Date de fin de séjour"
* modeEntree 0..1 string "Mode d'entrée" "Mode d'entrée du séjour"
* modeSortie 0..1 string "Mode de sortie" "Mode de sortie pendant le séjour"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"