Instance: 21d466cf-1b62-4451-bca2-f23786f223b5
InstanceOf: Provenance
Title: "Correction des codes cim10 (ajout du '.')"
Description: """Correction des codes cim10 (ajout du '.')"""
Usage: #definition

* target[0] = Reference(cas-11-usage-core)
* target[+] = Reference(df9c9a9c-854b-46f4-9687-1fbe40c06540)
* target[+] = Reference(UsageCore)
* occurredDateTime = "2025-10-15"
* reason.text = """Correction des codes cim10 (ajout du '.')"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-10-15T14:58:10+02:00"

Instance: 2a4b2a9e-4a7b-4cf4-a83c-9882b80b3a37
InstanceOf: Provenance
Title: "Création du QuestionnaireResponse correspondant au patient de test n°9"
Description: """Création du QuestionnaireResponse correspondant au patient de test n°9"""
Usage: #definition

* target[0] = Reference(cas-9-usage-core)
* occurredDateTime = "2025-10-15"
* reason.text = """Création du QuestionnaireResponse correspondant au patient de test n°9"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-10-15T14:58:10+02:00"

Instance: 5b9c3723-f23f-4cdd-abe3-640e551a41cc
InstanceOf: Provenance
Title: "évolution pour bonne prise en compte de l'exemple patient 9"
Description: """Modifications marginales du Questionnaire pour l'usage socle EDS (quelque answerOption) pour bon fonctionnement du QR du patient 9"""
Usage: #definition

* target[0] = Reference(UsageCore)
* occurredDateTime = "2025-10-15"
* reason.text = """Modifications marginales du Questionnaire pour l'usage socle EDS (quelque answerOption) pour bon fonctionnement du QR du patient 9"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-10-15T14:58:10+02:00"


