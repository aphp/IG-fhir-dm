Instance: 21d466cf-1b62-4451-bca2-f23786f223b5
InstanceOf: Provenance
Title: "Correction des codes cim10 (ajout du '.')"
Description: """Correction des codes cim10 (ajout du '.')"""
Usage: #definition

* target[0] = Reference(test-usage-core-complet)
* target[+] = Reference(df9c9a9c-854b-46f4-9687-1fbe40c06540)
* target[+] = Reference(UsageCore)
* occurredDateTime = "2025-10-15"
* reason.text = """Correction des codes cim10 (ajout du '.')"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-10-15T14:58:10+02:00"
