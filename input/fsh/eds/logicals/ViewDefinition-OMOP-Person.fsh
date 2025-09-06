Instance: OMOP-Person-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Person View"
Description: "ViewDefinition to transform FHIR Patient resources into OMOP Person table format"

* name = "OMOP-Person-View"
* status = #draft
* resource = #Patient
* select[0]
  * column[0]
    * name = "person_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the person"
    * type = #integer
  * column[+]
    * name = "year_of_birth"
    * path = "Patient.birthDate.toString().substring(0,4).toInteger()"
    * description = "Year of birth extracted from birthDate"
    * type = #integer
  * column[+]
    * name = "month_of_birth"
    * path = "Patient.birthDate.toString().substring(5,7).toInteger()"
    * description = "Month of birth extracted from birthDate"
    * type = #integer
  * column[+]
    * name = "day_of_birth"
    * path = "Patient.birthDate.toString().substring(8,10).toInteger()"
    * description = "Day of birth extracted from birthDate"
    * type = #integer
  * column[+]
    * name = "birth_datetime"
    * path = "Patient.birthDate"
    * description = "Birth date and time"
    * type = #dateTime
  * column[+]
    * name = "location_id"
    * path = "Patient.address.first().id"
    * description = "Location identifier from primary address"
    * type = #integer
  * column[+]
    * name = "provider_id"
    * path = "Patient.generalPractitioner.first().reference.substring(12)"
    * description = "Provider identifier from general practitioner"
    * type = #integer
  * column[+]
    * name = "care_site_id"
    * path = "Patient.managingOrganization.reference.substring(13)"
    * description = "Care site identifier from managing organization"
    * type = #integer
  * column[+]
    * name = "person_source_value"
    * path = "Patient.meta.source"
    * description = "Source value for person"
    * type = #string
  * column[+]
    * name = "gender_source_value"
    * path = "Patient.gender"
    * description = "Source value for gender"
    * type = #string