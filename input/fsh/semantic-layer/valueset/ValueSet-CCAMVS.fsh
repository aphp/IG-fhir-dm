ValueSet: CcamVS
Title: "Actes CCAM pour le PMSI"
Description: """
Jeu de valeurs de la CCAM correspondant aux actes médicaux pour le codage du PMSI
"""

* ^experimental = false
* ^immutable = false

* include codes from system Ccam

Instance: 92dcbc9c-247b-4ff0-97f6-103d664f8549
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(CcamVS)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"