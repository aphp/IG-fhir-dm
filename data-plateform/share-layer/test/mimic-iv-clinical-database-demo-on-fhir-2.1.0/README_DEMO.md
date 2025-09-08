# MIMIC-IV on FHIR

The MIMIC-IV Clinical Database Demo on FHIR contains the MIMIC-IV Clinical Database Demo dataset and the MIMIC-IV-ED demo dataset into the HL7 FHIR (Fast Healthcare Interoperability Resources) format, making the data more accessible and interoperable for healthcare research and development.

## Dataset Overview

The dataset contains clinical data for 100 randomly selected patients from the MIMIC-IV Clinical Database. The data has been converted from traditional relational database tables to FHIR-compliant JSON resources.

- All resources follow FHIR R4 specifications
- Data from MIMIC-IV ED are included and distributed in separate resources
- MIMIC specific terminologies were converted to coding systems and bound to value sets as needed

Resources in the demo dataset include patient and organization resources (MimicOrganization, MimicLocation, MimicPatient, MimicEncounter, MimicEncounterED), observation resources which reference a specimen sampled from a patient (MimicObservationLabevents, MimicObservationMicroTest, MimicObservationMicroOrg, and MimicObservationMicroSusc, MimicSpecimen), medication resources (MimicMedication, MimicMedicationAdministration, MimicMedicationAdministrationICU, MimicMedicationDispense, MimicMedicationDispenseED, MimicMedicationStatementED, MimicMedicationRequest), charted observation resources (MimicObservationChartevents, MimicObservationDatetimeevents, and MimicObservationOutputevents, MimicProcedureICU, MimicObservationED, MimicObservationVitalSignsED), and resources related to billing (MimicCondition, MimicConditionED, MimicProcedure, MimicProcedureED).


The dataset is provided as NDJSON (Newline Delimited JSON) files, compressed using gzip compression. Each line in an NDJSON file is a complete FHIR resource. Example Python code to read:

```python
import json
import gzip

# Read compressed NDJSON file
with gzip.open('MimicPatient.ndjson.gz', 'rt') as f:
    patients = []
    for line in f:
        patient = json.loads(line)
        patients.append(patient)

# Access patient data
first_patient = patients[0]
patient_id = first_patient['id']
patient_name = first_patient['name'][0]['family']
```

Resources are linked using FHIR references. For example:
- Observations reference the Patient via `subject.reference`
- Encounters reference the Patient via `subject.reference`
- Laboratory results reference the Encounter via `encounter.reference`
