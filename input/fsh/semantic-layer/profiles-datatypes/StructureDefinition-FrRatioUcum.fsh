Profile: FrRatioUcum
Parent: Ratio
Title: "Ratio with UCUM quantity units"
Description: "Ratio with numerator and denominator unit UCUM encoded"
* numerator only FrSimpleQuantityUcum
* numerator ^short = "Numerator with UCUM unit"
* numerator ^definition = "unit of measure SHALL be UCUM encoded"
* denominator only FrSimpleQuantityUcum
* denominator ^short = "Denominator with UCUM unit"
* denominator ^definition = "unit of measure SHALL be UCUM encoded"

Instance: f2c4efd4-a0ec-4d0d-96ed-739ea19fec13
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrRatioUcum)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"