Logical: CoreMedicationAdm
Parent: Base
Characteristics: #can-be-target
Title: "CORE.MEDICATION_ADM"
Description: """
Table CORE.MEDICATION_ADM (DDL)
"""

* medicationAdmNi 1..1 integer "MEDICATION_ADM_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* encounterNi 1..1 Reference(CoreEncounter) "ENCOUNTER_NI"
