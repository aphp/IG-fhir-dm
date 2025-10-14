Profile: DMObservationLaboratoryErythrocytes
Parent: DMObservationLaboratoryGeneric
Title: "Érythrocytes"
Description: """
Profil des résultats d'érythrocytes (globules rouges) du socle commun des EDSH
"""

* code = $loinc#789-8 "Érythrocytes [Nombre/Volume] Sang ; Numérique ; Comptage automate" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#10*6/uL (exactly)
