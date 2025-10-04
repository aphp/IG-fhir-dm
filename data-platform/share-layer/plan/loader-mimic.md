## Implementation Plan: MIMIC FHIR Data Loader to MinIO

Based on [loader-mimic.md](data-platform/share-layer/prompt/loader-mimic.md), I'll create a Python script to upload MIMIC-IV FHIR NDJSON files to MinIO storage.

### Key Requirement Update
**IMPORTANT**: The spec requires **decompressing** .ndjson.gz files before upload:
- Line 68: "Decompress each .ndjson.gz file to .ndjson before upload"
- Line 69: Upload decompressed files as `{bucket}/{filename.ndjson}` (without .gz)
- Line 72: Clean up temporary decompressed files after upload

### Files to Create:

1. **`data-platform/share-layer/test/loader/.env.example`**
   - MinIO configuration template (ENDPOINT, ACCESS_KEY, SECRET_KEY, BUCKET_NAME, SECURE)

2. **`data-platform/share-layer/test/loader/requirements.txt`**
   - Dependencies: minio>=7.2.0, python-dotenv>=1.0.0

3. **`data-platform/share-layer/test/loader/ndjson_uploader.py`**
   - CLI with argparse: --input-dir (required), --bucket, --log-file
   - Functions: parse_arguments, setup_logging, load_config, validate_input_directory, **decompress_file**, create_minio_client, ensure_bucket, upload_files, main
   - Workflow: validate → find .gz files → **decompress to temp .ndjson** → upload → **cleanup temp files**

4. **`data-platform/share-layer/test/loader/README.md`**
   - Installation, configuration, usage, troubleshooting
   - Explain decompression step and .ndjson upload format

### Key Features:
✅ Decompress .ndjson.gz → .ndjson before upload (using gzip module)
✅ Upload decompressed files to {bucket}/{filename.ndjson}
✅ Clean up temporary decompressed files
✅ CLI arguments, env config, MinIO connection, bucket creation
✅ Skip existing files, progress tracking, logging, error handling, summary stats