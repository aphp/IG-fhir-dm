# HAPI FHIR Batch Uploader - Feature 3

## Objective
Create a Python script to upload FHIR NDJSON files from a local directory to HAPI FHIR server using batch transactions (NOT $import).

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
          ├── download_minio_resources.py # Feature 2: Download
          ├── upload_to_fhir.py         # Feature 3: Upload (this feature)
          ├── cleanup_ndjson_files.py   # Feature 4: Cleanup
          └── minio_to_fhir.py          # Feature 5: Orchestrator
```

### Input
- **Source**: Local directory with NDJSON files
- **Format**: NDJSON files (*.ndjson) containing FHIR R4 resources

### Output
- Resources uploaded to HAPI FHIR server
- Progress tracking
- Success/failure statistics per file and per resource

### Resource Loading Order
Resources must be loaded in this specific order to maintain referential integrity:
1. Organization
2. Location
3. Medication
4. Specimen
5. Patient
6. Encounter
7. Clinical Resources: Procedure, Observation, Condition, MedicationRequest, MedicationDispense, MedicationStatement

## Requirements

### 1. Use Existing Configuration
Use the `.env` file from previous features:
```bash
# HAPI FHIR Configuration
FHIR_BASE_URL=http://localhost:8080/fhir
FHIR_AUTH_ENABLED=false
FHIR_USERNAME=
FHIR_PASSWORD=

# Upload Configuration
UPLOAD_DIR=/tmp/fhir-upload
BATCH_SIZE=100
```

### 2. Command-Line Interface
```bash
# Basic usage - upload from default directory
python upload_to_fhir.py

# With custom source directory
python upload_to_fhir.py --input /data/fhir-files

# With custom batch size
python upload_to_fhir.py --batch-size 50

# Filter by resource type
python upload_to_fhir.py --filter "Patient,Observation"

# Dry run (validate without uploading)
python upload_to_fhir.py --dry-run

# Continue on errors
python upload_to_fhir.py --continue-on-error

# Help
python upload_to_fhir.py --help
```

**Arguments**:
- `--input` / `-i`: Source directory (overrides .env)
- `--batch-size` / `-s`: Resources per batch (default: 100)
- `--filter` / `-f`: Upload only specific resource types
- `--dry-run`: Validate files without uploading
- `--continue-on-error`: Continue if a batch fails
- `--skip-validation`: Skip FHIR validation before upload

### 3. Core Functionality

**Must do**:
- Load configuration from `.env` file
- Test HAPI FHIR server connectivity
- Scan directory for NDJSON files
- Group files by resource type
- **Sort by resource order** (referential integrity)
- For each file:
  - Read NDJSON line by line
  - Create batches of N resources
  - Build FHIR Bundle (type: batch)
  - POST bundle to FHIR server
  - Parse response and track results
- Track success/failure per resource
- Display progress and statistics

**Batch Bundle Structure**:
```json
{
  "resourceType": "Bundle",
  "type": "batch",
  "entry": [
    {
      "request": {
        "method": "POST",
        "url": "Patient"
      },
      "resource": {
        "resourceType": "Patient",
        ...
      }
    },
    ...
  ]
}
```

### 4. Resource Order (CRITICAL)

```python
RESOURCE_ORDER = [
    'Organization',
    'Location',
    'Medication',
    'Specimen',
    'Patient',
    'Encounter',
    ['Procedure', 'Observation', 'Condition', 
     'MedicationRequest', 'MedicationDispense', 'MedicationStatement']
]
```

### 5. Output Format

**Progress Output**:
```
=== HAPI FHIR Batch Uploader ===
Source: /tmp/fhir-upload
Destination: http://localhost:8080/fhir
Batch Size: 100

Scanning directory...
Found 8 NDJSON files (2,845 resources total)

Sorted by dependency order:
  Step 1: Organization (1 file, 12 resources)
  Step 2: Location (1 file, 35 resources)
  Step 3: Patient (1 file, 250 resources)
  Step 4: Encounter (1 file, 420 resources)
  Step 5: Clinical (4 files, 2,128 resources)

Starting upload...

[Step 1/5] Organization.ndjson
  Batch 1/1 (12 resources)... ✓ (12 created, 0 failed) - 1.2s

[Step 2/5] Location.ndjson
  Batch 1/1 (35 resources)... ✓ (35 created, 0 failed) - 2.1s

