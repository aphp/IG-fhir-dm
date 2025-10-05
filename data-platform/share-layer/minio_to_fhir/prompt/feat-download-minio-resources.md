# MinIO Resource Downloader - Feature 2

## Objective
Create a Python script to download all FHIR NDJSON files from a MinIO bucket to a local directory.

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
          ├── list_minio_resources.py   # Feature 1: List
          ├── download_minio_resources.py # Feature 2: Download (this feature)
          ├── upload_to_fhir.py         # Feature 3: Upload
          ├── cleanup_ndjson_files.py   # Feature 4: Cleanup
          └── minio_to_fhir.py          # Feature 5: Orchestrator
```

### Input
- **Source**: MinIO bucket (configured in .env)
- **Format**: NDJSON files (*.ndjson)

### Output
- Downloaded NDJSON files in local directory
- Progress indicators for each file
- Summary of downloaded files

## Requirements

### 1. Use Existing Configuration
Use the `.env` file from previous features:
```bash
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=fhir-data
MINIO_SECURE=false
DOWNLOAD_DIR=/tmp/fhir-download
```

### 2. Command-Line Interface
```bash
# Basic usage - download to default directory
python download_minio_resources.py

# With custom bucket
python download_minio_resources.py --bucket my-bucket

# With custom download directory
python download_minio_resources.py --output /data/downloads

# Filter by resource type
python download_minio_resources.py --filter "Patient,Observation"

# Overwrite existing files
python download_minio_resources.py --overwrite

# Help
python download_minio_resources.py --help
```

**Arguments**:
- `--bucket` / `-b`: Override bucket name from .env
- `--output` / `-o`: Override download directory from .env
- `--filter` / `-f`: Download only specific resource types (comma-separated)
- `--overwrite`: Overwrite existing files (default: skip)
- `--organize`: Organize files in subdirectories by resource type

### 3. Core Functionality

**Must do**:
- Load configuration from `.env` file
- Connect to MinIO
- Create download directory if it doesn't exist
- List all `.ndjson` files (or filtered files)
- Download each file with progress indication
- Skip existing files (unless --overwrite)
- Organize files by resource type if requested
- Show download statistics

**File Organization Options**:
- **Flat** (default): All files in DOWNLOAD_DIR
  ```
  /tmp/fhir-download/
    ├── Patient.ndjson
    ├── Observation.ndjson
    └── Organization.ndjson
  ```

- **Organized** (with --organize): Files in subdirectories
  ```
  /tmp/fhir-download/
    ├── Patient/
    │   └── Patient.ndjson
    ├── Observation/
    │   └── Observation.ndjson
    └── Organization/
        └── Organization.ndjson
  ```

### 4. Output Format

**Progress Output**:
```
=== MinIO Resource Downloader ===
Source: fhir-data@localhost:9000
Destination: /tmp/fhir-download

Found 11 files to download...

[1/11] Downloading Organization.ndjson... ✓ (45.2 KB in 0.3s)
[2/11] Downloading Location.ndjson... ✓ (23.1 KB in 0.2s)
[3/11] Downloading Patient.ndjson... ✓ (1.2 MB in 2.1s)
[4/11] Downloading Observation.ndjson... ✓ (8.7 MB in 12.5s)
[5/11] Downloading Encounter.ndjson... ⊘ (already exists, skipped)
...

=== Summary ===
Total files found: 11
Downloaded: 9
Skipped (already exist): 2
Failed: 0
Total size: 12.4 MB
Duration: 28.3s
Location: /tmp/fhir-download
```

### 5. Dependencies
Same as Feature 1:
```txt
minio>=7.2.0
python-dotenv>=1.0.0
```

### 6. Error Handling
- Handle connection errors
- Handle disk space issues
- Handle permission errors
- Handle corrupted downloads
- Partial download recovery
- Clear error messages with suggestions

### 7. Code Structure

```python
#!/usr/bin/env python3
"""
MinIO Resource Downloader
Download all FHIR NDJSON files from MinIO bucket to local directory.
"""

import os
import sys
import argparse
from pathlib import Path
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv
import time

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(bucket_override=None, output_override=None):
    """Load and validate environment variables."""
    pass

def create_minio_client(config):
    """Create and test MinIO client."""
    pass

def get_resource_type_from_filename(filename):
    """Extract FHIR resource type from filename."""
    pass

def prepare_download_directory(base_dir, organize=False, resource_type=None):
    """Create directory structure for downloads."""
    pass

def download_file(client, bucket_name, object_name, local_path, overwrite=False):
    """Download a single file from MinIO."""
    # Check if file exists and handle overwrite
    # Download with progress
    # Return stats (size, duration, success/skip/fail)
    pass

def download_all_files(client, bucket_name, download_dir, resource_filter=None, 
                       organize=False, overwrite=False):
    """Download all matching NDJSON files."""
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
✅ Creates necessary directories  
✅ Handles existing files correctly  
✅ Supports resource filtering  
✅ Supports organized file structure  
✅ Displays summary statistics  
✅ Handles errors gracefully  

## Deliverables
1. `download_minio_resources.py` - Main script
2. Update `requirements.txt` if needed
3. Brief usage instructions in comments or docstring
```