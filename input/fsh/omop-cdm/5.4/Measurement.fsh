Logical: OMOPMeasurement
Parent: Base
Characteristics: #can-be-target
Title: "Measurement OMOP Table"
Description: "The MEASUREMENT table contains records of Measurements, i.e. structured values (numerical or categorical) obtained through systematic and standardized examination or testing of a Person or Person's sample. The MEASUREMENT table contains both orders and results of such Measurements as laboratory tests, vital signs, quantitative findings from pathology reports, etc. Measurements are stored as attribute value pairs, with the attribute as the Measurement Concept and the value representing the result. The value can be a Concept (stored in VALUE_AS_CONCEPT), or a numerical value (VALUE_AS_NUMBER) with a Unit (UNIT_CONCEPT_ID). The Procedure for obtaining the sample is housed in the PROCEDURE_OCCURRENCE table, though it is unnecessary to create a PROCEDURE_OCCURRENCE record for each measurement if one does not exist in the source data. Measurements differ from Observations in that they require a standardized test or some other activity to generate a quantitative or qualitative result. If there is no result, it is assumed that the lab test was conducted but the result was not captured."

* measurement_id 1..1 integer "Measurement Identifier" ""
* person_id 1..1 Reference(OMOPPerson) "Person" "The PERSON_ID of the Person for whom the Measurement is recorded. This may be a system generated code."
* measurement_concept_id 1..1 Reference(OMOPConcept) "Measurement" "The MEASUREMENT_CONCEPT_ID field is recommended for primary use in analyses, and must be used for network studies."
* measurement_date 1..1  date "Measurement Date" "Use this date to determine the date of the measurement."
* measurement_datetime 0..1 dateTime "Measurement Datetime" ""
* measurement_time 0..1 string "Measurement Time" ""
* measurement_type_concept_id 1..1 Reference(OMOPConcept) "Measurement Type" "This field can be used to determine the provenance of the Measurement record, as in whether the measurement was from an EHR system, insurance claim, registry, or other sources."
* operator_concept_id 0..1  Reference(OMOPConcept) "Operator" "The meaning of Concept [4172703](https://athena.ohdsi.org/search-terms/terms/4172703) for '=' is identical to omission of a OPERATOR_CONCEPT_ID value. Since the use of this field is rare, it's important when devising analyses to not to forget testing for the content of this field for values different from =."
* value_as_number 0..1 decimal "Value as Number" "This is the numerical value of the Result of the Measurement, if available. Note that measurements such as blood pressures will be split into their component parts i.e. one record for systolic, one record for diastolic."
* value_as_concept_id 0..1 Reference(OMOPConcept) "Value as Concept" "If the raw data gives a categorial result for measurements those values are captured and mapped to standard concepts in the 'Meas Value' domain."
* unit_concept_id 0..1 Reference(OMOPConcept) "Unit" "There is currently no recommended unit for individual measurements, i.e. it is not mandatory to represent Hemoglobin a1C measurements as a percentage. UNIT_SOURCE_VALUES should be mapped to a Standard Concept in the Unit domain that best represents the unit as given in the source data."
* range_low 0..1 decimal "Range Low" "Ranges have the same unit as the VALUE_AS_NUMBER. These ranges are provided by the source and should remain NULL if not given."
* range_high 0..1 decimal "Range High" "Ranges have the same unit as the VALUE_AS_NUMBER. These ranges are provided by the source and should remain NULL if not given."
* provider_id 0..1 Reference(OMOPProvider) "Provider" "The provider associated with measurement record, e.g. the provider who ordered the test or the provider who recorded the result."
* visit_occurrence_id 0..1 Reference(OMOPVisitOccurrence) "Visit Occurence" "The visit during which the Measurement occurred."
* visit_detail_id 0..1 Reference(OMOPVisitDetail) "Visit Detail" "The VISIT_DETAIL record during which the Measurement occurred. For example, if the Person was in the ICU at the time the VISIT_OCCURRENCE record would reflect the overall hospital stay and the VISIT_DETAIL record would reflect the ICU stay during the hospital visit."
* measurement_source_value 0..1 string "Measurement Source Value" "This field houses the verbatim value from the source data representing the Measurement that occurred. For example, this could be an ICD10 or Read code."
* measurement_source_concept_id 0..1 Reference(OMOPConcept) "Measurement Source" "This is the concept representing the MEASUREMENT_SOURCE_VALUE and may not necessarily be standard. This field is discouraged from use in analysis because it is not required to contain Standard Concepts that are used across the OHDSI community, and should only be used when Standard Concepts do not adequately represent the source detail for the Measurement necessary for a given analytic use case. Consider using MEASUREMENT_CONCEPT_ID instead to enable standardized analytics that can be consistent across the network."
* unit_source_value 0..1 string "Unit Source Value" "This field houses the verbatim value from the source data representing the unit of the Measurement that occurred."
* unit_source_concept_id 0..1 Reference(OMOPConcept) "Unit Source" "This is the concept representing the UNIT_SOURCE_VALUE and may not necessarily be standard. This field is discouraged from use in analysis because it is not required to contain Standard Concepts that are used across the OHDSI community, and should only be used when Standard Concepts do not adequately represent the source detail for the Measurement necessary for a given analytic use case. Consider using UNIT_CONCEPT_ID instead to enable standardized analytics that can be consistent across the network."
* value_source_value 0..1 string "Value Source Value" "This field houses the verbatim result value of the Measurement from the source data ."
//* measurement_event_id 0..1 Reference(OMOPMeasurementEvent) "Measurement Event" "If the Measurement record is related to another record in the database, this field is the primary key of the linked record."
* measurement_event_id 0..1 string "Measurement Event" "If the Measurement record is related to another record in the database, this field is the primary key of the linked record."
* meas_event_field_concept_id 0..1 Reference(OMOPConcept) "Measurement Event Field" "If the Measurement record is related to another record in the database, this field is the CONCEPT_ID that identifies which table the primary key of the linked record came from."