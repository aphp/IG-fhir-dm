ValueSet: FrRouteOfAdministration
Title: "French Route of Administration"
Description: "Le jeu de valeurs à utiliser pour coder l'élément *dosageInstruction.route* de la ressource *FrMedicationRequest*."
* ^experimental = false
* ^immutable = false
* include codes from system SNOMED_CT
    where constraint = "< 284009009 |Route of administration value (qualifier value)|"

Instance: 40000690-9cc0-4572-a8ea-419a4f5f77dc
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrRouteOfAdministration)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"