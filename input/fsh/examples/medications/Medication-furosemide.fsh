Instance: furosemide
InstanceOf: FrMedicationNonproprietaryName
Title: "Furosémide"
Description: """Description du furosémide"""
Usage: #example

* code = http://snomed.info/sct#776052007

* status = #active

* ingredient
  * itemCodeableConcept = http://www.whocc.no/atc#C03CA01
  * isActive = true
  * strength
    * numerator = 40 'mg' "mg"
    * denominator = 1 '{}'


Instance: 9af9cb18-53ff-40d6-807b-580dd422f0bf
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(furosemide)
* occurredDateTime = "2025-10-21"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-21T16:00:00+02:00"
