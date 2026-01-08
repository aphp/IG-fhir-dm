Instance: asat-cas-9
InstanceOf: DMObservationLaboratoryASAT
Title: "ASAT de Madame Blanc"
Description: """Représente le taux d'ASAT [du patient 9](use-core-variables-acquisition.html#cas-9--ponction-évacuatrice-dascite)"""
Usage: #example

* identifier
  * value = "22"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity = 37.0 '[IU]/L' "[IU]/L"

* referenceRange
  * low = 6.0 '[IU]/L' "[IU]/L"
  * high = 25.0 '[IU]/L' "[IU]/L"

* performer.display = "Laboratoire Beaujon"


Instance: 07477f59-7688-4584-b311-cd3c838b745a 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(asat-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