[Step 3/5] Patient.ndjson
  Batch 1/3 (100 resources)... ✓ (100 created, 0 failed) - 5.3s
  Batch 2/3 (100 resources)... ✓ (100 created, 0 failed) - 5.1s
  Batch 3/3 (50 resources)... ✓ (50 created, 0 failed) - 2.8s

[Step 4/5] Encounter.ndjson
  Batch 1/5 (100 resources)... ✓ (100 created, 0 failed) - 6.2s
  Batch 2/5 (100 resources)... ✓ (98 created, 2 failed) - 6.1s
  Batch 3/5 (100 resources)... ✓ (100 created, 0 failed) - 6.3s
  Batch 4/5 (100 resources)... ✓ (100 created, 0 failed) - 6.0s
  Batch 5/5 (20 resources)... ✓ (20 created, 0 failed) - 1.5s

[Step 5/5] Clinical Resources (Observation, Procedure, Condition, MedicationRequest)
  ...

=== Summary ===
Total files: 8
Total resources: 2,845
Successfully uploaded: 2,843
Failed: 2
Duration: 3m 24s

Failed resources logged to: upload_failures.log
```

### 6. Dependencies
```txt
minio>=7.2.0
python-dotenv>=1.0.0
requests>=2.31.0
```

### 7. Error Handling
- Test FHIR server before upload
- Validate NDJSON format
- Handle batch failures gracefully
- Log failed resources with details
- Option to continue on error
- Retry logic for network errors
- Clear error messages

### 8. Code Structure

```python
#!/usr/bin/env python3
"""
HAPI FHIR Batch Uploader
Upload FHIR NDJSON files to HAPI FHIR server using batch transactions.
"""

import os
import sys
import json
import argparse
from pathlib import Path
from dotenv import load_dotenv
import requests
from typing import List, Dict, Tuple

# Resource loading order (referential integrity)
RESOURCE_ORDER = [
    'Organization',
    'Location',
    'Medication',
    'Specimen',
    'Patient',
    'Encounter',
    ['Procedure', 'Observation', 'Condition', 
     'MedicationRequest', 'MedicationDispense', 'MedicationStatement']
]

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(input_override=None):
    """Load and validate environment variables."""
    pass

def test_fhir_server(config):
    """Test HAPI FHIR server connectivity."""
    # GET /metadata
    # Check server is accessible
    # Check authentication if enabled
    pass

def get_resource_type_from_filename(filename):
    """Extract FHIR resource type from filename."""
    pass

def scan_ndjson_files(directory):
    """Scan directory for NDJSON files and group by resource type."""
    pass

def sort_files_by_order(files_by_type):
    """Sort files according to RESOURCE_ORDER."""
    pass

def read_ndjson_file(filepath):
    """Read NDJSON file and yield resources."""
    pass

def create_batch_bundle(resources: List[Dict]) -> Dict:
    """Create FHIR Bundle of type 'batch'."""
    pass

def upload_batch(fhir_url: str, bundle: Dict, auth=None) -> Tuple[int, int]:
    """Upload batch bundle to FHIR server."""
    # POST bundle
    # Parse response
    # Count successes/failures
    # Return (success_count, failure_count)
    pass

def upload_file(filepath, resource_type, fhir_config, batch_size, continue_on_error):
    """Upload all resources from a single NDJSON file."""
    # Read file
    # Create batches
    # Upload each batch
    # Track stats
    # Return stats
    pass

def upload_all_files(files_by_type, fhir_config, batch_size, 
                     continue_on_error, dry_run):
    """Upload all files in correct order."""
    pass

def log_failed_resource(resource, error, log_file):
    """Log failed resource to file."""
    pass

def main():
    """Main entry point."""
    pass

if __name__ == "__main__":
    main()
```

## Success Criteria
✅ Tests FHIR server connectivity  
✅ Reads NDJSON files correctly  
✅ Groups and sorts files by resource order  
✅ Creates valid FHIR batch bundles  
✅ Uploads batches successfully  
✅ Tracks success/failure per resource  
✅ Handles errors gracefully  
✅ Displays clear progress  
✅ Logs failures for review  
✅ Respects referential integrity order  

## Deliverables
1. `upload_to_fhir.py` - Main script
2. Update `requirements.txt` if needed (add requests)
3. Brief usage instructions in comments or docstring
```