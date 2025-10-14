Profile: DMObservationLaboratoryBilirubineConjuguee
Parent: DMObservationLaboratoryGeneric
Title: "Bilirubine conjuguée"
Description: """
Profil des résultats de bilirubine conjuguée du socle commun des EDSH
"""

* code = $loinc#29760-6 "Bilirubine conjuguée [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#umol/L (exactly)
