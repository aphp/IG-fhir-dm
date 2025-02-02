Logical: CoreDataSet
Parent: Base
Characteristics: #can-be-target
Title: "Core - DataSet"
Description:  """
Modèle logique pour les DataSet issues du DPI
"""

* logicalid 0..1 id "id"
* patient 1..1 CorePatient "Patient"
* encounter 0..* CoreEncounter "Encounter"
* biology 0..* CoreBiology "Biologies"
* clinical 0..* CoreClinical "Clinical"
* medicationPre 0..* CoreMedicationPre "Medication prescription"
* medicationAdm 0..* CoreMedicationAdm "Medication administration"
