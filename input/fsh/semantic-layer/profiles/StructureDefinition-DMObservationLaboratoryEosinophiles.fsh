Profile: DMObservationLaboratoryEosinophiles
Parent: DMObservationLaboratoryGeneric
Title: "Éosinophiles"
Description: """
Profil des résultats d'éosinophiles du socle commun des EDSH
"""

* code = $loinc#26449-9 "Polynucléaires éosinophiles [Nombre/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*3/uL (exactly)
