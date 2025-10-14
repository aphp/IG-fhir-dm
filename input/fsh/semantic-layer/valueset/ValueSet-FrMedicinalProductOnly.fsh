ValueSet: FrMedicinalProductOnly
Title: "French Medicinal Product only"
Description: "Le jeu de valeurs à utiliser pour coder l'élément *code* de la ressource *FrMedicationNonproprietaryName*."
* ^experimental = false
* ^immutable = false
* include codes from system SNOMED_CT
    where constraint = "< 763158003 |Medicinal product (product)| : 127489000 |Has active ingredient (attribute)| = * ,  [0..0] 411116001 |Has manufactured dose form (attribute)| = *"

Instance: e1497c68-0225-497a-a520-6bd7b1d9c324
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrMedicinalProductOnly)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"