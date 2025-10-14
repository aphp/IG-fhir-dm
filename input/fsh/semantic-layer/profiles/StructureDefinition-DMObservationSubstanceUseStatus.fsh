Profile: DMObservationSubstanceUseStatus
Parent: Observation
Title: "Consommation d'autres drogues"
Description: """
It specifies which core elements, extensions, vocabularies, and value sets **SHALL** be present and constrains how the elements are used. Providing the floor for standards development for specific use cases promotes interoperability and adoption.
"""

* status MS

* category MS
* category ^slicing.discriminator.type = #value
* category ^slicing.discriminator.path = "$this"
* category ^slicing.rules = #open
* category contains 
  SocialHistory 1..1 MS
* category[SocialHistory] = $observation-category#social-history

* code MS
* code = $loinc#11343-1 "History of Other nonmedical drug use" (exactly)
  * text = "Substance use status" (exactly)

* subject 1..1 MS
* subject only Reference(DMPatient)
* subject ^type[0].targetProfile[0].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* subject ^type[=].targetProfile[=].extension.valueBoolean = true

* effective[x] only dateTime or Period or Timing or instant
* effective[x] MS
* effective[x] ^type[0].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* effective[x] ^type[=].extension.valueBoolean = true

* performer only Reference(DMOrganization or DMPatient or DMPractitioner or DMPractitionerRole or CareTeam or RelatedPerson)
* performer MS
* performer ^type[0].targetProfile[0].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* performer ^type[=].targetProfile[=].extension.valueBoolean = false
* performer ^type[=].targetProfile[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* performer ^type[=].targetProfile[=].extension.valueBoolean = false
* performer ^type[=].targetProfile[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* performer ^type[=].targetProfile[=].extension.valueBoolean = false
* performer ^type[=].targetProfile[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* performer ^type[=].targetProfile[=].extension.valueBoolean = false
* performer ^type[=].targetProfile[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* performer ^type[=].targetProfile[=].extension.valueBoolean = false
* performer ^type[=].targetProfile[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* performer ^type[=].targetProfile[=].extension.valueBoolean = false

* value[x] only Quantity or CodeableConcept or string or boolean or integer or Range or Ratio or SampledData or time or dateTime or Period
* value[x] MS
* value[x] ^type[0].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* value[x] ^type[=].extension.valueBoolean = true
* value[x] ^type[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* value[x] ^type[=].extension.valueBoolean = true
* value[x] ^type[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* value[x] ^type[=].extension.valueBoolean = true
* value[x] ^type[+].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* value[x] ^type[=].extension.valueBoolean = true

Instance: 25ecfaff-2086-421e-a64f-57faf2914a4e
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMObservationSubstanceUseStatus)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
