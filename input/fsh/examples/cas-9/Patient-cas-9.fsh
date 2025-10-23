Instance: cas-9
InstanceOf: DMPatient
Title: "de Madame Blanc"
Description: """Resource patient illustrant [le patient 9](use-core-variables-acquisition.html#cas-9--patiente-bénéficiant-dune-ponction-dascite-évacuatrice-et-dexploration-de-sa-cirrhose)"""
Usage: #example

//* extension[identityReliability]
//  * extension[identityStatus]
//    * valueCoding = https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-v2-0445#PROV "Identité provisoire"
* extension[birthPlace]
  * valueAddress
    * postalCode = "64"

* identifier[NSS].value = "278056432187654"
* identifier[PI]
  * value = "9"
  * system = "https://test.fr/patientId"

* name[usualName]
  * given = "Isabelle"
  * family = "Blanc"

* gender = #female
* birthDate = "1978-05-06"

* address
  * extension[+]
    * url = "http://hl7.org/fhir/StructureDefinition/geolocation"
    * extension[+]
      * url = "latitude"
      * valueDecimal = 48.8499
    * extension[+]
      * url = "longitude"
      * valueDecimal = 2.2943
  * extension[+]
    * url = "https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/PmsiCodeGeo"
    * valueCode = #75015


Instance: d8d75006-3d8b-431c-8b6a-e3e5244d8301 
InstanceOf: Provenance
Title: "Création des ressources de la couche sémantique pour la représentation du cas 9"
Description: """Création des ressources de la couche sémantique pour la représentation du cas 9"""
Usage: #definition

* target[0] = Reference(cas-9)
* occurredDateTime = "2025-10-16"
* reason.text = """Création des ressources de la couche sémantique pour la représentation du cas 9"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T16:00:00+02:00"

