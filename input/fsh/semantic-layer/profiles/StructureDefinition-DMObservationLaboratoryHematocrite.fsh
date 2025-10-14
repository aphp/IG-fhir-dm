Profile: DMObservationLaboratoryHematocrite
Parent: DMObservationLaboratoryGeneric
Title: "Hématocrite"
Description: """
Profil Hématocrite du socle commun des EDSH
"""

* code = $loinc#4544-3 "Hématocrite [Fraction volumique] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #% (exactly)
* valueQuantity.unit = #% (exactly)

Instance: 4d4fc139-9817-48cc-821a-53723d371ecb
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryHematocrite)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
