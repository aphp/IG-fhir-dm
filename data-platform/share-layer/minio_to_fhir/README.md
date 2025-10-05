# MinIO to FHIR Data Pipeline

Modular Python pipeline for transferring FHIR NDJSON data from MinIO storage to HAPI FHIR server.

## Features

1. **List Resources** - View all NDJSON files in MinIO bucket
2. **Download Resources** - Download FHIR files from MinIO
3. **Upload to FHIR** - Batch upload resources to HAPI FHIR server
4. **Cleanup Files** - Remove temporary files after processing
5. **Full Pipeline** - Orchestrate complete workflow in one command

## Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Create configuration
cp .env.example .env
# Edit .env with your settings
```

## Configuration

Edit `.env` file with your MinIO and FHIR server settings:
- MinIO endpoint, credentials, and bucket name
- HAPI FHIR server URL and authentication
- Directory paths and batch size

## Usage

See individual script documentation:
- `python list_minio_resources.py --help`
- `python download_minio_resources.py --help`
- `python upload_to_fhir.py --help`
- `python cleanup_ndjson_files.py --help`
- `python minio_to_fhir_pipeline.py --help`

## Project Structure

```
minio_to_fhir/
├── common/              # Shared utilities
├── *.py                 # Feature scripts
├── .env                 # Configuration (not in git)
├── .env.example         # Configuration template
└── requirements.txt     # Dependencies
```

## FHIR Resource Order

Resources are loaded in dependency order to maintain referential integrity:
1. Organization
2. Location
3. Medication
4. Specimen
5. Patient
6. Encounter
7. Clinical Resources (Procedure, Observation, Condition, etc.)
