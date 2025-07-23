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

* code from Ccam (extensible)
