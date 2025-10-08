# MinIO Resource Lister - Simplified

## Objective
Create a Python script to list all FHIR NDJSON files in a MinIO bucket.

## Project Structure

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
          └── list_minio_resources.py   # This script
```

## Configuration (.env)
```bash
# MinIO Configuration
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=fhir-data
MINIO_SECURE=false
```

## Command-Line Interface
```bash
# Basic usage
python list_minio_resources.py

# With custom bucket
python list_minio_resources.py --bucket my-bucket

# With detailed output (size, modified date)
python list_minio_resources.py --verbose

# Help
python list_minio_resources.py --help
```

**Arguments**:
- `--bucket` / `-b`: Override bucket name from .env
- `--verbose` / `-v`: Show file size and last modified date

## Core Functionality

- Load configuration from `.env` file
- Connect to MinIO
- List all `.ndjson` files in bucket
- Display results with count
- Handle errors gracefully

## Output Format

**Standard Output**:
```
=== MinIO Resource Lister ===
Bucket: fhir-data
Endpoint: localhost:9000

📋 NDJSON Files:
  - Organization.ndjson
  - Location.ndjson
  - Patient.ndjson
  - Patient_part2.ndjson
  - Observation_labs.ndjson
  - Observation_vitals.ndjson
  - Encounter.ndjson
  - Procedure.ndjson

Total files: 8
```

**Verbose Output** (with --verbose):
```
📋 NDJSON Files:
  - Organization.ndjson (45.2 KB, 2025-10-03 14:23:15)
  - Location.ndjson (12.8 KB, 2025-10-03 14:24:01)
  - Patient.ndjson (2.3 MB, 2025-10-03 15:10:42)
  ...

Total files: 8
```

## Dependencies (requirements.txt)
```txt
minio>=7.2.0
python-dotenv>=1.0.0
```

## Error Handling
- Connection errors
- Missing bucket
- Invalid credentials
- Empty bucket
- Clear error messages

## Code Structure

```python
#!/usr/bin/env python3
"""
MinIO Resource Lister
List all FHIR NDJSON files in MinIO bucket.
"""

import argparse
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(bucket_override=None):
    """Load environment variables."""
    pass

def create_minio_client(config):
    """Create MinIO client."""
    pass

def list_ndjson_files(client, bucket_name, verbose=False):
    """List all NDJSON files."""
    pass

def display_results(files, verbose=False):
    """Display results."""
    pass

def main():
    """Main entry point."""
    pass

if __name__ == "__main__":
    main()
```

## Success Criteria
✅ Connects to MinIO  
✅ Lists all .ndjson files  
✅ Shows file count  
✅ Verbose mode shows size/date  
✅ Handles errors gracefully  
✅ Has --help text