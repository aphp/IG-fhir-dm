Profile: DMObservationLaboratoryTCA
Parent: DMObservationLaboratoryGeneric 
Title: "Temps de céphaline activée"
Description: """
Profil des résultats de TCA - socle commun des EDS
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
    * system = $ucum (exactly)

* component[ControlTCA] ^short = "pour rapporter le TCA témoin."
* component[ControlTCA]
  * code = $loinc#13488-2 (exactly)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"
  * valueQuantity
    * code = #s (exactly)
    * system = $ucum (exactly)

* component[TCARatioPonC] ^short = "pour rapporter le ratio des TCA P/T."
* component[TCARatioPonC]
  * code = $loinc#63561-5 (exactly)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"