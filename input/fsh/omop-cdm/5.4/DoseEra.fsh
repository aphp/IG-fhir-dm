Logical: OMOPDoseEra
Parent: Base
Characteristics: #can-be-target
Title: "Dose Era OMOP Table"
Description: "A Dose Era is defined as a span of time when the Person is assumed to be exposed to a constant dose of a specific active ingredient."

* dose_era_id 1..1 Reference(OMOPConcept) "Dose Era Identifier" ""
* person_id 1..1 Reference(OMOPPerson) "Person" ""
* drug_concept_id 1..1 Reference(OMOPConcept) "Drug" "The Concept Id representing the specific drug ingredient."
* unit_concept_id 1..1 Reference(OMOPConcept) "Unit" "The Concept Id representing the unit of the specific drug ingredient."
* dose_value 1..1 integer "Dose Value" "The numeric value of the dosage of the drug_ingredient."
* dose_era_start_date 1..1 date "Dose Era Start Date" "The date the Person started on the specific dosage, with at least 31 days since any prior exposure."
* dose_era_end_date 1..1 date "Dose Era End Date" ""
