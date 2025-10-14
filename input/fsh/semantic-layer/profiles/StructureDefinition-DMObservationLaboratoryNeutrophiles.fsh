Profile: DMObservationLaboratoryNeutrophiles
Parent: DMObservationLaboratoryGeneric
Title: "Neutrophiles"
Description: """
Profil des résultats de neutrophiles du socle commun des EDSH
"""

* code = $loinc#26499-4 "Polynucléaires neutrophiles [Nombre/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*3/uL (exactly)
