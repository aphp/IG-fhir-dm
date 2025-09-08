Instance: OMOP-ConditionOccurrence-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Condition Occurrence View"
Description: "ViewDefinition to transform FHIR Condition resources into OMOP Condition Occurrence table format"

* name = "OMOP-ConditionOccurrence-View"
* status = #draft
* resource = #Condition
* select[+]
  * column[+]
    * name = "condition_occurrence_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the condition occurrence"
    * type = #integer
  * column[+]
    * name = "person_id"
    * path = "Condition.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "condition_concept_id"
    * path = "Condition.code.coding.first().code"
    * description = "Condition concept from primary coding"
    * type = #integer
  * column[+]
    * name = "condition_start_date"
    * path = "Condition.onsetDateTime.toString().substring(0,10)"
    * description = "Condition start date from onset"
    * type = #date
  * column[+]
    * name = "condition_start_datetime"
    * path = "Condition.onsetDateTime"
    * description = "Condition start datetime from onset"
    * type = #dateTime
  * column[+]
    * name = "condition_end_date"
    * path = "Condition.abatementDateTime.toString().substring(0,10)"
    * description = "Condition end date from abatement"
    * type = #date
  * column[+]
    * name = "condition_end_datetime"
    * path = "Condition.abatementDateTime"
    * description = "Condition end datetime from abatement"
    * type = #dateTime
  * column[+]
    * name = "stop_reason"
    * path = "Condition.abatementString"
    * description = "Stop reason from abatement string"
    * type = #string
  * column[+]
    * name = "provider_id"
    * path = "Condition.asserter.reference.substring(12)"
    * description = "Provider identifier from asserter"
    * type = #integer
  * column[+]
    * name = "visit_occurrence_id"
    * path = "Condition.encounter.reference.substring(10)"
    * description = "Visit occurrence identifier from encounter"
    * type = #integer
  * column[+]
    * name = "visit_detail_id"
    * path = "Condition.encounter.reference.substring(10)"
    * description = "Visit detail identifier from encounter"
    * type = #integer
  * column[+]
    * name = "condition_source_value"
    * path = "Condition.meta.source"
    * description = "Source value for condition"
    * type = #string
  * column[+]
    * name = "condition_status_source_value"
    * path = "Condition.clinicalStatus.text"
    * description = "Source value for condition status"
    * type = #string