ValueSet: CIM10PMSIDA
Title: "Liste des diagnostiques CIM-10 acceptable en DA pour les PMSI MCO et HAD"
Description: "ValueSet des code CIM10 ATIH utilisable en DA"
* ^experimental = false
* ^immutable = false

* include codes from system CIM10 where typeMcoHad in "0,1,2,4"

Instance: 001aecc1-419c-4012-aabd-84df2a713cf9
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(CIM10PMSIDA)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00" 