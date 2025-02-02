Instance: DpiEncounterType2SemanticLayerEncounterType
InstanceOf: ConceptMap
Usage: #definition

* title = "DPI Encounter type to Semantic layer"
* name = "DpiEncounterType2SemanticLayerEncounterType"
* description = "TODO"
* experimental = false
* status = #active
* sourceUri = "https://aphp.fr/ig/fhir/dm/ValueSet/DpiEncounterType"
* targetUri = "https://aphp.fr/ig/fhir/dm/ValueSet/SemanticLayerEncounterType"
* group[0]
  * source = "https://aphp.fr/ig/fhir/dm/CodeSystem/DpiEncounterType"
  * target = "https://aphp.fr/ig/fhir/dm/CodeSystem/SemanticLayerEncounterType"
  * element[0]
    * code = #1
    * display = "Type 1"
    * target[0]
      * code = #b
      * display = "Type B"
      * equivalence = #equivalent
  * element[+]
    * code = #2
    * display = "Type 2"
    * target[0]
      * code = #a
      * display = "Type A"
      * equivalence = #equivalent