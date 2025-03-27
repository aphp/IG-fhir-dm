Profile: DMObservationLaboratoryUremie
Parent: DMObservationLaboratoryGeneric 
Title: "Urémie"
Description: """
Profil des résultats d'urémie du socle commun des EDS
"""

* code = $loinc#22664-7 "Urée [Moles/Volume] Sérum/Plasma ; Numérique" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = "http://unitsofmeasure.org" (exactly)
* valueQuantity.code 1..
* valueQuantity.code = $ucum#mmol/L (exactly)

* referenceRange 1..
* referenceRange MS