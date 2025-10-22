Instance: poids-cas-9
InstanceOf: DMObservationBodyWeight
Title: "Poids du patient 9"
Description: """Poids [du cas 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13"
* valueQuantity = 58.2 'kg' "kg"


Instance: e370e99d-f7f1-4a8a-aaaa-578320aeebbe
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(poids-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
