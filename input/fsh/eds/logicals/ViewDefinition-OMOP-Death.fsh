Instance: OMOP-Death-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Death View"
Description: "ViewDefinition to transform FHIR Observation resources (cause of death) into OMOP Death table format"

* name = "OMOP-Death-View"
* status = #draft
* resource = #Observation
* where[+]
  * path = "Observation.code.coding.exists(code = '79378-6')"
  * description = "Filter for cause of death observations"
* select[+]
  * column[+]
    * name = "person_id"
    * path = "Observation.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "death_date"
    * path = "Observation.effectiveDateTime.toString().substring(0,10)"
    * description = "Death date from effective datetime"
    * type = #date
  * column[+]
    * name = "death_datetime"
    * path = "Observation.effectiveDateTime"
    * description = "Death datetime from effective datetime"
    * type = #dateTime
  * column[+]
    * name = "death_type_concept_id"
    * path = "Observation.category.first().coding.first().code"
    * description = "Death type concept from category"
    * type = #integer
  * column[+]
    * name = "cause_concept_id"
    * path = "Observation.valueCodeableConcept.coding.first().code"
    * description = "Cause concept from value codeable concept"
    * type = #integer
  * column[+]
    * name = "cause_source_value"
    * path = "Observation.valueCodeableConcept.text"
    * description = "Source value for cause of death"
    * type = #string
  * column[+]
    * name = "cause_source_concept_id"
    * path = "0"
    * description = "Source concept for cause of death (default 0)"
    * type = #integer