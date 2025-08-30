Logical: Hemogramme
Id: hemogramme
Title: "Hémogramme"
Description: "Hémogramme - examens sanguins de base incluant leucocytes, hémoglobine, hématocrite, globules rouges, VGM, plaquettes et neutrophiles"
* ^status = #draft
* ^experimental = true
* ^purpose = "Variables socles pour les EDSH (Core variables for Health Data Warehouses) - Blood Count Tests"

* id 1..1 integer "Identifiant technique de la table" "Identifiant séquentiel auto-généré"
* patientId 1..1 Reference(IdentitePatient) "Référence patient" "Référence vers l'identité du patient"
  * ^short = "Identifiant du patient"
  * ^definition = "Référence vers la table identite_patient"

// White blood cells
* leucocytesValeur 0..1 decimal "Valeur des leucocytes" "Concentration des globules blancs dans le sang"
  * ^short = "Taux de leucocytes"
  * ^definition = "Nombre de leucocytes par unité de volume sanguin"
* leucocytesCodeLoinc 0..1 string "Code LOINC leucocytes" "Code LOINC standardisé pour les leucocytes"
  * ^maxLength = 20
* leucocytesDatePrelevement 0..1 dateTime "Date prélèvement leucocytes" "Date et heure du prélèvement leucocytes"
* leucocytesStatutValidation 0..1 string "Statut validation leucocytes" "Statut de validation leucocytes"
  * ^maxLength = 50
* leucocytesBorneInf 0..1 decimal "Borne inférieure leucocytes" "Borne inférieure normalité leucocytes"
* leucocytesBorneSup 0..1 decimal "Borne supérieure leucocytes" "Borne supérieure normalité leucocytes"

// Hemoglobin
* hemoglobineValeur 0..1 decimal "Valeur de l'hémoglobine" "Concentration d'hémoglobine dans le sang"
  * ^short = "Taux d'hémoglobine"
  * ^definition = "Quantité d'hémoglobine présente dans le sang"
* hemoglobineCodeLoinc 0..1 string "Code LOINC hémoglobine" "Code LOINC standardisé pour l'hémoglobine"
  * ^maxLength = 20
* hemoglobineDatePrelevement 0..1 dateTime "Date prélèvement hémoglobine" "Date et heure du prélèvement hémoglobine"
* hemoglobineStatutValidation 0..1 string "Statut validation hémoglobine" "Statut de validation hémoglobine"
  * ^maxLength = 50
* hemoglobineBorneInf 0..1 decimal "Borne inférieure hémoglobine" "Borne inférieure normalité hémoglobine"
* hemoglobineBorneSup 0..1 decimal "Borne supérieure hémoglobine" "Borne supérieure normalité hémoglobine"

// Hematocrit
* hematocriteValeur 0..1 decimal "Valeur de l'hématocrite" "Volume occupé par les globules rouges dans le sang"
  * ^short = "Pourcentage d'hématocrite"
  * ^definition = "Proportion du volume sanguin occupée par les globules rouges"
* hematocriteCodeLoinc 0..1 string "Code LOINC hématocrite" "Code LOINC standardisé pour l'hématocrite"
  * ^maxLength = 20
* hematocriteDatePrelevement 0..1 dateTime "Date prélèvement hématocrite" "Date et heure du prélèvement hématocrite"
* hematocriteStatutValidation 0..1 string "Statut validation hématocrite" "Statut de validation hématocrite"
  * ^maxLength = 50
* hematocriteBorneInf 0..1 decimal "Borne inférieure hématocrite" "Borne inférieure normalité hématocrite"
* hematocriteBorneSup 0..1 decimal "Borne supérieure hématocrite" "Borne supérieure normalité hématocrite"

// Red blood cells
* globulesRougesValeur 0..1 decimal "Valeur globules rouges" "Dosage sanguin des globules rouges"
  * ^short = "Nombre de globules rouges"
  * ^definition = "Concentration des érythrocytes dans le sang"
