Profile: DMObservationLaboratoryUremie
Parent: DMObservationLaboratoryGeneric
Title: "Urée"
Description: """
Taux d'urée dans le sang. L'urée est un catabolite composé formé dans le foie à partir de l'ammoniac produit par la désamination des acides aminés. C'est le principal produit final du catabolisme des protéines et il constitue environ la moitié des solides urinaires totaux.
"""

* code = $loinc#22664-7 "Urée [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #mmol/L (exactly)
* valueQuantity.unit = "mmol/L"

* referenceRange 1..
* referenceRange MS

Instance: a9b0c1d2-3e4f-5a6b-7c8d-9e0f1a2b3c4d
InstanceOf: Provenance
Title: "fixing QA assessment"
Description: """fixing QA assessment"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryUremie)
* occurredDateTime = "2025-03-27"
* reason.text = """fixing QA assessment"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-03-27T18:20:06+01:00"

Instance: e2f3a4b5-6c7d-8e9f-0a1b-2c3d4e5f6a7b
InstanceOf: Provenance
Title: "WIP adding EDSH vars"
Description: """WIP adding EDSH vars"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryUremie)
* occurredDateTime = "2025-03-24"
* reason.text = """WIP adding EDSH vars"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-03-24T09:26:15+01:00"