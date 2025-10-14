Profile: DMEncounter
Parent: FRCoreEncounterProfile
Title: "Encounter"
Description: "Encounter adapted to Data Management"

* subject only Reference(DMPatient)
* episodeOfCare only Reference(DMEpisodeOfCare)
* hospitalization.preAdmissionIdentifier.assigner only Reference(DMOrganization)
* hospitalization.origin only Reference(DMLocation or DMOrganization)

* serviceProvider only Reference(DMOrganization)

* partOf only Reference(DMEncounter)

Instance: ceaac970-fd2b-43fc-b22c-db2a376e663c
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMEncounter)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"