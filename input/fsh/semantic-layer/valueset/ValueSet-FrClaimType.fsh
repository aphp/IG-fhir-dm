ValueSet: FrClaimType
Title: "ValueSet des type fr des claims"
Description: "Permet de préciser le cadre dans lequel in facture est émise (champ du PMSI par example)"

* ^experimental = false
* ^immutable = false

* include codes from system FrClaimType where type = #type
* include codes from valueset http://hl7.org/fhir/ValueSet/claim-type

Instance: 926db37b-7849-4d10-b867-8865d138e6bc
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(FrClaimType)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"