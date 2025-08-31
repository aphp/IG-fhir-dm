@echo off
REM Batch file to set DBT environment variables on Windows

echo Setting DBT environment variables...

REM Set user variables (temporary for this session)
set DBT_USER=postgres
set DBT_PASSWORD=123456
set DBT_HOST=localhost
set DBT_PORT=5432
set DBT_DATABASE=fhir_dm
set DBT_SCHEMA=dbt_dev

echo Environment variables set for this session.
echo.
echo To make them permanent, use one of these methods:
echo.
echo Method 1: System Properties
echo   1. Right-click 'This PC' or 'My Computer'
echo   2. Click 'Properties' → 'Advanced system settings'
echo   3. Click 'Environment Variables'
echo   4. Add new User variables for DBT_USER, DBT_PASSWORD, etc.
echo.
echo Method 2: Command line (requires admin rights):
echo   setx DBT_USER "postgres"
echo   setx DBT_PASSWORD "your_password"
echo   setx DBT_HOST "localhost"
echo   setx DBT_PORT "5432"
echo   setx DBT_DATABASE "fhir_dm"
echo   setx DBT_SCHEMA "dbt_dev"
echo.
echo Current values:
echo   DBT_USER=%DBT_USER%
echo   DBT_HOST=%DBT_HOST%
echo   DBT_DATABASE=%DBT_DATABASE%
echo   DBT_SCHEMA=%DBT_SCHEMA%

pause