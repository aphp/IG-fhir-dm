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