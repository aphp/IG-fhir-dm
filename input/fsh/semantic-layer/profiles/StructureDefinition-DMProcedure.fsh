Profile: DMProcedure
Parent: Procedure
Title: "Procedure"
Description: "Procedure adapted to Data Management"

* partOf only Reference(DMProcedure)
* subject only Reference(DMPatient)
* encounter only Reference(DMEncounter)

* performer
  * actor only Reference(DMPractitioner or DMPractitionerRole or DMOrganization)
  * onBehalfOf only Reference(DMOrganization)

* location only Reference(DMLocation)
* reasonReference only Reference(DMCondition or Observation or DMProcedure)

* code from CcamVS (extensible)

Instance: e286e28b-c58b-4cc5-953d-8e6e7af22e56
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMProcedure)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
