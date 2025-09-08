Instance: OMOP-Measurement-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Measurement View"
Description: "ViewDefinition to transform FHIR Observation resources into OMOP Measurement table format"

* name = "OMOP-Measurement-View"
* status = #draft
* resource = #Observation
* select[0]
  * column[0]
    * name = "measurement_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the measurement"
    * type = #integer
  * column[+]
    * name = "person_id"
    * path = "Observation.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "measurement_date"
    * path = "Observation.effectiveDateTime.toString().substring(0,10)"
    * description = "Measurement date from effective datetime"
    * type = #date
  * column[+]
    * name = "measurement_datetime"
    * path = "Observation.effectiveDateTime"
    * description = "Measurement datetime from effective datetime"
    * type = #dateTime
  * column[+]
    * name = "measurement_time"
    * path = "Observation.effectiveDateTime.toString().substring(11,19)"
    * description = "Measurement time from effective datetime"
    * type = #string
  * column[+]
    * name = "value_as_number"
    * path = "Observation.valueQuantity.value"
    * description = "Numeric value from value quantity"
    * type = #decimal
  * column[+]
    * name = "range_low"
    * path = "Observation.referenceRange.first().low.value"
    * description = "Range low from reference range"
    * type = #decimal
  * column[+]
    * name = "range_high"
    * path = "Observation.referenceRange.first().high.value"
    * description = "Range high from reference range"
    * type = #decimal
  * column[+]
    * name = "provider_id"
    * path = "Observation.performer.first().reference.substring(12)"
    * description = "Provider identifier from performer"
    * type = #integer
  * column[+]
    * name = "visit_occurrence_id"
    * path = "Observation.encounter.reference.substring(10)"
    * description = "Visit occurrence identifier from encounter"
    * type = #integer
  * column[+]
    * name = "visit_detail_id"
    * path = "Observation.encounter.reference.substring(10)"
    * description = "Visit detail identifier from encounter"
    * type = #integer
  * column[+]
    * name = "measurement_source_value"
    * path = "Observation.code.text"
    * description = "Source value for measurement"
    * type = #string
  * column[+]
    * name = "unit_source_value"
    * path = "Observation.valueQuantity.unit"
    * description = "Source value for unit"
    * type = #string
  * column[+]
    * name = "value_source_value"
    * path = "Observation.valueString"
    * description = "Source value for the observation value"
    * type = #string