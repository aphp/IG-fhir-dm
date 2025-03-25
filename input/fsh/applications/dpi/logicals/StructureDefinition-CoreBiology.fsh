Logical: CoreBiology
Parent: Base
Characteristics: #can-be-target
Title: "CORE.BIOLOGY"
Description: """
Table CORE.BIOLOGY (DDL)
"""

* biologyNi 1..1 integer "BIOLOGY_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* dateCreat 1..1 date "DATE_CREAT"
* dateModif 1..1 date "DATE_MODIF"
* dateRemove 0..1 date "DATE_REMOVE"
* biologyCode 0..1 string "null"
* biologyValue 0..1 decimal "null"
* biologyUnit 0..1 string "null"
* biologyDatePrel 0..1 date "null"
* biologyDateEnr 0..1 date "null"
* biologyDateValTech 0..1 date "null"
* biologyDateValBiol 0..1 date "null"
* sejourNi 1..1 Reference(CoreSejour) "null"
