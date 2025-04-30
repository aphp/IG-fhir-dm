Logical: CoreDataSet
Parent: Base
Characteristics: #can-be-target
Title: "Core - DataSet"
Description:  """
Modèle logique pour les DataSet issues du DPI
"""

* logicalId 0..1 id "id"
* patient 1..1 CorePatient "Patient"
* sejour 0..* CoreSejour "Sejour"
* biology 0..* CoreBiology "Biologies"
* clinical 0..* CoreClinical "Clinical"
* medicationPre 0..* CoreMedicationPre "Medication prescription"
* medicationAdm 0..* CoreMedicationAdm "Medication administration"
