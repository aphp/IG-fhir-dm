ValueSet: FrMCOClaimSubType
Title: "ValueSet des type fr des claims"
Description: "Permet de préciser, dans un champ du PMSI, le type de facture."

* ^experimental = false
* ^immutable = false

* include codes from system FrClaimType where concept descendent-of "PMSIMCO"

Instance: 6c436364-bccf-491e-929f-e0cf51835d8b
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrMCOClaimSubType)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"