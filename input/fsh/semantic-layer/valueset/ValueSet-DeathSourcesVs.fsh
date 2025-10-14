ValueSet: DeathSourcesVs
Title: "ValueSet des sources d'informations fr sur le statut vital"
Description: "Ce ValueSet contient les sources d'informations sur le statut vital"

* ^experimental = false
* ^immutable = false

* include codes from system DeathSources

Instance: 3ec01e4a-41fa-4cf4-9064-1b55d984e0bb
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DeathSourcesVs)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"