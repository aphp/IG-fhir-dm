Instance: phosphatases-alcalines-cas-9
InstanceOf: DMObservationLaboratoryPAL
Title: "Phosphatases alcalines de Madame Blanc"
Description: """Représente le taux de PAL [du patient 9](use-core-variables-acquisition.html#cas-9--ponction-évacuatrice-dascite)"""
Usage: #example

* identifier
  * value = "23"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity = 100.0 'U/L' "U/L"

* referenceRange
  * low = 35.0 'U/L' "U/L"
  * high = 104.0 'U/L' "U/L"

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
