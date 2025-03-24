ValueSet: FrMpDoseForm
Title: "French Medicinal product Dose form"
Description: "Le jeu de valeurs à utiliser pour coder l'élément *doseForm* des ressources *FrMedicationUcd*, *FrMedicationUcdPart* ou *FrMedicationNonProprietaryName*."
* ^experimental = false
* ^immutable = false
* include codes from system SNOMED_CT
    where constraint = "< 763158003 |Medicinal product (product)| : 411116001 |Has manufactured dose form (attribute)| = *"