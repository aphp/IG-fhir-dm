Logical: LogicalBundle
Parent: Base
Id: LogicalBundle
Title: "LogicalBundle"
Description: """
The BundleLogical has the same objective as the FHIR Bundle resource but allows for the grouping of logical models.
"""

* id 1..1 id "Logical id of this artifact"
* type 1..1 code "Indicates the purpose of this bundle - how it is intended to be used." """	
It's possible to use a bundle for other purposes (e.g. a document can be accepted as a transaction). This is primarily defined so that there can be specific rules for some of the bundle types.
"""
* type ^short = "document | message | transaction | transaction-response | batch | batch-response | history | searchset | collection"
* type from http://hl7.org/fhir/ValueSet/bundle-type (required)
* entry 0..* BackboneElement "An entry in a bundle resource - will either contain a resource or information about a resource (transactions and history only)."
// TODO add all necessary types
  * person 0..1 OMOPPerson "The Person for the entry. The purpose/meaning of the person is determined by the Bundle.type."
  * person ^short = "A person in the bundle"
  * location 0..1 OMOPLocation "The Location for the entry. The purpose/meaning of the location is determined by the Bundle.type."
  * location ^short = "A location in the bundle"
  * death 0..1 OMOPDeath "The Death for the entry. The purpose/meaning of the death is determined by the Bundle.type."
  * death ^short = "A death in the bundle"
  * measurement 0..* OMOPMeasurement "Measurement for the entry. The purpose/meaning of the measurements is determined by the Bundle.type."
  * measurement ^short = "Measurement(s) in the bundle"
