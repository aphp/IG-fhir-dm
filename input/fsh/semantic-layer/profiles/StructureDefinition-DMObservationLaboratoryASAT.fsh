Profile: DMObservationLaboratoryAsat
Parent: DMObservationLaboratoryGeneric
Title: "Aspartate aminotransférase (ASAT)"
Description: """
Taux d'ASAT dans le sang. L'ASAT est une enzyme faisant partie des transaminases qui intervient dans la navette malate-aspartate de transfert des électrons du NADH cytosolique vers le NAD+ mitochondrial.
"""

// * code = $loinc#30239-8 "Aspartate aminotransférase [Catalytique/Volume] Sérum/Plasma ; Numérique ; Avec phosphate de pyridoxal" (exactly)
* code from DMLaboratoryAsat

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #[IU]/L (exactly)
* valueQuantity.unit = "[IU]/L"


Instance: 6feb05dc-9bdd-491d-925d-9840a535fbb7
InstanceOf: Provenance
Title: "Assouplissement du code (VS plutôt que valeur fixe). Modification du nom du profil pour respect des conventions"
Description: """Assouplissement du code (VS plutôt que valeur fixe). Modification du nom du profil pour respect des conventions"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryAsat)
* occurredDateTime = "2025-11-10"
* reason.text = """Assouplissement du code (VS plutôt que valeur fixe). Modification du nom du profil pour respect des conventions"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: 54a2948b-6ae1-4fa7-8a99-d5db61701273
InstanceOf: Provenance
Title: "feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"
Description: """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryAsat)
* occurredDateTime = "2025-10-14"
* reason.text = """feat(fhir-profiles): add 18 laboratory observation profiles for EDSH core variables"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T16:58:23+02:00"
