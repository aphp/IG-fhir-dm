Logical: FonctionRenale
Id: fonction-renale
Title: "Fonction Rénale"
Description: "Dosage sanguin de l'urée qui permet d'évaluer la fonction rénale"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"

* ureeValeur 0..1 decimal "Urée valeur" "Valeur du dosage de l'urée dans le sang"
* ureeCodeLoinc 0..1 string "Urée code LOINC" "Code LOINC pour l'urée"
* ureeDatePrelevement 0..1 dateTime "Urée date prélèvement" "Date et heure du prélèvement d'urée"
* ureeStatutValidation 0..1 string "Urée statut validation" "Statut de validation du résultat d'urée"
* ureeBorneInf 0..1 decimal "Urée borne inférieure" "Borne inférieure de normalité pour l'urée"
* ureeBorneSup 0..1 decimal "Urée borne supérieure" "Borne supérieure de normalité pour l'urée"

* creatinineValeur 0..1 decimal "Créatinine valeur" "Valeur de la créatininémie"
* creatinineCodeLoinc 0..1 string "Créatinine code LOINC" "Code LOINC pour la créatinine"
* creatinineDatePrelevement 0..1 dateTime "Créatinine date prélèvement" "Date et heure du prélèvement de créatinine"
* creatinineStatutValidation 0..1 string "Créatinine statut validation" "Statut de validation du résultat de créatinine"
* creatinineBorneInf 0..1 decimal "Créatinine borne inférieure" "Borne inférieure de normalité pour la créatinine"
* creatinineBorneSup 0..1 decimal "Créatinine borne supérieure" "Borne supérieure de normalité pour la créatinine"

* dfgValeur 0..1 decimal "DFG valeur" "Valeur du débit de filtration glomérulaire"
* dfgCodeLoinc 0..1 string "DFG code LOINC" "Code LOINC pour le DFG"
* dfgDatePrelevement 0..1 dateTime "DFG date prélèvement" "Date et heure du prélèvement pour DFG"
* dfgStatutValidation 0..1 string "DFG statut validation" "Statut de validation du résultat de DFG"
* dfgBorneInf 0..1 decimal "DFG borne inférieure" "Borne inférieure de normalité pour le DFG"
* dfgBorneSup 0..1 decimal "DFG borne supérieure" "Borne supérieure de normalité pour le DFG"

* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"