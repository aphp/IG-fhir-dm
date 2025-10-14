Profile:  DMMedicationAdministration
Parent:   MedicationAdministration
Title:    "Prise de médicaments"
Description: "Profil pour la prise de médicaments"
* medication[x] only Reference(FrMedicationUcd or FrMedicationNonproprietaryName or FrMedicationCompound)
* medication[x] MS
* subject only Reference(DMPatient)
* subject MS
* effective[x] MS
* dosage 1..1
  * route from FrRouteOfAdministration (extensible)
  * route MS
  * dose only FrSimpleQuantityUcum
  * dose MS
  * rate[x] only FrRatioUcum or FrSimpleQuantityUcum
  * rate[x] MS

Instance: 57c2e039-233f-434b-9c65-3f8673f55727
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMMedicationAdministration)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"