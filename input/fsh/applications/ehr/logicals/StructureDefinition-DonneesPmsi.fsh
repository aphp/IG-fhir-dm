Logical: DonneesPmsi
Id: donnees-pmsi
Title: "Données PMSI"
Description: "Description générale du patient et de la venue à l'hôpital, dans les différents PMSI (MCO, SSR, HAD, Psy)"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - PMSI Stay Information"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"
* dateDebutSejour 0..1 date "Date de début de séjour" "Date d'admission du patient à l'hôpital"
  * ^short = "Date d'admission"
  * ^definition = "Date de début du séjour hospitalier"
* dateFinSejour 0..1 date "Date de fin de séjour" "Date de sortie du patient de l'hôpital"
  * ^short = "Date de sortie"
  * ^definition = "Date de fin du séjour hospitalier"
* modeEntree 0..1 string "Mode d'entrée du séjour" "Mode d'admission du patient (urgences, mutation, transfert, etc.)"
  * ^short = "Mode d'admission"
  * ^definition = "Modalité d'entrée du patient dans le service"
  * ^maxLength = 10
* modeSortie 0..1 string "Mode de sortie pendant le séjour" "Mode de sortie du patient (domicile, transfert, décès, etc.)"
  * ^short = "Mode de sortie"
  * ^definition = "Modalité de sortie du patient du service"
  * ^maxLength = 10
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"