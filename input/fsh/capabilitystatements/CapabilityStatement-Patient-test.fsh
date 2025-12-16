Instance: Patient-test
InstanceOf: CapabilityStatement
Title: "test"
Description: "test."
Usage: #definition

* name = "Test"
* status = #active
* date = "2025-12-15T18:00:00.000+01:00"
* kind = #requirements
* format[0] = #json
* fhirVersion = #4.0.1

* rest[0]
  * mode = #client
  * resource
    * type = #Patient
    * extension[0]
      * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
      * valueCode = #SHALL
    * interaction[0].code = #read
    * interaction[+]
      * code = #search-type
    * searchParam[0]
      * name = "family"
      * type = #string
      * definition = "http://hl7.org/fhir/SearchParameter/individual-family"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    * searchParam[+]
      * name = "given"
      * type = #string
      * definition = "http://hl7.org/fhir/SearchParameter/individual-given"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    * searchParam[+]
      * name = "gender"
      * type = #token
      * definition = "http://hl7.org/fhir/SearchParameter/individual-gender"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    * searchParam[+]
      * name = "birthdate"
      * type = #date
      * definition = "http://hl7.org/fhir/SearchParameter/individual-birthdate"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    * searchParam[+]
      * name = "phonetic"
      * type = #string
      * definition = "http://hl7.org/fhir/SearchParameter/individual-phonetic"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    * searchParam[+]
      * name = "telecom"
      * type = #token
      * definition = "http://hl7.org/fhir/SearchParameter/individual-telecom"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    * searchParam[+]
      * name = "language"
      * type = #token
      * definition = "http://hl7.org/fhir/SearchParameter/Patient-language"
      * extension
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
    // the following extension is rendered badly in the built IG :
    * extension[+]
      * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination"
      * extension[0].url = "optional"
      * extension[=].valueString = "family"
      * extension[+].url = "optional"
      * extension[=].valueString = "given"
      * extension[+].url = "optional"
      * extension[=].valueString = "gender"
      * extension[+].url = "optional"
      * extension[=].valueString = "birthdate"
      * extension[+].url = "optional"
      * extension[=].valueString = "phonetic"
      * extension[+].url = "optional"
      * extension[=].valueString = "telecom"
      * extension[+].url = "optional"
      * extension[=].valueString = "language"
      * extension[+]
        * url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
        * valueCode = #SHALL
