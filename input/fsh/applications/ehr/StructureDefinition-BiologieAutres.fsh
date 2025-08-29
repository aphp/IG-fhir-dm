Logical: BiologieAutres
Id: biologie-autres
Title: "Biologie Autres"
Description: "Autres examens biologiques non catégorisés"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"
* testName 0..1 string "Nom du test" "Nom du test biologique"
* testValeur 0..1 decimal "Valeur du test" "Valeur du test"
* testCodeLoinc 0..1 string "Code LOINC" "Code LOINC du test"
* testDatePrelevement 0..1 dateTime "Date prélèvement" "Date et heure du prélèvement"
* testStatutValidation 0..1 string "Statut validation" "Statut de validation"
* testBorneInf 0..1 decimal "Borne inférieure" "Borne inférieure de normalité"
* testBorneSup 0..1 decimal "Borne supérieure" "Borne supérieure de normalité"
* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"