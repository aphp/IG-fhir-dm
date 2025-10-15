Profile: DMObservationLaboratoryTCA
Parent: DMObservationLaboratoryGeneric
Title: "Temps de céphaline activée (TCA)"
Description: """
Profil Temps de céphaline activée (TCA) du socle commun des EDSH
"""

* code = $loinc#50197-3 "Temps de céphaline activée panel [-] Plasma pauvre en plaquettes ; Numérique" (exactly)

* component ^slicing.discriminator[0].type = #value
* component ^slicing.discriminator[=].path = "code"
* component ^slicing.rules = #open
* component ^short = "Permet de rapporter le temps patient, le temps témoins et le ratio."
* component contains
    PatientTCA 1..1 MS and
    ControlTCA 1..1 MS and
    TCARatioPonC 1..1 MS

* component[PatientTCA] ^short = "pour rapporter le TCA patient."
* component[PatientTCA]
  * code = $loinc#14979-9 (exactly)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"
  * valueQuantity
    * code = #s (exactly)
    * unit = "s"
    * system = $ucum (exactly)

* component[ControlTCA] ^short = "pour rapporter le TCA témoin."
* component[ControlTCA]
  * code = $loinc#13488-2 (exactly)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"
  * valueQuantity
    * code = #s (exactly)
    * unit = "s"
    * system = $ucum (exactly)

* component[TCARatioPonC] ^short = "pour rapporter le ratio des TCA P/T."
* component[TCARatioPonC]
  * code = $loinc#63561-5 (exactly)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"

Instance: f8a9b0c1-2d3e-4f5a-6b7c-8d9e0f1a2b3c
InstanceOf: Provenance
Title: "fixing QA assessment"
Description: """fixing QA assessment"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryTCA)
* occurredDateTime = "2025-03-27"
* reason.text = """fixing QA assessment"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-03-27T18:20:06+01:00"

Instance: d1e2f3a4-5b6c-7d8e-9f0a-1b2c3d4e5f6a
InstanceOf: Provenance
Title: "WIP adding EDSH vars"
Description: """WIP adding EDSH vars"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryTCA)
* occurredDateTime = "2025-03-24"
* reason.text = """WIP adding EDSH vars"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-03-24T09:26:15+01:00"