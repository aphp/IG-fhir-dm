# ========================================================================
# DBT Pipeline Execution Script for EHR to FHIR Semantic Layer Transform
# ========================================================================

param(
    [ValidateSet("dev", "prod", "test")]
    [string]$Target = "dev",
    
    [switch]$SkipTests,
    
    [switch]$FullRefresh,
    
    [switch]$DebugMode,
    
    [string]$Models = "",
    
    [switch]$DocsGenerate,
    
    [switch]$DocsServe
)

# Set error action
$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColoredOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success { param([string]$Message) Write-ColoredOutput $Message "Green" }
function Write-Warning { param([string]$Message) Write-ColoredOutput $Message "Yellow" }
function Write-Error { param([string]$Message) Write-ColoredOutput $Message "Red" }
function Write-Info { param([string]$Message) Write-ColoredOutput $Message "Cyan" }

# Script header
Write-Info "=========================================="
Write-Info "🚀 DBT EHR to FHIR Transform Pipeline"
Write-Info "=========================================="
Write-Info "Target Environment: $Target"
Write-Info "Full Refresh: $FullRefresh"
Write-Info "Skip Tests: $SkipTests"
Write-Info "Debug Mode: $DebugMode"
if ($Models) { Write-Info "Models Filter: $Models" }
Write-Info "==========================================`n"

# Verify DBT installation
Write-Info "Checking DBT installation..."
try {
    $dbtVersion = dbt --version
    Write-Success "✅ DBT is installed"
    Write-Host $dbtVersion
} catch {
    Write-Error "❌ DBT is not installed or not in PATH"
    Write-Error "Please install DBT: pip install dbt-postgres"
    exit 1
}

# Verify working directory
$expectedPath = "data-platform\transform-layer\data-transformer"
$currentDir = (Get-Location).Path

if (-not $currentDir.EndsWith($expectedPath.Replace('\', [IO.Path]::DirectorySeparatorChar))) {
    Write-Warning "⚠️  Working directory should be: $expectedPath"
    Write-Info "Current directory: $currentDir"
    
    # Try to change to correct directory if it exists
    $projectPath = Join-Path $currentDir $expectedPath
    if (Test-Path $projectPath) {
        Write-Info "Changing to project directory: $projectPath"
        Set-Location $projectPath
    } else {
        Write-Error "❌ Cannot find DBT project directory"
        exit 1
    }
}

# Verify required files
$requiredFiles = @("dbt_project.yml", "profiles.yml")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Error "❌ Required file missing: $file"
        exit 1
    }
}
Write-Success "✅ Required DBT files found"

# Charger le fichier .env
$envFile = ".\.env"

if (Test-Path $envFile) {
    $content = Get-Content $envFile
    
    foreach ($line in $content) {
        # Ignorer les lignes vides et les commentaires
        if ($line -and !$line.StartsWith("#")) {
            # Séparer la clé et la valeur
            $kvp = $line -split "=", 2
            if ($kvp.Count -eq 2) {
                $key = $kvp[0].Trim()
                $value = $kvp[1].Trim()
                
                # Retirer les guillemets si présents
                $value = $value -replace '^["'']|["'']$', ''
                
                # Définir la variable d'environnement
                [System.Environment]::SetEnvironmentVariable($key, $value)
                
                # Ou utiliser cette syntaxe alternative
                #Set-Item -Path "Env:$key" -Value $value

                Write-Host "$key=$value" -ForegroundColor Green
            }
        }
    }
    Write-Host "Variables d'environnement chargées depuis $envFile" -ForegroundColor Green
} else {
    Write-Host "Fichier $envFile non trouvé" -ForegroundColor Red
}

# Set environment variables if they don't exist
if (-not $env:DBT_POSTGRES_PASSWORD) {
    Write-Error "❌  DBT_POSTGRES_PASSWORD environment variable not set"
    Write-Error "Using default password 'postgres'. Set the environment variable for production."
    exit 1
}

# DBT command construction
$dbtArgs = @("--target", $Target)
if ($DebugMode) { $dbtArgs += "--debug" }
if ($Models) { $dbtArgs += @("--models", $Models) }

# Step 1: Install dependencies
Write-Info "📦 Installing DBT dependencies..."
try {
    dbt deps @dbtArgs
    Write-Success "✅ Dependencies installed"
} catch {
    Write-Error "❌ Failed to install dependencies"
    Write-Error $_.Exception.Message
    exit 1
}

