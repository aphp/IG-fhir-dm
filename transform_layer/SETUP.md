# DBT Setup Guide for EHR to FHIR Transform

## Quick Start

### 1. Set Environment Variables

**Windows (Command Prompt):**
```cmd
set DBT_USER=postgres
set DBT_PASSWORD=123456
set DBT_HOST=localhost
set DBT_PORT=5432
set DBT_DATABASE=fhir_dm
set DBT_SCHEMA=dbt_dev
```

**Windows (PowerShell):**
```powershell
$env:DBT_USER="postgres"
$env:DBT_PASSWORD="123456"
$env:DBT_HOST="localhost"
$env:DBT_PORT="5432"
$env:DBT_DATABASE="fhir_dm"
$env:DBT_SCHEMA="dbt_dev"
```

**Linux/Mac/Git Bash:**
```bash
export DBT_USER=postgres
export DBT_PASSWORD=123456
export DBT_HOST=localhost
export DBT_PORT=5432
export DBT_DATABASE=fhir_dm
export DBT_SCHEMA=dbt_dev
```

### 2. Copy Profile Configuration

```bash
# Create dbt profiles directory
mkdir -p ~/.dbt

# Copy the profiles.yml file
cp profiles.yml ~/.dbt/profiles.yml
```

### 3. Test Connection

```bash
cd transform_layer
dbt debug
```

You should see output like:
```
Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]
  
Connection:
  host: localhost
  port: 5432
  user: postgres
  database: fhir_dm
  schema: dbt_dev
  
All checks passed!
```

## Common Issues and Solutions

### Issue 1: `search_path` error
**Error:** `['public'] is not valid under any of the given schemas`
**Solution:** This has been fixed in the profiles.yml - the search_path configuration was removed.

### Issue 2: Connection refused
**Error:** `could not connect to server: Connection refused`
**Solutions:**
- Ensure PostgreSQL is running: `pg_ctl status`
- Check if the port is correct (default: 5432)
- Verify host is accessible

### Issue 3: Authentication failed
**Error:** `FATAL: password authentication failed for user`
**Solutions:**
- Verify DBT_USER and DBT_PASSWORD are set correctly
- Check PostgreSQL user exists: `psql -U postgres -c "\du"`
- Ensure user has database access permissions

### Issue 4: Database does not exist
**Error:** `database "fhir_dm" does not exist`
**Solution:** Create the database:
```sql
CREATE DATABASE fhir_dm;
```

### Issue 5: Environment variables not found
**Error:** `Env var required but not provided: 'DBT_USER'`
**Solutions:**
- Set environment variables as shown in step 1
- Or use the `dev_direct` target with hardcoded values

## Alternative: Direct Configuration

If you prefer not to use environment variables, edit `~/.dbt/profiles.yml` and use the `dev_direct` target:

```yaml
transform_layer:
  target: dev_direct
  outputs:
    dev_direct:
      type: postgres
      host: localhost
      port: 5432
      user: postgres
      pass: 123456  # Your actual password
      dbname: fhir_dm
      schema: dbt_dev
      threads: 4
      keepalives_idle: 0
      sslmode: prefer
```

Then run: `dbt debug --target dev_direct`

## Next Steps

Once `dbt debug` passes:

1. **Load test data:** `dbt seed`
2. **Run transformations:** `dbt run`
3. **Run tests:** `dbt test`
4. **Generate docs:** `dbt docs generate && dbt docs serve`

## Useful Commands

```bash
# Build everything from scratch
dbt build --full-refresh

# Run only staging models
dbt run --select tag:staging

# Run a specific model
dbt run --select fhir_patient

# Compile SQL without running
dbt compile

# Show model lineage
dbt docs generate && dbt docs serve
```