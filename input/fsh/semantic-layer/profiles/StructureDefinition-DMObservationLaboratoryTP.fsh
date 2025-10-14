Profile: DMObservationLaboratoryTP
Parent: DMObservationLaboratoryGeneric
Title: "Taux de prothrombine"
Description: """
Profil des résultats du taux de prothrombine (TP) du socle commun des EDSH
"""

* code = $loinc#5894-1 "Temps de quick Patient (%) [Temps relatif] Plasma pauvre en plaquettes ; Numérique ; Coagulation" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#% (exactly)
