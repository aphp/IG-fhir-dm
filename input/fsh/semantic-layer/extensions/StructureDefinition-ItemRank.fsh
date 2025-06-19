Extension: ItemRank
Title: "Ordre des Item dans un claim"
Description: "Cette extension permet d'ordonnancer les items lorsque que les autres éléments présent ne permettent pas de le faire. C'est notament le cas des items de type RUM dont les dates sont parfois trop imprécises pour permettre ce ranking (granularité au jour)"
* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Claim.item"
* . 0..1
* value[x] only positiveInt

