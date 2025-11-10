Instance: albumine-cas-9
InstanceOf: DMMedicationRequest
Title: "Prescription d'albumine de Madame Blanc"
Description: """Prescription d'albumine [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #completed
* intent = #original-order

* medicationReference.display = "albumine"
* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* dosageInstruction
  * timing
    * event = "2024-01-13"
  * route = http://snomed.info/sct#47625008 "voie intraveineuse"
  * doseAndRate
    * doseQuantity = 2 '{poche}' "poche"


Instance: bd006fd2-5649-4770-b210-6a7ec78b7cfa
InstanceOf: Provenance
Title: "Simplification des references aux medications"
Description: """Simplification des references aux medications"""
Usage: #definition

* target[0] = Reference(albumine-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Simplification des references aux medications"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

Instance: aba28439-bba0-4219-b570-28bdc2ff1c4c
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(MedicationRequest/albumine-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
