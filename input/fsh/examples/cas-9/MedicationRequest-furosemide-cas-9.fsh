Instance: furosemide-cas-9
InstanceOf: DMMedicationRequest
Title: "Prescription de furosémide de Madame Blanc"
Description: """Prescription de furosémide [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #completed
* intent = #original-order

* medicationReference.display = "furosemide"
* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* dosageInstruction
  * timing.repeat
    * boundsPeriod
      * start = "2024-01-13"
      * end = "2024-02-13"
    * frequency = 1
    * period = 1
    * periodUnit = #d
  * route = http://snomed.info/sct#26643006 "voie orale"
  * doseAndRate
    * doseQuantity = 1 '{comprimé}' "comprimé"


Instance: f75bcdeb-4200-4935-b2c6-9333419f9049
InstanceOf: Provenance
Title: "Simplification des references aux medications"
Description: """Simplification des references aux medications"""
Usage: #definition

* target[0] = Reference(furosemide-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Simplification des references aux medications"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

Instance: a9ab68cd-0e9a-4629-8e57-489322dbf6da
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(furosemide-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
