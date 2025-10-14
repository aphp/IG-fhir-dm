Profile: DMObservationLaboratoryMonocytes
Parent: DMObservationLaboratoryGeneric
Title: "Monocytes"
Description: """
Profil Monocytes du socle commun des EDSH
"""

* code = $loinc#26484-6 "Monocytes [Nombre/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #10*3/uL (exactly)
* valueQuantity.unit = #10*3/uL (exactly)

Instance: 0a5b5832-86f0-48bd-93b4-ec55b769a863
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryMonocytes)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
