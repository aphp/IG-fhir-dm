Profile: DMObservationLaboratoryBilirubineConjuguee
Parent: DMObservationLaboratoryGeneric
Title: "Bilirubine conjuguée"
Description: """
Profil Bilirubine conjuguée du socle commun des EDSH
"""

* code = $loinc#29760-6 "Bilirubine conjuguée [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #umol/L (exactly)
* valueQuantity.unit = #umol/L (exactly)

Instance: 8f95027b-e9fd-40fb-b8c8-7de2bd39b6f1
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryBilirubineConjuguee)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
