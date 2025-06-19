ValueSet: FrMCOClaimSubType
Title: "ValueSet des type fr des claims"
Description: "Permet de préciser, dans un champ du PMSI, le type de facture."

* ^experimental = false
* ^immutable = false

* include codes from system FrClaimType where concept descendent-of "PMSIMCO"