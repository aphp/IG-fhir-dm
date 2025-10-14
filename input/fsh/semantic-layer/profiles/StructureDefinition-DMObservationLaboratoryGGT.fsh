Profile: DMObservationLaboratoryGGT
Parent: DMObservationLaboratoryGeneric
Title: "Gamma-glutamyl transférase"
Description: """
Profil des résultats de gamma-glutamyl transférase (GGT) du socle commun des EDSH
"""

* code = $loinc#2324-2 "Gamma glutamyltransférase [Catalytique/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#U/L (exactly)
