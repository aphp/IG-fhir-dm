Logical: BilanHepatique
Id: bilan-hepatique
Title: "Bilan Hépatique"
Description: "Bilan hépatique - tests de fonction hépatique"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Hepatic Assessment"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

// Note: The SQL DDL shows this table structure is not yet fully defined
// The following represents expected hepatic function tests structure
// that would follow the same pattern as fonction_renale and hemogramme

* astValeur 0..1 decimal "Valeur AST" "Aspartate aminotransférase (ASAT)"
  * ^short = "Taux d'AST"
  * ^definition = "Concentration d'aspartate aminotransférase dans le sang"
* astCodeLoinc 0..1 string "Code LOINC AST" "Code LOINC standardisé pour l'AST"
  * ^maxLength = 20
* astDatePrelevement 0..1 dateTime "Date prélèvement AST" "Date et heure du prélèvement AST"
* astStatutValidation 0..1 string "Statut validation AST" "Statut de validation AST"
  * ^maxLength = 50
* astBorneInf 0..1 decimal "Borne inférieure AST" "Borne inférieure de normalité pour l'AST"
* astBorneSup 0..1 decimal "Borne supérieure AST" "Borne supérieure de normalité pour l'AST"

* altValeur 0..1 decimal "Valeur ALT" "Alanine aminotransférase (ALAT)"
  * ^short = "Taux d'ALT"
  * ^definition = "Concentration d'alanine aminotransférase dans le sang"
* altCodeLoinc 0..1 string "Code LOINC ALT" "Code LOINC standardisé pour l'ALT"
  * ^maxLength = 20
* altDatePrelevement 0..1 dateTime "Date prélèvement ALT" "Date et heure du prélèvement ALT"
* altStatutValidation 0..1 string "Statut validation ALT" "Statut de validation ALT"
  * ^maxLength = 50
* altBorneInf 0..1 decimal "Borne inférieure ALT" "Borne inférieure de normalité pour l'ALT"
* altBorneSup 0..1 decimal "Borne supérieure ALT" "Borne supérieure de normalité pour l'ALT"

* bilirubineValeur 0..1 decimal "Valeur bilirubine" "Concentration de bilirubine totale"
  * ^short = "Taux de bilirubine"
  * ^definition = "Concentration de bilirubine totale dans le sang"
* bilirubineCodeLoinc 0..1 string "Code LOINC bilirubine" "Code LOINC standardisé pour la bilirubine"
  * ^maxLength = 20
* bilirubinemeDatePrelevement 0..1 dateTime "Date prélèvement bilirubine" "Date et heure du prélèvement bilirubine"
* bilirubineStatutValidation 0..1 string "Statut validation bilirubine" "Statut de validation bilirubine"
  * ^maxLength = 50
* bilirubinemBorneInf 0..1 decimal "Borne inférieure bilirubine" "Borne inférieure de normalité pour la bilirubine"
* bilirubinemBorneSup 0..1 decimal "Borne supérieure bilirubine" "Borne supérieure de normalité pour la bilirubine"

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"