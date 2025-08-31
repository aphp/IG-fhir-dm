# PostgreSQL Database Setup Script for EHR to FHIR Transformation
# Handles UTF-8 encoding issues on Windows

Write-Host "Setting up PostgreSQL databases for EHR to FHIR transformation..."

# Set environment variables to force English locale
$env:PGCLIENTENCODING = "UTF8"
$env:LC_ALL = "C"
$env:LANG = "C" 
$env:LC_MESSAGES = "C"
$env:LANGUAGE = "en_US:en"

# Database connection parameters
$PG_HOST = "localhost"
$PG_PORT = "5432"  
$PG_USER = "postgres"
$PG_PASSWORD = "123456"

# Test PostgreSQL connection
Write-Host "Testing PostgreSQL connection..."
try {
    $testResult = & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d postgres -c "SELECT version();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL connection successful" -ForegroundColor Green
    } else {
        Write-Host "✗ PostgreSQL connection failed: $testResult" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error testing PostgreSQL: $_" -ForegroundColor Red
    exit 1
}

# Create databases
Write-Host "Creating databases..."

$databases = @("ehr", "fhir_semantic_layer", "theRing")

foreach ($db in $databases) {
    Write-Host "Creating database: ${db}"
    try {
        $result = & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d postgres -c "CREATE DATABASE ${db} WITH OWNER = postgres ENCODING = 'UTF8' TEMPLATE = template0 LC_COLLATE = 'C' LC_CTYPE = 'C';" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Database ${db} created successfully" -ForegroundColor Green
        } else {
            if ($result -like "*already exists*") {
                Write-Host "- Database ${db} already exists" -ForegroundColor Yellow
            } else {
                Write-Host "✗ Failed to create database ${db}: ${result}" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "✗ Error creating database ${db}: $_" -ForegroundColor Red
    }
}

# Load schemas
Write-Host "Loading database schemas..."

# Load EHR schema
Write-Host "Loading EHR schema..."
try {
    $result = & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d ehr -f "../input/sql/applications/ehr/questionnaire-core-ddl.sql" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ EHR schema loaded successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to load EHR schema: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Error loading EHR schema: $_" -ForegroundColor Red
}

# Load FHIR schema
Write-Host "Loading FHIR semantic layer schema..."
try {
    $result = & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d fhir_semantic_layer -f "../input/sql/semantic-layer/fhir-core-ddl.sql" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ FHIR schema loaded successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to load FHIR schema: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Error loading FHIR schema: $_" -ForegroundColor Red
}

Write-Host "Database setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Run: .\run_dbt.ps1 debug    (to test DBT connection)"
Write-Host "2. Run: .\run_dbt.ps1 'run --full-refresh'   (to execute transformation)"