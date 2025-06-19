ValueSet: FrClaimType
Title: "ValueSet des type fr des claims"
Description: "Permet de préciser le cadre dans lequel in facture est émise (champ du PMSI par example)"

* ^experimental = false
* ^immutable = false

* include codes from system FrClaimType where type = #type
* include codes from valueset http://hl7.org/fhir/ValueSet/claim-type