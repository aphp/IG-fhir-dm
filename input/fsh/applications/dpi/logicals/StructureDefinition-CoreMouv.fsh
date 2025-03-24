Logical: CoreMouv
Parent: Base
Characteristics: #can-be-target
Title: "CORE.MOUV"
Description: """
Table CORE.MOUV (DDL)
"""

* mouvNi 1..1 integer "MOUV_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* sejourNi 1..1 Reference(CoreSejour) "SEJOUR_NI"
* mouvType 1..1 string "MOUV_TYPE"
* dateCreat 1..1 date "DATE_CREAT"
* dateModif 1..1 date "DATE_MODIF"
* dateRemove 0..1 date "DATE_REMOVE"
* mouvStart 0..1 date "MOUV_START"
* mouvEnd 0..1 date "MOUV_END"
