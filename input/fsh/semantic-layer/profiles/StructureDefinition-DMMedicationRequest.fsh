Profile:  DMMedicationRequest
Parent:   MedicationRequest
Title:    "Prescription de médicaments"
Description:  "Profil pour les prescriptions médicamenteuses"
* medication[x] only Reference(FrMedicationUcd or FrMedicationNonproprietaryName or FrMedicationCompound)
* medication[x] MS
* subject only Reference(DMPatient)
* subject MS
* dosageInstruction 1..
  * route from FrRouteOfAdministration (extensible)
  * route MS
  * doseAndRate
    * dose[x] only FrRangeUcum or FrSimpleQuantityUcum
    * dose[x] MS
    * rate[x] only FrRatioUcum or FrRangeUcum or FrSimpleQuantityUcum
    * rate[x] ^definition = "Amount of medication per unit of time. Using a ratio, the denominator SHALL be a quantity of time. Using a simple quantity the UCUM unit SHALL be a unit of rate."
    * rate[x] MS
  * timing MS
  * maxDosePerPeriod
    * numerator only FrSimpleQuantityUcum
    * denominator only FrSimpleQuantityUcum
  * maxDosePerAdministration only FrSimpleQuantityUcum
  * maxDosePerLifetime only FrSimpleQuantityUcum

Instance: f99b5bbd-3144-4bd0-b0f3-9f6e061ed363
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMMedicationRequest)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"