Logical: FonctionRenale
Id: fonction-renale
Title: "Fonction Rénale"
Description: "Dosage sanguin de l'urée qui permet d'évaluer la fonction rénale"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Renal Function Biology Tests"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

// Urea tests
* ureeValeur 0..1 decimal "Valeur du dosage de l'urée" "Valeur du dosage de l'urée dans le sang"
  * ^short = "Taux d'urée"
  * ^definition = "Concentration d'urée mesurée dans le sang"
* ureeCodeLoinc 0..1 string "Code LOINC pour l'urée" "Code LOINC standardisé pour le dosage d'urée"
  * ^maxLength = 20
* ureeeDatePrelevement 0..1 dateTime "Date prélèvement urée" "Date et heure du prélèvement d'urée"
* ureeStatutValidation 0..1 string "Statut validation urée" "Statut de validation du résultat d'urée"
  * ^maxLength = 50
* ureeBorneInf 0..1 decimal "Borne inférieure urée" "Borne inférieure de normalité pour l'urée"
* ureeBorneSup 0..1 decimal "Borne supérieure urée" "Borne supérieure de normalité pour l'urée"

// Creatinine tests
* creatinineValeur 0..1 decimal "Valeur de la créatininémie" "Valeur de la créatinine sérique"
  * ^short = "Taux de créatinine"
  * ^definition = "Concentration de créatinine mesurée dans le sang"
* creatinineCodeLoinc 0..1 string "Code LOINC créatinine" "Code LOINC standardisé pour la créatinine"
  * ^maxLength = 20
* creatinineDatePrelevement 0..1 dateTime "Date prélèvement créatinine" "Date et heure du prélèvement de créatinine"
* creatinineStatutValidation 0..1 string "Statut validation créatinine" "Statut de validation du résultat de créatinine"
  * ^maxLength = 50
* creatinineBorneInf 0..1 decimal "Borne inférieure créatinine" "Borne inférieure de normalité pour la créatinine"
* creatinineBorneSup 0..1 decimal "Borne supérieure créatinine" "Borne supérieure de normalité pour la créatinine"

// GFR (Glomerular Filtration Rate) tests
* dfgValeur 0..1 decimal "Valeur du DFG" "Valeur du débit de filtration glomérulaire"
  * ^short = "Débit de filtration glomérulaire"
  * ^definition = "Mesure de la capacité de filtration des reins"
* dfgCodeLoinc 0..1 string "Code LOINC pour le DFG" "Code LOINC standardisé pour le DFG"
  * ^maxLength = 20
* dfgDatePrelevement 0..1 dateTime "Date prélèvement DFG" "Date et heure du prélèvement pour DFG"
* dfgStatutValidation 0..1 string "Statut validation DFG" "Statut de validation du résultat de DFG"
  * ^maxLength = 50
* dfgBorneInf 0..1 decimal "Borne inférieure DFG" "Borne inférieure de normalité pour le DFG"
* dfgBorneSup 0..1 decimal "Borne supérieure DFG" "Borne supérieure de normalité pour le DFG"

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"