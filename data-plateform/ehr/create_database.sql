-- ========================================================================
-- PostgreSQL 17.x Database Creation Script for FHIR Data Management
-- ========================================================================
-- This script creates the fhir_dm database with proper UTF-8 encoding
-- for French healthcare data management with FHIR resources.

-- Create the EHR database
CREATE DATABASE ehr
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;