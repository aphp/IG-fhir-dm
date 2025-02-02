Logical: CorePatient
Parent: Base
Characteristics: #can-be-target
Title: "CORE.PATIENT"
Description: """
Table CORE.PATIENT (DDL)
"""

* patientNi 1..1 integer "PATIENT_NI"
* vip 1..1 string "VIP"
* name 0..1 string "NAME"
* firstName 0..1 string "FIRST_NAME"
* gender 0..1 string "GENDER"
* birthDate 0..1 date "BIRTH_DATE"
