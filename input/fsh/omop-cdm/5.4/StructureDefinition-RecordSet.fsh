Logical: RecordSet
Parent: Base
Characteristics: #can-be-target
Title: "RecordSet"
Description: "Conteneur intermediaire utilise par RecordSetMap (Bundle -> plusieurs tables OMOP) et par BloodPressureVitalSignsMap (routage vers plusieurs Measurement independants en raison de la limitation FML une entree/une sortie). Types composes en direct (pas de Reference()) - correction validee sur BloodPressureVitalSignsMap apres l'erreur 'Cannot set property measurement_id on measurement'."

* record_id 0..1 string "Record ID" "Identifiant du Bundle source."
* record_set_timestamp 0..1 dateTime "Record Set Timestamp" "Horodatage du Bundle source."
* patient_id 0..1 string "Patient ID" "Identifiant brut du Patient (RecordSetMap uniquement, pas de Reference() ici)."
* allergy 0..* OMOPObservation "Allergy" "Enregistrement OMOP Observation genere depuis une AllergyIntolerance."
* condition 0..* OMOPConditionOccurrence "Condition" "Enregistrement OMOP ConditionOccurrence genere depuis une Condition."
* visitOccurrence 0..* OMOPVisitOccurrence "Visit Occurrence" "Enregistrement OMOP VisitOccurrence genere depuis un Encounter."
* measurement 0..* OMOPMeasurement "Measurement" "Enregistrement OMOP Measurement genere depuis une Observation (mesure simple, ou une ligne parmi plusieurs pour une PA composite)."
* procedure 0..* OMOPProcedureOccurrence "Procedure" "Enregistrement OMOP ProcedureOccurrence genere depuis une Procedure."
