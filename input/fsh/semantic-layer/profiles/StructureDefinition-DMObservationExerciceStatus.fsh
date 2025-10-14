Profile: DMObservationExerciceStatus
Parent: Observation
Title: "Activité physique"
Description: """
. It specifies which core elements, extensions, vocabularies, and value sets **SHALL** be present and constrains how the elements are used. Providing the floor for standards development for specific use cases promotes interoperability and adoption.
"""

* obeys dm-exercice-minutes-per-day and dm-exercice-days-per-week
* . ^alias = "Obs"
* . ^mustSupport = false

* status MS

* category MS
* category ^slicing.discriminator.type = #value
* category ^slicing.discriminator.path = "$this"
* category ^slicing.rules = #open
* category contains 
  SocialHistory 1..1 MS
  and PhysicalActivity 1..1 MS

* category[SocialHistory] = $observation-category#social-history (exactly)
* category[PhysicalActivity] = $observation-category#activity (exactly)

* code MS
* code from DMExerciceStatusType (extensible)
* code ^short = "Exercice Status"
* code ^condition[0] = "dm-exercice-minutes-per-day"
* code ^condition[+] = "dm-exercice-days-per-week"
* code ^binding.description = "Exercice status type"

* subject 1..1 MS
* subject only Reference(DMPatient)
* subject ^type[0].targetProfile[0].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* subject ^type[=].targetProfile[=].extension.valueBoolean = true

* effective[x] only dateTime or Period or Timing or instant
* effective[x] MS
* effective[x] ^type[0].extension.url = "http://hl7.org/fhir/StructureDefinition/elementdefinition-type-must-support"
* effective[x] ^type[=].extension.valueBoolean = true

* performer only Reference($fr-core-practitioner or $fr-core-organization or DMPatient or PractitionerRole or CareTeam or RelatedPerson)
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

* value[x] only Quantity
* value[x] MS
* value[x] ^condition[0] = "dm-exercice-minutes-per-day"
* value[x] ^condition[+] = "dm-exercice-days-per-week"

* valueQuantity 0..1 MS
* valueQuantity ^short = "Quantitative Response"

Instance: c57100d2-84e3-4ffe-ab82-5588c7dbcae6
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMObservationExerciceStatus)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"