CodeSystem: FrClaimSupInfoCategoryPMSIMCO
Title: "Categorie d'information pour les supporting information"
Description: "CodeSystem aggrégeant les categories d'informations susceptible d'alimenter les Claim dans le système de santé français."

* ^status = #active
* ^experimental = false
* ^content = #complete
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* #RUM "Information contextualisant un Claim de sous type RUM"

Instance: f6a7b8c9-0d1e-2f3a-4b5c-6d7e8f9a0b1c
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrClaimSupInfoCategoryPMSIMCO)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"