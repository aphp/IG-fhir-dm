ValueSet: PmsiCodeGeoVs
Title: "ValueSet des codes géographiques de résidence du PMSI"
Description: "Ce ValueSet contient les codes géographiques de résidence du PMSI"

* ^experimental = false
* ^immutable = false

* include codes from system PmsiCodeGeo

Instance: 5406d79e-6053-43fc-9a49-4c4608e1990d
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PmsiCodeGeoVs)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"