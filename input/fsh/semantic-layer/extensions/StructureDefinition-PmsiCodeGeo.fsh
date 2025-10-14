Extension: PmsiCodeGeo
Title: "Codage géographique du lieu de résidence pour les RSA du PMSI"
Description: "Cette extension permet de porter le code géographique du lieu de résidence tel que prévu dans les RSA du PMSI"

* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Address"
* . 0..1
* value[x] only code
* valueCode from PmsiCodeGeoVs (required)

Instance: fae02d9a-c8dd-46d4-8995-1cc7e33612c7
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PmsiCodeGeo)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"