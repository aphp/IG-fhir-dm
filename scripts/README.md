# FHIR QuestionnaireResponse Database Population Scripts

This directory contains scripts for processing FHIR QuestionnaireResponse data and populating a PostgreSQL health data warehouse.

## Files Overview

### Database Schema Scripts
- **`questionnaire-core-ddl.sql`** - Original PostgreSQL DDL schema (MySQL syntax issues)
- **`questionnaire-core-ddl-fixed.sql`** - Corrected PostgreSQL DDL schema (production ready)
- **`questionnaire-core-population.sql`** - Static SQL insertion script with sample data

### Python Processing Scripts
- **`questionnaire_populate_db.py`** - Main Python pandas script for FHIR data processing
- **`requirements.txt`** - Python dependencies
- **`.env.example`** - Configuration template

## Quick Start

### 1. Database Setup

```bash
# Create and populate the database schema
PGPASSWORD=test psql -h localhost -U test -d test -f questionnaire-core-ddl-fixed.sql
```

### 2. Python Environment Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Copy and configure environment variables
cp .env.example .env
# Edit .env with your database credentials and encryption key
```

### 3. Run the Python Script

```bash
# Process FHIR QuestionnaireResponse file
python questionnaire_populate_db.py
```

## Database Schema

The database contains 15 tables for French healthcare data (EDSH):

### Core Patient Data
- `identite_patient` - Patient identity with French NIR
- `donnees_socio_demographiques` - Demographics (age, gender)
- `geocodage` - Geographic coordinates

### Clinical Data
- `diagnostics` - Medical diagnostics (ICD-10)
- `actes` - Medical procedures (CCAM)
- `donnees_pmsi` - PMSI hospital stay data
- `dossier_soins` - Care records

### Laboratory Results
- `fonction_renale` - Renal function (urea, creatinine, GFR)
- `hemogramme` - Complete blood count (CBC)
- `bilan_hepatique` - Hepatic function tests
- `biologie_autres` - Other laboratory tests

### Medication Management
- `exposition_medicamenteuse` - Medication exposure (ATC codes)
- `posologie_detail` - Dosage details
- `dosage` - Individual administration records

### Lifestyle Data
- `style_vie` - Lifestyle factors (tobacco, alcohol, physical activity)

## Python Script Features

### 🔐 Security Features
- **Field-level encryption** for PII/PHI data (NIR, names)
- **SQL injection prevention** through parameterized queries
- **Audit logging** for all database operations
- **GDPR compliance** support

### 🏥 Healthcare Data Validation
- **French NIR format validation** (13 or 15 digits)
- **LOINC code validation** for laboratory tests
- **ICD-10 code validation** for diagnostics
- **Clinical range validation** for lab values
- **Date constraint validation** (birth dates, temporal consistency)

### 📊 Data Processing
- **Pandas DataFrames** for efficient data manipulation
- **Batch processing** with configurable chunk sizes
- **Foreign key dependency management** (proper insertion order)
- **Transaction management** with rollback on errors
- **Memory optimization** with categorical data types

### 🔍 Monitoring & Logging
- **Structured logging** with JSON output
- **Processing statistics** tracking
- **Error categorization** and reporting
- **Performance metrics** collection

## Configuration

### Environment Variables

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=test
DB_USER=test
DB_PASSWORD=test
DB_SSLMODE=prefer

# Security
FHIR_ENCRYPTION_KEY=your-encryption-key-here

# Processing
BATCH_SIZE=1000
MAX_WORKERS=4
```

### Generate Encryption Key

```bash
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

## FHIR Data Mapping

The script maps FHIR QuestionnaireResponse linkIds to database tables:

### Patient Identity (`identite_patient`)
- `8605698058770` → `nom_patient` (Last name)
- `6214879623503` → `prenom_patient` (First name)  
- `5711960356160` → `nir` (French National Insurance Number)
- `5036133558154` → `date_naissance` (Birth date)

### Geographic Data (`geocodage`)
- `3709843054556` → `latitude`
- `7651448032665` → `longitude`
- `1185653257776` → `date_recueil` (Collection date)

### Demographics (`donnees_socio_demographiques`)
- `8164976487070` → `age`
- `1690778867802` → `date_recueil_age` (Age collection date)
- `3894630481120` → `sexe` (Gender from valueCoding.display)

## Error Handling

The script provides comprehensive error handling:

### Validation Errors
- **Data format errors** (invalid NIR, dates, coordinates)
- **Healthcare standard violations** (LOINC, ICD-10 codes)
- **Business rule violations** (temporal inconsistencies)

### Database Errors
- **Connection failures** with retry logic
- **Constraint violations** with detailed logging
- **Transaction rollback** on partial failures

### Processing Errors
- **JSON parsing errors** with file path logging
- **Memory errors** with batch size recommendations
- **Configuration errors** with clear error messages

## Production Considerations

### Security
- Use proper key management service for encryption keys
- Enable SSL/TLS for database connections
- Implement row-level security (RLS) for patient data access
- Regular security audits and penetration testing

### Performance
- Configure PostgreSQL connection pooling
- Monitor memory usage during large file processing
- Use database partitioning for time-series data
- Implement caching for reference data lookups

### Compliance
- Ensure GDPR compliance for EU patient data
- Implement data retention policies
- Maintain audit trails for all data operations
- Regular data quality assessments

### Monitoring
- Set up alerts for processing failures
- Monitor data quality metrics
- Track processing performance trends
- Regular backup and recovery testing

## Troubleshooting

### Common Issues

1. **Module not found errors**
   ```bash
   pip install -r requirements.txt
   ```

2. **Database connection errors**
   - Check database configuration in `.env`
   - Verify PostgreSQL is running and accessible
   - Test connection with `psql` command

3. **Validation errors**
   - Check FHIR QuestionnaireResponse format
   - Verify linkId mappings are correct
   - Review error logs for specific validation failures

4. **Memory errors**
   - Reduce `BATCH_SIZE` in configuration
   - Increase available system memory
   - Process files individually rather than in batch

### Getting Help

For issues related to:
- **FHIR standards**: Contact HL7 FHIR community
- **French healthcare codes**: Refer to ANS (Agence du Numérique en Santé)
- **Database performance**: PostgreSQL community resources
- **Python/Pandas**: Official documentation and Stack Overflow

## License

This script is part of the APHP FHIR Implementation Guide project.