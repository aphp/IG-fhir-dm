# PostgreSQL Database Setup Script - French Locale Compatible
# Creates databases compatible with French_France.1252 locale

Write-Host "Setting up PostgreSQL databases (French locale compatible)..." -ForegroundColor Cyan

# Set environment variables
$env:PGCLIENTENCODING = "UTF8"

# Database connection parameters
$PG_HOST = "localhost"
$PG_PORT = "5432"  
$PG_USER = "postgres"
$PG_PASSWORD = "123456"

# Test PostgreSQL connection
Write-Host "`nTesting PostgreSQL connection..."
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

# Check current database template
Write-Host "`nChecking database template locale..."
$templateLocale = & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d postgres -t -c "SELECT datcollate FROM pg_database WHERE datname='template1';" 2>&1
Write-Host "Template1 locale: $templateLocale" -ForegroundColor Yellow

# Create databases with compatible locale
Write-Host "`nCreating databases with French-compatible locale..."
$databases = @("ehr", "fhir_semantic_layer", "theRing")

foreach ($db in $databases) {
    Write-Host "Creating database: $db"
    try {
        # Create database using template1 (keeps French locale)
        $result = & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d postgres -c "CREATE DATABASE $db WITH OWNER = postgres ENCODING = 'UTF8';" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Database $db created successfully" -ForegroundColor Green
        } else {
            if ($result -like "*already exists*") {
                Write-Host "- Database $db already exists" -ForegroundColor Yellow
            } else {
                Write-Host "✗ Failed to create database $db`: $result" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "✗ Error creating database $db`: $_" -ForegroundColor Red
    }
}

# Set French locale for PostgreSQL connections
Write-Host "`nConfiguring French locale compatibility..."
foreach ($db in $databases) {
    try {
        & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d $db -c "SET lc_messages = 'French_France.1252';" 2>&1 | Out-Null
        & psql -U $PG_USER -h $PG_HOST -p $PG_PORT -d $db -c "ALTER DATABASE $db SET lc_messages = 'French_France.1252';" 2>&1 | Out-Null
    } catch {
        Write-Host "Warning: Could not set locale for $db" -ForegroundColor Yellow
    }
}

# Load schemas
Write-Host "`nLoading database schemas..."

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

Write-Host "`nDatabase setup complete!" -ForegroundColor Green
Write-Host "Databases created with French locale compatibility." -ForegroundColor Yellow
Write-Host "`nNext steps:"
Write-Host "1. Update profiles.yml to use French locale"
Write-Host "2. Run: .\run_dbt.ps1 debug"
Write-Host "3. Run: .\run_dbt.ps1 'run --full-refresh'"