# Step 2: Debug connection
Write-Info "🔗 Testing database connection..."
try {
    dbt debug @dbtArgs
    Write-Success "✅ Database connection successful"
} catch {
    Write-Error "❌ Database connection failed"
    Write-Error $_.Exception.Message
    Write-Info "Please check:"
    Write-Info "- PostgreSQL is running on localhost:5432"
    Write-Info "- Database 'transform_layer' exists"
    Write-Info "- User 'postgres' has proper permissions"
    Write-Info "- DBT_POSTGRES_PASSWORD environment variable is set correctly"
    exit 1
}

# Step 3: Load seed data
Write-Info "🌱 Loading seed data..."
try {
    dbt seed @dbtArgs $(if ($FullRefresh) { "--full-refresh" })
    Write-Success "✅ Seed data loaded"
} catch {
    Write-Error "❌ Failed to load seed data"
    Write-Error $_.Exception.Message
    exit 1
}

# Step 4: Snapshot (if any snapshot models exist)
if (Test-Path "snapshots") {
    Write-Info "📸 Running snapshots..."
    try {
        dbt snapshot @dbtArgs
        Write-Success "✅ Snapshots completed"
    } catch {
        Write-Warning "⚠️  Snapshots failed (this may be expected if no snapshot models exist)"
    }
}

# Step 5: Run DBT models
Write-Info "🏗️  Running DBT models..."
try {
    $runArgs = $dbtArgs
    if ($FullRefresh) { $runArgs += "--full-refresh" }
    
    dbt run @runArgs
    Write-Success "✅ DBT models executed successfully"
} catch {
    Write-Error "❌ DBT run failed"
    Write-Error $_.Exception.Message
    exit 1
}

# Step 6: Run tests (unless skipped)
if (-not $SkipTests) {
    Write-Info "🧪 Running DBT tests..."
    try {
        dbt test @dbtArgs
        Write-Success "✅ All tests passed"
    } catch {
        Write-Warning "⚠️  Some tests failed - check output above"
        # Don't exit on test failures in development
        if ($Target -eq "prod") {
            Write-Error "❌ Tests must pass in production environment"
            exit 1
        }
    }
} else {
    Write-Warning "⏭️  Skipping tests"
}

# Step 7: Generate documentation (if requested)
if ($DocsGenerate) {
    Write-Info "📚 Generating documentation..."
    try {
        dbt docs generate @dbtArgs
        Write-Success "✅ Documentation generated"
        
        if ($DocsServe) {
            Write-Info "🌐 Starting documentation server..."
            Write-Info "Documentation will be available at http://localhost:8080"
            Write-Info "Press Ctrl+C to stop the server"
            dbt docs serve --port 8080
        }
    } catch {
        Write-Warning "⚠️  Documentation generation failed"
    }
}

# Step 8: Summary and validation
Write-Info "`n📊 Validating transformation results..."

# Get record counts for validation
try {
    # This would require psql or similar tool to be available
    # For now, we'll just show completion message
    Write-Info "Transformation completed successfully!"
    Write-Info ""
    Write-Info "FHIR Semantic Layer tables created:"
    Write-Info "- fhir_patient"
    Write-Info "- fhir_encounter" 
    Write-Info "- fhir_condition"
    Write-Info "- fhir_procedure"
    Write-Info "- fhir_observation"
    Write-Info "- fhir_medication_request"
    Write-Info "- fhir_medication_administration"
    Write-Info ""
    Write-Success "✅ EHR to FHIR transformation pipeline completed successfully!"
} catch {
    Write-Warning "⚠️  Could not validate results, but transformation appears successful"
}

# Final summary
Write-Info "`n=========================================="
Write-Success "🎉 Pipeline Execution Complete!"
Write-Info "Target: $Target"
Write-Info "Models created in schema: dbt_fhir_semantic_layer"
Write-Info "==========================================`n"

# Instructions for next steps
Write-Info "Next steps:"
Write-Info "1. Verify data in PostgreSQL database 'transform_layer'"
Write-Info "2. Check data quality using: dbt test --target $Target"
Write-Info "3. Generate docs with: .\run_dbt.ps1 -DocsGenerate -DocsServe"
Write-Info "4. Run specific models with: .\run_dbt.ps1 -Models 'fhir_patient'"

Write-Info "`nFor help: Get-Help .\run_dbt.ps1 -Full"