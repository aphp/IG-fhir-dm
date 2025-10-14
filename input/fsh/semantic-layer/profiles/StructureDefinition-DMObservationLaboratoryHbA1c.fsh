Profile: DMObservationLaboratoryHbA1c
Parent: DMObservationLaboratoryGeneric
Title: "Hémoglobine glyquée"
Description: """
Profil des résultats d'hémoglobine glyquée (HbA1c) du socle commun des EDSH
"""

* code = $loinc#4548-4 "Hémoglobine A1c/hémoglobine totale [Fraction massique] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#% (exactly)
