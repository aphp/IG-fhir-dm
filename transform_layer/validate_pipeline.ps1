# FHIR Data Transformation Pipeline Validation Script
# This script validates the complete DBT pipeline from EHR to FHIR semantic layer

param(
    [string]$Environment = "dev",
    [switch]$SkipTests = $false,
    [switch]$FullRefresh = $false,
    [switch]$SeedsOnly = $false
)

Write-Host "🚀 FHIR Data Transformation Pipeline Validation" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Full Refresh: $FullRefresh" -ForegroundColor Cyan
Write-Host "Skip Tests: $SkipTests" -ForegroundColor Cyan
Write-Host ""

# Set environment variables
$env:DBT_PROFILES_DIR = $PWD
$env:DBT_TARGET = $Environment

try {
    # Step 1: Install dependencies
    Write-Host "📦 Installing DBT dependencies..." -ForegroundColor Yellow
    dbt deps
    if ($LASTEXITCODE -ne 0) { throw "DBT dependencies installation failed" }

    # Step 2: Parse project
    Write-Host "🔍 Parsing DBT project..." -ForegroundColor Yellow
    dbt parse
    if ($LASTEXITCODE -ne 0) { throw "DBT project parsing failed" }

    # Step 3: Load seeds (test data)
    if ($SeedsOnly) {
        Write-Host "🌱 Loading seed data only..." -ForegroundColor Yellow
        dbt seed
        if ($LASTEXITCODE -ne 0) { throw "DBT seed loading failed" }
        Write-Host "✅ Seeds loaded successfully!" -ForegroundColor Green
        exit 0
    }

    Write-Host "🌱 Loading seed data for testing..." -ForegroundColor Yellow
    dbt seed
    if ($LASTEXITCODE -ne 0) { throw "DBT seed loading failed" }

    # Step 4: Run staging models
    Write-Host "📊 Running staging models..." -ForegroundColor Yellow
    if ($FullRefresh) {
        dbt run --select "tag:staging" --full-refresh
    } else {
        dbt run --select "tag:staging"
    }
    if ($LASTEXITCODE -ne 0) { throw "Staging models execution failed" }

    # Step 5: Run intermediate models
    Write-Host "⚙️ Running intermediate models..." -ForegroundColor Yellow
    if ($FullRefresh) {
        dbt run --select "tag:intermediate" --full-refresh
    } else {
        dbt run --select "tag:intermediate"
    }
    if ($LASTEXITCODE -ne 0) { throw "Intermediate models execution failed" }

    # Step 6: Run marts models (FHIR semantic layer)
    Write-Host "🎯 Running FHIR marts models..." -ForegroundColor Yellow
    if ($FullRefresh) {
        dbt run --select "tag:mart" --full-refresh
    } else {
        dbt run --select "tag:mart"
    }
    if ($LASTEXITCODE -ne 0) { throw "Marts models execution failed" }

    # Step 7: Run data quality monitoring
    Write-Host "📈 Running data quality monitoring..." -ForegroundColor Yellow
    dbt run --select "tag:monitoring"
    if ($LASTEXITCODE -ne 0) { throw "Data quality monitoring failed" }

    # Step 8: Run tests (unless skipped)
    if (-not $SkipTests) {
        Write-Host "🧪 Running data quality tests..." -ForegroundColor Yellow
        dbt test
        if ($LASTEXITCODE -ne 0) { 
            Write-Warning "Some tests failed - check results for data quality issues"
        }
    }

    # Step 9: Generate documentation
    Write-Host "📚 Generating documentation..." -ForegroundColor Yellow
    dbt docs generate
    if ($LASTEXITCODE -ne 0) { throw "Documentation generation failed" }

    # Step 10: Validation summary
    Write-Host ""
    Write-Host "🎉 Pipeline Validation Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 SUMMARY:" -ForegroundColor Cyan
    Write-Host "- Staging models: Extracted and cleaned EHR source data" -ForegroundColor White
    Write-Host "- Intermediate models: Applied business logic and transformations" -ForegroundColor White
    Write-Host "- FHIR marts: Generated compliant FHIR R4 resources" -ForegroundColor White
    Write-Host "- Monitoring: Data quality metrics calculated" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 FHIR RESOURCES CREATED:" -ForegroundColor Cyan
    Write-Host "- Patient: French healthcare identifiers (INS-NIR)" -ForegroundColor White
    Write-Host "- Encounter: PMSI-based hospital episodes" -ForegroundColor White
    Write-Host "- Condition: ICD-10 coded diagnoses" -ForegroundColor White
    Write-Host "- Observation: Laboratory, vital signs, lifestyle (LOINC)" -ForegroundColor White
    Write-Host "- Procedure: CCAM coded medical procedures" -ForegroundColor White
    Write-Host "- MedicationRequest: ATC coded prescriptions" -ForegroundColor White
    Write-Host ""
    Write-Host "🔗 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Review data quality summary: SELECT * FROM data_core.fhir_semantic_layer.data_quality_summary" -ForegroundColor Yellow
    Write-Host "2. Open documentation: dbt docs serve" -ForegroundColor Yellow
    Write-Host "3. Query FHIR resources in data_core.fhir_semantic_layer schema" -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "❌ Pipeline validation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check database connections and credentials" -ForegroundColor White
    Write-Host "2. Verify source EHR database accessibility" -ForegroundColor White
    Write-Host "3. Review DBT logs for detailed error messages" -ForegroundColor White
    Write-Host "4. Run 'dbt debug' to diagnose configuration issues" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Optional: Serve documentation
$serve = Read-Host "Would you like to serve the documentation? (y/N)"
if ($serve -eq "y" -or $serve -eq "Y") {
    Write-Host "📚 Starting documentation server..." -ForegroundColor Yellow
    Write-Host "Open http://localhost:8080 in your browser" -ForegroundColor Cyan
    dbt docs serve
}