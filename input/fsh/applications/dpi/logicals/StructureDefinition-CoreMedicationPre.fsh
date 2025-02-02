Logical: CoreMedicationPre
Parent: Base
Characteristics: #can-be-target
Title: "CORE.MEDICATION_PRE"
Description: """
Table CORE.MEDICATION_PRE (DDL)
"""

* medicationPreNi 1..1 integer "MEDICATION_PRE_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* encounterNi 1..1 Reference(CoreEncounter) "ENCOUNTER_NI"
