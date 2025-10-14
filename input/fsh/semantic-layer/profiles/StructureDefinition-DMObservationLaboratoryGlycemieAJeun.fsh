Profile: DMObservationLaboratoryGlycemieAJeun
Parent: DMObservationLaboratoryGeneric
Title: "Glycémie à jeun"
Description: """
Profil des résultats de glycémie à jeun du socle commun des EDSH
"""

* code = $loinc#14749-6 "Glucose [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#mmol/L (exactly)
