# NDJSON File Cleaner - Feature 4

## Objective
Create a Python script to safely delete NDJSON files from a specified directory with various filtering and safety options.

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
          ├── upload_to_fhir.py         # Feature 3: Upload
          ├── cleanup_ndjson_files.py   # Feature 4: Cleanup (this feature)
          └── minio_to_fhir.py          # Feature 5: Orchestrator
```

### Input
- **Target**: Local directory with NDJSON files

### Output
- Deleted NDJSON files based on criteria
- Summary of deleted files

## Requirements

### 1. Use Existing Configuration
Use the `.env` file from previous features:
```bash
DOWNLOAD_DIR=/tmp/fhir-download
UPLOAD_DIR=/tmp/fhir-upload
```

### 2. Command-Line Interface
```bash
# Basic usage - interactive cleanup of default directory
python cleanup_ndjson_files.py

# With specific directory
python cleanup_ndjson_files.py --directory /tmp/fhir-download

# Filter by resource type
python cleanup_ndjson_files.py --filter "Patient,Observation"

# Delete all without confirmation
python cleanup_ndjson_files.py --yes

# Dry run (show what would be deleted)
python cleanup_ndjson_files.py --dry-run

# Delete older than N days
python cleanup_ndjson_files.py --older-than 7

# Recursive (include subdirectories)
python cleanup_ndjson_files.py --recursive

# Help
python cleanup_ndjson_files.py --help
```

**Arguments**:
- `--directory` / `-d`: Target directory (default: DOWNLOAD_DIR from .env)
- `--filter` / `-f`: Delete only specific resource types (comma-separated)
- `--yes` / `-y`: Skip confirmation prompt
- `--dry-run`: Show what would be deleted without deleting
- `--older-than`: Delete files older than N days
- `--recursive` / `-r`: Include subdirectories
- `--keep-structure`: Don't delete empty directories after cleanup

### 3. Core Functionality

**Must do**:
- Load configuration from `.env` file
- Scan directory for NDJSON files
- Apply filters (resource type, age, etc.)
- Show list of files to be deleted
- Request confirmation (unless --yes)
- Delete files safely
- Remove empty directories (unless --keep-structure)
- Display deletion statistics
- Handle errors gracefully

**Safety Features**:
- Always show what will be deleted before deleting
- Require confirmation by default
- Dry-run mode to preview
- Never delete files outside specified directory
- Validate directory exists before operation
- Handle permission errors

### 4. Output Format

**Interactive Mode**:
```
=== NDJSON File Cleaner ===
Target Directory: /tmp/fhir-download

Scanning for NDJSON files...
Found 11 files:

Organization (1 file, 45.2 KB):
  - Organization.ndjson

Location (1 file, 23.1 KB):
  - Location.ndjson

Patient (2 files, 1.4 MB):
  - Patient.ndjson
  - Patient_part2.ndjson

Observation (3 files, 8.9 MB):
  - Observation_labs.ndjson
  - Observation_vitals.ndjson
  - Observation_other.ndjson

...

Total: 11 files (12.4 MB)

⚠️  WARNING: This will permanently delete these files!
Continue? [y/N]: y

Deleting files...
  ✓ Organization.ndjson
  ✓ Location.ndjson
  ✓ Patient.ndjson
  ✓ Patient_part2.ndjson
  ...

Removing empty directories...
  ✓ Removed: /tmp/fhir-download/Organization
  ✓ Removed: /tmp/fhir-download/Location

=== Summary ===
Files deleted: 11
Total size freed: 12.4 MB
Directories removed: 8
Duration: 0.5s
```

**Dry Run Mode**:
```
=== NDJSON File Cleaner (DRY RUN) ===
Target Directory: /tmp/fhir-download

Would delete 11 files (12.4 MB):
  - Organization.ndjson (45.2 KB)
  - Location.ndjson (23.1 KB)
  - Patient.ndjson (1.2 MB)
  ...

Would remove 8 empty directories

No files were actually deleted (dry run mode)
```

**With Filters**:
```
=== NDJSON File Cleaner ===
Target Directory: /tmp/fhir-download
Filter: Patient, Observation

Found 5 matching files (10.3 MB):
  - Patient.ndjson
  - Patient_part2.ndjson
  - Observation_labs.ndjson
  - Observation_vitals.ndjson
  - Observation_other.ndjson

Continue? [y/N]:
```

### 5. Dependencies
Same as previous features:
```txt
minio>=7.2.0
python-dotenv>=1.0.0
requests>=2.31.0
```

### 6. Error Handling
- Handle non-existent directory
- Handle permission errors
- Handle files in use
- Handle partial deletions
- Provide clear error messages
- Rollback capability for critical errors

### 7. Code Structure

```python
#!/usr/bin/env python3
"""
NDJSON File Cleaner
Safely delete NDJSON files from a directory with filtering options.
"""

import os
import sys
import argparse
from pathlib import Path
from dotenv import load_dotenv
from datetime import datetime, timedelta
from typing import List, Dict
import shutil

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(directory_override=None):
    """Load and validate environment variables."""
    pass

def get_resource_type_from_filename(filename):
    """Extract FHIR resource type from filename."""
    pass

def scan_ndjson_files(directory, recursive=False, older_than_days=None, 
                      resource_filter=None):
    """Scan directory for NDJSON files matching criteria."""
    # Find all .ndjson files
    # Apply filters (resource type, age)
    # Group by resource type
    # Calculate sizes and counts
    # Return dict with file info
    pass

def get_file_age_days(filepath):
    """Get file age in days."""
    pass

def format_size(bytes):
    """Format bytes to human-readable size."""
    pass

def display_files(files_by_type, total_size):
    """Display files to be deleted in organized format."""
    pass

def confirm_deletion(file_count, total_size):
    """Prompt user for confirmation."""
    # Display warning
    # Ask for confirmation
    # Return True/False
    pass

def delete_files(files_list, dry_run=False):
    """Delete files from list."""
    # For each file:
    #   - Delete file (if not dry_run)
    #   - Track success/failure
    #   - Show progress
    # Return stats
    pass

def remove_empty_directories(base_dir, keep_structure=False, dry_run=False):
    """Remove empty directories recursively."""
    pass

def main():
    """Main entry point."""
    # Parse arguments
    # Load config
    # Scan for files
    # Display files to delete
    # Confirm (unless --yes)
    # Delete files
    # Remove empty directories
    # Display summary
    pass

if __name__ == "__main__":
    main()
```

## Success Criteria
✅ Scans directory for NDJSON files  
✅ Applies filters correctly  
✅ Shows clear preview of deletion  
✅ Requires confirmation (interactive mode)  
✅ Supports dry-run mode  
✅ Deletes files safely  
✅ Removes empty directories  
✅ Handles errors gracefully  
✅ Displays clear statistics  
✅ Has safety features  

## Deliverables
1. `cleanup_ndjson_files.py` - Main script
2. Brief usage instructions in comments or docstring

## Safety Notes
- Always preview files before deletion
- Default to interactive mode (require confirmation)
- Use dry-run to test filters
- Be careful with --yes flag
- Backup important data before cleanup
```