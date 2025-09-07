# FHIR to OMOP Data Exporter - Core Files

## 📁 **Core Python Modules**

### 🏗️ **Main Application Files**

| File | Purpose | Description |
|------|---------|-------------|
| `main.py` | CLI Entry Point | Command-line interface with rich console output |
| `fhir_exporter.py` | Core Exporter | Main orchestrator for FHIR to OMOP transformation |
| `config.py` | Configuration | Pydantic-based configuration management |

### 🔄 **Data Processing Modules**

| File | Purpose | Description |
|------|---------|-------------|
| `data_source.py` | Data Sources | Abstract data source with FHIR server & file implementations |
| `transformer.py` | ViewDefinition Processing | FHIR ViewDefinition transformer with post-processing |
| `post_processor.py` | Data Post-Processing | Data cleaning, validation, and concept mapping |
| `output_writer.py` | Multi-Format Output | Parquet, DuckDB, CSV, JSON export writers |

### 🛠️ **Supporting Modules**

| File | Purpose | Description |
|------|---------|-------------|
| `schema_validator.py` | OMOP Schema Validation | DDL-based schema compliance checking |
| `utils.py` | Utilities & Error Handling | Common utilities, logging, and error management |
| `pathling_config.py` | Pathling Configuration | Windows-compatible Pathling/Spark setup |

### 🦆 **DuckDB Integration**

| File | Purpose | Description |
|------|---------|-------------|
| `duckdb_omop_optimized.py` | DuckDB 1.3.2 Processor | Optimized OMOP processing with DuckDB 1.3.2 |

### 🎯 **Demo & Testing**

| File | Purpose | Description |
|------|---------|-------------|
| `demo_transformation.py` | Demonstration | Working demo of FHIR to OMOP transformation |

## 📚 **Documentation Files**

### 📖 **Main Documentation**

| File | Purpose | Description |
|------|---------|-------------|
| `README.md` | Project Overview | Main project documentation and usage guide |
| `README_FINAL.md` | Final Summary | Complete implementation summary |
| `DATA_EXPORTER_FILES.md` | This File | Overview of all core files |

### 📈 **Technical Documentation**

| File | Purpose | Description |
|------|---------|-------------|
| `DUCKDB_132_UPGRADE_SUMMARY.md` | DuckDB Upgrade | DuckDB 1.3.2 upgrade details and features |
| `SUCCESS_SUMMARY.md` | Implementation Success | Technical success summary and metrics |

### ⚙️ **Configuration Files**

| File | Purpose | Description |
|------|---------|-------------|
| `requirements.txt` | Dependencies | Python package requirements |
| `pytest.ini` | Test Configuration | Pytest configuration for test suite |
| `.gitignore` | Git Ignore | Git ignore patterns |

## 🧪 **Test Suite**

### 📁 **Test Organization**
```
tests/
├── README.md                          # Test documentation
├── TEST_ORGANIZATION_SUMMARY.md      # Test organization summary
├── conftest.py                       # Pytest fixtures
├── integration/                      # End-to-end tests
├── unit/                            # Component tests  
├── performance/                     # Performance tests
└── samples/                         # Sample tests & debug tools
```

## 🚀 **Quick Start Files**

### **Essential Files for Basic Usage**
1. `main.py` - Run the data exporter
2. `config.py` - Configure the exporter  
3. `requirements.txt` - Install dependencies
4. `README.md` - Read the documentation

### **Command to Start**
```bash
# Install dependencies
pip install -r requirements.txt

# Run basic export
python main.py --tables Person --formats parquet json

# See help
python main.py --help
```

## 📊 **File Statistics**

- **Python Files**: 11 core modules
- **Documentation Files**: 6 markdown files  
- **Test Files**: 18 test files across 4 categories
- **Configuration Files**: 3 config files
- **Total Lines of Code**: ~2000+ lines (estimated)

## 🎯 **File Dependencies**

### **Core Dependencies**
```
main.py
├── fhir_exporter.py
│   ├── config.py
│   ├── data_source.py
│   ├── transformer.py
│   ├── post_processor.py
│   ├── output_writer.py
│   ├── schema_validator.py
│   └── utils.py
└── pathling_config.py (optional)
```

### **DuckDB Integration**
```
duckdb_omop_optimized.py (standalone)
├── Uses DuckDB 1.3.2 directly
├── Independent of main pipeline  
└── Optimized for analytics
```

## 🔧 **Development Files**

### **For Development/Debugging**
- `demo_transformation.py` - Working demo
- `pathling_config.py` - Pathling setup helper
- `tests/samples/debug_*.py` - Debug utilities

### **For Production**
- `main.py` - Primary entry point
- `fhir_exporter.py` - Core functionality  
- `config.py` - Production configuration
- All supporting modules in data processing section

## 📦 **Deployment Package**

### **Minimum Files for Deployment**
```
data-exporter/
├── main.py
├── fhir_exporter.py  
├── config.py
├── data_source.py
├── transformer.py
├── post_processor.py
├── output_writer.py
├── schema_validator.py
├── utils.py
├── requirements.txt
└── README.md
```

### **Full Package (Recommended)**
- All Python modules listed above
- Complete documentation
- Test suite for validation
- DuckDB optimization module
- Demo and debug utilities

---

**Last Updated**: September 7, 2025  
**Python Version**: 3.9+  
**DuckDB Version**: 1.3.2  
**Pathling Version**: 8.0.1+