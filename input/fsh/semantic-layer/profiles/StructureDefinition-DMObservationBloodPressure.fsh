Profile: DMObservationBloodPressure
Parent: FRCoreObservationBpProfile
Title: "Pression artérielle"
Description: "Profil de la pression artérielle du socle commun des EDS"

* subject only Reference(DMPatient)
* subject ^short = "L'observation concerne la personne que l'on analyse."

* encounter only Reference(DMEncounter)
* encounter ^short = "NDA (Numéro de Dossier Administratif) associé à la mesure"
* encounter ^definition = "Le NDA peut correspondre à une hospitalisation complète, un dossier de consultation, d'hospitalisation de jour..."

* performer only Reference(DMPatient or DMPractitioner or DMPractitionerRole or DMOrganization)

* effective[x] only dateTime
* effective[x] ^short = "Date de réalisation de la mesure"

* bodySite from BloodPressureMeasurementBodyLocationPrecoodinated (example)
* method from BloodPressureMeasurementMethod (example)

Instance: 5236693c-8f6f-46fc-8ba6-63665228922e
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMObservationBloodPressure)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
