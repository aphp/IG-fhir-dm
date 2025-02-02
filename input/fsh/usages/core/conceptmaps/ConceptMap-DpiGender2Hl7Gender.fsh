Instance: DpiGender2Hl7Gender
InstanceOf: ConceptMap
Usage: #definition

* title = "DPI (local) Gender to HL7 Gender"
* name = "DpiGender2Hl7Gender"
* description = "TODO"
* experimental = false
* status = #active
* sourceUri = "https://aphp.fr/ig/fhir/dm/ValueSet/DpiGender"
* targetUri = "https://hl7.fr/ig/fhir/core/ValueSet/fr-core-vs-patient-gender-INS"
* group[0]
  * source = "https://aphp.fr/ig/fhir/dm/CodeSystem/DpiGender"
  * target = "http://hl7.org/fhir/administrative-gender"
  * element[0]
    * code = #h
    * display = "Homme"
    * target[0]
      * code = #male
      * display = "Male"
      * equivalence = #equivalent
  * element[+]
    * code = #f
    * display = "Femme"
    * target[0]
      * code = #female
      * display = "Female"
      * equivalence = #equivalent