Profile: DMObservationLaboratoryPlaquettes
Parent: DMObservationLaboratoryGeneric
Title: "Plaquettes"
Description: """
Profil Plaquettes du socle commun des EDSH
"""

* code = $loinc#777-3 "Plaquettes [Nombre/Volume] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #10*3/uL (exactly)
* valueQuantity.unit = #10*3/uL (exactly)

Instance: c7ac6c79-d3ea-4e80-8859-2217c044b3ec
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryPlaquettes)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
