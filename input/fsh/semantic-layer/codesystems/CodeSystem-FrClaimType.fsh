CodeSystem: FrClaimType
Title: "Cadre de facturation dans la réglementation française"
Description: "Typage des claim en France, dans le cadre du PMSI"

* ^status = #active
* ^experimental = false
* ^content = #complete
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* ^property[+].code = #type
* ^property[=].description = "Granularité des cadres de facturation (type vs. sous type)"
* ^property[=].type = #code

* #PMSIMCO "PMSI - MCO"
* #PMSIMCO ^property[+].code = #type
* #PMSIMCO ^property[=].valueCode = #type
  * #RUM "Résumé d'Unité Médicale"
  * #RUM ^property[+].code = #type
  * #RUM ^property[=].valueCode = #subtype
  * #RSA "Résumé de Sortie Anonymisé"
  * #RSA ^property[+].code = #type
  * #RSA ^property[=].valueCode = #subtype
* #PMSIHAD "PMSI - HAD"
* #PMSIHAD ^property[+].code = #type
* #PMSIHAD ^property[=].valueCode = #type
* #PMSISSR "PMSI - SSR"
* #PMSISSR ^property[+].code = #type
* #PMSISSR ^property[=].valueCode = #type
* #PMSIPSY "PMSI - PSY"
* #PMSIPSY ^property[+].code = #type
* #PMSIPSY ^property[=].valueCode = #type
* #ACTEXT "Activité externe"
* #ACTEXT ^property[+].code = #type
* #ACTEXT ^property[=].valueCode = #type

* #type 
* #type ^property[+].code = #type
* #type ^property[=].valueCode = #property
* #subtype 
* #subtype ^property[+].code = #type
* #subtype ^property[=].valueCode = #property
* #property
* #property ^property[+].code = #type
* #property ^property[=].valueCode = #property

Instance: a7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d
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
