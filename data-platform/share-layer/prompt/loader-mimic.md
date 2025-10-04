# MIMIC FHIR Data Upload to MinIO

## Objective
Create a simple Python script to upload MIMIC-IV FHIR NDJSON files to a MinIO storage instance.

## Context

### Input Data
- **Location**: `data-platform/share-layer/test/mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir/`
- **Format**: Gzip compressed NDJSON files (*.ndjson.gz)
- **Content**: FHIR R4 resources (Patient, Observation, Condition, Encounter, etc.)

### Output Requirements
1. **Main Script**: `data-platform/share-layer/test/loader/ndjson_uploader.py`
2. **Environment Template**: `data-platform/share-layer/test/loader/.env.example`
3. **Dependencies**: `data-platform/share-layer/test/loader/requirements.txt`
4. **Documentation**: `data-platform/share-layer/test/loader/README.md`

## Instructions

### Step 1: Setup Configuration

Create `.env.example` with:
```bash
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=fhir-data
MINIO_SECURE=false
```

### Step 2: Core Script Requirements

**Command-Line Interface**:
- Use argparse for command-line arguments
- Required argument: `--input-dir` or `-i` - path to directory with NDJSON files
- Optional argument: `--bucket` or `-b` - override bucket name from .env
- Optional argument: `--log-file` or `-l` - log file path (default: "upload.log")
- Help text for each argument

**Usage examples**:
```bash
# Basic usage
python ndjson_uploader.py --input-dir ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir

# With custom bucket
python ndjson_uploader.py -i ../data/fhir -b my-custom-bucket

# With custom log file
python ndjson_uploader.py -i ../data/fhir -l my-upload.log
```

**Environment Loading**:
- Load variables from `.env` file using python-dotenv
- Check all required variables exist, exit with error if missing
- Allow bucket name override from command-line argument
- Print configuration (mask secret key)

**MinIO Connection**:
- Create MinIO client with credentials
- Test connection by checking if bucket exists
- Create bucket if it doesn't exist
- Handle connection errors with clear messages

**File Upload**:
- Validate input directory exists and is readable
- Find all `*.ndjson.gz` files in input directory
- **Decompress each .ndjson.gz file to .ndjson before upload**
- Upload decompressed files to MinIO with structure: `{bucket}/{filename.ndjson}`
- Show progress: "Uploading file X of Y: {filename}"
- Skip file if already exists in MinIO (same name and size)
- Clean up temporary decompressed files after upload

**Logging**:
- Print to console: start time, each file upload, errors, completion summary
- Log to file specified by --log-file argument with timestamps
- Summary at end: total files, successful, failed, total size

### Step 3: Error Handling

**Simple approach**:
- Validate input directory exists before processing
- Try to decompress and upload each file
- If decompression or upload fails, log error and continue with next file
- Clean up temporary files even on error
- Print final summary of successes and failures
- Exit with code 0 if all succeeded, 1 if any failed

### Step 4: Code Structure

```python
# ndjson_uploader.py

import os
import sys
import gzip
import argparse
import logging
from pathlib import Path
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv

def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Upload MIMIC-IV FHIR NDJSON files to MinIO',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s --input-dir ../data/fhir
  %(prog)s -i ../data/fhir -b my-bucket
        '''
    )
    
    parser.add_argument(
        '--input-dir', '-i',
        required=True,
        help='Directory containing NDJSON.gz files'
    )
    
    parser.add_argument(
        '--bucket', '-b',
        help='MinIO bucket name (overrides .env)'
    )
    
    parser.add_argument(
        '--log-file', '-l',
        default='upload.log',
        help='Log file path (default: upload.log)'
    )
    
    return parser.parse_args()

def setup_logging(log_file):
    """Setup logging to console and file."""
    # Configure logging
    pass

def load_config(bucket_override=None):
    """Load and validate environment variables."""
    # Load .env file
    # Check required vars exist
    # Override bucket if provided
    # Return config dict
    pass

def validate_input_directory(input_dir):
    """Validate input directory exists and has NDJSON files."""
    # Check directory exists
    # Check it's readable
    # Find .ndjson.gz files
    # Exit with error if no files found
    pass

def decompress_file(gz_file_path, output_path):
    """Decompress a .ndjson.gz file to .ndjson."""
    # Read compressed file
    # Write decompressed content
    # Return path to decompressed file
    pass

def create_minio_client(config):
    """Create and test MinIO client."""
    # Create client
    # Test connection
    # Return client
    pass

def ensure_bucket(client, bucket_name):
    """Create bucket if doesn't exist."""
    # Check bucket exists
    # Create if needed
    pass

def upload_files(client, bucket_name, input_dir):
    """Upload all NDJSON files from directory."""
    # Find all .ndjson.gz files
    # For each file:
    #   - Decompress to temporary .ndjson file
    #   - Build object key: {filename.ndjson} (without .gz)
    #   - Check if exists in MinIO
    #   - Upload decompressed file if new or different size
    #   - Clean up temporary decompressed file
    #   - Log progress
    # Return summary stats
    pass

def main():
    """Main entry point."""
    # Parse arguments
    # Setup logging
    # Validate input directory
    # Load config
    # Create client
    # Ensure bucket
    # Upload files
    # Print summary
    # Exit with appropriate code
    pass

if __name__ == "__main__":
    main()
```

### Step 5: Dependencies

Create `requirements.txt`:
```txt
minio>=7.2.0
python-dotenv>=1.0.0
```

### Step 6: Documentation

Create README.md with:

1. **Installation**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Configuration**:
   ```bash
   cp .env.example .env
   # Edit .env with your MinIO credentials
   ```

