# EHR to FHIR Semantic Layer Transformation Pipeline

This DBT project implements a comprehensive data transformation pipeline that converts Electronic Health Record (EHR) data into a FHIR R4 compliant semantic layer, following French healthcare standards and InteropSanté profiles.

## 🎯 Project Overview

**Purpose**: Transform raw EHR data into standardized FHIR resources for healthcare interoperability and analytics.

**Architecture**: Medallion (Bronze/Silver/Gold) with staging → intermediate → marts layers.

**Standards Compliance**: 
- FHIR R4
- French InteropSanté profiles
- INS-NIR patient identifiers
- ICD-10, LOINC, CCAM, ATC terminologies

## 📊 Data Flow Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   EHR Database  │    │  Staging Layer  │    │ Intermediate    │    │  FHIR Marts     │
│   (Source)      │───▶│   (Bronze)      │───▶│   (Silver)      │───▶│   (Gold)        │
│                 │    │                 │    │                 │    │                 │
│ • patient       │    │ • stg_ehr__*    │    │ • int_*         │    │ • fhir_*        │
│ • donnees_pmsi  │    │ • Data cleaning │    │ • Business      │    │ • FHIR R4       │
│ • diagnostics   │    │ • Validation    │    │   logic         │    │   compliant     │
│ • actes         │    │ • Standardize   │    │ • Terminology   │    │ • Semantic      │
│ • biologie      │    │ • Type casting  │    │   mapping       │    │   layer         │
│ • exposition_*  │    │                 │    │ • Quality       │    │                 │
│ • dossier_soins │    │                 │    │   scoring       │    │                 │
│ • style_vie     │    │                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🏗️ Project Structure

```
transform_layer/
├── models/
│   ├── staging/                   # Bronze layer - source data extraction
│   │   ├── _sources.yml           # Source definitions
│   │   ├── _staging__models.yml   # Staging model documentation
│   │   ├── stg_ehr__patient.sql
│   │   ├── stg_ehr__donnees_pmsi.sql
│   │   ├── stg_ehr__diagnostics.sql
│   │   ├── stg_ehr__actes.sql
│   │   ├── stg_ehr__biologie.sql
│   │   ├── stg_ehr__exposition_medicamenteuse.sql
│   │   ├── stg_ehr__dossier_soins.sql
│   │   └── stg_ehr__style_vie.sql
│   │
│   ├── intermediate/               # Silver layer - business transformations
│   │   ├── _intermediate__models.yml
│   │   ├── int_patient_identifiers.sql
│   │   ├── int_encounter_episodes.sql
│   │   ├── int_condition_mapping.sql
│   │   └── int_observation_unified.sql
│   │
│   └── marts/                     # Gold layer - FHIR semantic layer
│       ├── fhir/
│       │   ├── _fhir__models.yml
│       │   ├── fhir_patient.sql
│       │   ├── fhir_encounter.sql
│       │   ├── fhir_condition.sql
│       │   ├── fhir_observation.sql
│       │   ├── fhir_procedure.sql
│       │   └── fhir_medication_request.sql
│       └── monitoring/
│           └── data_quality_summary.sql
├── tests/                        # Data quality tests
├── seeds/                        # Test data
├── dbt_project.yml               # Project configuration
├── profiles.yml                  # Database connections
├── validate_pipeline.ps1         # Validation script
└── PIPELINE_README.md            # This file
```

## 🎭 FHIR Resource Mapping

### Source → FHIR Resource Mapping

| EHR Source Table | FHIR Resource | Terminology | Description |
|------------------|---------------|-------------|-------------|
| `patient` | `fhir_patient` | INS-NIR | Patient demographics with French healthcare identifiers |
| `donnees_pmsi` | `fhir_encounter` | PMSI codes | Hospital episodes and encounters |
| `diagnostics` | `fhir_condition` | ICD-10 | Medical diagnoses and conditions |
| `actes` | `fhir_procedure` | CCAM | Medical procedures and interventions |
| `biologie` | `fhir_observation` | LOINC | Laboratory test results |
| `dossier_soins` | `fhir_observation` | LOINC | Vital signs and nursing observations |
| `style_vie` | `fhir_observation` | LOINC | Lifestyle factors and social determinants |
| `exposition_medicamenteuse` | `fhir_medication_request` | ATC | Medication prescriptions and exposures |

