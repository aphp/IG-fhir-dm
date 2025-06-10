Instance: DpiEncounterType2SemanticLayerEncounterType
InstanceOf: ConceptMap
Description: "TODO"
Usage: #definition

* title = "DPI Encounter type to Semantic layer"
* experimental = false
* status = #active
* sourceCanonical = Canonical(DpiEncounterType)
* targetCanonical = Canonical(SemanticLayerEncounterType)
* group[0]
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