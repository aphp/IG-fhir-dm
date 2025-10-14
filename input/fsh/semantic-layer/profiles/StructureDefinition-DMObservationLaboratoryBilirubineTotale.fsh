Profile: DMObservationLaboratoryBilirubineTotale
Parent: DMObservationLaboratoryGeneric
Title: "Bilirubine totale"
Description: """
Profil des résultats de bilirubine totale du socle commun des EDSH
"""

* code = $loinc#14631-6 "Bilirubine [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#umol/L (exactly)
