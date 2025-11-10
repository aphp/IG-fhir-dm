Instance: ggt-cas-9
InstanceOf: DMObservationLaboratoryGgt
Title: "GGT de Madame Blanc"
Description: """Représente le taux de gamma glutamyl transferase [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "24"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity = 30 'U/L' "U/L"

* referenceRange
  * high = 35 'U/L' "U/L"

* performer.display = "Laboratoire Beaujon"


Instance: b275833d-0e45-4a3d-bacc-6806ed6ebb1d
InstanceOf: Provenance
Title: "Modification du nom du profil"
Description: """Modification du nom du profil"""
Usage: #definition

* target[0] = Reference(ggt-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Modification du nom du profil"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: c624f2d2-8522-4288-9916-4b5a6c27e729
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(ggt-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
