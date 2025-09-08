Instance: OMOP-Location-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Location View"
Description: "ViewDefinition to transform FHIR Location resources into OMOP Location table format"

* name = "OMOP-Location-View"
* status = #draft
* resource = #Patient
* select[0]
  * column[0]
    * name = "location_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the location"
    * type = #integer
  * column[+]
    * name = "address_1"
    * path = "Location.address.line.first()"
    * description = "Primary address line"
    * type = #string
  * column[+]
    * name = "address_2"
    * path = "Location.address.line[1]"
    * description = "Secondary address line"
    * type = #string
  * column[+]
    * name = "city"
    * path = "Location.address.city"
    * description = "City from address"
    * type = #string
  * column[+]
    * name = "state"
    * path = "Location.address.state"
    * description = "State from address"
    * type = #string
  * column[+]
    * name = "zip"
    * path = "Location.address.postalCode"
    * description = "Postal code from address"
    * type = #string
  * column[+]
    * name = "county"
    * path = "Location.address.district"
    * description = "County from address district"
    * type = #string
  * column[+]
    * name = "location_source_value"
    * path = "Location.identifier.first().value"
    * description = "Source value for location identification"
    * type = #string
  * column[+]
    * name = "country_concept_id"
    * path = "Location.address.country"
    * description = "Country concept from address country"
    * type = #integer
  * column[+]
    * name = "country_source_value"
    * path = "Location.address.country"
    * description = "Source value for country"
    * type = #string
  * column[+]
    * name = "latitude"
    * path = "Location.position.latitude"
    * description = "Latitude from position"
    * type = #decimal
  * column[+]
    * name = "longitude"
    * path = "Location.position.longitude"
    * description = "Longitude from position"
    * type = #decimal