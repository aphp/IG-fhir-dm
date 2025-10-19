Instance: sejour-cas-9
InstanceOf: DMEncounter
Title: "Séjour du patient 9"
Description: """Représente le séjour [du cas 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

* identifier[+]
  * type = https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-identifier-type#VN "Visit Number"
  * value = "9"
  * system = "https://test.fr/encounterId"

* status = #finished
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#IMP
* subject = Reference(cas-9)
* period
  * start = "2024-01-13"
  * end = "2024-10-14"
* hospitalization
  * admitSource = https://interop.aphp.fr/ig/fhir/dm/CodeSystem/PMSIMCOMDE#8
  * dischargeDisposition = https://interop.aphp.fr/ig/fhir/dm/CodeSystem/PMSIMCOMDS#8
* serviceProvider.display = "Service d'hépatologie B de l'hopital Beaujon"


Instance: 2396b6ce-0e61-4f5e-a365-873db612c4d5 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(sejour-cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"
