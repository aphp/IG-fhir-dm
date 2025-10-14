/*Instance: deadPatient
InstanceOf: DMPatient
Description: "Patient contextualisant les autres exemples et notament le monorum"
Usage: #example

* address
  * postalCode = "01290"
  * city = "GRIÈGES"
  * extension[+].url = "https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/PmsiCodeGeo"
  * extension[=].valueCode = #01C01
* deceasedDateTime = "2025-08-31T10:00:00Z"
* deceasedDateTime.extension.url = "https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DeathSource"
* deceasedDateTime.extension.valueCode = #cepidc
* gender = #male
*/