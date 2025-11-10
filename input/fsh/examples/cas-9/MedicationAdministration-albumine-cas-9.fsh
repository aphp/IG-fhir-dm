Instance: albumine-j1-cas-9
InstanceOf: DMMedicationAdministration
Title: "Administration d'albumine de Madame Blanc"
Description: """Administration d'albumine [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #completed

* medicationReference.display = "albumine"
* subject = Reference(cas-9)
* context = Reference(sejour-cas-9)

* effectivePeriod
  * start = "2024-01-13T09:30:00+01:00"
  * end = "2024-01-13T11:14:00+01:00"

* request = Reference(albumine-cas-9)

* dosage
  * route = http://snomed.info/sct#47625008 "voie intraveineuse"
  * dose = 2 '{poche}' "poche"


Instance: db945738-c0be-461d-ac52-349f0aca45ba
InstanceOf: Provenance
Title: "Simplification des references aux medications"
Description: """Simplification des references aux medications"""
Usage: #definition

* target[0] = Reference(albumine-j1-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Simplification des references aux medications"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

Instance: 9af6d9c2-8913-4525-8e9d-c0d5c168d714
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(albumine-j1-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"