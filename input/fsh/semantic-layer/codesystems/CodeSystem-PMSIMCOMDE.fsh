CodeSystem: PMSIMCOMDE
Title: "Mode d'entré du PMSI MCO"
Description: "Permet de coder la propriété RSS du PMSI MCO 'Mode d'entré'"

* ^content = #complete
* ^status = #draft
* ^experimental = false
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false
* #6 "Mutation"
* #7 "Transfert définitif"
* #0 "Transfert provisoire"
* #8 "Domicile"
* #N "Naissance"
* #O "Patient entré décédé pour prélèvement d'organes"

Instance: d0e1f2a3-4b5c-6d7e-8f9a-0b1c2d3e4f5a
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PMSIMCOMDE)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
