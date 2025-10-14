Profile: DMPractitioner
Parent: AsPractitionerProfile
Title: "Practitioner"
Description: "Practitioner adapted to Data Management"

Instance: e9f0a1b2-3c4d-5e6f-7a8b-9c0d1e2f3a4b
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMPractitioner)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"