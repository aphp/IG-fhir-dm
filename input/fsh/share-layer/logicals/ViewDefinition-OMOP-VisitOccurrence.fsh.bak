Instance: OMOP-VisitOccurrence-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Visit Occurrence View"
Description: "ViewDefinition to transform FHIR Encounter resources into OMOP Visit Occurrence table format"

* name = "OMOP-VisitOccurrence-View"
* status = #draft
* resource = #Encounter
* select[0]
  * column[0]
    * name = "visit_occurrence_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the visit occurrence"
    * type = #integer
  * column[+]
    * name = "person_id"
    * path = "Encounter.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "visit_concept_id"
    * path = "Encounter.class.code"
    * description = "Visit concept from encounter class"
    * type = #integer
  * column[+]
    * name = "visit_start_date"
    * path = "Encounter.period.start.toString().substring(0,10)"
    * description = "Visit start date from period start"
    * type = #date
  * column[+]
    * name = "visit_start_datetime"
    * path = "Encounter.period.start"
    * description = "Visit start datetime from period start"
    * type = #dateTime
  * column[+]
    * name = "visit_end_date"
    * path = "Encounter.period.end.toString().substring(0,10)"
    * description = "Visit end date from period end"
    * type = #date
  * column[+]
    * name = "visit_end_datetime"
    * path = "Encounter.period.end"
    * description = "Visit end datetime from period end"
    * type = #dateTime
  * column[+]
    * name = "provider_id"
    * path = "Encounter.participant.where(type.coding.code='ATND').individual.reference.substring(12)"
    * description = "Provider identifier from attending participant"
    * type = #integer
  * column[+]
    * name = "care_site_id"
    * path = "Encounter.serviceProvider.reference.substring(13)"
    * description = "Care site identifier from service provider"
    * type = #integer
  * column[+]
    * name = "visit_source_value"
    * path = "Encounter.identifier.first().value"
    * description = "Source value for visit identification"
    * type = #string
  * column[+]
    * name = "admitted_from_source_value"
    * path = "Encounter.hospitalization.admitSource.text"
    * description = "Source value for admission source"
    * type = #string
  * column[+]
    * name = "discharged_to_source_value"
    * path = "Encounter.hospitalization.dischargeDisposition.text"
    * description = "Source value for discharge disposition"
    * type = #string