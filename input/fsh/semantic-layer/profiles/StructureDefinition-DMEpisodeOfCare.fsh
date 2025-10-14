Profile: DMEpisodeOfCare
Parent: EpisodeOfCare
Title: "Episode of care"
Description: "Episode of care adapted to Data Management"

* patient only Reference(DMPatient)
* managingOrganization only Reference(DMOrganization)

Instance: c4a1cf2f-5519-421d-9040-461a2598c8cb
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMEpisodeOfCare)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"