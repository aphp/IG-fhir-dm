Instance: DpiGender2Hl7Gender
InstanceOf: ConceptMap
Description: "Standardisation du sexe administratif des patients pour se conformer aux exigences de FHIR"
Usage: #definition

* title = "DPI (local) Gender to HL7 Gender"
* experimental = false
* status = #active
* sourceCanonical = Canonical(DpiGender)
* targetCanonical = Canonical($fr-core-vs-patient-gender-INS)
* group[0]
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