3. **Usage**:
   ```bash
   # Basic usage
   python ndjson_uploader.py --input-dir path/to/fhir/files
   
   # Short form
   python ndjson_uploader.py -i path/to/fhir/files
   
   # With custom bucket
   python ndjson_uploader.py -i path/to/fhir/files -b my-bucket
   
   # With custom log file
   python ndjson_uploader.py -i path/to/fhir/files -l my-upload.log
   
   # Help
   python ndjson_uploader.py --help
   ```

4. **Command-Line Arguments**:
   | Argument | Short | Required | Description | Default |
   |----------|-------|----------|-------------|---------|
   | `--input-dir` | `-i` | Yes | Directory with NDJSON files | - |
   | `--bucket` | `-b` | No | MinIO bucket name | From .env |
   | `--log-file` | `-l` | No | Log file path | upload.log |

5. **What it does**:
   - Validates input directory exists
   - Finds all NDJSON.gz files
   - Decompresses each file from .ndjson.gz to .ndjson
   - Uploads decompressed files to MinIO at `{bucket}/{filename.ndjson}`
   - Cleans up temporary decompressed files
   - Skips existing files (same name and size)
   - Shows progress
   - Logs results

6. **MinIO folder structure**:
   ```
   fhir-data/                    (bucket from .env or --bucket)
       Patient.ndjson
       Observation.ndjson
       Condition.ndjson
       ...
   ```

7. **Examples**:
   ```bash
   # Upload MIMIC demo data
   python ndjson_uploader.py \
     --input-dir ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir
   
   # Upload to production bucket
   python ndjson_uploader.py \
     -i ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir \
     -b fhir-production
   ```

8. **Troubleshooting**:
   - `Input directory does not exist`: Check the path to --input-dir
   - `No .ndjson.gz files found`: Verify files exist in directory
   - `Connection refused`: Check MinIO is running and MINIO_ENDPOINT is correct
   - `Authentication failed`: Check credentials in .env
   - `Bucket error`: Check bucket name in .env or --bucket argument
   - `Decompression failed`: Check that .ndjson.gz files are valid gzip files

## Key Features (Keep It Simple)

**DO Include**:
- ✅ Command-line arguments with argparse
- ✅ Input directory validation
- ✅ Load config from .env
- ✅ Connect to MinIO
- ✅ Create bucket if needed
- ✅ Decompress .ndjson.gz files before upload
- ✅ Upload decompressed files as .ndjson
- ✅ Clean up temporary files
- ✅ Skip existing files (same name + size)
- ✅ Basic logging (console + file)
- ✅ Progress messages
- ✅ Error handling
- ✅ Summary statistics
- ✅ Help text

**DO NOT Include**:
- ❌ Dry-run mode
- ❌ NDJSON validation
- ❌ Parallel processing
- ❌ Retry logic
- ❌ MD5 checksums
- ❌ Manifest generation
- ❌ Interactive mode

## Success Criteria

Script is complete when:
1. Accepts required --input-dir argument
2. Validates input directory exists and contains .ndjson.gz files
3. All `.ndjson.gz` files are decompressed successfully
4. All decompressed `.ndjson` files upload successfully
5. Files organized in MinIO as `{bucket}/{filename.ndjson}`
6. Temporary decompressed files are cleaned up
7. Console shows clear progress
8. Log file created with results
9. Help text is clear and useful
10. README explains all arguments
11. No credentials hardcoded

## Expected Output

**Help output**:
```bash
$ python ndjson_uploader.py --help
usage: ndjson_uploader.py [-h] --input-dir INPUT_DIR [--bucket BUCKET] 
                          [--log-file LOG_FILE]

Upload MIMIC-IV FHIR NDJSON files to MinIO

optional arguments:
  -h, --help            show this help message and exit
  --input-dir INPUT_DIR, -i INPUT_DIR
                        Directory containing NDJSON.gz files
  --bucket BUCKET, -b BUCKET
                        MinIO bucket name (overrides .env)
  --log-file LOG_FILE, -l LOG_FILE
                        Log file path (default: upload.log)

Examples:
  ndjson_uploader.py --input-dir ../data/fhir
  ndjson_uploader.py -i ../data/fhir -b my-bucket
```

**Console output example**:
```bash
$ python ndjson_uploader.py -i ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir

[2025-10-04 10:00:00] Starting upload...
[2025-10-04 10:00:00] Configuration:
  - Endpoint: localhost:9000
  - Bucket: fhir-data
  - Prefix: mimic-iv-demo
  - Input: ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir
  - Log file: upload.log

[2025-10-04 10:00:00] MinIO connection successful
[2025-10-04 10:00:01] Bucket 'fhir-data' ready
[2025-10-04 10:00:01] Found 8 files to upload

Decompressing and uploading file 1/8: Patient.ndjson.gz → Patient.ndjson (5.8 MB) ✓
Decompressing and uploading file 2/8: Observation.ndjson.gz → Observation.ndjson (42.1 MB) ✓
Decompressing and uploading file 3/8: Condition.ndjson.gz → Condition.ndjson (3.2 MB) already exists, skipped
...

[2025-10-04 10:05:30] Upload complete!
Summary:
  - Total files: 8
  - Uploaded: 7
  - Skipped: 1
  - Failed: 0
  - Total compressed size: 45.2 MB
  - Total decompressed size: 178.5 MB
  - Log file: upload.log
```

## References

- **MinIO Python SDK**: https://min.io/docs/minio/linux/developers/python/minio-py.html
- **Python dotenv**: https://pypi.org/project/python-dotenv/
- **Python argparse**: https://docs.python.org/3/library/argparse.html
- **Python gzip**: https://docs.python.org/3/library/gzip.html