ValueSet: DMLaboratoryEstimatedDFG
Title: "Liste des analyses correspondant à l'estimation du DFG - socle des EDS"
Description: """
Trois codes LOINC possibles pour l'estimation du débit de filtration glomérulaire, selon l'équation utilisée (Cockroft, MDRD ou CKD-EPI)
"""

* ^experimental = false
* ^immutable = false

* include $loinc#62238-1
* include $loinc#77147-7
* include $loinc#35591-7

Instance: 5b5788dd-b1ad-46eb-8859-df351e3930ba
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMLaboratoryEstimatedDFG)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"