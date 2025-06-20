Logical: CoreActe
Parent: Base
Characteristics: #can-be-target
Title: "CORE.ACTE"
Description: """
Table CORE.ACTE (DDL)
"""

* acteNi 1..1 integer "ACTE_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* sejourNi 1..1 Reference(CoreSejour) "SEJOUR_NI"
* code 1..1 string "CODE"
* dateStart 0..1 dateTime "DATE_START"
* dateEnd 0..1 dateTime "DATE_END"