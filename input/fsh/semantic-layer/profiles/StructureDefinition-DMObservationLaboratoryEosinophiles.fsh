Profile: DMObservationLaboratoryEosinophiles
Parent: DMObservationLaboratoryGeneric
Title: "Eosinophiles"
Description: """
Profil Eosinophiles du socle commun des EDSH
"""

* code = $loinc#26449-9 "Polynucléaires éosinophiles [Nombre/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #10*3/uL (exactly)
* valueQuantity.unit = "10*3/uL"

Instance: 2237429f-4de7-41bb-bfd9-37544b427e37
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryEosinophiles)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
