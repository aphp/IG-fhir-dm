Profile: DMClaimPMSIMCO
Parent: DMClaimPMSI
Title: "Profil de Claim pour le champ MCO du PMSI"
Description: "Profil abstrait pour les invariants dans les claims du champs MCO du PMSI."

* ^abstract = true

* type = FrClaimType#PMSIMCO
* subType from FrMCOClaimSubType (required)

Instance: ec3b0504-7d75-4601-87b1-b9143672cbf0
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMClaimPMSIMCO)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
