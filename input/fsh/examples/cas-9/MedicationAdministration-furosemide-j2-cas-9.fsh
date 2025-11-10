Instance: furosemide-j2-cas-9
InstanceOf: DMMedicationAdministration
Title: "Administration à J2 de furosemide de Madame Blanc"
Description: """Administration J2 de furosemide [au patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* status = #completed

* medicationReference.display = "furosemide"
* subject = Reference(cas-9)
* context = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-14T08:00:00+01:00"

* request = Reference(furosemide-cas-9)

* dosage
  * route = http://snomed.info/sct#26643006 "voie orale"
  * dose = 1 '{comprimé}' "comprimé"


Instance: 95d08896-0529-4312-b7f2-a3eb7d6b831c
InstanceOf: Provenance
Title: "Simplification des references aux medications"
Description: """Simplification des references aux medications"""
Usage: #definition

* target[0] = Reference(furosemide-j2-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Simplification des references aux medications"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

Instance: 92f36775-f3d7-4925-83ad-58658f0e19d0
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(furosemide-j2-cas-9)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"