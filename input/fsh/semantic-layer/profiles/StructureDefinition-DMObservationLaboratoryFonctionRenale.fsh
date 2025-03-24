Profile: DMObservationLaboratoryFonctionRenale
Parent: DMObservationLaboratoryGeneric 
Title: "Fonction rénale"
Description: """
Profil des résultats de fonction rénale du socle commun des EDS
"""

* code = $loinc#45066-8 (exactly)

* component ^slicing.discriminator[0].type = #value
* component ^slicing.discriminator[=].path = "code"
* component ^slicing.rules = #open
* component ^short = "Permet de rapporter la créatininémie et l'estimation du DFG."
* component contains
    Creat 1..1 MS and
    Dfg 1..1 MS 


* component[Creat] ^short = "Créatininémie"
* component[Creat]
  * code = $loinc#14682-9 (exactly)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"
  * valueQuantity
    * system = $ucum (exactly)
    * code = $ucum#umol/L (exactly)
  * referenceRange 1..
  * referenceRange MS

* component[Dfg] ^short = "Débit de filtration glomérulaire estimé"
* component[Dfg]
  * code from DMLaboratoryEstimatedDFG (required)
  * value[x] only Quantity
  * valueQuantity ^short = "Valeur mesurée"
  * valueQuantity
    * system = $ucum (exactly)
    * code from DMLaboratoryEstimatedDFGUnit (extensible)
  * referenceRange 1..
  * referenceRange MS