* globulesRougesCodeLoinc 0..1 string "Code LOINC globules rouges" "Code LOINC standardisé pour les globules rouges"
  * ^maxLength = 20
* globulesRougesDatePrelevement 0..1 dateTime "Date prélèvement globules rouges" "Date et heure du prélèvement globules rouges"
* globulesRougesStatutValidation 0..1 string "Statut validation globules rouges" "Statut de validation globules rouges"
  * ^maxLength = 50
* globulesRougesBorneInf 0..1 decimal "Borne inférieure globules rouges" "Borne inférieure normalité globules rouges"
* globulesRougesBorneSup 0..1 decimal "Borne supérieure globules rouges" "Borne supérieure normalité globules rouges"

// Mean Corpuscular Volume
* vgmValeur 0..1 decimal "Valeur du VGM" "Volume moyen des globules rouges, valeur centrale pour le diagnostic des anémies"
  * ^short = "Volume globulaire moyen"
  * ^definition = "Volume moyen des érythrocytes, indicateur important pour le diagnostic d'anémie"
* vgmCodeLoinc 0..1 string "Code LOINC pour le VGM" "Code LOINC standardisé pour le VGM"
  * ^maxLength = 20
* vgmDatePrelevement 0..1 dateTime "Date prélèvement VGM" "Date et heure du prélèvement VGM"
* vgmStatutValidation 0..1 string "Statut validation VGM" "Statut de validation VGM"
  * ^maxLength = 50
* vgmBorneInf 0..1 decimal "Borne inférieure VGM" "Borne inférieure normalité VGM"
* vgmBorneSup 0..1 decimal "Borne supérieure VGM" "Borne supérieure normalité VGM"

// Platelets
* plaquettesValeur 0..1 decimal "Valeur des plaquettes" "Dosage sanguin des plaquettes, utile pour toute pathologie faisant intervenir le système immunitaire/hématologique"
  * ^short = "Numération plaquettaire"
  * ^definition = "Concentration des thrombocytes dans le sang"
* plaquettesCodeLoinc 0..1 string "Code LOINC plaquettes" "Code LOINC standardisé pour les plaquettes"
  * ^maxLength = 20
* plaquettesDatePrelevement 0..1 dateTime "Date prélèvement plaquettes" "Date et heure du prélèvement plaquettes"
* plaquettesStatutValidation 0..1 string "Statut validation plaquettes" "Statut de validation plaquettes"
  * ^maxLength = 50
* plaquettesBorneInf 0..1 decimal "Borne inférieure plaquettes" "Borne inférieure normalité plaquettes"
* plaquettesBorneSup 0..1 decimal "Borne supérieure plaquettes" "Borne supérieure normalité plaquettes"

// Neutrophils
* neutrophilesValeur 0..1 decimal "Valeur des neutrophiles" "Dosage sanguin des neutrophiles"
  * ^short = "Taux de neutrophiles"
  * ^definition = "Concentration des neutrophiles dans le sang"
* neutrophilesCodeLoinc 0..1 string "Code LOINC neutrophiles" "Code LOINC standardisé pour les neutrophiles"
  * ^maxLength = 20
* neutrophilesDatePrelevement 0..1 dateTime "Date prélèvement neutrophiles" "Date et heure du prélèvement neutrophiles"
* neutrophilesStatutValidation 0..1 string "Statut validation neutrophiles" "Statut de validation neutrophiles"
  * ^maxLength = 50
* neutrophilesBorneInf 0..1 decimal "Borne inférieure neutrophiles" "Borne inférieure normalité neutrophiles"
* neutrophilesBorneSup 0..1 decimal "Borne supérieure neutrophiles" "Borne supérieure normalité neutrophiles"

* createdAt 1..1 dateTime "Date de création" "Timestamp de création de l'enregistrement"