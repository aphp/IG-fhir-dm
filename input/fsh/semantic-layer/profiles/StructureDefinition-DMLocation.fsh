Profile: DMLocation
Parent: AsLocationProfile
Title: "Location"
Description: "Location adapted to Data Management"

* managingOrganization only Reference(DMOrganization)

Instance: b6c7d8e9-0f1a-2b3c-4d5e-6f7a8b9c0d1e
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMLocation)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"