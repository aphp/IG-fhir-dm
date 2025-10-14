Profile: DMCondition
Parent: Condition
Title: "Condition"
Description: "Condition adapted to Data Management"

* subject only Reference(DMPatient)
* encounter only Reference(DMEncounter)

* code from CIM10 (extensible)

Instance: d6e7f8a9-0b1c-2d3e-4f5a-6b7c8d9e0f1a
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMCondition)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"

