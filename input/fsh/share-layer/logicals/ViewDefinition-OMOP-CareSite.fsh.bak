Instance: OMOP-CareSite-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Care Site View"
Description: "ViewDefinition to transform FHIR Organization resources into OMOP Care Site table format"

* name = "OMOP-CareSite-View"
* status = #draft
* resource = #Organization
* select[0]
  * column[0]
    * name = "care_site_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the care site"
    * type = #integer
  * column[+]
    * name = "care_site_name"
    * path = "Organization.name"
    * description = "Name of the care site"
    * type = #string
  * column[+]
    * name = "location_id"
    * path = "Organization.address.first().id"
    * description = "Location identifier from primary address"
    * type = #integer
  * column[+]
    * name = "care_site_source_value"
    * path = "Organization.meta.source"
    * description = "Source value for care site"
    * type = #string
  * column[+]
    * name = "place_of_service_source_value"
    * path = "Organization.type.first().text"
    * description = "Source value for place of service"
    * type = #string