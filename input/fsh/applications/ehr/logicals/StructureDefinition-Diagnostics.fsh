Logical: Diagnostics
Id: diagnostics
Title: "Diagnostics"
Description: "Diagnostics du patient dans le contexte PMSI"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - PMSI Diagnostics"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"
* sejourId 0..1 string "Identifiant du séjour" "Identifiant unique du séjour hospitalier"
  * ^short = "ID du séjour"
  * ^definition = "Identifiant du séjour dans lequel le diagnostic a été posé"
  * ^maxLength = 50
* dateRecueil 0..1 date "Date du recueil" "Date du recueil de l'information diagnostique"
  * ^short = "Date de collecte du diagnostic"
  * ^definition = "Date à laquelle l'information diagnostique a été collectée"
* typeDiagnostic 0..1 string "Type de diagnostic" "Type de diagnostic: DP (Principal), DAS (Associé significatif), DR (Relié)"
  * ^short = "Classification du diagnostic"
  * ^definition = "Type de diagnostic selon la classification PMSI"
  * ^maxLength = 10
* codeDiagnostic 0..1 string "Code diagnostic" "Code diagnostique (CIM-10)"
  * ^short = "Code CIM-10"
  * ^definition = "Code du diagnostic selon la Classification Internationale des Maladies (CIM-10)"
  * ^maxLength = 20
* libelleDiagnostic 0..1 string "Libellé du diagnostic" "Libellé textuel du diagnostic"
  * ^short = "Description du diagnostic"
  * ^definition = "Libellé descriptif du diagnostic en texte libre"
  * ^maxLength = 500
* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"