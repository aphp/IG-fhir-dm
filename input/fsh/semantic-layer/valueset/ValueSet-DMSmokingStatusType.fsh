ValueSet: DMSmokingStatusType
Title: "Smoking Status Type"
Description: "Type de statut tabagique en provenance de LOINC et de SNOMED CT"

* ^experimental = false
* ^immutable = false

* include codes from valueset DMSmokingStatusTypeLOINC
* include codes from valueset DMSmokingStatusPackYearsSCT

Instance: e5e5619c-43b3-4acf-9d16-32f074c38aab
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMSmokingStatusType)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"