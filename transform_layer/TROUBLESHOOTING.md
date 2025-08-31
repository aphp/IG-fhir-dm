# DBT Troubleshooting Guide

## Fixed Issues

### ✅ Issue 1: `search_path` error (RESOLVED)
**Error:** `['public'] is not valid under any of the given schemas`  
**Solution:** Removed `search_path` from profiles.yml

### ✅ Issue 2: `fhir_schema` variable not found (RESOLVED)
**Error:** `Could not render {{ var('fhir_schema') }}_snapshots: Required var 'fhir_schema' not found`  
**Solution:** Simplified dbt_project.yml and removed problematic macros

## Quick Test Commands

```bash
# Test if configuration is valid
dbt debug

# Parse models without running
dbt parse

# List all models
dbt list

# Compile a specific model
dbt compile --select fhir_patient
```

## Step-by-Step Verification

### 1. Check Connection
```bash
dbt debug
```
Should show: `All checks passed!`

### 2. Parse Models
```bash
dbt parse
```
Should complete without errors.

### 3. List Available Models
```bash
dbt list
```
Should show models like:
- `ehr_fhir_transform.staging.ehr.stg_ehr__patient`
- `ehr_fhir_transform.marts.core.fhir_patient`

### 4. Load Test Data
```bash
dbt seed
```

### 5. Run Transformations
```bash
# Start with staging layer
dbt run --select tag:staging

# Then intermediate layer
dbt run --select tag:intermediate

# Finally marts layer
dbt run --select tag:mart
```

## Common Next Steps

If you get database connection errors:
1. Ensure PostgreSQL is running
2. Verify credentials in environment variables
3. Check database and schema exist

If you get model compilation errors:
1. Start with simple models: `dbt run --select stg_ehr__patient`
2. Check for syntax errors in SQL files
3. Verify source tables exist in your database

## Database Setup

If you need to create the source EHR tables:
```sql
-- Run the EHR DDL script first
\i input/sql/applications/ehr/questionnaire-core-ddl.sql

-- Then run the FHIR target DDL
\i input/sql/semantic-layer/fhir-core-ddl.sql
```

## Environment Variables Check

Verify your environment variables are set:

**Windows:**
```cmd
echo %DBT_USER%
echo %DBT_DATABASE%
echo %DBT_SCHEMA%
```

**Linux/Mac:**
```bash
echo $DBT_USER
echo $DBT_DATABASE  
echo $DBT_SCHEMA
```

## Success Indicators

You'll know it's working when:
- ✅ `dbt debug` shows "All checks passed!"
- ✅ `dbt parse` completes without errors
- ✅ `dbt seed` loads test data successfully
- ✅ `dbt run --select tag:staging` creates staging views
- ✅ `dbt run --select tag:mart` creates final FHIR tables