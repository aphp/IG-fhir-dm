Instance: ascite-cas-9
InstanceOf: DMCondition
Title: "Ascite de Madame Blanc"
Description: """Représente l'ascite dont souffre [le patient 9](use-core-variables-acquisition.html#cas-9--ponction-évacuatrice-dascite)"""
Usage: #example

* identifier
  * value = "16"
  * system = "https://test.fr/diagnosticId"

* clinicalStatus = http://terminology.hl7.org/CodeSystem/condition-clinical#active "Active"
* verificationStatus = http://terminology.hl7.org/CodeSystem/condition-ver-status#confirmed "Confirmed"
* category = http://terminology.hl7.org/CodeSystem/condition-category#encounter-diagnosis
* code[+] = http://hl7.org/fhir/sid/icd-10#R18 "Ascites"

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)
* recordedDate = "2024-01-13"

Instance: 02c623c6-1c34-43bb-9ff9-5e1b1b6caf90 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(ascite-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
