ValueSet: FrMpDoseForm
Title: "French Medicinal product Dose form"
Description: "Le jeu de valeurs à utiliser pour coder l'élément *doseForm* des ressources *FrMedicationUcd*, *FrMedicationUcdPart* ou *FrMedicationNonProprietaryName*."
* ^experimental = false
* ^immutable = false
* include codes from system SNOMED_CT
    where constraint = "< 763158003 |Medicinal product (product)| : 411116001 |Has manufactured dose form (attribute)| = *"

Instance: 854444ec-e3be-4de4-80f7-ff96e49e7891
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrMpDoseForm)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"