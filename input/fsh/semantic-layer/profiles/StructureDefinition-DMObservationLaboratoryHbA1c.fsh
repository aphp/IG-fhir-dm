Profile: DMObservationLaboratoryHbA1c
Parent: DMObservationLaboratoryGeneric
Title: "Hémoglobine glyquée"
Description: """
Forme glycquée de la molécule de l'hémoglobine dans le sang. Sa valeur biologique est le reflet de la concentration de glucose dans le sang (glycémie) sur trois mois.
"""

* code = $loinc#4548-4 "Hémoglobine A1c/hémoglobine totale [Fraction massique] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #% (exactly)
* valueQuantity.unit = "%"

Instance: e8f4d2c1-3a5b-4c6d-7e8f-9a0b1c2d3e4f
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryHbA1c)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
