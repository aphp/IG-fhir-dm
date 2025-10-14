Profile: DMObservationLaboratoryLymphocytes
Parent: DMObservationLaboratoryGeneric
Title: "Lymphocytes"
Description: """
Profil des résultats de lymphocytes du socle commun des EDSH
"""

* code = $loinc#26474-7 "Lymphocytes totaux [Nombre/Volume] Sang ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*3/uL (exactly)
