CodeSystem: GHM
Title:     "Classification des GHM  utilisée pour le groupage des séjours dans le PMSI MCO."
Description: "Groupes Homogènes de Malades."

* ^experimental = false
* ^caseSensitive = false
* ^status = #draft
* ^content = #fragment
* ^date = "2025-05-13"
* ^hierarchyMeaning = #grouped-by
* ^language = #fr-FR

* #05K06 "Endoprothèses vasculaires sans infarctus du myocarde"
  * #05K06T "Endoprothèses vasculaires sans infarctus du myocarde, très courte durée"
  * #05K061 "Endoprothèses vasculaires sans infarctus du myocarde, niveau 1"
  * #05K062 "Endoprothèses vasculaires sans infarctus du myocarde, niveau 2"
  * #05K063 "Endoprothèses vasculaires sans infarctus du myocarde, niveau 3"
  * #05K064 "Endoprothèses vasculaires sans infarctus du myocarde, niveau 4"
* #05M09 "Insuffisances cardiaques et états de choc circulatoire"
  * #05M093 "Insuffisances cardiaques et états de choc circulatoire, niveau 3"

Instance: a3b4c5d6-7e8f-9a0b-1c2d-3e4f5a6b7c8d
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(GHM)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"