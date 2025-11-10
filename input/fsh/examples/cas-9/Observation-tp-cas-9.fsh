Instance: tp-cas-9
InstanceOf: DMObservationLaboratoryTp
Title: "Taux de prothrombine de Madame Blanc"
Description: """Représente le taux de prothrombine [du patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier
  * value = "25"
  * system = "https://test.fr/biologieId"

* status = #final

* subject = Reference(cas-9)
* encounter = Reference(sejour-cas-9)

* effectiveDateTime = "2024-01-13T08:30:00+01:00"

* valueQuantity = 80 '%' "%"

* referenceRange
  * low = 50 '%' "%"

* performer.display = "Laboratoire Beaujon"


Instance: f79b9c20-9c0a-440e-bbb4-859dc9c6abd3
InstanceOf: Provenance
Title: "Modification du nom du profil"
Description: """Modification du nom du profil"""
Usage: #definition

* target[0] = Reference(tp-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Modification du nom du profil"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: 78cb0ad0-1089-4c65-b61b-5323602b15bc
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(tp-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
