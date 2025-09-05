# EHR to FHIR Semantic Layer Transform

This dbt project transforms Electronic Health Record (EHR) data from the EDSH (Entrepôt de Données de Santé Hospitalières) model into FHIR R4 compliant resources following the Data Management (DM) profiles developed by AP-HP.

## Project Structure

```
models/
├── staging/          # Source-conformed, minimal transformations
│   └── ehr/          # EHR source data staging models
├── intermediate/     # Business logic and FHIR mapping implementation
│   ├── core/         # Core FHIR resources (Patient, Encounter)
│   ├── clinical/     # Clinical FHIR resources (Condition, Procedure, Observation)
│   └── medication/   # Medication FHIR resources (MedicationRequest)
└── marts/           # Final FHIR-compliant resources
    ├── core/        # Core FHIR resources ready for consumption
    ├── clinical/    # Clinical FHIR resources ready for consumption
    └── medication/  # Medication FHIR resources ready for consumption
```

## Key Features

- **FHIR R4 Compliance**: All output resources follow FHIR R4 specification
- **DM Profile Adherence**: Resources conform to AP-HP Data Management profiles
- **Medallion Architecture**: Follows dbt Labs best practices with bronze/silver/gold layers
- **Incremental Loading**: Supports incremental updates with late-arriving data handling
- **FML Mapping Implementation**: Based on the StructureMap-EHR2FSL.fml mapping definition
- **Comprehensive Testing**: Data quality tests and FHIR validation
- **French Healthcare Standards**: Supports INS-NIR, ICD-10, CCAM, ATC coding systems

## Usage

### Initial Setup

1. Copy `profiles.yml` to `~/.dbt/profiles.yml` and configure your database connection
2. Install dependencies: `dbt deps` (if packages are defined)
3. Test connection: `dbt debug`

### Running the Transform

```bash
# Build all models from scratch
dbt build --full-refresh

# Build specific model groups
dbt build --select tag:staging
dbt build --select tag:core_fhir
dbt build --select tag:clinical_fhir

# Run incremental updates (default behavior)
dbt run

# Run with specific lookback period
dbt run --vars '{"incremental_lookback_days": 14}'

# Run tests
dbt test

# Generate documentation
dbt docs generate && dbt docs serve
```

## Source Data Model (EHR)

The source data follows the EDSH core variables model:

- **patient**: Patient demographics with INS-NIR identifiers
- **donnees_pmsi**: Healthcare encounters from PMSI system
- **diagnostics**: Diagnostic conditions with ICD-10 codes
- **actes**: Medical procedures with CCAM codes
- **biologie**: Laboratory test results with LOINC codes
- **exposition_medicamenteuse**: Medication exposures with ATC codes
- **dossier_soins**: Vital signs and physical measurements
- **style_vie**: Lifestyle and social history observations

## Target FHIR Resources

The transformation produces FHIR R4 resources:

- **fhir_patient**: DMPatient profile with French identifiers
- **fhir_encounter**: DMEncounter profile for healthcare encounters  
- **fhir_condition**: DMCondition profile with ICD-10 diagnoses
- **fhir_procedure**: DMProcedure profile with CCAM procedures
- **fhir_observation**: DM observation profiles (laboratory, vital signs, lifestyle)
- **fhir_medication_request**: DMMedicationRequest profile with ATC codes

## Configuration

Set these environment variables in your shell or `.env` file:

```bash
# Database connection
DBT_USER=your_username
DBT_PASSWORD=your_password  
DBT_DATABASE=fhir_dm
DBT_SCHEMA=dbt_dev

# Production environment
PROD_HOST=prod_host
PROD_USER=prod_user
PROD_PASSWORD=prod_password
PROD_DATABASE=prod_database
PROD_SCHEMA=fhir_semantic_layer
```

## Architecture

This project implements a medallion architecture following dbt Labs best practices:

1. **Staging Layer** (`staging/ehr/`): Source-conformed data with basic cleansing
2. **Intermediate Layer** (`intermediate/`): Business logic implementing FML mapping rules
3. **Marts Layer** (`marts/`): Final FHIR-compliant resources ready for consumption

The transformation logic is based on the FML StructureMap definition in `input/fml/StructureMap-EHR2FSL.fml`, ensuring compliance with both FHIR R4 specifications and AP-HP Data Management profiles.
