Instance: OMOP-Provider-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Provider View"
Description: "ViewDefinition to transform FHIR Practitioner resources into OMOP Provider table format"

* name = "OMOP-Provider-View"
* status = #draft
* resource = #Practitioner
* select[+]
  * column[+]
    * name = "provider_id"
    * path = "Practitioner.id"
    * description = "Unique identifier for the provider"
    * type = #integer
  * column[+]
    * name = "provider_name"
    * path = "Practitioner.name.first().family + ', ' + Practitioner.name.first().given.first()"
    * description = "Provider name from name elements"
    * type = #string
  * column[+]
    * name = "npi"
    * path = "Practitioner.identifier.where(system='http://hl7.org/fhir/sid/us-npi').value"
    * description = "NPI from identifier with NPI system"
    * type = #string
  * column[+]
    * name = "dea"
    * path = "Practitioner.identifier.where(system='http://terminology.hl7.org/NamingSystem/us-dea-number').value"
    * description = "DEA number from identifier"
    * type = #string
  * column[+]
    * name = "specialty_concept_id"
    * path = "Practitioner.qualification.first().code.coding.first().code"
    * description = "Specialty concept from qualification"
    * type = #integer
  * column[+]
    * name = "care_site_id"
    * path = "Practitioner.extension.where(url='http://hl7.org/fhir/StructureDefinition/practitioner-job').valueReference.reference.substring(13)"
    * description = "Care site from practitioner job extension"
    * type = #integer
  * column[+]
    * name = "year_of_birth"
    * path = "Practitioner.birthDate.toString().substring(0,4).toInteger()"
    * description = "Year of birth from birth date"
    * type = #integer
  * column[+]
    * name = "gender_concept_id"
    * path = "Practitioner.gender"
    * description = "Gender concept from gender"
    * type = #integer
  * column[+]
    * name = "provider_source_value"
    * path = "Practitioner.identifier.first().value"
    * description = "Source value for provider identification"
    * type = #string
  * column[+]
    * name = "specialty_source_value"
    * path = "Practitioner.qualification.first().code.text"
    * description = "Source value for specialty"
    * type = #string
  * column[+]
    * name = "specialty_source_concept_id"
    * path = "0"
    * description = "Source concept for specialty (default 0)"
    * type = #integer
  * column[+]
    * name = "gender_source_value"
    * path = "Practitioner.gender"
    * description = "Source value for gender"
    * type = #string
  * column[+]
    * name = "gender_source_concept_id"
    * path = "0"
    * description = "Source concept for gender (default 0)"
    * type = #integer