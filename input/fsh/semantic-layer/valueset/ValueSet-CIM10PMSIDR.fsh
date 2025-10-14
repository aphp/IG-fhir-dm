ValueSet: CIM10PMSIDR
Title: "Liste des diagnostiques CIM-10 acceptable en DR pour les PMSI MCO et HAD"
Description: "ValueSet des code CIM10 ATIH utilisable en DR"

* ^experimental = false
* ^immutable = false

* include codes from system CIM10 where typeMcoHad in "0,4"

Instance: 50bacdb0-8fa2-4670-b88a-8816a50b841d
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(CIM10PMSIDR)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"