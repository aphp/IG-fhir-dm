Profile: DMObservationLaboratoryHemoglobine
Parent: DMObservationLaboratoryGeneric
Title: "Hémoglobine"
Description: """
Profil des résultats d'hémoglobine du socle commun des EDSH
"""

* code = $loinc#718-7 "Hémoglobine [Masse/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#g/dL (exactly)
