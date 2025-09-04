Instance: deadPatient
InstanceOf: DMPatient
Description: "Patient contextualisant les autres exemples et notament le monorum"
Usage: #example

* address
  * postalCode = "01290"
  * city = "GRIÈGES"
  * extension[+].url = "https://aphp.fr/ig/fhir/dm/StructureDefinition/PmsiCodeGeo"
  * extension[=].valueCode = #01C01
* deceasedBoolean = true
* deceasedBoolean.extension.url = "https://aphp.fr/ig/fhir/dm/StructureDefinition/DeathSource"
* deceasedBoolean.extension.valueCodeableConcept = https://aphp.fr/ig/fhir/dm/CodeSystem/DeathSources#cepidc
* gender = #male
