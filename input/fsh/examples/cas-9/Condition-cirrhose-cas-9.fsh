Instance: cirrhose-cas-9
InstanceOf: DMCondition
Title: "Cirrhose de Madame Blanc"
Description: """Représente la cirrhose dont souffre [le patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "15"
  * system = "https://test.fr/diagnosticId"

* clinicalStatus = http://terminology.hl7.org/CodeSystem/condition-clinical#active "Active"
* verificationStatus = http://terminology.hl7.org/CodeSystem/condition-ver-status#confirmed "Confirmed"
* category = http://terminology.hl7.org/CodeSystem/condition-category#encounter-diagnosis
* code[+] = http://hl7.org/fhir/sid/icd-10#K70.3 "Alcoholic cirrhosis of liver"

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)
* recordedDate = "2024-01-13"


Instance: 7915b6c9-9118-4c10-94a4-e7e09b809ab8 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(cirrhose-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
