-- ========================================================================
-- PostgreSQL 17.x Database Creation Script for FHIR Data Management
-- ========================================================================
-- This script creates the data_core database with proper UTF-8 encoding
-- for French healthcare data management with FHIR resources.

CREATE DATABASE transform_layer
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C.UTF-8'
    LC_CTYPE = 'C.UTF-8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
