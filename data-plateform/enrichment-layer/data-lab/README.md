# Parquet to DuckDB Analytics Solution

A comprehensive Python solution for loading Parquet files into DuckDB with OMOP Common Data Model (CDM) schema support. This tool is designed for high-performance analytics on healthcare data exported from Pathling or other FHIR-based systems.

## Features

- **High-Performance Loading**: Utilizes DuckDB's native Parquet integration for optimal performance
- **OMOP CDM Support**: Automatically creates OMOP CDM 5.4 schema with proper constraints
- **Flexible Configuration**: Configurable input/output directories, memory limits, and processing options
- **Data Validation**: Comprehensive validation suite to ensure data quality and integrity
- **Rich CLI Interface**: User-friendly command-line interface with progress bars and detailed output
- **Extensible Architecture**: Modular design allowing easy customization and extension

## Installation

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Verify the OMOP DDL files are present:
```bash
ls ../sql/omop/
# Should show: OMOPCDM_duckdb_5.4_ddl.sql and related files
```

## Quick Start

### Basic Usage

Load all Parquet files from the default directory:
```bash
python parquet_to_duckdb.py load
```

### Custom Configuration

Specify custom input and output directories:
```bash
python parquet_to_duckdb.py load \
    --input /path/to/parquet/files \
    --output /path/to/output \
    --database my_omop_db \
    --memory 8GB \
    --threads 8
```

### Advanced Usage

Skip DDL creation if database already exists:
```bash
python parquet_to_duckdb.py load --skip-ddl --skip-constraints
```

Force overwrite existing database:
```bash
python parquet_to_duckdb.py load --force
```

## Configuration

### Environment Variables

You can configure the application using environment variables with the `PARQUET_DUCKDB_` prefix:

```bash
export PARQUET_DUCKDB_INPUT_DIRECTORY="../script/output"
export PARQUET_DUCKDB_OUTPUT_DIRECTORY="./output"
export PARQUET_DUCKDB_DATABASE_NAME="omop_cdm"
export PARQUET_DUCKDB_MEMORY_LIMIT="4GB"
export PARQUET_DUCKDB_THREADS="4"
export PARQUET_DUCKDB_LOG_LEVEL="INFO"
```

### Configuration File

Create a `.env` file in the application directory:
```env
PARQUET_DUCKDB_INPUT_DIRECTORY=../script/output
PARQUET_DUCKDB_OUTPUT_DIRECTORY=./output
PARQUET_DUCKDB_DATABASE_NAME=omop_cdm
PARQUET_DUCKDB_SCHEMA_NAME=omop
PARQUET_DUCKDB_MEMORY_LIMIT=4GB
PARQUET_DUCKDB_THREADS=4
PARQUET_DUCKDB_LOG_LEVEL=INFO
PARQUET_DUCKDB_BATCH_SIZE=10000
```

## Architecture

### Core Components

1. **`config.py`**: Configuration management using Pydantic for validation
2. **`db_utils.py`**: DuckDB database operations and OMOP schema management
3. **`loader.py`**: Parquet file discovery, analysis, and loading logic
4. **`parquet_to_duckdb.py`**: Main CLI application with Typer
5. **`test_queries.py`**: Data validation and test query execution

### Data Flow

1. **Discovery**: Scan input directory for Parquet files
2. **Analysis**: Analyze file structure and estimate OMOP table mapping
3. **Schema Creation**: Create DuckDB database with OMOP CDM schema
4. **Loading**: Load and transform data with appropriate mappings
5. **Validation**: Run data quality checks and test queries

## Data Mapping

### FHIR to OMOP Mapping

The loader includes basic mappings from FHIR Patient resources to OMOP Person table:

| FHIR Field | OMOP Field |
|------------|------------|
| id | person_id |
| identifier | person_source_value |
| gender | gender_source_value |
| birthDate | birth_datetime |
| deceasedDateTime | death_datetime |

### Custom Mappings

Extend the `map_columns_to_omop()` method in `loader.py` for custom field mappings:

