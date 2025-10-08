# MinIO Resource Downloader - Simplified

## Objective
Create a Python script to download all FHIR NDJSON files from a MinIO bucket to a local directory.

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
          ├── list_minio_resources.py   # Feature 1: List
          └── download_minio_resources.py # This script
```

## Configuration (.env)
```bash
# MinIO Configuration
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=fhir-data
MINIO_SECURE=false

# Download Configuration
DOWNLOAD_DIR=/tmp/fhir-download
```

## Command-Line Interface
```bash
# Basic usage - download to default directory
python download_minio_resources.py

# With custom bucket
python download_minio_resources.py --bucket my-bucket

# With custom download directory
python download_minio_resources.py --output /data/downloads

# Help
python download_minio_resources.py --help
```

**Arguments**:
- `--bucket` / `-b`: Override bucket name from .env
- `--output` / `-o`: Override download directory from .env

## Core Functionality

- Load configuration from `.env` file
- Connect to MinIO
- Create download directory if it doesn't exist
- List all `.ndjson` files
- Download each file (always overwrite)
- Show progress for each file
- Display download statistics

**File Organization**:
- All files saved in flat structure (same as bucket)
  ```
  /tmp/fhir-download/
    ├── Patient.ndjson
    ├── Observation.ndjson
    └── Organization.ndjson
  ```

## Output Format

**Progress Output**:
```
=== MinIO Resource Downloader ===
Source: fhir-data@localhost:9000
Destination: /tmp/fhir-download

Found 8 files to download...

[1/8] Downloading Organization.ndjson... ✓ (45.2 KB in 0.3s)
[2/8] Downloading Location.ndjson... ✓ (23.1 KB in 0.2s)
[3/8] Downloading Patient.ndjson... ✓ (1.2 MB in 2.1s)
[4/8] Downloading Observation_labs.ndjson... ✓ (8.7 MB in 12.5s)
[5/8] Downloading Encounter.ndjson... ✓ (456 KB in 1.2s)
[6/8] Downloading Procedure.ndjson... ✓ (234 KB in 0.8s)
[7/8] Downloading Condition.ndjson... ✓ (567 KB in 1.5s)
[8/8] Downloading Medication.ndjson... ✓ (123 KB in 0.4s)

=== Summary ===
Total files: 8
Downloaded: 8
Failed: 0
Total size: 12.4 MB
Duration: 19.2s
Location: /tmp/fhir-download
```

## Dependencies (requirements.txt)
```txt
minio>=7.2.0
python-dotenv>=1.0.0
```

## Error Handling
- Connection errors
- Disk space issues
- Permission errors
- Download failures
- Clear error messages

## Code Structure

```python
#!/usr/bin/env python3
"""
MinIO Resource Downloader
Download all FHIR NDJSON files from MinIO bucket to local directory.
"""

import argparse
import time
from pathlib import Path
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(bucket_override=None, output_override=None):
    """Load environment variables."""
    pass

def create_minio_client(config):
    """Create MinIO client."""
    pass

def prepare_download_directory(download_dir):
    """Create download directory if it doesn't exist."""
    pass

def download_file(client, bucket_name, object_name, local_path):
    """Download a single file from MinIO."""
    # Download file
    # Return stats (size, duration, success/fail)
    pass

def download_all_files(client, bucket_name, download_dir):
    """Download all NDJSON files."""
    pass

def format_size(bytes):
    """Format bytes to human-readable size."""
    pass

def main():
    """Main entry point."""
    pass

if __name__ == "__main__":
    main()
```

## Success Criteria
✅ Downloads all NDJSON files from MinIO  
✅ Shows progress for each file  
✅ Creates download directory  
✅ Always overwrites existing files  
✅ Displays summary statistics  
✅ Handles errors gracefully