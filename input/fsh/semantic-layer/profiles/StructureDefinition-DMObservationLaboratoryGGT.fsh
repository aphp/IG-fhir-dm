Profile: DMObservationLaboratoryGgt
Parent: DMObservationLaboratoryGeneric
Title: "Gamma-glutamyl transférase (GGT)"
Description: """
Taux sanguin de GGT. Aminoacyltransférase impliquées dans la catalyse d'enzymes hépatiques impliquées dans le métabolisme des acides aminés.
"""

* code = $loinc#2324-2 "Gamma glutamyltransférase [Catalytique/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #U/L (exactly)
* valueQuantity.unit = "U/L"


Instance: cd46246e-c9b2-4a63-b3fc-13c67ad74eea
InstanceOf: Provenance
Title: "Modification du nom du profil pour respect des conventions"
Description: """Modification du nom du profil pour respect des conventions"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryGgt)
* occurredDateTime = "2025-11-10"
* reason.text = """Modification du nom du profil pour respect des conventions"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: 0e124f44-28c3-4ce5-a5f2-08e9619ef73f
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryGgt)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
