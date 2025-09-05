# Set environment variables for DBT
$env:DBT_USER = "postgres"
$env:DBT_PASSWORD = "123456"
$env:DBT_HOST = "localhost"
$env:DBT_PORT = "5432"
$env:DBT_DATABASE = "data_core"
$env:DBT_SCHEMA = "dbt"

# Run DBT command passed as argument
if ($args.Count -eq 0) {
    dbt debug
} else {
    $command = $args -join " "
    Invoke-Expression "dbt $command"
}