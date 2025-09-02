-- HAPI FHIR Database Initialization Script
-- This script sets up the database with optimized settings for FHIR workloads

-- Create HAPI database if not exists (handled by Docker environment variables)
-- The database is created automatically by the postgres Docker image

-- Set optimal database parameters for FHIR workloads
ALTER DATABASE hapi SET random_page_cost = 1.1;
ALTER DATABASE hapi SET effective_io_concurrency = 200;
ALTER DATABASE hapi SET shared_preload_libraries = 'pg_stat_statements';

-- Create additional schemas if needed
CREATE SCHEMA IF NOT EXISTS fhir;
CREATE SCHEMA IF NOT EXISTS audit;

-- Grant permissions to hapi user
GRANT ALL PRIVILEGES ON SCHEMA fhir TO hapi;
GRANT ALL PRIVILEGES ON SCHEMA audit TO hapi;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA fhir TO hapi;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA fhir TO hapi;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA fhir TO hapi;

-- Create extension for better performance
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- For text search optimization
CREATE EXTENSION IF NOT EXISTS btree_gin;  -- For better index performance
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- For better index performance
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;  -- For query performance monitoring

-- Create a read-only user for reporting/analytics (optional)
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_user
      WHERE usename = 'hapi_read') THEN
      CREATE USER hapi_read WITH PASSWORD 'hapi_read_password';
   END IF;
END
$do$;

GRANT CONNECT ON DATABASE hapi TO hapi_read;
GRANT USAGE ON SCHEMA public TO hapi_read;
GRANT USAGE ON SCHEMA fhir TO hapi_read;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hapi_read;
GRANT SELECT ON ALL TABLES IN SCHEMA fhir TO hapi_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO hapi_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA fhir GRANT SELECT ON TABLES TO hapi_read;

-- Create audit log table for tracking database changes
CREATE TABLE IF NOT EXISTS audit.database_changes (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    user_name VARCHAR(255) DEFAULT current_user,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    row_data JSONB,
    changed_fields JSONB
);

-- Create index on audit table
CREATE INDEX idx_audit_table_name ON audit.database_changes(table_name);
CREATE INDEX idx_audit_changed_at ON audit.database_changes(changed_at);
CREATE INDEX idx_audit_operation ON audit.database_changes(operation);

-- Function to log slow queries (for monitoring)
CREATE OR REPLACE FUNCTION log_slow_queries()
RETURNS void AS $$
BEGIN
    -- This function can be called periodically to log slow queries
    -- Requires pg_stat_statements extension
    INSERT INTO audit.database_changes (table_name, operation, row_data)
    SELECT 
        'slow_queries' as table_name,
        'LOG' as operation,
        jsonb_build_object(
            'query', query,
            'calls', calls,
            'total_time', total_exec_time,
            'mean_time', mean_exec_time,
            'max_time', max_exec_time
        ) as row_data
    FROM pg_stat_statements
    WHERE mean_exec_time > 1000  -- Log queries taking more than 1 second
    ORDER BY mean_exec_time DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Create a maintenance function for regular cleanup
CREATE OR REPLACE FUNCTION maintenance_routine()
RETURNS void AS $$
BEGIN
    -- Analyze tables for query optimization
    ANALYZE;
    
    -- Clean up old audit logs (keep last 90 days)
    DELETE FROM audit.database_changes 
    WHERE changed_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
    
    -- Reset pg_stat_statements periodically
    PERFORM pg_stat_statements_reset();
END;
$$ LANGUAGE plpgsql;

-- Create indexes for common FHIR searches (will be created after HAPI creates tables)
-- These are placeholder comments for reference
-- CREATE INDEX CONCURRENTLY idx_hfj_resource_type_id ON hfj_resource(res_type, res_id);
-- CREATE INDEX CONCURRENTLY idx_hfj_resource_updated ON hfj_resource(res_updated);
-- CREATE INDEX CONCURRENTLY idx_hfj_res_ver_updated ON hfj_res_ver(res_updated);
-- CREATE INDEX CONCURRENTLY idx_hfj_spidx_token_hash ON hfj_spidx_token(hash_identity, sp_id, res_id);
-- CREATE INDEX CONCURRENTLY idx_hfj_spidx_string_hash ON hfj_spidx_string(hash_exact, sp_id, res_id);
-- CREATE INDEX CONCURRENTLY idx_hfj_spidx_date_hash ON hfj_spidx_date(hash_identity, sp_id, res_id);

-- Notify that initialization is complete
DO $$
BEGIN
    RAISE NOTICE 'HAPI FHIR database initialization completed successfully';
END $$;