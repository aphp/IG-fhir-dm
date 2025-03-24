Profile: FrSimpleQuantityUcum
Parent: SimpleQuantity
Title: "SimpleQuantity with UCUM quantity unit"
Description: "simple quantity datatype requiring a UCUM unit"
* . ^short = "A fixed quantity (no comparator) with UCUM unit"
* . ^definition = "The comparator is not used on a SimpleQuantity. The unit SHALL be a UCUM code."
* . ^comment = "The context of use may frequently define what kind of quantity this is and therefore what kind of units can be used. The context of use explicitely excludes the use of the simpleQuantity \"comparator\" element."
* system 1.. MS
* system = "http://unitsofmeasure.org" (exactly)
* system ^definition = "UCUM requiered for the identification of the system that provides the coded form of the unit."
* system ^requirements = "UCUM requiered."
* code 1.. MS
* code ^comment = "UCUM code required."