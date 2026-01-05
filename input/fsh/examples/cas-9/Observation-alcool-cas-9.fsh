Instance: alcool-cas-9
InstanceOf: DMObservationAlcoholUseStatus
Title: "Consommation d'alcool de Madame Blanc"
Description: """Consommation d'alcool [du patient 9](use-core-variables-acquisition.html#cas-9--ponction-évacuatrice-dascite)"""
Usage: #example

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13"

* valueString = "Ex-buveur"


Instance: 640fca34-d16d-41af-8812-fd7aec335db4
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(alcool-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