```python
def map_columns_to_omop(self, columns: List[str], estimated_table: str) -> Dict[str, str]:
    # Add your custom mappings here
    custom_mappings = {
        'patient_id': 'person_id',
        'birth_date': 'birth_datetime',
        # Add more mappings as needed
    }
    # ... rest of mapping logic
```

## Data Validation

### Built-in Validations

The system includes comprehensive validation checks:

- **Table Existence**: Verify core OMOP tables are created
- **Data Quality**: Check for duplicates, null values, and data ranges
- **Data Types**: Validate column types match OMOP specifications
- **Referential Integrity**: Check foreign key relationships

### Running Validations

```bash
# Validate existing database
python parquet_to_duckdb.py validate

# Validate specific database file
python parquet_to_duckdb.py validate --database /path/to/database.duckdb
```

### Custom Validation Queries

Add custom validation queries in `test_queries.py`:

```python
def validate_custom_logic(self) -> Dict[str, Any]:
    # Your custom validation logic
    pass
```

## Performance Optimization

### DuckDB Configuration

The system automatically configures DuckDB for optimal performance:

- **Memory Management**: Configurable memory limits
- **Parallel Processing**: Multi-threaded execution
- **Columnar Storage**: Efficient analytical queries
- **Native Parquet**: Direct Parquet file reading

### Batch Processing

Configure batch processing for large datasets:

```python
# In config.py
batch_size: int = 50000  # Increase for larger datasets
```

### Hardware Recommendations

- **RAM**: 8GB+ recommended for large datasets
- **Storage**: SSD recommended for optimal I/O performance
- **CPU**: Multi-core processor for parallel processing

## Troubleshooting

### Common Issues

1. **Out of Memory**: Reduce memory limit or batch size
2. **File Not Found**: Check input directory paths
3. **Permission Errors**: Ensure write access to output directory
4. **Schema Conflicts**: Use `--force` flag to recreate database

### Debug Mode

Enable debug logging for detailed information:

```bash
python parquet_to_duckdb.py load --log-level DEBUG
```

### Log Files

Configure log file output:

```bash
export PARQUET_DUCKDB_LOG_FILE="./logs/parquet_loader.log"
```

## API Reference

### Configuration Class

```python
from config import DatabaseConfig

config = DatabaseConfig(
    input_directory="./data",
    output_directory="./output",
    database_name="my_db",
    memory_limit="8GB",
    threads=8
)
```

### Database Manager

```python
from db_utils import DuckDBManager

with DuckDBManager(config) as db_manager:
    db_manager.create_schema()
    db_manager.load_omop_ddl()
    # ... database operations
```

### Parquet Loader

```python
from loader import ParquetLoader

loader = ParquetLoader(config, db_manager)
results = loader.load_all_parquet_files()
```

## Testing

### Unit Tests

Run the validation suite:

```bash
python test_queries.py
```

### Sample Queries

The system includes sample OMOP queries for testing:

- Person demographics analysis
- Age and gender distributions
- Data completeness reports
- Observation counts and patterns

### Custom Tests

Add custom test queries in `test_queries.py`:

```python
def get_sample_queries(self) -> Dict[str, str]:
    queries = {
        "custom_query": "SELECT COUNT(*) FROM custom_table",
        # Add more queries
    }
    return queries
```

## Integration

### DBT Integration

The solution is designed to work with the existing DBT project in `transform_layer/`:

1. Load data using this tool
2. Run DBT transformations on the loaded data
3. Create analytical views and reports

### FHIR Integration

Works seamlessly with Pathling exports and other FHIR data sources:

- Supports FHIR R4 Patient resources
- Extensible to other FHIR resources
- Maintains FHIR source references

## Contributing

### Code Structure

Follow these patterns when extending the solution:

1. Use type hints for all functions
2. Include comprehensive docstrings
3. Add appropriate error handling and logging
4. Follow OMOP CDM conventions

### Adding New Features

1. Create feature branch
2. Add comprehensive tests
3. Update documentation
4. Submit pull request

## License

This solution is part of the FHIR Implementation Guide for Data Management project.

## Support

For issues and questions:

1. Check the troubleshooting section
2. Review log files with debug enabled
3. Consult the OMOP CDM documentation
4. Submit issues with detailed error messages