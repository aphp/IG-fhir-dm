ValueSet: GHMVS
Title: "Liste des GHM pour le PMSI MCO"
Description: "Ce ValueSet contient les GHM pour le PMSI MCO"

* ^experimental = false
* ^immutable = false

* include codes from system GHM

Instance: a00dcdfc-39fc-457a-a897-27746749f894
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(GHMVS)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"