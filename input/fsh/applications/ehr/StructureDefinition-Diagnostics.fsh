Logical: Diagnostics
Id: diagnostics
Title: "Diagnostics"
Description: "Diagnostics du patient dans le contexte PMSI"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* sejourId 0..1 string "Identifiant séjour" "Identifiant du séjour"
* dateRecueil 0..1 date "Date de recueil" "Date du recueil de l'information diagnostique"
* typeDiagnostic 0..1 string "Type de diagnostic" "Type de diagnostic: DP (Principal), DAS (Associé significatif), DR (Relié)"
* codeDiagnostic 0..1 string "Code diagnostic" "Code diagnostique (CIM-10)"
* libelleDiagnostic 0..1 string "Libellé diagnostic" "Libellé du diagnostic"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"