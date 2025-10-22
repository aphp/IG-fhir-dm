Instance: bilirubine-totale-cas-9
InstanceOf: DMObservationLaboratoryBilirubineTotale
Title: "Bilirubine totale du patient 9"
Description: """Représente le taux de bilirubine totale [du cas 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "20"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity = 25.0 'umol/L' "umol/L"

* referenceRange
  * low = 5.0 'umol/L' "umol/L"
  * high = 21.0 'umol/L' "umol/L"

* performer.display = "Laboratoire Beaujon"


Instance: d91f1257-0dc4-454d-8d4f-93f0cf291ab2 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(bilirubine-totale-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