### Key FHIR Profiles Used

- **Patient**: [FrPatient](http://interopsante.org/fhir/StructureDefinition/FrPatient)
- **Encounter**: [FrEncounter](http://interopsante.org/fhir/StructureDefinition/FrEncounter)
- **Condition**: [FrCondition](http://interopsante.org/fhir/StructureDefinition/FrCondition)
- **Observation**: [FrObservation](http://interopsante.org/fhir/StructureDefinition/FrObservation)
- **Procedure**: [FrProcedure](http://interopsante.org/fhir/StructureDefinition/FrProcedure)
- **MedicationRequest**: [FrMedicationRequest](http://interopsante.org/fhir/StructureDefinition/FrMedicationRequest)

## 🚀 Quick Start

### Prerequisites

1. **DBT Core** installed (>= 1.6.0)
2. **PostgreSQL** connection to:
   - EHR source database (`ehr`)
   - Target database (`data_core`)
3. **Environment variables** configured:
   ```bash
   DBT_HOST=localhost
   DBT_PORT=5432
   DBT_USER=your_username
   DBT_PASSWORD=your_password
   DBT_DATABASE=data_core
   DBT_SCHEMA=dbt
   ```

### Installation & Setup

```bash
# 1. Navigate to project directory
cd transform_layer

# 2. Install DBT dependencies
dbt deps

# 3. Test database connections
dbt debug

# 4. Load test data (optional)
dbt seed

# 5. Run complete pipeline
dbt run

# 6. Run data quality tests
dbt test

# 7. Generate documentation
dbt docs generate
dbt docs serve
```

### Automated Validation

Use the provided PowerShell script for comprehensive validation:

```powershell
# Full validation with tests
.\validate_pipeline.ps1

# Full refresh (rebuild all models)
.\validate_pipeline.ps1 -FullRefresh

# Skip tests for faster execution
.\validate_pipeline.ps1 -SkipTests

# Load seeds only for testing
.\validate_pipeline.ps1 -SeedsOnly
```

## 🏥 French Healthcare Standards Implementation

### Patient Identifiers (INS-NIR)

The pipeline implements French national healthcare identifier standards:

- **INS-C/INS-A**: Identifiant National de Santé (priority identifier)
- **NIR**: Numéro d'Inscription au Répertoire (fallback identifier)
- **Validation**: Format and checksum validation
- **OIDs**: Official French healthcare OID references

### Terminology Mappings

| Standard | System URI | Usage |
|----------|------------|-------|
| ICD-10 | `http://hl7.org/fhir/sid/icd-10` | Diagnosis codes |
| LOINC | `http://loinc.org` | Laboratory and vital signs |
| CCAM | French CCAM system | Medical procedures |
| ATC | `http://www.whocc.no/atc` | Medication classification |
| SNOMED CT | `http://snomed.info/sct` | Clinical concepts |

### PMSI Integration

Hospital episode data follows PMSI (Programme de Médicalisation des Systèmes d'Information) standards:

- **Admission modes**: Mapped to FHIR encounter classes
- **Discharge dispositions**: Standardized coding
- **Length of stay**: Calculated and validated
- **Service departments**: Mapped to SNOMED CT

## 📊 Data Quality Framework

### Quality Metrics

The pipeline implements comprehensive data quality monitoring:

- **Completeness**: Required field population rates
- **Validity**: Format and range validation
- **Consistency**: Cross-table referential integrity
- **Accuracy**: Terminology compliance
- **Timeliness**: Data freshness indicators

### Quality Scoring

**Patient Quality Score** (0-10 points):
- INS identifier present: +3 points
- Valid NIR format: +2 points
- Complete name: +1 point
- Valid birth date: +1 point
- Valid gender: +1 point
- Geographic data: +1 point
- Valid address: +1 point

**Quality Levels**:
- **High**: Score ≥ 5 points
- **Medium**: Score 3-4 points  
- **Low**: Score < 3 points

### Monitoring Views

Query the data quality summary:

```sql
SELECT * FROM data_core.fhir_semantic_layer.data_quality_summary
ORDER BY resource_type;
```

## 🧪 Testing Strategy

### Test Categories

1. **Source Tests**: Data freshness and row counts
2. **Staging Tests**: Data type validation and completeness
3. **Intermediate Tests**: Business logic validation
4. **Marts Tests**: FHIR compliance and referential integrity
5. **Cross-cutting Tests**: End-to-end data lineage

### Key Test Cases

- ✅ All patients have valid identifiers
- ✅ All encounters reference valid patients  
- ✅ All conditions have valid ICD-10 codes
- ✅ All observations have LOINC codes
- ✅ All procedures have CCAM codes
- ✅ All medication requests have ATC codes
- ✅ FHIR resource IDs are globally unique
- ✅ Referential integrity maintained

## 🔧 Configuration

### Environment Variables

```bash
# Database connection
DBT_HOST=localhost
DBT_PORT=5432
DBT_USER=postgres
DBT_PASSWORD=password
DBT_DATABASE=data_core
DBT_SCHEMA=dbt

# Pipeline configuration
FHIR_VERSION=4.0.1
DEFAULT_ORGANIZATION_ID=fr-aphp
DEFAULT_FACILITY_ID=facility-default
```

### DBT Variables

Configure in `dbt_project.yml`:

```yaml
vars:
  # FHIR resource ID prefixes
  patient_id_prefix: 'pat-'
  encounter_id_prefix: 'enc-'
  condition_id_prefix: 'con-'
  observation_id_prefix: 'obs-'
  medication_request_id_prefix: 'medreq-'
  procedure_id_prefix: 'proc-'
  
  # Data quality thresholds
  min_patient_count: 1
  max_null_percentage: 10
  
  # Performance settings
  batch_size: 10000
  max_parallel_jobs: 4
```

## 📈 Performance Optimization

### Model Materialization Strategy

- **Views**: Staging models (source data extraction)
- **Tables**: Intermediate models (business logic)
- **Tables**: Marts models (FHIR resources)
- **Incremental**: Large fact tables (future enhancement)

### Indexing Strategy

FHIR tables include strategic indexes:
- Primary key (`id`) - unique index
- Last updated (`last_updated`) - for change tracking
- Source identifiers - for traceability

### Query Optimization

- Cross-database queries optimized with proper joins
- JSONB operations minimized in critical paths
- Window functions used efficiently for ranking
- CTEs used for complex transformations

## 🔒 Security & Privacy

### Data Protection

- **No PII exposure**: Raw identifiers transformed to FHIR format
- **Audit trails**: Complete data lineage maintained  
- **Access control**: Database-level permissions required
- **Encryption**: Database connections use SSL/TLS

### Compliance Considerations

- **GDPR**: Patient data pseudonymization capabilities
- **HDS**: Healthcare data hosting compliance ready
- **Interoperability**: FHIR R4 standard compliance
- **Audit**: Complete transformation audit trail

## 🚨 Troubleshooting

### Common Issues

**1. Database Connection Errors**
```bash
# Test connections
dbt debug

# Check environment variables
echo $DBT_HOST $DBT_USER $DBT_DATABASE
```

**2. Source Data Access Issues**
```sql
-- Test EHR database access
SELECT count(*) FROM ehr.public.patient;
```

**3. Memory Issues with Large Datasets**
```yaml
# Adjust batch size in dbt_project.yml
vars:
  batch_size: 5000  # Reduce from default 10000
```

**4. JSONB Performance Issues**
```sql
-- Monitor query performance
EXPLAIN ANALYZE SELECT * FROM fhir_patient LIMIT 100;
```

### Debug Commands

```bash
# Comprehensive debugging
dbt debug

# Parse models without execution
dbt parse

# Run specific model with debug output
dbt run --select fhir_patient --debug

# Test specific model
dbt test --select fhir_patient

# Compile SQL without running
dbt compile --select fhir_patient
```

## 📚 Additional Resources

### Documentation

- [DBT Documentation](https://docs.getdbt.com/)
- [FHIR R4 Specification](http://hl7.org/fhir/R4/)
- [InteropSanté Profiles](http://interopsante.org/fhir/)
- [French Healthcare Standards](https://esante.gouv.fr/)

### Support & Contribution

- **Issues**: Report in project repository
- **Enhancements**: Submit pull requests with tests
- **Questions**: Contact the data engineering team

---

**Last Updated**: August 2024  
**Version**: 1.0.0  
**Maintainer**: DBT Healthcare Data Team