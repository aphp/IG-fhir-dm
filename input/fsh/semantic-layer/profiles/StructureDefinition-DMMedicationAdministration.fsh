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