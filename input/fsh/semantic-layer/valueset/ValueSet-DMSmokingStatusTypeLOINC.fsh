ValueSet: DMSmokingStatusTypeLOINC
Title: "Smoking Status Type from LOINC"
Description: "Type de statut tabagique en provenance de LOINC"

* ^experimental = false
* ^immutable = false

* $loinc#11367-0 "History of Tobacco use"
* $loinc#72166-2 "Tobacco smoking status"

Instance: 7066adc9-afa4-4a87-9247-4f4e01f89607
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMSmokingStatusTypeLOINC)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"