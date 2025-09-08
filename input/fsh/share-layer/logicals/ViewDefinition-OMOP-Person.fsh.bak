Instance: OMOP-Person-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Person View"
Description: "ViewDefinition to transform FHIR Patient resources into OMOP Person table format"

* name = "OMOP-Person-View"
* status = #draft
* resource = #Patient
* constant[0]
  * name = "integerNull"
  * valueInteger = 0
* select[0]
  * column[0]
    * name = "person_id"
    * path = "id"
    * description = "Unique identifier for the person"
    * type = #id
    * tag[0]
      * name = "ansi/type"
      * value = "CHARACTER VARYING"
  * column[+]
    * name = "gender_concept_id"
    * path = "%integerNull"
    * description = "Gender concept id"
    * type = #integer
  * column[+]
    * name = "birth_datetime"
    * path = "birthDate"
    * description = "Birth date and time"
    * type = #date
    * tag[0]
      * name = "ansi/type"
      * value = "TIMESTAMP"
  * column[+]
    * name = "race_concept_id"
    * path = "%integerNull"
    * description = "Race concept"
    * type = #integer
  * column[+]
    * name = "ethnicity_concept_id"
    * path = "%integerNull"
    * description = "Ethnicity concept"
    * type = #integer
  * column[+]
    * name = "location_id"
    * path = "address.first().id"
    * description = "Location identifier from primary address"
    * type = #string
  * column[+]
    * name = "provider_id"
    * path = "generalPractitioner.first().getReferenceKey(Practitioner)"
    * description = "Provider identifier from general practitioner"
    * type = #string
  * column[+]
    * name = "care_site_id"
    * path = "managingOrganization.getReferenceKey(Organization)"
    * description = "Care site identifier from managing organization"
    * type = #string
  * column[+]
    * name = "person_source_value"
    * path = "getResourceKey()"
    * description = "Source value for person"
    * type = #string
  * column[+]
    * name = "gender_source_value"
    * path = "gender"
    * description = "Source value for gender"
    * type = #code
    * tag[0]
      * name = "ansi/type"
      * value = "CHARACTER VARYING"