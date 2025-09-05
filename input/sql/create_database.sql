-- ========================================================================
-- PostgreSQL 17.x Database Creation Script for FHIR Data Management
-- ========================================================================
-- This script creates the fhir_dm database with proper UTF-8 encoding
-- for French healthcare data management with FHIR resources.

-- Create the main database
CREATE DATABASE fhir_dm
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- Connect to the new database
\c fhir_dm;

-- Create schemas for different layers
CREATE SCHEMA IF NOT EXISTS ehr 
    COMMENT = 'Source EHR data schema';

CREATE SCHEMA IF NOT EXISTS fhir_semantic_layer 
    COMMENT = 'Target FHIR Semantic Layer schema';

CREATE SCHEMA IF NOT EXISTS dbt_dev 
    COMMENT = 'DBT development schema';

CREATE SCHEMA IF NOT EXISTS dbt_test 
    COMMENT = 'DBT test schema';

-- Create extensions for FHIR functionality
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" 
    COMMENT = 'UUID generation for FHIR resources';

CREATE EXTENSION IF NOT EXISTS "pg_trgm" 
    COMMENT = 'Trigram matching for text search';

-- Verify database setup
SELECT 
    current_database() as database_name,
    pg_encoding_to_char(encoding) as encoding,
    datcollate as collation,
    datctype as ctype
FROM pg_database 
WHERE datname = current_database();

-- List created schemas
SELECT schema_name, schema_owner 
FROM information_schema.schemata 
WHERE schema_name IN ('ehr', 'fhir_semantic_layer', 'dbt_dev', 'dbt_test');

-- Show installed extensions
SELECT extname, extversion 
FROM pg_extension 
WHERE extname IN ('uuid-ossp', 'pg_trgm');

\echo 'Database fhir_dm created successfully with UTF-8 encoding!'
\echo 'Schemas created: ehr, fhir_semantic_layer, dbt_dev, dbt_test'
\echo 'Extensions installed: uuid-ossp, pg_trgm'