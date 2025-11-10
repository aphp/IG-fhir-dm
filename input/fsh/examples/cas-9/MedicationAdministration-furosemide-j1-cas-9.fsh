Instance: furosemide-j1-cas-9
InstanceOf: DMMedicationAdministration
Title: "Administration à J1 de furosemide de Madame Blanc"
Description: """Administration J1 de furosemide [au patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #completed

* medicationReference.display = "furosemide"
* subject = Reference(cas-9)
* context = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:00:00+01:00"

* request = Reference(furosemide-cas-9)

* dosage
  * route = http://snomed.info/sct#26643006 "voie orale"
  * dose = 1 '{comprimé}' "comprimé"


Instance: 0ccaa996-76e8-4cee-b8c7-deb553219a51
InstanceOf: Provenance
Title: "Simplification des references aux medications"
Description: """Simplification des references aux medications"""
Usage: #definition

* target[0] = Reference(furosemide-j1-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Simplification des references aux medications"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

Instance: 16117d33-7897-4ee6-9266-2a0b497ff486
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(furosemide-j1-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"