# HAPI FHIR Batch Uploader

## Objective
Create a Python script to upload FHIR NDJSON files from a local directory to HAPI FHIR server using batch transactions, respecting referential integrity order and original id resource.

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
          ├── download_minio_resources.py # Feature 2: Download
          └── upload_to_fhir.py         # This script
```

## Configuration (.env)
```bash
# HAPI FHIR Configuration
FHIR_BASE_URL=http://localhost:8080/fhir
FHIR_AUTH_ENABLED=false
FHIR_USERNAME=
FHIR_PASSWORD=

# Upload Configuration
TMP_DIR=/tmp/fhir-upload
BATCH_SIZE=100
```

## Command-Line Interface
```bash
# Basic usage - upload from default directory
python upload_to_fhir.py

# With custom source directory
python upload_to_fhir.py --input ./data/fhir-files

# With custom batch size
python upload_to_fhir.py --batch-size 50

# Help
python upload_to_fhir.py --help
```

**Arguments**:
- `--input` / `-i`: Source directory (overrides .env)
- `--batch-size` / `-s`: Resources per batch (default: 100)

## Resource Loading Order (CRITICAL)

Resources must be loaded in this specific order to maintain referential integrity:

1. **Organization** 
2. **Location**
3. **Patient**
4. **Encounter**
5. **Medication**
6. **Condition**
7. **Observation**
8. **Procedure**
9. **Specimen**
10. **MedicationRequest**
11. **MedicationDispense**
12. **MedicationAdminstration** and **MedicationStatement**

```python
RESOURCE_ORDER = [
    'Organization',
    'Location',
    'Patient',
    'Encounter',
    'Condition',
    'Observation',
    'Procedure',
    'Medication',
    'Specimen',
    'MedicationRequest',
    'MedicationDispense',
    ['MedicationStatement', 'MedicationAdministration']
]
```

## Core Functionality

- Load configuration from `.env` file
- Test HAPI FHIR server connectivity
- Scan directory for all NDJSON files
- **Group files by resource type**
- **Sort by resource order** (referential integrity)
- For each file (in order):
  - Read NDJSON line by line
  - Create batches of N resources
  - Build FHIR Bundle (type: batch)
  - PUT bundle to FHIR server
  - Parse response and track results
- Display progress and statistics
- Log failed resources

**Batch Bundle Structure**:
```json
{
  "resourceType": "Bundle",
  "type": "batch",
  "entry": [
    {
      "request": {
        "method": "PUT",
        "url": "Patient/patient-001"
      },
      "resource": {
        "resourceType": "Patient",
        "id": "patient-001",
        ...
      }
    }
  ]
}
```

## Output Format

**Progress Output**:
```
=== HAPI FHIR Batch Uploader ===
Source: /tmp/fhir-upload
Destination: http://localhost:8080/fhir
Batch Size: 100

Testing FHIR server... ✓

Scanning directory...
Found 8 NDJSON files (2,845 resources total)

Sorted by dependency order:
  Step 1: Organization (1 file, 12 resources)
  Step 2: Location (1 file, 35 resources)
  Step 3: Patient (1 file, 250 resources)
  Step 4: Encounter (1 file, 420 resources)

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
  Observation_labs.ndjson
    Batch 1/8 (100 resources)... ✓ (100 created, 0 failed) - 7.2s
    ...
  Procedure.ndjson
    Batch 1/2 (100 resources)... ✓ (100 created, 0 failed) - 5.8s
    ...

=== Summary ===
Total files: 8
Total resources: 2,845
Successfully uploaded: 2,843
Failed: 2
Duration: 3m 24s

Failed resources logged to: upload_failures.log
```

## Dependencies (requirements.txt)
```txt
minio>=7.2.0
python-dotenv>=1.0.0
requests>=2.31.0
```

## Error Handling
- Test FHIR server before upload
- Handle batch failures gracefully
- Track failed resources
- Log failures to file
- Retry logic for network errors
- Clear error messages

## Code Structure

```python
#!/usr/bin/env python3
"""
HAPI FHIR Batch Uploader
Upload FHIR NDJSON files to HAPI FHIR server using batch transactions.
Respects referential integrity by uploading resources in dependency order.
"""

import json
import argparse
import time
from pathlib import Path
from dotenv import load_dotenv
import requests
from typing import List, Dict, Tuple

# Resource loading order (referential integrity)
RESOURCE_ORDER = [
    'Organization',
    'Location',
    'Patient',
    'Encounter',
    'Condition',
    'Observation',
    'Procedure',
    'Medication',
    'Specimen',
    'MedicationRequest',
    'MedicationDispense',
    ['MedicationStatement', 'MedicationAdministration']
]

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(input_override=None):
    """Load environment variables."""
    pass

def test_fhir_server(fhir_url, auth=None):
    """Test HAPI FHIR server connectivity."""
    # GET /metadata
    pass

def get_resource_type_from_filename(filename):
    """Extract FHIR resource type from filename."""
    # Handle patterns like:
    # - "Patient.ndjson" -> "Patient"
    # - "MimicPatient.ndjson" -> "Patient"
    # - "Patient_part1.ndjson" -> "Patient"
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
    # PUT bundle
    # Parse response
    # Return (success_count, failure_count)
    pass

def upload_file(filepath, fhir_url, batch_size, auth=None):
    """Upload all resources from a single NDJSON file."""
    # Read file
    # Create batches
    # Upload each batch
    # Return stats
    pass

def upload_all_files(sorted_files, fhir_url, batch_size, auth=None):
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
✅ Groups files by resource type
✅ Sorts files by dependency order  
✅ Creates valid FHIR batch bundles  
✅ Uploads batches successfully  
✅ Tracks success/failure per resource  
✅ Logs failures for review  
✅ Handles errors gracefully  
✅ Displays clear progress  
✅ Respects referential integrity order