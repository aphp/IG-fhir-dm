CodeSystem: PMSIMCODiagType
Title: "type de diagnostic du PMSI MCO"
Description: "Liste des types que peuvent avoir les diagnostiques CIM-10 dans les différents résumés/factures qui peuvent être émis dans le système de santé français."

* ^status = #active
* ^experimental = false
* ^content = #complete
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* #DP "Diagnostic Principal"
* #DR "Diagonstic Relié"
* #DA "Diagnostic Associé Significatif"
* #DAD "Diagnostic Associé Documentaire"

Instance: c9d0e1f2-3a4b-5c6d-7e8f-9a0b1c2d3e4f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(PMSIMCODiagType)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"