# Set environment variables for DBT
$env:DBT_USER = "postgres"
$env:DBT_PASSWORD = "123456"
$env:DBT_HOST = "localhost"
$env:DBT_PORT = "5432"
$env:DBT_DATABASE = "thering"
$env:DBT_SCHEMA = "public"

$env:EHR_USER = "postgres"
$env:EHR_PASSWORD = "123456"
$env:EHR_HOST = "localhost"
$env:EHR_PORT = "5432"
$env:EHR_DATABASE = "ehr"
$env:EHR_SCHEMA = "public"

$env:FHIR_USER = "postgres"
$env:FHIR_PASSWORD = "123456"
$env:FHIR_HOST = "localhost"
$env:FHIR_PORT = "5432"
$env:FHIR_DATABASE = "fhir_semantic_layer"
$env:FHIR_SCHEMA = "public"

# Set UTF-8 environment for console
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
$env:PYTHONIOENCODING = "utf-8"
$env:LC_ALL = "C"
$env:LANG = "C"
$env:LC_MESSAGES = "C"

# Run DBT command passed as argument
if ($args.Count -eq 0) {
    dbt debug
} else {
    $command = $args -join " "
    Invoke-Expression "dbt $command"
}