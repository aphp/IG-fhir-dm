Profile: DMClaimPMSI
Parent: Claim
Title: "Profil de Claim pour le PMSI"
Description: "Profil abstrait pour les invariants dans les claims du PMSI."

* ^abstract = true

* type from FrClaimType (required)
* type ^short = "Champ du PMSI concerné."

* patient only Reference(DMPatient)
* provider ^short = "Entité juridique émettrice"
* priority = http://terminology.hl7.org/CodeSystem/processpriority#normal
* use = #claim

* insurance.sequence = 1
* insurance.focal = true
* insurance.coverage.display 1..1
* insurance.coverage.display = "Assurance Maladie"

Instance: 00ced63e-5fff-4e7b-ab78-736c1d3bfcd8
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMClaimPMSI)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"