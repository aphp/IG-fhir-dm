Logical: UseCoreContactSystemeSante
Parent: Base
Characteristics: #can-be-target
Title: "Use Core - contact avec le système de santé"
Description:  """Contact"""

* patient 1..1 Reference(UseCorePatient) "Patient" """Patient element containing the data regarding the patient followed by the encounter"""
* hospital 1..1 Reference(UseCoreHopital) "Hospital" """Hospital element containing the data regarding the patient followed by the hospital"""
* status 1..1 CodeableConcept "supprimé, planifié, courant, sortie/cloturé"
* identifier 1..1 Identifier "Identifiant"
* contactType 1..1 CodeableConcept "hospitalisés, consultation externe, urgence, hospitalisation incomplète" """Type of contact registered"""
* period 1..1 Period "The start and end time of the contact" """The start and end time of the contact"""