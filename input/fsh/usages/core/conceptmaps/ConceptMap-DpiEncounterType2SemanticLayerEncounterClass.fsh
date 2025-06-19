Instance: DpiEncounterType2SemanticLayerEncounterClass
InstanceOf: ConceptMap
Description: "TODO"
Usage: #definition

* name = "DpiEncounterType2FhirEncounterClass"
* title = "DPI Encounter type to Semantic layer"
* experimental = false
* status = #active
* sourceCanonical = "https://aphp.fr/ig/fhir/dm/ValueSet/DpiEncounterType"
* targetCanonical = "http://terminology.hl7.org/ValueSet/v3-ActEncounterCode"
* group[0]
  * source = "https://aphp.fr/ig/fhir/dm/CodeSystem/DpiEncounterType"
  * target = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
  * element[0]
    * code = #1
    * display = "Hospitalisation complète"
    * target[0]
      * code = #IMP
      * display = "inpatient encounter"
      * equivalence = #equivalent
  * element[+]
    * code = #2
    * display = "Consultation/acte externe"
    * target[0]
      * code = #AMB
      * display = "ambulatory"
      * equivalence = #equivalent
  * element[+]
    * code = #3
    * display = "Passage aux urgences (sans hospitalisation)"
    * target[0]
      * code = #EMER
      * display = "emergency"
      * equivalence = #equivalent
  * element[+]
    * code = #4
    * display = "Hospitalisation de jour"
    * target[0]
      * code = #SS
      * display = "short stay"
      * equivalence = #subsumes
  * element[+]
    * code = #5
    * display = "Chirurgie ambulatoire"
    * target[0]
      * code = #SS
      * display = "short stay"
      * equivalence = #subsumes


