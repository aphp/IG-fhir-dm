Profile: DMObservationBodyHeight
Parent: FRCoreObservationBodyHeightProfile
Title: "Taille du patient"
Description: "Ce profil définit la manière de représenter les observations de taille corporelle en utilisant un code LOINC standard et des unités de mesure UCUM."

* subject only Reference(DMPatient)
* subject ^short = "Patient dont la taille est mesurée"

* encounter only Reference(DMEncounter)
* encounter ^short = "NDA (Numéro de Dossier Administratif) associé à la mesure"
* encounter ^definition = "Le NDA peut correspondre à une hospitalisation complète, un dossier de consultation, d'hospitalisation de jour..."
* performer only Reference(DMPatient or DMPractitioner or DMPractitionerRole or DMOrganization)

* code ^short = "Code standardisé pour 'Taille'"
* code ^definition = "Taille, codé en LOINC, en cohérence avec le cadre d'interopérabilité des systèmes d'information en santé (CI-SIS)."

* effective[x] only dateTime
* effective[x] ^short = "Date de réalisation de la mesure"
* value[x] ^short = "Valeur de la mesure. Les signes vitaux sont enregistrés sous forme de quantité, exprimés en unité du Système International."

* method from HeightLengthMeasurementMethod (example)

Instance: 9be02e59-c737-45b0-a64a-53484a5b79d4
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMObservationBodyHeight)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"