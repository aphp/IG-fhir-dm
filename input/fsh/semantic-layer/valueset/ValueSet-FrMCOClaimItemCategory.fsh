ValueSet: FrMCOClaimItemCategory
Title: "Categorisation des items de claim pour le PMSI MCO"
Description: "Cette catégorisation permet de spécifier les différents éléments d'information qui doivent être fournis (variable selon le type d'item facturé)"

* ^experimental = false
* ^immutable = false

* include codes from system FrMCOClaimItemCategory

Instance: 348fb03e-f8a9-4dd1-b632-26f4239bcefb
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