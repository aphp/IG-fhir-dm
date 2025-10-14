Profile: DMObservationLaboratoryPlaquettes
Parent: DMObservationLaboratoryGeneric
Title: "Plaquettes"
Description: """
Profil des résultats de plaquettes du socle commun des EDSH
"""

* code = $loinc#777-3 "Plaquettes [Nombre/Volume] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*3/uL (exactly)
