Instance: OMOP-ProcedureOccurrence-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Procedure Occurrence View"
Description: "ViewDefinition to transform FHIR Procedure resources into OMOP Procedure Occurrence table format"

* name = "OMOP-ProcedureOccurrence-View"
* status = #draft
* resource = #Procedure
* select[0]
  * column[0]
    * name = "procedure_occurrence_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the procedure occurrence"
    * type = #integer
  * column[+]
    * name = "person_id"
    * path = "Procedure.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "procedure_date"
    * path = "Procedure.performedDateTime.toString().substring(0,10)"
    * description = "Procedure date from performed datetime"
    * type = #date
  * column[+]
    * name = "procedure_datetime"
    * path = "Procedure.performedDateTime"
    * description = "Procedure datetime from performed datetime"
    * type = #dateTime
  * column[+]
    * name = "procedure_end_date"
    * path = "Procedure.performedPeriod.end.toString().substring(0,10)"
    * description = "Procedure end date from performed period end"
    * type = #date
  * column[+]
    * name = "procedure_end_datetime"
    * path = "Procedure.performedPeriod.end"
    * description = "Procedure end datetime from performed period end"
    * type = #dateTime
  * column[+]
    * name = "quantity"
    * path = "1"
    * description = "Quantity (default 1)"
    * type = #integer
  * column[+]
    * name = "provider_id"
    * path = "Procedure.performer.first().actor.reference.substring(12)"
    * description = "Provider identifier from performer"
    * type = #integer
  * column[+]
    * name = "visit_occurrence_id"
    * path = "Procedure.encounter.reference.substring(10)"
    * description = "Visit occurrence identifier from encounter"
    * type = #integer
  * column[+]
    * name = "visit_detail_id"
    * path = "Procedure.encounter.reference.substring(10)"
    * description = "Visit detail identifier from encounter"
    * type = #integer
  * column[+]
    * name = "procedure_source_value"
    * path = "Procedure.code.text"
    * description = "Source value for procedure"
    * type = #string
  * column[+]
    * name = "modifier_source_value"
    * path = "Procedure.bodySite.first().text"
    * description = "Source value for modifier"
    * type = #string