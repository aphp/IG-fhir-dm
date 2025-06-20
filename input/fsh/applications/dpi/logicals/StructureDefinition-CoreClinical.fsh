Logical: CoreClinical
Parent: Base
Characteristics: #can-be-target
Title: "CORE.CLINICAL"
Description: """
Table CORE.CLINICAL (DDL)
"""

* clinicalNi 1..1 integer "CLINICAL_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* sejourNi 1..1 Reference(CoreSejour) "SEJOUR_NI"
