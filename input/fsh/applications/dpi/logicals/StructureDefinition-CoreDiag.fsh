Logical: CoreDiag
Parent: Base
Characteristics: #can-be-target
Title: "CORE.DIAG"
Description: """
Table CORE.DIAG (DDL)
"""

* diagNi 1..1 integer "DIAG_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* sejourNi 1..1 Reference(CoreSejour) "SEJOUR_NI"
* code 1..1 string "CODE"
* codeType 0..1 string "CODE_TYPE"
