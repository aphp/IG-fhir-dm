Instance: spironolactone-cas-9
InstanceOf: DMMedicationRequest
Title: "Prescription de furosémide de Madame Blanc"
Description: """Prescription de furosémide [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #completed
* intent = #original-order

* medicationReference.display = "spironolactone"
* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* dosageInstruction
  * timing.repeat
    * boundsPeriod
      * start = "2024-01-13"
      * end = "2024-04-13"
    * frequency = 1
    * period = 1
    * periodUnit = #d
  * route = http://snomed.info/sct#26643006 "voie orale"
  * doseAndRate
    * doseQuantity = 1 '{comprimé}' "comprimé"


Instance: f6f4c734-ce09-4913-98ce-e0a2dff6e90c
InstanceOf: Provenance
Title: "Simplification des references aux medications"
Description: """Simplification des references aux medications"""
Usage: #definition

* target[0] = Reference(spironolactone-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Simplification des references aux medications"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

Instance: 557c2beb-0512-4242-952a-8903b2e8aa6f
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(spironolactone-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
