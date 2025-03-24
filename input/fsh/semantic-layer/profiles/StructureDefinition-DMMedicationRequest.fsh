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