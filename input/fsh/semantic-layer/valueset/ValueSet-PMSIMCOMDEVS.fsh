ValueSet: PMSIMCOMDEVS
Title: "Mode d'entré du PMSI MCO"
Description: "Ce ValueSet contient tous les modes d'entrée pour le PMSI MCO"

* ^experimental = false
* ^immutable = false

* include codes from system PMSIMCOMDE

Instance: 635efbdf-c6f2-498d-934c-97ec235b0bed
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PMSIMCOMDEVS)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"