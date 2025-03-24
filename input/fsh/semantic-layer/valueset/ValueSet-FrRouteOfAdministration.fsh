ValueSet: FrRouteOfAdministration
Title: "French Route of Administration"
Description: "Le jeu de valeurs à utiliser pour coder l'élément *dosageInstruction.route* de la ressource *FrMedicationRequest*."
* ^experimental = false
* ^immutable = false
* include codes from system SNOMED_CT
    where constraint = "< 284009009 |Route of administration value (qualifier value)|"