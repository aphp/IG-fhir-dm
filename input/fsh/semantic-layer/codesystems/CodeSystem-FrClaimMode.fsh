CodeSystem: FrClaimMode
Title: "mode PMSI"
Description: "Mode des claim en France, dans le cadre du PMSI"

* ^status = #active
* ^experimental = false
* ^content = #complete
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* #0 "Mode d'entrée"
* #1 "Mode de sortie"

Instance: e5f6a7b8-9c0d-1e2f-3a4b-5c6d7e8f9a0b
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrClaimMode)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"