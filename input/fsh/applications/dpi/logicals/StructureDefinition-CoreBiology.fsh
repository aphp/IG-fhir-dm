Logical: CoreBiology
Parent: Base
Characteristics: #can-be-target
Title: "CORE.BIOLOGY"
Description: """
Table CORE.BIOLOGY (DDL)
"""

* biologyNi 1..1 integer "BIOLOGY_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* encounterNi 1..1 Reference(CoreEncounter) "ENCOUNTER_NI"
* dateCreat 1..1 date "DATE_CREAT"
* dateModif 1..1 date "DATE_MODIF"
* dateRemove 0..1 date "DATE_REMOVE"
