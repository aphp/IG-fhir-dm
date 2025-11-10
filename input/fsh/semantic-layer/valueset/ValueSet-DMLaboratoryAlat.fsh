ValueSet: DMLaboratoryAlat
Title: "Liste des analyses correspondant au dosage des ALAT dans le sang - socle des EDS"
Description: """
Deux codes LOINC possibles pour le dosage des ALAT dans le sang, selon la méthode utilisée
"""

* ^experimental = false
* ^immutable = false

* include $loinc#1742-6
* include $loinc#1743-4

Instance: 882ee796-a2f1-4095-b5cd-69554094f012
InstanceOf: Provenance
Title: "élargissement des possibles pour le profil des ALAT"
Description: """élargissement des possibles pour le profil des ALAT"""
Usage: #definition

* target[0] = Reference(DMLaboratoryAsat)
* occurredDateTime = "2025-11-10"
* reason.text = """élargissement des possibles pour le profil des ALAT"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-11-10T21:36:10+01:00"