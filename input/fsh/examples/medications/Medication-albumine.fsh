Instance: albumine
InstanceOf: FrMedicationNonproprietaryName
Title: "Albumine"
Description: """Description de l'albumine"""
Usage: #example

* code = http://snomed.info/sct#789265003

* status = #active

* amount
  * numerator = 500 'mL' "mL"
  * denominator = 1 '{}'

* ingredient
  * itemCodeableConcept = http://www.whocc.no/atc#B05AA01
  * isActive = true
  * strength
    * numerator = 50 'g' "g"
    * denominator = 1 'L' "L"


Instance: 6ec693c3-e549-4498-9abe-8821b300e1d5
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(albumine)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
