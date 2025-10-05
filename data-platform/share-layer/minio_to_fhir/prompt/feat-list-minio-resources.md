# MinIO Resource Lister

## Objective
Create a Python script to list all FHIR NDJSON files available in a MinIO bucket, grouped by resource type.

## Context

### Project Structure

minio_to_fhir project following directory structure:

```
data-platform/
└── share-layer/
      └── minio_to_fhir/
          ├── .env.example              # Configuration template
          ├── .env                      # Local config (gitignored)
          ├── .gitignore                # Git ignore rules
          ├── requirements.txt          # Python dependencies
          ├── README.md                 # Project documentation
          ├── common/                   # Shared utilities
          │   ├── __init__.py
          │   ├── config.py             # Configuration loader
          │   ├── minio_client.py       # MinIO client wrapper
          │   ├── fhir_client.py        # FHIR client wrapper
          │   └── utils.py              # Common utilities
          ├── list_minio_resources.py   # Feature 1: List (this feature)
          ├── download_minio_resources.py # Feature 2: Download
          ├── upload_to_fhir.py         # Feature 3: Upload
          ├── cleanup_ndjson_files.py   # Feature 4: Cleanup
          └── minio_to_fhir.py          # Feature 5: Orchestrator
```

### Input
- **Location**: MinIO bucket (configured in .env)
- **Format**: NDJSON files (*.ndjson)
- **Content**: FHIR R4 resources (Organization, Patient, Observation, etc.)

### Output
- Console output showing all NDJSON files grouped by resource type
- Statistics: total files, files per resource type

## Requirements

### 1. Configuration File (.env)
Use the `.env` file from previous features:
```bash
# MinIO Configuration
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=fhir-data
MINIO_SECURE=false

# HAPI FHIR Configuration (for future features)
FHIR_BASE_URL=http://localhost:8080/fhir
FHIR_AUTH_ENABLED=false
FHIR_USERNAME=
FHIR_PASSWORD=

# Directories (for future features)
DOWNLOAD_DIR=/tmp/fhir-download
UPLOAD_DIR=/tmp/fhir-upload
```

### 2. Command-Line Interface
```bash
# Basic usage
python list_minio_resources.py

# With custom bucket
python list_minio_resources.py --bucket my-bucket

# With detailed output
python list_minio_resources.py --verbose

# Help
python list_minio_resources.py --help
```

**Arguments**:
- `--bucket` / `-b`: Override bucket name from .env
- `--verbose` / `-v`: Show detailed file information (size, last modified)
- `--filter` / `-f`: Filter by resource type (e.g., "Patient,Observation")

### 3. Core Functionality

**Must do**:
- Load configuration from `.env` file
- Connect to MinIO with credentials
- Test bucket accessibility
- List all `.ndjson` files in bucket
- Extract resource type from filename (e.g., "Patient.ndjson" → "Patient")
- Group files by resource type
- Display organized output with statistics
- Handle errors gracefully

**Resource Type Detection**:
- Pattern: `{Prefix}{ResourceType}.ndjson`
- Examples:
  - `Patient.ndjson` → Patient
  - `MimicPatient.ndjson` → Patient
  - `Organization.ndjson` → Organization

### 4. Output Format

**Standard Output**:
```
=== MinIO Resource Lister ===
Bucket: fhir-data
Endpoint: localhost:9000

📋 Found 11 NDJSON files:

Organization (1 file):
  - Organization.ndjson

Location (1 file):
  - Location.ndjson

Medication (1 file):
  - Medication.ndjson

Patient (2 files):
  - Patient.ndjson
  - Patient_part2.ndjson

Observation (3 files):
  - Observation_labs.ndjson
  - Observation_vitals.ndjson
  - Observation_other.ndjson

Encounter (1 file):
  - Encounter.ndjson

Procedure (1 file):
  - Procedure.ndjson

Condition (1 file):
  - Condition.ndjson

=== Summary ===
Total files: 11
Resource types: 8
```

**Verbose Output** (with --verbose):
```
Organization (1 file, 45.2 KB):
  - Organization.ndjson (45.2 KB, modified: 2025-10-03 14:23:15)
```

### 5. Dependencies (requirements.txt)
```txt
minio>=7.2.0
python-dotenv>=1.0.0
```

### 6. Error Handling
- Graceful connection errors
- Missing bucket handling
- Invalid credentials handling
- Empty bucket handling
- Clear error messages

### 7. Code Structure

```python
#!/usr/bin/env python3
"""
MinIO Resource Lister
List all FHIR NDJSON files in MinIO bucket grouped by resource type.
"""

import os
import sys
import argparse
from pathlib import Path
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv
from datetime import datetime

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(bucket_override=None):
    """Load and validate environment variables."""
    pass

def create_minio_client(config):
    """Create and test MinIO client."""
    pass

def get_resource_type_from_filename(filename):
    """Extract FHIR resource type from filename."""
    # Handle patterns like:
    # - "Patient.ndjson" -> "Patient"
    # - "MimicPatient.ndjson" -> "Patient"
    # - "Patient_part1.ndjson" -> "Patient"
    pass

def list_ndjson_files(client, bucket_name, verbose=False):
    """List all NDJSON files grouped by resource type."""
    pass

def display_results(files_by_type, total_files, verbose=False):
    """Display organized results."""
    pass

def main():
    """Main entry point."""
    pass

if __name__ == "__main__":
    main()
```

## Success Criteria
✅ Script connects to MinIO successfully  
✅ Lists all .ndjson files in bucket  
✅ Groups files by resource type correctly  
✅ Displays clear, organized output  
✅ Shows summary statistics  
✅ Handles errors gracefully  
✅ Supports command-line arguments  
✅ Has helpful --help text  

## Deliverables
1. `list_minio_resources.py` - Main script
2. `.env.example` - Configuration template
3. `requirements.txt` - Python dependencies
4. Brief usage instructions in comments or docstring
```
