Profile: DMObservationLaboratoryLeucocytes
Parent: DMObservationLaboratoryGeneric
Title: "Leucocytes"
Description: """
Profil des résultats de leucocytes du socle commun des EDSH
"""

* code = $loinc#6690-2 "Leucocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*3/uL (exactly)
