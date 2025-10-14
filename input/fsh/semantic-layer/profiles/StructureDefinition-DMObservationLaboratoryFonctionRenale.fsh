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

Instance: 02323e68-3c00-4304-88a8-3b9ffdc1f8ec
InstanceOf: Provenance
Title: "WIP adding EDSH vars"
Description: """WIP adding EDSH vars"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryFonctionRenale)
* occurredDateTime = "2025-03-24"
* reason.text = """WIP adding EDSH vars"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-03-24T09:26:15+01:00"