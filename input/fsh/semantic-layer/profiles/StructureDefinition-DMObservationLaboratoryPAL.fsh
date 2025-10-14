Profile: DMObservationLaboratoryPAL
Parent: DMObservationLaboratoryGeneric
Title: "Phosphatases alcalines"
Description: """
Profil des résultats de phosphatases alcalines (PAL) du socle commun des EDSH
"""

* code = $loinc#6768-6 "Phosphatases alcalines [Catalytique/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#U/L (exactly)
