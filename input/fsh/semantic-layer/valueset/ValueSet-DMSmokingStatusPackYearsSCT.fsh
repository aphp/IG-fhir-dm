ValueSet: DMSmokingStatusPackYearsSCT
Title: "Smoking Status Pack Years SCT"
Description: "Type de statut tabagique en provenance de SNOMED CT"

* ^experimental = false
* ^immutable = false

* include codes from system $sct
    where concept is-a #401201003
* include codes from system $sct
    where concept is-a #782516008

Instance: 89711626-5726-453c-8fa0-e1405c507d4f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMSmokingStatusPackYearsSCT)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"