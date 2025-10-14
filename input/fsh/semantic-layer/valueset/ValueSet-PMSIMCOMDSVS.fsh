ValueSet: PMSIMCOMDSVS
Title: "Mode de sortie du PMSI MCO"
Description: "Ce ValueSet contient tous les modes de sortie pour le PMSI MCO"

* ^experimental = false
* ^immutable = false

* include codes from system PMSIMCOMDS

Instance: 056e3075-2a78-4004-b2db-d19413387e8f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PMSIMCOMDSVS)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"