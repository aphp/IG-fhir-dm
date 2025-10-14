Profile: DMObservationLaboratoryMonocytes
Parent: DMObservationLaboratoryGeneric
Title: "Monocytes"
Description: """
Profil des résultats de monocytes du socle commun des EDSH
"""

* code = $loinc#26484-6 "Monocytes [Nombre/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*3/uL (exactly)
