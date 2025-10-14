Extension: DeathSource
Title: "Source ayant fournie l'information de décès"
Description: "Cette extension permet de formaliser la source d'information de laquelle est issue le statu vital du patient tel que renseigné dans Patien.deceased[x]"
* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Patient.deceased[x]"
* . 0..1
* value[x] only code
* valueCode from DeathSourcesVs (extensible)

Instance: 58097736-2e81-4794-b3de-1db6eef1345f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DeathSource)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"