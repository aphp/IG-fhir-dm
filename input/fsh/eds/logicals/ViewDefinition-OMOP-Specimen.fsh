Instance: OMOP-Specimen-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Specimen View"
Description: "ViewDefinition to transform FHIR Specimen resources into OMOP Specimen table format"

* name = "OMOP-Specimen-View"
* status = #draft
* resource = #Specimen
* select[0]
  * column[0]
    * name = "specimen_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the specimen"
    * type = #integer
  * column[+]
    * name = "person_id"
    * path = "Specimen.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "specimen_date"
    * path = "Specimen.collection.collectedDateTime.toString().substring(0,10)"
    * description = "Specimen date from collection datetime"
    * type = #date
  * column[+]
    * name = "specimen_datetime"
    * path = "Specimen.collection.collectedDateTime"
    * description = "Specimen datetime from collection datetime"
    * type = #dateTime
  * column[+]
    * name = "quantity"
    * path = "Specimen.collection.quantity.value"
    * description = "Quantity from collection quantity"
    * type = #decimal
  * column[+]
    * name = "specimen_source_id"
    * path = "Specimen.identifier.first().value"
    * description = "Source identifier for specimen"
    * type = #string
  * column[+]
    * name = "specimen_source_value"
    * path = "Specimen.type.text"
    * description = "Source value for specimen type"
    * type = #string
  * column[+]
    * name = "unit_source_value"
    * path = "Specimen.collection.quantity.unit"
    * description = "Source value for unit"
    * type = #string
  * column[+]
    * name = "anatomic_site_source_value"
    * path = "Specimen.collection.bodySite.text"
    * description = "Source value for anatomic site"
    * type = #string
  * column[+]
    * name = "disease_status_source_value"
    * path = "Specimen.condition.first().text"
    * description = "Source value for disease status"
    * type = #string