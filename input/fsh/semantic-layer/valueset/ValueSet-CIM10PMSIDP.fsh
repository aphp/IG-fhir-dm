ValueSet: CIM10PMSIDP
Title: "Liste des diagnostiques CIM-10 acceptable en DP pour les PMSI MCO et HAD"
Description: "ValueSet des code CIM10 ATIH utilisable en DP"

* ^experimental = false
* ^immutable = false

* include codes from system CIM10
  where typeMcoHad = #0

Instance: bc025839-a594-4c3f-9452-a64a80ef9b69
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(CIM10PMSIDP)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"