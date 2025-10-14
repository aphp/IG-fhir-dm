CodeSystem: FrMCOClaimItemCategory
Title: "Categorisation des items de claim pour le PMSI MCO"
Description: "Cette catégorisation permet de spécifier les différents éléments d'information qui doivent être fournis (variable selon le type d'item facturé)"

* ^status = #active
* ^content = #complete
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false
* ^experimental = false

* #0 "Procédure"
* #1 "RUM"

Instance: b8c9d0e1-2f3a-4b5c-6d7e-8f9a0b1c2d3e
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrMCOClaimItemCategory)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
