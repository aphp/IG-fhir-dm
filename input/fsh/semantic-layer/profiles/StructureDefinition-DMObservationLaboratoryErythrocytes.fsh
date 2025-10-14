Profile: DMObservationLaboratoryErythrocytes
Parent: DMObservationLaboratoryGeneric
Title: "Erythrocytes"
Description: """
Profil Erythrocytes du socle commun des EDSH
"""

* code = $loinc#789-8 "Érythrocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #10*6/uL (exactly)
* valueQuantity.unit = #10*6/uL (exactly)

Instance: de1f2303-d9a4-485b-80c3-94a12081776f
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryErythrocytes)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
