Extension: PmsiCodeGeo
Title: "Codage géographique du lieu de résidence pour les RSA du PMSI"
Description: "Cette extension permet de porter le code géographique du lieu de résidence tel que prévu dans les RSA du PMSI"

* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Address"
* . 0..1
* value[x] only code
* valueCode from PmsiCodeGeoVs (required)