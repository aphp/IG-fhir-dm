<goal>
Implement a production-grade Python script to transfer full schema definitions and data from a source PostgreSQL database to a target PostgreSQL database.
</goal>
<instructions>
1. Environment Configuration
Implement two distinct groups of environment variables:

**Source Database Configuration:**
```
SOURCE_DB_HOST
SOURCE_DB_PORT (default: 5432)
SOURCE_DB_NAME
SOURCE_SCHEMA (ordered list)
SOURCE_DB_USER
SOURCE_DB_PASSWORD
```

**Destination Database Configuration:**
```
DEST_DB_HOST
DEST_DB_PORT (default: 5432)
DEST_DB_NAME
DEST_SCHEMA (ordered list)
DEST_DB_USER
DEST_DB_PASSWORD
```
Le résultat doit supporter l'approche par .env ou arguments passés au moment de l'appel

2. Technical Specifications
#### Must-Have Features:
1. **Complete database object migration:**
   - Tables with all constraints (PK, FK, UNIQUE, CHECK)
   - Indexes (B-tree, GIN, GiST, etc.)
   - Sequences with current values
   - Views and materialized views
   - Functions, procedures, and aggregates
   - Custom types and domains
   - Triggers and rules
   - Comments on all objects

2. **Data migration capabilities:**
   - Efficient bulk data transfer
   - Handle large tables (>1TB) with streaming
   - Preserve data types (JSONB, arrays, UUID, etc.)
   - Maintain referential integrity
   - Support for BYTEA and large objects

3. **Performance optimization:**
   - Parallel processing with configurable workers
   - Batch processing with adjustable size
   - Memory-efficient streaming for large datasets
   - Connection pooling
   - Automatic index creation deferral

4. **Error handling & resilience:**
   - Comprehensive error handling with retry logic
   - Transaction management with rollback capability
   - Deadlock detection and resolution
   - Network interruption recovery
   - Detailed error logging with context
4. Advanced Features

#### Command-line Interface:

```bash
# Full migration (default)
python migrate.py

# Full migration (with args)					
python migrate.py --srchost localhost \
					--srcport 5432 \
					--srcdb ehr \
					--srcschema public,ehr \
					--srcuser ehr_user \
					--srcpassword ehr_user_123 \
					--dsthost localhost \
					--dstport 5432 \
					--dstdb ehr \
					--dstschema public,other \
					--dstuser transform_user \
					--dstpassword transform_user_123

# Schema only
python migrate.py --mode schema-only

# Data only
python migrate.py --mode data-only

# Performance tuning
python migrate.py --parallel-workers 8 \
                  --batch-size 50000 \
                  --disable-triggers \
                  --disable-indexes-during-copy

# Validation mode
python migrate.py --validate-only

# Dry run
python migrate.py --dry-run
```

#### Configuration Options:
```python
{
    "mode": ["full", "schema-only", "data-only"],
    "parallel_workers": 1-32,
    "batch_size": 1000-100000,
    "include_tables": [],
    "exclude_tables": [],
    "disable_triggers": bool,
    "disable_indexes_during_copy": bool,
    "continue_on_error": bool,
    "validate_after_migration": bool,
    "use_copy_expert": bool,  # For maximum performance
    "compression": bool,
    "ssl_mode": ["disable", "require", "verify-full"]
}
```
### 5. Project Structure

```
data-platform/transform-layer/data-migrator/
├── requirements.txt
├── setup.py
├── .env.example
├── README.md
├── migrate.py                 # Main entry point
├── config/
│   ├── __init__.py
│   ├── settings.py           # Configuration management
│   └── validators.py         # Input validation
├── src/
│   ├── __init__.py
│   ├── connections/
│   │   ├── __init__.py
│   │   ├── pool.py          # Connection pooling
│   │   └── manager.py       # Connection management
│   ├── migration/
│   │   ├── __init__.py
│   │   ├── schema_mapper.py # Schema mapping logic
│   │   ├── structure.py     # DDL migration
│   │   ├── data.py         # DML migration
│   │   ├── sequences.py    # Sequence handling
│   │   └── validators.py   # Post-migration validation
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── logger.py       # Logging configuration
│   │   ├── progress.py     # Progress tracking
│   │   └── helpers.py      # Utility functions
│   └── exceptions.py        # Custom exceptions
└── tests/
    ├── __init__.py
    ├── unit/
    │   └── test_*.py
    └── integration/
        └── test_*.py

```

