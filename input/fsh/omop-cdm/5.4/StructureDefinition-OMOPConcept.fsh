Logical: OMOPConcept
Parent: Base
Characteristics: #can-be-target
Title: "Concept OMOP Table"
Description: """
The Standardized Vocabularies contains records, or Concepts, that uniquely identify each fundamental unit of meaning used to express clinical information in all domain tables of the CDM. Concepts are derived from vocabularies, which represent clinical information across a domain (e.g. conditions, drugs, procedures) through the use of codes and associated descriptions. Some Concepts are designated Standard Concepts, meaning these Concepts can be used as normative expressions of a clinical entity within the OMOP Common Data Model and within standardized analytics. Each Standard Concept belongs to one domain, which defines the location where the Concept would be expected to occur within data tables of the CDM.

Concepts can represent broad categories (like "Cardiovascular disease"), detailed clinical elements ("Myocardial infarction of the anterolateral wall") or modifying characteristics and attributes that define Concepts at various levels of detail (severity of a disease, associated morphology, etc.).

Records in the Standardized Vocabularies tables are derived from national or international vocabularies such as SNOMED-CT, RxNorm, and LOINC, or custom Concepts defined to cover various aspects of observational data analysis.
"""

* concept_id 1..1 integer "A unique identifier for each Concept across all domains."
* concept_name 1..1 string "An unambiguous, meaningful and descriptive name for the Concept."
* domain_id 1..1 string "A foreign key to the DOMAIN table the Concept belongs to."
* vocabulary_id 1..1 string "A foreign key to the VOCABULARY table indicating from which source the Concept has been adapted."
* concept_class_id 1..1 string "The attribute or concept class of the Concept. Examples are \"Clinical Drug\", \"Ingredient\", \"Clinical Finding\" etc."
* standard_concept 0..1 string "This flag determines where a Concept is a Standard Concept, i.e. is used in the data, a Classification Concept, or a non-standard Source Concept. The allowable values are \"S\" (Standard Concept) and \"C\" (Classification Concept), otherwise the content is NULL."
* concept_code 1..1 string "The concept code represents the identifier of the Concept in the source vocabulary, such as SNOMED-CT concept IDs, RxNorm RXCUIs etc. Note that concept codes are not unique across vocabularies."
* valid_start_date 1..1 date "The date when the Concept was first recorded. The default value is 1-Jan-1970, meaning, the Concept has no (known) date of inception."
* valid_end_date 1..1 date "The date when the Concept became invalid because it was deleted or superseded (updated) by a new concept. The default value is 31-Dec-2099, meaning, the Concept is valid until it becomes deprecated."
* invalid_reason 0..1 string "Reason the Concept was invalidated. Possible values are D (deleted), U (replaced with an update) or NULL when valid_end_date has the default value."