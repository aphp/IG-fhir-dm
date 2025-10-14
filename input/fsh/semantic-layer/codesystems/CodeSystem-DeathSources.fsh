CodeSystem: DeathSources
Title:     "Sources susceptibles d'informer sur le statu vital des patients"
Description: "Ce CodeSystem aggrège les sources desquelles peuvent provenir les informations sur le statu vital des patients en France."

* ^experimental = false
* ^caseSensitive = false
* ^status = #draft
* ^content = #complete
* ^date = "2025-09-04"
* ^hierarchyMeaning = #grouped-by
* ^language = #fr-FR

* #insee "Insee"
* #cepidc "CepiDC"
* #sih "Système d'information hospitalier"

Instance: c5d6e7f8-9a0b-1c2d-3e4f-5a6b7c8d9e0f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DeathSources)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"