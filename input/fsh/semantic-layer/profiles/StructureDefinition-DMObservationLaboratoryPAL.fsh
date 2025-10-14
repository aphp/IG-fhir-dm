Profile: DMObservationLaboratoryPAL
Parent: DMObservationLaboratoryGeneric
Title: "Phosphatases alcaline"
Description: """
Profil Phosphatases alcaline du socle commun des EDSH
"""

* code = $loinc#6768-6 "Phosphatases alcalines [Catalytique/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #U/L (exactly)
* valueQuantity.unit = #U/L (exactly)

Instance: 36035e17-dee7-45eb-9f5a-1fa7628524da
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryPAL)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
