Profile: DMObservationLaboratoryGlycemieAJeun
Parent: DMObservationLaboratoryGeneric
Title: "Glycémie à jeun"
Description: """
Taux de glucose dans le sang à jeun (c'est à dire après une période sans apport alimentaire d'au moins 8 heures).
"""

* code = $loinc#14749-6 "Glucose [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #mmol/L (exactly)
* valueQuantity.unit = "mmol/L"

Instance: 83e237db-e8c4-43d0-a24e-f4ec76da1aa6
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryGlycemieAJeun)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
