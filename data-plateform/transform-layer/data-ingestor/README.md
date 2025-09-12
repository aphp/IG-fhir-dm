# EHR to FHIR Semantic Layer - DBT Project

This DBT project implements the transformation between EHR data and FHIR Semantic Layer as specified in the FML (FHIR Mapping Language) mapping `input/fml/StructureMap-EHR2FSL.fml`.

## Project Structure

```
data-plateform/transform-layer/data-ingestor/
├── dbt_project.yml           # DBT project configuration
├── profiles.yml              # Database connection profiles  
├── packages.yml              # DBT package dependencies
├── run_dbt.ps1              # PowerShell script to run the pipeline
├── validate_pipeline.ps1     # PowerShell script to validate results
├── seeds/                   # Test data (CSV files)
├── models/
│   ├── staging/             # Clean and standardize source data
│   │   ├── _sources.yml     # Source table definitions
│   │   ├── stg_ehr__patient.sql
│   │   ├── stg_ehr__patient_adresse.sql
│   │   ├── stg_ehr__donnees_pmsi.sql
│   │   ├── stg_ehr__diagnostics.sql
│   │   ├── stg_ehr__actes.sql
│   │   ├── stg_ehr__biologie.sql
│   │   ├── stg_ehr__prescription.sql
│   │   ├── stg_ehr__posologie.sql
│   │   ├── stg_ehr__administration.sql
│   │   ├── stg_ehr__dossier_soins.sql
│   │   └── stg_ehr__style_vie.sql
│   ├── intermediate/         # Complex transformations and business logic
│   │   ├── int_patient_enriched.sql
│   │   ├── int_encounter_enriched.sql
│   │   ├── int_medication_request_enriched.sql
│   │   └── int_lifestyle_observations_split.sql
│   └── marts/               # Final FHIR resource tables
│       ├── fhir/
│       │   ├── fhir_patient.sql
│       │   ├── fhir_encounter.sql
│       │   ├── fhir_condition.sql
│       │   ├── fhir_procedure.sql
│       │   ├── fhir_observation.sql
│       │   ├── fhir_medication_request.sql
│       │   └── fhir_medication_administration.sql
│       └── monitoring/
│           └── data_quality_summary.sql
```

## Database Architecture

### Source Database: `ehr`
- Contains raw EHR data tables (patient, donnees_pmsi, diagnostics, etc.)
- Schema: `public`

### Target Database: `transform_layer`  
- **`dbt_seeds`** - Test data loaded from CSV files
- **`dbt_staging`** - Cleaned and standardized source data
- **`dbt_intermediate`** - Complex transformations and enrichments
- **`dbt_fhir_semantic_layer`** - Final FHIR resource tables

## Key Transformations

### 1. Patient Transformation
- Maps EHR patient data to FHIR Patient resource
- Includes INS-NIR identifiers, demographics, address with geolocation
- Handles multiple birth, death information with extensions

### 2. Encounter Transformation  
- Transforms PMSI encounter data to FHIR Encounter resource
- Maps admission/discharge modes, length of stay, service providers

### 3. Condition Transformation
- Converts diagnostic codes to FHIR Condition resources
- Uses ICD-10 coding system, maps PMSI diagnosis types to FHIR categories

### 4. Procedure Transformation
- Maps medical procedures to FHIR Procedure resources  
- Uses CCAM coding system for French medical procedures

### 5. Observation Transformation
- **Laboratory**: Transforms biologie data with LOINC codes
- **Vital Signs**: Transforms dossier_soins measurements  
- **Lifestyle**: Splits style_vie into separate observations (tobacco, alcohol, drugs, physical activity)

### 6. Medication Transformation
- **MedicationRequest**: Transforms prescriptions with ATC coding
- **MedicationAdministration**: Transforms administration records
- Links prescriptions to administrations where applicable

## Usage

### Prerequisites
1. PostgreSQL 17.x running on localhost:5432
2. Databases: `ehr` (source) and `transform_layer` (target) 
3. DBT installed with PostgreSQL adapter: `pip install dbt-postgres`
4. PowerShell (for Windows) or adapt scripts for Linux/Mac

### Environment Setup
```powershell
# Set PostgreSQL password (optional, defaults to 'postgres')
$env:DBT_POSTGRES_PASSWORD = "your_password"
```

### Running the Pipeline

#### Full Pipeline Execution
```powershell
# Run complete pipeline with test data
.\run_dbt.ps1 -Target dev

# Production run with full refresh
.\run_dbt.ps1 -Target prod -FullRefresh

# Run specific models only
.\run_dbt.ps1 -Models "fhir_patient,fhir_encounter"

# Generate and serve documentation
.\run_dbt.ps1 -DocsGenerate -DocsServe
```

#### Validation
```powershell
# Validate transformation results
.\validate_pipeline.ps1 -Target dev
```

### Manual DBT Commands
```bash
# Install dependencies
dbt deps

# Test connection
dbt debug

# Load seed data  
dbt seed

# Run transformations
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## Data Quality

The pipeline includes comprehensive data quality checks:

- **Source validation**: Tests referential integrity and data types
- **Transformation validation**: Ensures FHIR compliance and completeness
- **Output validation**: Monitors record counts and data quality scores
- **Monitoring dashboard**: `data_quality_summary` table provides KPIs

## FHIR Compliance

All generated resources follow FHIR R4 specification with French profiles:

- **Patient**: `DMPatient` profile with INS-NIR identifiers
- **Encounter**: `DMEncounter` profile for PMSI data
- **Condition**: `DMCondition` profile with ICD-10 coding
- **Procedure**: `DMProcedure` profile with CCAM coding  
- **Observation**: `DMObservation` profiles for laboratory, vital signs, lifestyle
- **MedicationRequest**: `DMMedicationRequest` profile with ATC coding
- **MedicationAdministration**: `DMMedicationAdministration` profile

## FML Mapping Compliance

The DBT transformations implement the complete FML mapping specification:

✅ **Patient transformation** with identifiers, names, demographics  
✅ **Address transformation** with geolocation extensions  
✅ **Encounter transformation** with PMSI hospitalization data  
✅ **Condition transformation** with ICD-10 diagnosis codes  
✅ **Procedure transformation** with CCAM procedure codes  
✅ **Laboratory observation** transformation with LOINC codes  
✅ **Vital signs observation** transformation  
✅ **Lifestyle observations** split into separate resources per element  
✅ **Medication request** transformation with dosage instructions  
✅ **Medication administration** transformation with/without orders  
✅ **FHIR JSON structure** generation for all resources  

## Troubleshooting

### Common Issues

1. **Connection failed**: Check PostgreSQL is running and credentials are correct
2. **Schema not found**: Run `dbt run` to create target schemas  
3. **No data**: Load seed data first with `dbt seed`
4. **Tests failing**: Expected for empty databases; load test data

### Logs and Debugging
```powershell
# Run with debug output
.\run_dbt.ps1 -Debug

# Run with verbose logging
dbt --debug run
```

### Getting Help
```powershell  
# Script help
Get-Help .\run_dbt.ps1 -Full

# DBT help
dbt --help
```

## Performance Optimization

- Indexes on all FHIR resource ID fields and foreign keys
- Materialized tables for final FHIR resources
- Views for staging and intermediate transformations
- Partitioning recommendations for large datasets in production