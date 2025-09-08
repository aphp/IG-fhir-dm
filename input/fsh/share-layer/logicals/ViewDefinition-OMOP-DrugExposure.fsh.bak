Instance: OMOP-DrugExposure-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Drug Exposure View"
Description: "ViewDefinition to transform FHIR MedicationAdministration resources into OMOP Drug Exposure table format"

* name = "OMOP-DrugExposure-View"
* status = #draft
* resource = #MedicationAdministration
* select[0]
  * column[0]
    * name = "drug_exposure_id"
    * path = "getResourceKey()"
    * description = "Unique identifier for the drug exposure"
    * type = #integer
  * column[+]
    * name = "person_id"
    * path = "MedicationAdministration.subject.reference.substring(8)"
    * description = "Reference to person from subject"
    * type = #integer
  * column[+]
    * name = "drug_exposure_start_date"
    * path = "MedicationAdministration.effectiveDateTime.toString().substring(0,10)"
    * description = "Drug exposure start date from effective datetime"
    * type = #date
  * column[+]
    * name = "drug_exposure_start_datetime"
    * path = "MedicationAdministration.effectiveDateTime"
    * description = "Drug exposure start datetime from effective datetime"
    * type = #dateTime
  * column[+]
    * name = "drug_exposure_end_date"
    * path = "MedicationAdministration.effectivePeriod.end.toString().substring(0,10)"
    * description = "Drug exposure end date from effective period end"
    * type = #date
  * column[+]
    * name = "drug_exposure_end_datetime"
    * path = "MedicationAdministration.effectivePeriod.end"
    * description = "Drug exposure end datetime from effective period end"
    * type = #dateTime
  * column[+]
    * name = "verbatim_end_date"
    * path = "MedicationAdministration.effectivePeriod.end.toString().substring(0,10)"
    * description = "Verbatim end date from effective period end"
    * type = #date  
  * column[+]
    * name = "stop_reason"
    * path = "MedicationAdministration.statusReason.first().text"
    * description = "Stop reason from status reason"
    * type = #string  
  * column[+]
    * name = "quantity"
    * path = "MedicationAdministration.dosage.dose.value"
    * description = "Quantity from dosage dose value"
    * type = #decimal
  * column[+]
    * name = "sig"
    * path = "MedicationAdministration.dosage.text"
    * description = "Sig from dosage text"
    * type = #string
  * column[+]
    * name = "lot_number"
    * path = "MedicationAdministration.medication.batch.lotNumber"
    * description = "Lot number from medication batch"
    * type = #string
  * column[+]
    * name = "provider_id"
    * path = "MedicationAdministration.performer.first().actor.reference.substring(12)"
    * description = "Provider identifier from performer"
    * type = #integer
  * column[+]
    * name = "visit_occurrence_id"
    * path = "MedicationAdministration.context.reference.substring(10)"
    * description = "Visit occurrence identifier from context"
    * type = #integer
  * column[+]
    * name = "visit_detail_id"
    * path = "MedicationAdministration.context.reference.substring(10)"
    * description = "Visit detail identifier from context"
    * type = #integer
  * column[+]
    * name = "drug_source_value"
    * path = "MedicationAdministration.medicationCodeableConcept.text"
    * description = "Source value for drug"
    * type = #string
  * column[+]
    * name = "route_source_value"
    * path = "MedicationAdministration.dosage.route.text"
    * description = "Source value for route"
    * type = #string
  * column[+]
    * name = "dose_unit_source_value"
    * path = "MedicationAdministration.dosage.dose.unit"
    * description = "Source value for dose unit"
    * type = #string