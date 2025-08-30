Logical: BiologieAutres
Id: biologie-autres
Title: "Biologie Autres"
Description: "Autres examens biologiques non catégorisés"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Other Biology Tests"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

// Generic structure for other biology tests
* testName 0..1 string "Nom du test biologique" "Nom descriptif du test biologique réalisé"
  * ^short = "Nom du test"
  * ^definition = "Dénomination du test biologique effectué"
  * ^maxLength = 255
* testValeur 0..1 decimal "Valeur du test" "Résultat numérique du test biologique"
  * ^short = "Résultat du test"
  * ^definition = "Valeur mesurée lors du test biologique"
* testCodeLoinc 0..1 string "Code LOINC du test" "Code LOINC standardisé identifiant le test"
  * ^short = "Code de référence LOINC"
  * ^definition = "Code LOINC permettant l'identification standardisée du test"
  * ^maxLength = 20
* testDatePrelevement 0..1 dateTime "Date du prélèvement" "Date et heure du prélèvement biologique"
  * ^short = "Moment du prélèvement"
  * ^definition = "Date et heure précises du prélèvement de l'échantillon"
* testStatutValidation 0..1 string "Statut de validation" "Statut de validation du résultat du test"
  * ^short = "État de validation"
  * ^definition = "Statut indiquant le niveau de validation du résultat"
  * ^maxLength = 50
* testBorneInf 0..1 decimal "Borne inférieure" "Borne inférieure de normalité pour le test"
  * ^short = "Limite inférieure normale"
  * ^definition = "Valeur minimale de l'intervalle de référence"
* testBorneSup 0..1 decimal "Borne supérieure" "Borne supérieure de normalité pour le test"
  * ^short = "Limite supérieure normale"
  * ^definition = "Valeur maximale de l'intervalle de référence"

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"