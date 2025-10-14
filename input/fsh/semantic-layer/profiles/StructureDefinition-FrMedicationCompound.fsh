Profile: FrMedicationCompound
Parent: Medication
Title: "French compound Medication"
Description: "A complex medication composed of two to many simple médication. The simple medications component are described in as many ingredient.itemReference referencing a Medication resource profiled fr-medication-1."
* . ^short = "Definition of a Medication compound of a MedicinalRequest, Dispense or Usage"
* . ^definition = "Medication compound of a Medication representing the composition of a MedicationRequest, a MedicationDispense or a MedicationUsage (pka MedicationStatement). For instance, Glucose 5% 1L part of an infusion made of 3 compounds, Glucose 5% 1L + Sodium chloride 3g + Potassium chloride 2g."
* code 1..
* code ^short = "No code that identify this medication"
* code ^definition = "Defines the text of the compound detailed in this compound Medication."
* code ^requirements = "Text of compound SHALL be provided."
* code.coding ^short = "Generaly no code for compound medicinal product"
* code.coding ^definition = "A code identifing the compound medicinal product. Generaly none : no code defined for G5 1L + NaCl 3g + KCl 2g."
* code.coding ^comment = "Codes may be defined very casually in enumerations."
* code.text 1..
* code.text ^requirements = "Although a code is genraly unavailable for a compoud medicinal product, there is alway a denomination for it."
* form from FrMpDoseForm (extensible)
* amount only FrRatioUcum
* amount ^definition = "Specific amount in Medication defined by the element collection. For instance 1 L for the amount of the compound Glucose 5% of an infusion Glucose 5% 1L + Sodium chloride 3g + Potassium chloride 2g. Or 3 g for the amount of compound Sodium chloride of the same infusion. SHALL be 1 (without unit, ie. code = 1 in UCUM system) when there is multiple ingredient element with at least the strenght element of two of them expressed in asbolute quantity (ie. simple quantity)."
* amount ^comment = "The Ratio datatype is limited to numerator value, leading back to the SimpleQuantity datatype."
* ingredient 1..
* ingredient ^short = "Medication component of compound medication"
* ingredient ^definition = "Identifies a medicinal component of the compound medicinal product"
* ingredient ^comment = "The Medication SHALL contain ALL the items of the item element list AND ONLY the items of the item element list."
* ingredient.item[x] only Reference(FrMedicationNonproprietaryName or FrMedicationUcd)
* ingredient.item[x] ^short = "The actual compound"
* ingredient.item[x] ^definition = "The actual compound, either nonproprietary named medication or branded named medication identified by a UCD code."
* ingredient.strength ..0
* ingredient.strength ^requirements = "The amount and strength of the medication component are described in the item element referencing a Medication ressource profiled fr-medication-1."
* batch ..0

Instance: ab6b8dbc-0cf1-4c2a-b5dd-93799ba638ba
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrMedicationCompound)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"