Instance: fogd-cas-9
InstanceOf: DMProcedure
Title: "Fibroscopie oeso-gastroduodénale de Madame Blanc"
Description: """Représente la Fibroscopie oeso-gastroduodénale  dont a bénéficié [le patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "12"
  * system = "https://test.fr/acteId"

* status = #completed

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* code = https://interop.aphp.fr/ig/fhir/dm/CodeSystem/Ccam#HEQE002 "Endoscopie oeso-gastro-duodénale"

* performedDateTime = "2024-01-14T07:00:00+01:00"

* performer.actor.display = "Dr. Hépatologue"


Instance: d22eb54c-0027-4829-b7ed-85853965d40f 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(fogd-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
