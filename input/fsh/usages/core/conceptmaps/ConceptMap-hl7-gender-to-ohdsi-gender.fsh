Instance: hl7-gender-to-ohdsi-gender
InstanceOf: ConceptMap
Title: "HL7 Gender to OHDSI Gender"
Description: "L'objectif de cet alignement est rendre possible la conversion d'un code 'gender' d'HL7 vers son équivalent dans OHDSI"
Usage: #definition

* name = "HL7Gender2OHDSIGender"
* experimental = false
* status = #active
* sourceCanonical = Canonical($fr-core-vs-patient-gender-INS)
* targetCanonical = Canonical(OMOPGender)
* group[0]
  * source = "http://hl7.org/fhir/administrative-gender"
  * target = Canonical(DMOmopCDMv20240229)
  * element[0]
    * code = #male
    * display = "Male"
    * target[0]
      * code = #8507
      * display = "MALE" 
      * equivalence = #equivalent
  * element[+]
    * code = #female
    * display = "Female"
    * target[0]
      * code = #8532
      * display = "FEMALE"
      * equivalence = #equivalent