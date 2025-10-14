CodeSystem: Ccam
Title: "CCAM illustrative"
Description: "Fragment de CCAM permettant d'illustrer l'utilisation des codes CCAM dans les ressources procedures. Idéalement, il faudrait disposer d'une CCAM descriptive dans un serveur de terminologie FHIR. Pour l'heure, on ne dispose que d'une ccam facturante sur le SMT de l'ANS, sans ValueSet associés."

* ^status = #active
* ^experimental = false
* ^content = #fragment
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* #BGQP002...01. "Examen du fond d'oeil par biomicroscopie avec verre de contact - Phase par defaut - 1° activité chir/med - NA"
* #DEQP003...01. "Électrocardiographie sur au moins 12 dérivations - Phase par defaut - 1° activité chir/med - NA"
* #HFFC0044 "Cholécystectomie, par coelioscopie - anesthésie"

Instance: d4e5f6a7-8b9c-0d1e-2f3a-4b5c6d7e8f9a
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(Ccam)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"