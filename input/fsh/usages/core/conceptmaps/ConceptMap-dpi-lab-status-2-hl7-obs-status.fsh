Instance: dpi-lab-status-2-hl7-obs-status
InstanceOf: ConceptMap
Title: "DPI (local) laboratory status to HL7 laboratory observation status"
Description: "Standardisation du status des résultats d'analyse de biologie médicale"
Usage: #definition

* name = "DpiLabStatus2Hl7ObsStatus"
* experimental = false
* status = #active
* group[0]
  * target = "http://hl7.org/fhir/observation-status"
  * element[0]
    * code = #valide
    * display = "valide"
    * target[0]
      * code = #final
      * display = "Final"
      * equivalence = #equivalent
  * unmapped
    * mode = #fixed
    * code = #unknown


Instance: db6c47e4-63f3-4ec2-87c2-8cb16de1a771
InstanceOf: Provenance
Title: "Ajout d'une conceptMap pour standardisation du status des résultats d'analyses biologique"
Description: """Ajout d'une conceptMap pour standardisation du status des résultats d'analyses biologique"""
Usage: #definition

* target[0] = Reference(spironolactone-j1-cas-9)
* occurredDateTime = "2025-11-10"
* reason.text = """Ajout d'une conceptMap pour standardisation du status des résultats d'analyses biologique"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T17:00:00+02:00"

