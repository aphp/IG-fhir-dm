Profile: FrMedicationUcd
Parent: Medication
Title: "French branded name Medication"
Description: "French prescribed, dispensed or used medication expressed as branded medication composed of one to many substances. The code the french UCD (Unité Commune de Dispensation)."
* code 1..
* code from $SIPh-CIO_UCD (extensible)
* code ^definition = "The UCD code of the branded medication."
* code ^requirements = "The developper SHALL support the infusion use case, which requires a multi-compounds Medication ressource."
* code.text ^comment = "When some code is available, the text is the same as a displayName of one of the codings."
* form from FrMpDoseForm (extensible)
* form ^comment = "When branded medication is referenced from MedicationRequest, this is the ordered form.  When Medication is referenced within MedicationDispense, this is the dispensed form.  When branded medication is referenced within MedicationAdministration, this is administered form."
* amount only FrRatioUcum
* amount ^short = "Amount of drug in the MRequest, MDispense, MAdministration or MUsage"
* amount ^definition = "It is the volume (liquid) or mass (ointment) in the Medication of the MeidcationRequest, MedicationDispense, MAdministration or MedicationUse (pka MedicationStatement)."
* ingredient 1..
* ingredient ^definition = "Identifies a particular constituent in the product."
* ingredient ^comment = "For the active ingedients, the medication contains ALL the ingredients and ONLY the ingredients."
* ingredient.item[x] only CodeableConcept or Reference(FrMedicationUcdPart)
* ingredient.item[x] ^short = "Substance or UCD part"
* ingredient.item[x] ^definition = "The actual substance (single component mediction) or component (multiple component medication) o"
* ingredient.item[x] ^requirements = "The composition of the medication for this ingredient has to be defined"
* ingredient.strength only FrRatioUcum
* ingredient.strength ^definition = "Specifies how many of the item[x]:refernce(FrMedciationUcdPart) or how much subtance of the item[x]:codeableConcept(snomedSubstance) there are in this FrMedicationUcd"
* ingredient.strength ^comment = "The quantity of this ingredient defining the medication. For instance, 50 mg/mL defining the glucose quantity for the glucose 5% or 500 mg medicine and 30 mg respectively defining the paracetamol and the codeine quantity for the association paracetamol+codeine 500 mg+30 mg medicine."
* batch ^definition = "This applies for the proprietary named medication involved in a MedicationDispense, MedicationAdministration or a MedicationUse."
* batch ^comment = "WARNING: it is the batch number of the part.\r\nIf it is not discerned for each part, it SHALL NOT be provided here but at the grouping level where it is defined, most often the UCD."

Instance: 2f4db025-9de9-4166-8b23-3edfe381ee1f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrMedicationUcd)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"