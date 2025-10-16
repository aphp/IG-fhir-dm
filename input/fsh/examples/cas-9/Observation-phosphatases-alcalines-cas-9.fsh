Instance: phosphatases-alcalines-cas-9
InstanceOf: DMObservationLaboratoryPAL
Title: "Phosphatases alcalines du patient 9"
Description: """Représente le taux de pal [du cas 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "23"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity.value = 100.0

* referenceRange
  * low.value = 35.0
  * high.value = 104.0

* performer.display = "Laboratoire Beaujon"


Instance: 890a8151-4398-453d-bf42-b2dc2d9e0dfe
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(phosphatases-alcalines-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
