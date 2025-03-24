Logical: CoreSejour
Parent: Base
Characteristics: #can-be-target
Title: "CORE.SEJOUR"
Description: """
Table CORE.SEJOUR (DDL)
"""

* sejourNi 1..1 integer "SEJOUR_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* sejourType 1..1 string "SEJOUR_TYPE"
* nda 1..1 string "NDA"
* dateCreat 1..1 date "DATE_CREAT"
* dateModif 1..1 date "DATE_MODIF"
* dateRemove 0..1 date "DATE_REMOVE"
* sejourStart 0..1 date "SEJOUR_START"
* sejourEnd 0..1 date "SEJOUR_END"
