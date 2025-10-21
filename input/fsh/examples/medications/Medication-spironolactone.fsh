Instance: spironolactone
InstanceOf: FrMedicationNonproprietaryName
Title: "Spironolactone"
Description: """Description du spironolactone"""
Usage: #example

* code = http://snomed.info/sct#777603002

* status = #active

* ingredient
  * itemCodeableConcept = http://www.whocc.no/atc#C03DA01
  * isActive = true
  * strength
    * numerator = 25 'mg' "mg"
    * denominator = 1 '{}'


Instance: afe60463-d6ce-43c0-a585-b0b1a5653fcd
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(spironolactone)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
