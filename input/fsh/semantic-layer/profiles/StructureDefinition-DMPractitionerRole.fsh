Profile: DMPractitionerRole
//Parent: AsPractitionerRoleProfile
Parent: PractitionerRole
Title: "PractitionerRole"
Description: "PractitionerRole adapted to Data Management"

* practitioner only Reference(DMPractitioner)

Instance: f0a1b2c3-4d5e-6f7a-8b9c-0d1e2f3a4b5c
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMPractitionerRole)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"