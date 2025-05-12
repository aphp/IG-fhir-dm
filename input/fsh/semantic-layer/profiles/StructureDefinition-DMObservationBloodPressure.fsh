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
