# FHIR to OMOP Data Exporter - Test Suite

## 📁 Test Organization

This directory contains comprehensive tests for the FHIR to OMOP Data Exporter, organized by test type and complexity.

### 🗂️ Directory Structure

```
tests/
├── README.md                    # This documentation
├── integration/                 # End-to-end integration tests
│   ├── test_complete_pipeline.py
│   ├── test_fhir_server.py
│   └── test_omop_export.py
├── unit/                       # Unit tests for individual components
│   ├── test_config.py
│   ├── test_data_source.py
│   └── test_post_processor.py
├── performance/                # Performance and load tests
│   ├── test_duckdb_performance.py
│   └── test_large_dataset.py
├── samples/                    # Sample data and minimal tests
│   ├── test_minimal.py
│   └── test_samples.py
└── conftest.py                 # Pytest configuration and fixtures
```

## 🧪 Test Categories

### 1. **Integration Tests** (`tests/integration/`)
Full end-to-end tests that validate the complete data transformation pipeline.

| Test File | Purpose | Description |
|-----------|---------|-------------|
| `test_complete_pipeline.py` | Complete workflow | Tests FHIR → ViewDefinition → OMOP → Export pipeline |
| `test_fhir_server.py` | FHIR server integration | Tests bulk export from HAPI FHIR server |
| `test_omop_export.py` | OMOP export validation | Tests OMOP Person table generation and validation |

### 2. **Unit Tests** (`tests/unit/`)
Focused tests for individual components and modules.

| Test File | Purpose | Description |
|-----------|---------|-------------|
| `test_config.py` | Configuration validation | Tests configuration loading and validation |
| `test_data_source.py` | Data source implementations | Tests FHIR server and file system data sources |
| `test_post_processor.py` | Post-processing pipeline | Tests data cleaning and transformation steps |

### 3. **Performance Tests** (`tests/performance/`)
Performance benchmarks and load testing.

| Test File | Purpose | Description |
|-----------|---------|-------------|
| `test_duckdb_performance.py` | DuckDB 1.3.2 performance | Benchmarks DuckDB operations and analytics |
| `test_large_dataset.py` | Large dataset handling | Tests with realistic data volumes |

### 4. **Sample Tests** (`tests/samples/`)
Simple validation tests with sample data.

| Test File | Purpose | Description |
|-----------|---------|-------------|
| `test_minimal.py` | Basic functionality | Minimal test with sample patients |
| `test_samples.py` | Sample data validation | Tests with various sample data scenarios |

## 🚀 Running Tests

### Prerequisites
```bash
pip install -r requirements.txt
pip install pytest pytest-cov pytest-mock
```

### Run All Tests
```bash
cd data-plateform/share-layer/data-exporter
python -m pytest tests/ -v
```

### Run Specific Test Categories
```bash
# Integration tests only
python -m pytest tests/integration/ -v

# Unit tests only  
python -m pytest tests/unit/ -v

# Performance tests only
python -m pytest tests/performance/ -v

# Sample tests only
python -m pytest tests/samples/ -v
```

### Run Individual Tests
```bash
# Test complete pipeline
python -m pytest tests/integration/test_complete_pipeline.py -v

# Test DuckDB performance
python -m pytest tests/performance/test_duckdb_performance.py -v
```

### Coverage Report
```bash
python -m pytest tests/ --cov=. --cov-report=html
```

## 📊 Test Data

### FHIR Patient Sample Data
The tests use realistic French healthcare context data:

```json
{
  "resourceType": "Patient",
  "id": "patient-001",
  "gender": "male",
  "birthDate": "1980-01-15",
  "address": [{
    "id": "addr-001",
    "city": "Paris",
    "country": "France"
  }],
  "managingOrganization": {
    "reference": "Organization/aphp-hopital-001"
  }
}
```

### Expected OMOP Person Output
```json
{
  "person_id": "patient-001",
  "gender_concept_id": 0,
  "year_of_birth": 1980,
  "birth_datetime": "1980-01-15T00:00:00",
  "location_id": "addr-001",
  "care_site_id": "Organization/aphp-hopital-001",
  "person_source_value": "patient-001",
  "gender_source_value": "male"
}
```

## ✅ Test Validation Criteria

### Integration Tests
- ✅ FHIR server connectivity and bulk export
- ✅ ViewDefinition loading and parsing
- ✅ Patient → Person transformation completeness
- ✅ Multi-format export (Parquet, DuckDB, CSV, JSON)
- ✅ Schema validation against OMOP CDM 5.4
- ✅ Data quality and completeness checks

### Unit Tests
- ✅ Configuration parameter validation
- ✅ Data source error handling
- ✅ Post-processing pipeline steps
- ✅ Output writer format compliance
- ✅ Schema validator DDL parsing

### Performance Tests
- ✅ DuckDB 1.3.2 query optimization
- ✅ Large dataset processing (1K+ patients)
- ✅ Memory usage within limits
- ✅ Export performance benchmarks
- ✅ Index effectiveness validation

## 🐛 Test Environment Requirements

### Software Dependencies
- Python 3.9+
- DuckDB 1.3.2
- Pathling 8.0.1+
- Pytest 7.0+

### Optional Components
- HAPI FHIR Server (for integration tests)
- Docker (for containerized testing)
- Large sample datasets (for performance tests)

### Environment Variables
```bash
export FHIR_ENDPOINT_URL="http://localhost:8080/fhir"
export OUTPUT_DIR="./test_output"
export VIEW_DEFINITIONS_DIR="view-definition/omop"
```

## 📈 Test Metrics

### Success Criteria
- **Unit Tests**: 95% pass rate minimum
- **Integration Tests**: 90% pass rate minimum  
- **Performance Tests**: Within 2x baseline performance
- **Code Coverage**: 80% minimum

### Performance Benchmarks
- **Small Dataset** (10 patients): < 30 seconds
- **Medium Dataset** (100 patients): < 2 minutes
- **Large Dataset** (1000+ patients): < 10 minutes

## 🔧 Troubleshooting

### Common Issues

#### Windows Unicode Encoding
```python
# Fix for Windows console encoding issues
import sys
sys.stdout.reconfigure(encoding='utf-8')
```

#### Pathling/Spark Timeout
```bash
# Increase timeout for Spark initialization
export SPARK_CONF_spark.sql.execution.arrow.pyspark.enabled=false
```

#### DuckDB Memory Issues  
```python
# Configure DuckDB memory limits
conn.execute("SET memory_limit='2GB'")
```

## 📝 Test Documentation

Each test file includes:
- **Purpose**: What the test validates
- **Setup**: Required configuration and data
- **Expected Results**: Success criteria
- **Cleanup**: Resource management
- **Error Scenarios**: Expected failure modes

## 🎯 Contributing

When adding new tests:
1. Place in appropriate category directory
2. Follow naming convention: `test_<component>_<purpose>.py`
3. Include docstring with test purpose and setup
4. Add sample data to `tests/samples/` if needed
5. Update this README with test description
6. Ensure tests are idempotent and isolated

---

**Test Suite Version**: 1.0  
**Last Updated**: September 7, 2025  
**DuckDB Version**: 1.3.2  
**Pathling Version**: 8.0.1+