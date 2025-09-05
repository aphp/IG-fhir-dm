# FHIR Data Loader - PostgreSQL to MinIO S3

A Python application for transferring FHIR data from PostgreSQL Semantic Layer to MinIO Object Storage in NDJSON format.

## Features

- Extract FHIR resources from PostgreSQL database
- Transform database records to FHIR-compliant JSON format
- Upload data to MinIO S3 storage in NDJSON (Newline Delimited JSON) format
- Parallel processing with configurable batch sizes
- Progress tracking and comprehensive logging
- Export summaries and statistics
- Support for all major FHIR resource types

## Prerequisites

- Python 3.8+
- PostgreSQL database with FHIR Semantic Layer schema
- MinIO server (local or remote)
- Required Python packages (see requirements.txt)

## Installation

1. Navigate to the bucket-s3 directory:
```bash
cd bucket-s3
```

2. Install required packages:
```bash
pip install -r requirements.txt
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Configuration

Edit the `.env` file with your specific configuration:

### Database Configuration
- `DBT_HOST`: PostgreSQL host (default: localhost)
- `DBT_PORT`: PostgreSQL port (default: 5432)
- `DBT_USER`: Database username
- `DBT_PASSWORD`: Database password
- `DBT_DATABASE`: Database name (default: data_core)
- `DBT_SCHEMA`: Schema name (default: dbt_fhir_semantic_layer)

### MinIO Configuration
- `MINIO_ENDPOINT`: MinIO server endpoint (default: 127.0.0.1:9000)
- `MINIO_ACCESS_KEY`: MinIO access key
- `MINIO_SECRET_KEY`: MinIO secret key
- `MINIO_SECURE`: Use HTTPS (default: false)
- `MINIO_BUCKET_NAME`: Target bucket name (default: fhir-data)

### Loader Configuration
- `BATCH_SIZE`: Records per batch (default: 1000)
- `MAX_WORKERS`: Parallel workers (default: 4)
- `LOG_LEVEL`: Logging level (default: INFO)
- `OUTPUT_FORMAT`: Output format - ndjson or json (default: ndjson)
- `EXPORT_TABLES`: Comma-separated list of tables to export

## Usage

### Run the loader

```bash
python loader.py
```

### Run with custom configuration

```bash
# Override specific settings
export BATCH_SIZE=500
export MAX_WORKERS=2
python loader.py
```

## Output Structure

Data is organized in MinIO with the following structure:

```
fhir-data/
├── fhir/
│   ├── Patient/
│   │   └── [export_id]/
│   │       ├── Patient_0000.ndjson
│   │       ├── Patient_0001.ndjson
│   │       └── ...
│   ├── Encounter/
│   │   └── [export_id]/
│   │       └── ...
│   └── ...
├── exports/
│   └── [export_id]/
│       └── summary.json
└── manifests/
    └── [batch_id]/
        └── [resource]_manifest.json
```

## FHIR Resources Supported

- Patient
- Encounter
- Condition
- Procedure
- Observation
- MedicationRequest
- MedicationAdministration
- Organization
- Location
- Practitioner
- PractitionerRole
- EpisodeOfCare
- Claim

## Architecture

### Modules

- **config.py**: Configuration management using Pydantic
- **database.py**: PostgreSQL connection and data extraction
- **storage.py**: MinIO S3 storage operations
- **transformer.py**: FHIR data transformation logic
- **loader.py**: Main orchestration and execution

### Data Flow

1. Connect to PostgreSQL and MinIO
2. Validate tables and configuration
3. For each table:
   - Extract data in batches
   - Transform to FHIR format
   - Upload to MinIO as NDJSON
4. Generate export summary
5. Clean up connections

## Development

### Running Tests

```bash
pytest tests/
```

### Code Quality

```bash
# Type checking
mypy .

# Linting
pylint *.py

# Formatting
black .
```

## Monitoring

### Logs

Logs are stored in `bucket-s3/logs/` with rotation and retention policies.

### Export Summary

Each export generates a summary JSON file containing:
- Export ID and timestamp
- Configuration used
- Table-level statistics
- Total records processed
- Error details (if any)

## Troubleshooting

### Common Issues

1. **Connection refused to PostgreSQL**
   - Check database credentials in .env
   - Verify PostgreSQL is running
   - Check network connectivity

2. **MinIO connection error**
   - Verify MinIO server is running
   - Check endpoint and credentials
   - Ensure bucket exists or can be created

3. **Memory issues with large tables**
   - Reduce BATCH_SIZE in configuration
   - Increase available memory
   - Use fewer parallel workers

4. **Slow performance**
   - Increase BATCH_SIZE for better throughput
   - Add more parallel workers
   - Check network bandwidth

## Performance Considerations

- **Batch Size**: Larger batches improve throughput but use more memory
- **Parallel Workers**: More workers can speed up processing but increase database load
- **Network**: Ensure adequate bandwidth between database, application, and MinIO
- **Storage**: Use SSD storage for MinIO data directory for better performance

## Security

- Store credentials securely (use environment variables or secrets management)
- Use TLS/SSL for production deployments
- Implement access controls on MinIO buckets
- Audit data access and exports
- Encrypt sensitive data at rest and in transit

## License

This project is part of the FHIR Implementation Guide for Data Management.

## Support

For issues or questions, please refer to the main project documentation or create an issue in the repository.