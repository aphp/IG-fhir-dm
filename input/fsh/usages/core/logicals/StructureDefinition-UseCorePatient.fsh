Logical: UseCorePatient
Parent: Base
Characteristics: #can-be-target
Title: "Core - patient"
Description: """
Ensemble de dimensions associées au patient pour l'usage variables socles.
"""

* identifier 0..1 Identifier "IPP du patient"
* active 1..1 boolean "Whether this patient's record is in active use"
* deceased[x] 0..1 boolean or dateTime "Indicates if the individual is deceased or not"
* birthDate 1..1 date "Date de naissance du patient"
* gender 1..1 CodeableConcept "Gender" """Describes biological sex as recorded in the patient's identity document or in the hospital record. In the absence of documentation, the one declared by the patient will be recorded"""