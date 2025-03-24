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