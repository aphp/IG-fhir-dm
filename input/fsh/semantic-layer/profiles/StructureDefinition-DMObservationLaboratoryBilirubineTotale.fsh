Profile: DMObservationLaboratoryBilirubineTotale
Parent: DMObservationLaboratoryGeneric
Title: "Bilirubine totale"
Description: """
Taux de bilirubine sanguin. La bilirubine est un pigment jaune produit de la dégradation de l'hémoglobine, et d'autres hémoprotéines (cytochrome ou catalases).
"""

* code = $loinc#14631-6 "Bilirubine [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #umol/L (exactly)
* valueQuantity.unit = #umol/L (exactly)

Instance: 34ca9da4-4ca3-418a-aa45-9e001241d6e8
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryBilirubineTotale)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
