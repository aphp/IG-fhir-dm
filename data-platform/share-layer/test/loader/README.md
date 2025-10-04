# MIMIC-IV FHIR NDJSON Uploader to MinIO

A simple Python script to decompress and upload MIMIC-IV FHIR NDJSON files to MinIO object storage.

## Installation

```bash
pip install -r requirements.txt
```

## Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your MinIO credentials:
   ```bash
   MINIO_ENDPOINT=localhost:9000
   MINIO_ACCESS_KEY=minioadmin
   MINIO_SECRET_KEY=minioadmin
   MINIO_BUCKET_NAME=fhir-data
   MINIO_SECURE=false
   ```

## Usage

### Basic Usage

```bash
# Upload FHIR files from a directory
python ndjson_uploader.py --input-dir path/to/fhir/files

# Short form
python ndjson_uploader.py -i path/to/fhir/files
```

### Advanced Usage

```bash
# Override bucket name from .env
python ndjson_uploader.py -i path/to/fhir/files -b my-custom-bucket

# Specify custom log file
python ndjson_uploader.py -i path/to/fhir/files -l my-upload.log

# Combine options
python ndjson_uploader.py -i path/to/fhir/files -b my-bucket -l upload.log
```

### Get Help

```bash
python ndjson_uploader.py --help
```

## Command-Line Arguments

| Argument | Short | Required | Description | Default |
|----------|-------|----------|-------------|---------|
| `--input-dir` | `-i` | Yes | Directory with NDJSON.gz files | - |
| `--bucket` | `-b` | No | MinIO bucket name | From .env |
| `--log-file` | `-l` | No | Log file path | upload.log |

## What it Does

1. Validates input directory exists
2. Finds all `*.ndjson.gz` files in the directory
3. **Decompresses each .ndjson.gz file to .ndjson** (temporary file)
4. Uploads decompressed files to MinIO at `{bucket}/{filename.ndjson}`
5. **Cleans up temporary decompressed files**
6. Skips existing files (same name and size)
7. Shows progress for each file
8. Logs all operations to console and file
9. Prints summary statistics

## MinIO Folder Structure

Files are uploaded in decompressed format:

```
fhir-data/                          (bucket from .env or --bucket)
    MimicPatient.ndjson             (decompressed)
    MimicObservation.ndjson         (decompressed)
    MimicCondition.ndjson           (decompressed)
    MimicEncounter.ndjson           (decompressed)
    ...
```

**Note**: The `.gz` extension is removed - files are stored as `.ndjson` (decompressed).

## Examples

### Upload MIMIC Demo Data

```bash
python ndjson_uploader.py \
  --input-dir ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir
```

This will:
- Find all `*.ndjson.gz` files in the directory
- Decompress `MimicPatient.ndjson.gz` → upload as `MimicPatient.ndjson`
- Decompress `MimicObservation.ndjson.gz` → upload as `MimicObservation.ndjson`
- etc.

### Upload to Production Bucket

```bash
python ndjson_uploader.py \
  -i ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir \
  -b fhir-production
```

## Expected Output

### Help Text

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

### Console Output

```bash
$ python ndjson_uploader.py -i ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir

[2025-10-04 10:00:00] Starting upload...
[2025-10-04 10:00:00] Configuration:
  - Endpoint: localhost:9000
  - Bucket: fhir-data
  - Input: ../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir
  - Log file: upload.log

[2025-10-04 10:00:00] MinIO connection successful
[2025-10-04 10:00:01] Bucket 'fhir-data' ready
[2025-10-04 10:00:01] Found 24 files to upload

Decompressing and uploading file 1/24: MimicPatient.ndjson.gz → MimicPatient.ndjson (5.8 MB) ✓
Decompressing and uploading file 2/24: MimicObservation.ndjson.gz → MimicObservation.ndjson (42.1 MB) ✓
Decompressing and uploading file 3/24: MimicCondition.ndjson.gz → MimicCondition.ndjson (3.2 MB) already exists, skipped
...

[2025-10-04 10:05:30] Upload complete!
Summary:
  - Total files: 24
  - Uploaded: 23
  - Skipped: 1
  - Failed: 0
  - Total compressed size: 45.2 MB
  - Total decompressed size: 178.5 MB
  - Log file: upload.log
```

## Troubleshooting

| Error | Solution |
|-------|----------|
| `Input directory does not exist` | Check the path to `--input-dir` is correct |
| `No .ndjson.gz files found` | Verify `.ndjson.gz` files exist in the directory |
| `Connection refused` | Check MinIO is running and `MINIO_ENDPOINT` is correct |
| `Authentication failed` | Verify `MINIO_ACCESS_KEY` and `MINIO_SECRET_KEY` in `.env` |
| `Bucket error` | Check `MINIO_BUCKET_NAME` in `.env` or `--bucket` argument |
| `Decompression failed` | Check that `.ndjson.gz` files are valid gzip files |
| `.env file not found` | Create `.env` from `.env.example` in the script directory |

## Features

**Included:**
- ✅ Command-line arguments with argparse
- ✅ Input directory validation
- ✅ Load config from .env
- ✅ Connect to MinIO
- ✅ Create bucket if needed
- ✅ **Decompress .ndjson.gz files before upload**
- ✅ **Upload decompressed files as .ndjson**
- ✅ **Clean up temporary files**
- ✅ Skip existing files (same name + size)
- ✅ Basic logging (console + file)
- ✅ Progress messages
- ✅ Error handling
- ✅ Summary statistics
- ✅ Help text

**Excluded (by design):**
- ❌ Dry-run mode
- ❌ NDJSON validation
- ❌ Parallel processing
- ❌ Retry logic
- ❌ MD5 checksums
- ❌ Manifest generation
- ❌ Interactive mode

## How Decompression Works

1. **Input**: `MimicPatient.ndjson.gz` (compressed, ~2.3 MB)
2. **Decompress**: Creates temporary file `.temp_MimicPatient.ndjson` (decompressed, ~5.8 MB)
3. **Upload**: Uploads to MinIO as `MimicPatient.ndjson`
4. **Cleanup**: Removes `.temp_MimicPatient.ndjson`

The script handles cleanup even if errors occur, ensuring no temporary files are left behind.

## Requirements

- Python 3.7+
- MinIO server running and accessible
- Valid MinIO credentials
- Sufficient disk space for temporary decompressed files

## Dependencies

- `minio>=7.2.0` - MinIO Python SDK
- `python-dotenv>=1.0.0` - Environment variable management

Built-in Python modules used:
- `gzip` - File decompression
- `argparse` - Command-line parsing
- `logging` - Logging functionality
- `pathlib` - File path operations

## License

This script is part of the FHIR Implementation Guide for Data Management project.
