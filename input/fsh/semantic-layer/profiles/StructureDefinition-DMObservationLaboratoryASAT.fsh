Profile: DMObservationLaboratoryASAT
Parent: DMObservationLaboratoryGeneric
Title: "Aspartate aminotransférase"
Description: """
Profil des résultats d'aspartate aminotransférase (ASAT) du socle commun des EDSH
"""

* code = $loinc#30239-8 "Aspartate aminotransférase [Catalytique/Volume] Sérum/Plasma ; Numérique ; Avec phosphate de pyridoxal" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#U/L (exactly)
