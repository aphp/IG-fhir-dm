Logical: Hemogramme
Id: hemogramme
Title: "Hémogramme"
Description: "Hémogramme - examens sanguins de base incluant leucocytes, hémoglobine, hématocrite, globules rouges, VGM, plaquettes et neutrophiles"
* ^status = #active
* ^experimental = false

* id 0..1 integer "Identifiant technique" "Identifiant technique auto-incrémenté"
* patientId 1..1 string "Identifiant patient" "Link to main patient table"

* leucocytesValeur 0..1 decimal "Leucocytes valeur" "Valeur des leucocytes"
* leucocytesCodeLoinc 0..1 string "Leucocytes code LOINC" "Code LOINC pour les leucocytes"
* leucocytesDatePrelevement 0..1 dateTime "Leucocytes date prélèvement" "Date et heure du prélèvement leucocytes"
* leucocytesStatutValidation 0..1 string "Leucocytes statut validation" "Statut de validation leucocytes"
* leucocytesBorneInf 0..1 decimal "Leucocytes borne inférieure" "Borne inférieure normalité leucocytes"
* leucocytesBorneSup 0..1 decimal "Leucocytes borne supérieure" "Borne supérieure normalité leucocytes"

* hemoglobineValeur 0..1 decimal "Hémoglobine valeur" "Valeur de l'hémoglobine"
* hemoglobineCodeLoinc 0..1 string "Hémoglobine code LOINC" "Code LOINC pour l'hémoglobine"
* hemoglobineDatePrelevement 0..1 dateTime "Hémoglobine date prélèvement" "Date et heure du prélèvement hémoglobine"
* hemoglobineStatutValidation 0..1 string "Hémoglobine statut validation" "Statut de validation hémoglobine"
* hemoglobineBorneInf 0..1 decimal "Hémoglobine borne inférieure" "Borne inférieure normalité hémoglobine"
* hemoglobineBorneSup 0..1 decimal "Hémoglobine borne supérieure" "Borne supérieure normalité hémoglobine"

* hematocriteValeur 0..1 decimal "Hématocrite valeur" "Volume occupé par les globules rouges dans le sang"
* hematocriteCodeLoinc 0..1 string "Hématocrite code LOINC" "Code LOINC pour l'hématocrite"
* hematocriteDatePrelevement 0..1 dateTime "Hématocrite date prélèvement" "Date et heure du prélèvement hématocrite"
* hematocriteStatutValidation 0..1 string "Hématocrite statut validation" "Statut de validation hématocrite"
* hematocriteBorneInf 0..1 decimal "Hématocrite borne inférieure" "Borne inférieure normalité hématocrite"
* hematocriteBorneSup 0..1 decimal "Hématocrite borne supérieure" "Borne supérieure normalité hématocrite"

* globulesRougesValeur 0..1 decimal "Globules rouges valeur" "Dosage sanguin des globules rouges"
* globulesRougesCodeLoinc 0..1 string "Globules rouges code LOINC" "Code LOINC pour les globules rouges"
* globulesRougesDatePrelevement 0..1 dateTime "Globules rouges date prélèvement" "Date et heure du prélèvement globules rouges"
* globulesRougesStatutValidation 0..1 string "Globules rouges statut validation" "Statut de validation globules rouges"
* globulesRougesBorneInf 0..1 decimal "Globules rouges borne inférieure" "Borne inférieure normalité globules rouges"
* globulesRougesBorneSup 0..1 decimal "Globules rouges borne supérieure" "Borne supérieure normalité globules rouges"

* vgmValeur 0..1 decimal "VGM valeur" "Volume moyen des globules rouges, valeur centrale pour le diagnostic des anémies"
* vgmCodeLoinc 0..1 string "VGM code LOINC" "Code LOINC pour le VGM"
* vgmDatePrelevement 0..1 dateTime "VGM date prélèvement" "Date et heure du prélèvement VGM"
* vgmStatutValidation 0..1 string "VGM statut validation" "Statut de validation VGM"
* vgmBorneInf 0..1 decimal "VGM borne inférieure" "Borne inférieure normalité VGM"
* vgmBorneSup 0..1 decimal "VGM borne supérieure" "Borne supérieure normalité VGM"

* plaquettesValeur 0..1 decimal "Plaquettes valeur" "Dosage sanguin des plaquettes, utile pour toute pathologie faisant intervenir le système immunitaire/hématologique"
* plaquettesCodeLoinc 0..1 string "Plaquettes code LOINC" "Code LOINC pour les plaquettes"
* plaquettesDatePrelevement 0..1 dateTime "Plaquettes date prélèvement" "Date et heure du prélèvement plaquettes"
* plaquettesStatutValidation 0..1 string "Plaquettes statut validation" "Statut de validation plaquettes"
* plaquettesBorneInf 0..1 decimal "Plaquettes borne inférieure" "Borne inférieure normalité plaquettes"
* plaquettesBorneSup 0..1 decimal "Plaquettes borne supérieure" "Borne supérieure normalité plaquettes"

* neutrophilesValeur 0..1 decimal "Neutrophiles valeur" "Dosage sanguin des neutrophiles"
* neutrophilesCodeLoinc 0..1 string "Neutrophiles code LOINC" "Code LOINC pour les neutrophiles"
* neutrophilesDatePrelevement 0..1 dateTime "Neutrophiles date prélèvement" "Date et heure du prélèvement neutrophiles"
* neutrophilesStatutValidation 0..1 string "Neutrophiles statut validation" "Statut de validation neutrophiles"
* neutrophilesBorneInf 0..1 decimal "Neutrophiles borne inférieure" "Borne inférieure normalité neutrophiles"
* neutrophilesBorneSup 0..1 decimal "Neutrophiles borne supérieure" "Borne supérieure normalité neutrophiles"

* createdAt 0..1 dateTime "Date de création" "Date de création de l'enregistrement"