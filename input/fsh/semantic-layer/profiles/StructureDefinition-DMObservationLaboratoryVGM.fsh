Profile: DMObservationLaboratoryVGM
Parent: DMObservationLaboratoryGeneric
Title: "Volume Globulaire Moyen"
Description: """
Profil des résultats de Volume Globulaire Moyen (VGM) du socle commun des EDSH
"""

* code = $loinc#30428-7 "Volume globulaire moyen [Volume d'entité] Érythrocytes ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#fL (exactly)
