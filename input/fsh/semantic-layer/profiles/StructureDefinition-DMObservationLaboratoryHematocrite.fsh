Profile: DMObservationLaboratoryHematocrite
Parent: DMObservationLaboratoryGeneric
Title: "Hématocrite"
Description: """
Profil des résultats d'hématocrite du socle commun des EDSH
"""

* code = $loinc#4544-3 "Hématocrite [Fraction volumique] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#% (exactly)
