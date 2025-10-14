Profile: FrRangeUcum
Parent: Range
Title: "Range with UCUM quantity units"
Description: "Range with low and high unit UCUM encoded"
* low only FrSimpleQuantityUcum
* low ^short = "low bound with UCUM unit"
* low ^definition = "unit of measure SHALL be UCUM encoded"
* low ^requirements = "force UCUM unit encoding"
* high only FrSimpleQuantityUcum
* high ^short = "high bound with UCUM unit"
* high ^definition = "unit of measure SHALL be UCUM encoded"
* high ^requirements = "force UCUM unit encoding"

Instance: 18fbf9ba-5587-4a44-a7aa-c8526510feb1
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrRangeUcum)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"