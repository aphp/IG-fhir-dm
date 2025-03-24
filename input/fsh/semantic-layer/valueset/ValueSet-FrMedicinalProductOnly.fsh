ValueSet: FrMedicinalProductOnly
Title: "French Medicinal Product only"
Description: "Le jeu de valeurs à utiliser pour coder l'élément *code* de la ressource *FrMedicationNonproprietaryName*."
* ^experimental = false
* ^immutable = false
* include codes from system SNOMED_CT
    where constraint = "< 763158003 |Medicinal product (product)| : 127489000 |Has active ingredient (attribute)| = * ,  [0..0] 411116001 |Has manufactured dose form (attribute)| = *"