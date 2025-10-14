ValueSet: CIM10
Title: "Liste des diagnostiques CIM-10 OMS"
Description: "ValueSet reprenant la CIM10 OMS"
* ^experimental = false
* ^immutable = false

* include codes from system $icd-10

Instance: 1367c9e3-3316-4cc4-8ef1-cda979345e45
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(CIM10)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"