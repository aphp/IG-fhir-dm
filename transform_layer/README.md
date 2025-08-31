# EHR to FHIR Semantic Layer Transformation

This DBT project transforms EHR data into FHIR-compliant resources following the FML mapping specification.

## Prerequisites

### 1. PostgreSQL Setup
Create three databases with UTF-8 encoding:

```sql
-- Run this in PostgreSQL as superuser
CREATE DATABASE ehr WITH OWNER = postgres ENCODING = 'UTF8';
CREATE DATABASE fhir_semantic_layer WITH OWNER = postgres ENCODING = 'UTF8';
CREATE DATABASE theRing WITH OWNER = postgres ENCODING = 'UTF8';
```

### 2. Load Source Schema
Load the EHR schema:
```bash
psql -U postgres -d ehr -f "../input/sql/applications/ehr/questionnaire-core-ddl.sql"
```

Load the FHIR schema:
```bash
psql -U postgres -d fhir_semantic_layer -f "../input/sql/semantic-layer/fhir-core-ddl.sql"
```

## Environment Setup

### Windows
Use the provided PowerShell script:
```powershell
.\run_dbt.ps1
```

### Manual Environment Variables
```bash
export DBT_USER=postgres
export DBT_PASSWORD=123456
export DBT_HOST=localhost
export DBT_PORT=5432
export DBT_DATABASE=theRing
export DBT_SCHEMA=public

export EHR_USER=postgres
export EHR_PASSWORD=123456
export EHR_HOST=localhost
export EHR_PORT=5432
export EHR_DATABASE=ehr
export EHR_SCHEMA=public

export FHIR_USER=postgres
export FHIR_PASSWORD=123456
export FHIR_HOST=localhost
export FHIR_PORT=5432
export FHIR_DATABASE=fhir_semantic_layer
export FHIR_SCHEMA=public
```

## Usage

### 1. Test Connection
```bash
dbt debug
```

### 2. Install Dependencies
```bash
dbt deps
```

### 3. Full Refresh (Initial Load)
```bash
dbt run --full-refresh
```

### 4. Incremental Updates
```bash
dbt run
```

### 5. Run Tests
```bash
dbt test
```

## Troubleshooting

### UTF-8 Encoding Issues
If you encounter UTF-8 encoding errors:

1. Ensure PostgreSQL databases were created with UTF-8 encoding
2. Set environment variable: `PYTHONIOENCODING=utf-8`
3. Update PostgreSQL client encoding: `SET client_encoding = 'UTF8';`

### Database Connection Issues
1. Verify PostgreSQL is running on port 5432
2. Check user credentials and permissions
3. Ensure all three databases exist
4. Test connection with: `psql -U postgres -h localhost -d theRing`

### Missing Source Data
The DBT models expect source tables to exist in the `ehr` database. If running without source data, models will fail with table not found errors.

## Model Structure

- **Staging**: Extract and clean data from EHR database
- **Intermediate**: Prepare FHIR-compliant data structures
- **Marts**: Final FHIR resources ready for consumption

## FHIR Resources Generated

- `fhir_patient` - DMPatient profile with French identifiers
- `fhir_encounter` - DMEncounter with PMSI data
- `fhir_condition` - DMCondition with ICD-10 codes
- `fhir_observation` - Laboratory and vital signs observations
- `fhir_medication_request` - ATC-coded medication requests
- `fhir_procedure` - CCAM-coded procedures

## Data Quality

The pipeline includes comprehensive data quality tests:
- Reference integrity validation
- FHIR compliance checks
- French healthcare standards validation
- Data completeness scoring