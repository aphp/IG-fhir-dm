Extension: ItemRank
Title: "Ordre des Item dans un claim"
Description: "Cette extension permet d'ordonnancer les items lorsque que les autres éléments présent ne permettent pas de le faire. C'est notament le cas des items de type RUM dont les dates sont parfois trop imprécises pour permettre ce ranking (granularité au jour)"
* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Claim.item"
* . 0..1
* value[x] only positiveInt

Instance: 31df1ab3-c776-493c-aacc-c4ff015893c7
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(ItemRank)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"