### 6. Implementation Details

#### Migration Workflow:
1. **Pre-flight checks:**
   - Validate connections
   - Check permissions
   - Estimate data size
   - Check disk space

2. **Structure migration:**
   - Determine migration order
   - Migrate types and domains first
   - Create tables without constraints
   - Add functions and procedures
   - Create views
   - Add constraints and indexes
   - Create triggers

3. **Data migration:**
   - Disable triggers and constraints
   - Copy data in dependency order
   - Use COPY command for performance
   - Update sequences
   - Re-enable triggers and constraints

4. **Validation:**
   - Compare row counts
   - Validate constraints
   - Check sequence values
   - Compare schema structures

### 7. Special Considerations

#### Handle PostgreSQL-specific features:
- Partitioned tables
- Table inheritance
- Foreign tables (FDW)
- Publications and subscriptions
- Extensions (CREATE EXTENSION)
- Collations and text search configurations
- Row-level security policies
- Event triggers

### 8. Error Scenarios to Handle

1. **Connection issues:**
   - Network timeouts
   - Authentication failures
   - Connection pool exhaustion

2. **Data issues:**
   - Data type mismatches
   - Encoding problems
   - Constraint violations
   - Duplicate key errors

3. **Resource issues:**
   - Out of memory
   - Disk space exhaustion
   - Transaction log full

4. **Concurrency issues:**
   - Deadlocks
   - Lock timeouts
   - Long-running transactions

### 9. Testing Requirements

- Unit tests with >80% coverage
- Integration tests with Docker PostgreSQL instances
- Performance benchmarks
- Data integrity validation tests
- Failure recovery tests
- Schema mapping validation tests

### 10. Documentation Requirements

#### README must include:
- Quick start guide
- Detailed configuration options
- Performance tuning guide
- Troubleshooting section
- Migration examples for common scenarios
- FAQ section
- Contribution guidelines

#### Code documentation:
- Type hints for all functions
- Comprehensive docstrings
- Inline comments for complex logic
- Architecture decision records (ADRs)

### 11. Security Requirements

- Never log sensitive information (passwords, data)
- Support SSL/TLS connections
- Implement SQL injection prevention
- Support encrypted configuration files
- Audit logging capability

### 12. Deliverables

1. **Core script** with all features implemented
2. **Comprehensive test suite**
3. **Documentation** (README, user guide)
4. **Example configurations** for common scenarios
</instructions>
<recommandations>
## Success Criteria

The script should:
- Successfully migrate a 1TB database in <2 hours on standard hardware
- Handle all PostgreSQL object types correctly
- Maintain 100% data integrity
- Provide clear progress indication and error messages
- Be maintainable and extensible
- Follow Python best practices (PEP 8, type hints, etc.)
- Include comprehensive error recovery mechanisms
- Support PostgreSQL versions 11-16

## Additional Notes

- Use `psycopg3` for better async support and performance
- Implement using `asyncio` for concurrent operations
- Consider using `rich` for beautiful CLI output
- Use `pydantic` for configuration validation
- Implement proper signal handling (SIGTERM, SIGINT)
- Add support for resumable migrations
- Consider implementing a web UI for monitoring (optional, using FastAPI)
</recommandations>
<output>
This tool should be production-ready and capable of handling enterprise-scale PostgreSQL migrations with zero data loss and minimal downtime.
</output>
