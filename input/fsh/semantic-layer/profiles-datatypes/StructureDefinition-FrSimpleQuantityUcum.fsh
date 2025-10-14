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

Instance: f3fb1ab8-ef39-45b7-82d8-87fca1496132
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrSimpleQuantityUcum)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"