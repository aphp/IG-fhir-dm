Instance: ponction-cas-9
InstanceOf: DMProcedure
Title: "Ponction évacuatrice du patient 9"
Description: """Représente la ponction évacuatrice dont a bénéficié [le cas 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "11"
  * system = "https://test.fr/acteId"

* status = #completed

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* code = https://interop.aphp.fr/ig/fhir/dm/CodeSystem/Ccam#HPHB003 "Ponction d'un épanchement péritonéal, par voie transcutanée"

* performedDateTime = "2024-01-13T12:15:00+01:00"

* performer.actor.display = "Dr. Hépatologue"


Instance: 1c5894b6-843e-460b-be4b-39ac135c0c69 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(ponction-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"

