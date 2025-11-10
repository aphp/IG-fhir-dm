Instance: alat-cas-9
InstanceOf: DMObservationLaboratoryAlat
Title: "ALAT de Madame Blanc"
Description: """Représente le taux d'ALAT [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "19"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* code = $loinc#1742-6

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity = 38.0 '[IU]/L' "[IU]/L"

* referenceRange
  * low = 6.0 '[IU]/L' "[IU]/L"
  * high = 25.0 '[IU]/L' "[IU]/L"

* performer.display = "Laboratoire Beaujon"

Instance: 7c900ced-e107-4160-a549-d16c1c219297
InstanceOf: Provenance
Title: "Modification du nom du profil + ajout du code (antérieurement contraint par le profil)"
Description: """Modification du nom du profil + ajout du code (antérieurement contraint par le profil)"""
Usage: #definition

* target[0] = Reference(alat-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Modification du nom du profil + ajout du code (antérieurement contraint par le profil)"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: b2c718a6-8e77-45ea-84ac-264b00872849 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(alat-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
