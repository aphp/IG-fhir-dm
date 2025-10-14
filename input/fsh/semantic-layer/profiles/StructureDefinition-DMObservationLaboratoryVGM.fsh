Profile: DMObservationLaboratoryVGM
Parent: DMObservationLaboratoryGeneric
Title: "Volume globulaire moyen"
Description: """
Profil Volume globulaire moyen du socle commun des EDSH
"""

* code = $loinc#30428-7 "Volume globulaire moyen [Volume d'entité] Érythrocytes ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #fL (exactly)
* valueQuantity.unit = #fL (exactly)

Instance: e7f8a9b0-1c2d-3e4f-5a6b-7c8d9e0f1a2b
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryVGM)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
