Profile: DMObservationLaboratoryLeucocytes
Parent: DMObservationLaboratoryGeneric
Title: "Leucocytes"
Description: """
Profil Leucocytes du socle commun des EDSH
"""

* code = $loinc#6690-2 "Leucocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #10*3/uL (exactly)
* valueQuantity.unit = #10*3/uL (exactly)

Instance: 6dbcf7b6-ef2f-4646-98e3-aae94bd5bfd2
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryLeucocytes)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
