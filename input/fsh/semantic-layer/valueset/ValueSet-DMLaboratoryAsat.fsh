ValueSet: DMLaboratoryAsat
Title: "Liste des analyses correspondant au dosage des ASAT dans le sang - socle des EDS"
Description: """
Deux codes LOINC possibles pour le dosage des ASAT dans le sang, selon la méthode utilisée
"""

* ^experimental = false
* ^immutable = false

* include $loinc#30239-8
* include $loinc#1920-8

Instance: bf209711-4a91-49be-86b5-9b864a85e85c
InstanceOf: Provenance
Title: "élargissement des possibles pour le profil des ASAT"
Description: """élargissement des possibles pour le profil des ASAT"""
Usage: #definition

* target[0] = Reference(DMLaboratoryAsat)
* occurredDateTime = "2025-11-10"
* reason.text = """élargissement des possibles pour le profil des ASAT"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-11-10T21:36:10+01:00"