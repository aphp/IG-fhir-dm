Profile: DMObservationLaboratoryVgm
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
* valueQuantity.unit = "fL"


Instance: 7015b719-cf9d-4c8f-a6ad-d7f6f4df7a78
InstanceOf: Provenance
Title: "Modification du nom du profil pour respect des conventions"
Description: """Modification du nom du profil pour respect des conventions"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryVgm)
* occurredDateTime = "2025-11-10"
* reason.text = """Modification du nom du profil pour respect des conventions"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: e7f8a9b0-1c2d-3e4f-5a6b-7c8d9e0f1a2b
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryVgm)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
