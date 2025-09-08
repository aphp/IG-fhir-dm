Instance: OMOP-DrugStrength-View
InstanceOf: ViewDefinition
Usage: #definition
Title: "OMOP Drug Strength View"
Description: "ViewDefinition to transform FHIR Medication resources into OMOP Drug Strength table format"

* name = "OMOP-DrugStrength-View"
* status = #draft
* resource = #Medication
* select[+]
  * column[+]
    * name = "drug_concept_id"
    * path = "Medication.code.coding.first().code"
    * description = "Drug concept from medication coding"
    * type = #integer
  * column[+]
    * name = "ingredient_concept_id"
    * path = "Medication.ingredient.first().itemCodeableConcept.coding.first().code"
    * description = "Ingredient concept from ingredient coding"
    * type = #integer
  * column[+]
    * name = "amount_value"
    * path = "Medication.ingredient.first().strength.numerator.value"
    * description = "Amount value from strength numerator"
    * type = #decimal
  * column[+]
    * name = "amount_unit_concept_id"
    * path = "Medication.ingredient.first().strength.numerator.code"
    * description = "Amount unit concept from strength numerator code"
    * type = #integer
  * column[+]
    * name = "numerator_value"
    * path = "Medication.ingredient.first().strength.numerator.value"
    * description = "Numerator value from strength"
    * type = #decimal
  * column[+]
    * name = "numerator_unit_concept_id"
    * path = "Medication.ingredient.first().strength.numerator.code"
    * description = "Numerator unit concept from strength code"
    * type = #integer
  * column[+]
    * name = "denominator_value"
    * path = "Medication.ingredient.first().strength.denominator.value"
    * description = "Denominator value from strength"
    * type = #decimal
  * column[+]
    * name = "denominator_unit_concept_id"
    * path = "Medication.ingredient.first().strength.denominator.code"
    * description = "Denominator unit concept from strength code"
    * type = #integer
  * column[+]
    * name = "box_size"
    * path = "Medication.amount.numerator.value"
    * description = "Box size from medication amount"
    * type = #integer
  * column[+]
    * name = "valid_start_date"
    * path = "Medication.batch.expirationDate.toString().substring(0,10)"
    * description = "Valid start date (using batch expiration as placeholder)"
    * type = #date
  * column[+]
    * name = "valid_end_date"
    * path = "Medication.batch.expirationDate.toString().substring(0,10)"
    * description = "Valid end date from batch expiration"
    * type = #date
  * column[+]
    * name = "invalid_reason"
    * path = "Medication.status"
    * description = "Invalid reason from medication status"
    * type = #string