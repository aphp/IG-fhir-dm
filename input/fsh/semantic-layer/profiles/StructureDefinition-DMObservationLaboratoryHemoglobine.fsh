Profile: DMObservationLaboratoryHemoglobine
Parent: DMObservationLaboratoryGeneric
Title: "Hémoglobine"
Description: """
Profil Hémoglobine du socle commun des EDSH
"""

* code = $loinc#718-7 "Hémoglobine [Masse/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #g/dL (exactly)
* valueQuantity.unit = #g/dL (exactly)

Instance: d59a5903-cb93-4b12-b9cd-7173c89b1c88
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryHemoglobine)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
