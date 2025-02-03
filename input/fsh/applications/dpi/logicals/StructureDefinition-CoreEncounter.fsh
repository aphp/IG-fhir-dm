Logical: CoreEncounter
Parent: Base
Characteristics: #can-be-target
Title: "CORE.ENCOUNTER"
Description: """
Table CORE.ENCOUNTER (DDL)
"""

* encounterNi 1..1 integer "ENCOUNTER_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* encounterType 1..1 string "ENCOUNTER_TYPE"
* dateCreat 1..1 date "null"
* dateModif 1..1 date "null"
* dateRemove 0..1 date "null"
* encounterStart 0..1 date "null"
* encounterEnd 0..1 date "null"
