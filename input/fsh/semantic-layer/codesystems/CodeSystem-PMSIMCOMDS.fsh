CodeSystem: PMSIMCOMDS
Title: "Mode de sortie du PMSI MCO"
Description: "Permet de coder la propriété RSS du PMSI MCO 'Mode de sortie'"

* ^content = #complete
* ^status = #draft
* ^experimental = false
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false
* #6 "Mutation"
* #7 "Transfert définitif"
* #0 "Transfert provisoire"
* #8 "Domicile"
* #9 "Décès"

Instance: e1f2a3b4-5c6d-7e8f-9a0b-1c2d3e4f5a6b
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PMSIMCOMDS)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"

