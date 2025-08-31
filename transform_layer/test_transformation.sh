#!/bin/bash

# Script to test the EHR to FHIR transformation using DBT
# This script demonstrates the full transformation pipeline

echo "================================================"
echo "EHR to FHIR Semantic Layer Transformation Test"
echo "================================================"
echo ""

# Check if dbt is installed
if ! command -v dbt &> /dev/null
then
    echo "ERROR: dbt is not installed. Please install dbt-postgres first:"
    echo "pip install dbt-postgres"
    exit 1
fi

# Set the working directory
cd "$(dirname "$0")"

echo "1. Setting up test environment..."
echo "--------------------------------"

# Create a test profile if it doesn't exist
if [ ! -f ~/.dbt/profiles.yml ]; then
    echo "Creating dbt profile..."
    mkdir -p ~/.dbt
    cp profiles.yml ~/.dbt/profiles.yml
    echo "⚠️  Please edit ~/.dbt/profiles.yml with your database credentials"
    exit 1
fi

echo "2. Testing database connection..."
echo "--------------------------------"
dbt debug --profiles-dir ~/.dbt

if [ $? -ne 0 ]; then
    echo "ERROR: Database connection failed. Please check your profiles.yml"
    exit 1
fi

echo ""
echo "3. Loading test data seeds..."
echo "--------------------------------"
dbt seed --full-refresh

echo ""
echo "4. Running staging models..."
echo "--------------------------------"
dbt run --select tag:staging --full-refresh

echo ""
echo "5. Running intermediate models..."
echo "--------------------------------"
dbt run --select tag:intermediate --full-refresh

echo ""
echo "6. Running mart models (final FHIR resources)..."
echo "--------------------------------"
dbt run --select tag:mart --full-refresh

echo ""
echo "7. Running data quality tests..."
echo "--------------------------------"
dbt test

echo ""
echo "8. Generating documentation..."
echo "--------------------------------"
dbt docs generate

echo ""
echo "================================================"
echo "Transformation Complete!"
echo "================================================"
echo ""
echo "To view the transformation results:"
echo "  1. Connect to your PostgreSQL database"
echo "  2. Query the mart tables:"
echo "     - SELECT * FROM dbt_dev.fhir_patient;"
echo "     - SELECT * FROM dbt_dev.fhir_encounter;"
echo "     - SELECT * FROM dbt_dev.fhir_observation;"
echo ""
echo "To view the documentation:"
echo "  dbt docs serve"
echo ""
echo "Sample query to see transformed FHIR Patient:"
echo "------------------------------------------------"
cat << 'EOF'
SELECT 
    id,
    ins_nir_identifier,
    family_name,
    given_names,
    gender,
    birth_date,
    jsonb_pretty(identifiers) as identifiers,
    jsonb_pretty(names) as names,
    jsonb_pretty(addresses) as addresses
FROM dbt_dev.fhir_patient
LIMIT 1;
EOF