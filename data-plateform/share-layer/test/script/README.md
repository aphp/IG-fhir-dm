# FHIR Bulk Loader

A Python script to import FHIR NDJSON.gz files into HAPI FHIR server using the `$import` operation (bulk import).

## Features

- **Bulk Import**: Uses HAPI FHIR's `$import` operation for efficient data loading
- **Compressed Files**: Handles NDJSON.gz files directly without manual decompression
- **Batch Processing**: Processes multiple files in a single import job
- **Progress Monitoring**: Real-time status updates and import job tracking
- **Error Handling**: Comprehensive error handling with retries and logging
- **Async Processing**: Modern async/await pattern for better performance
- **Configuration**: Environment variable and configuration file support

## Prerequisites

- Python 3.8+
- HAPI FHIR server (version 8.4.0 or compatible) running at `http://localhost:8080/fhir`
- PostgreSQL database (as configured in HAPI FHIR)
- MIMIC-IV Clinical Database Demo on FHIR 2.1.0 files

## Installation

1. Clone or navigate to the script directory:
```bash
cd data-plateform/share-layer/test/script
```

2. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Configuration

### Environment Variables

You can configure the loader using environment variables:

```bash
# HAPI FHIR Server Configuration
export HAPI_FHIR_URL="http://localhost:8080/fhir"
export HAPI_FHIR_VERSION="8.4.0"
export FHIR_VERSION="R4"
export HAPI_DB_TYPE="PostgreSQL"
export HAPI_TIMEOUT="30"
export HAPI_MAX_RETRIES="3"
export HAPI_RETRY_DELAY="5"

# Import Configuration
export DATA_DIRECTORY="../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir"
export FILE_PATTERN="*.ndjson.gz"
export BATCH_SIZE="1000"
export MAX_CONCURRENT_REQUESTS="5"
export POLL_INTERVAL="10"
export MAX_WAIT_TIME="3600"

# Logging Configuration
export LOG_LEVEL="INFO"
export LOG_FILE="fhir_import.log"
```

### Default Configuration

If no environment variables are set, the script uses these defaults:

- **HAPI FHIR URL**: `http://localhost:8080/fhir`
- **Data Directory**: `../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir`
- **File Pattern**: `*.ndjson.gz`
- **Batch Size**: 1000 resources per batch
- **Poll Interval**: 10 seconds between status checks
- **Max Wait Time**: 3600 seconds (1 hour) for import completion

## Usage

### Basic Usage

Run the bulk loader with default configuration:

```bash
python fhir_bulk_loader.py
```

### With Environment Variables

```bash
export DATA_DIRECTORY="/path/to/your/fhir/files"
export HAPI_FHIR_URL="http://your-server:8080/fhir"
python fhir_bulk_loader.py
```

### Expected Output

```
2024-09-06 12:00:00,000 - __main__ - INFO - Connected to HAPI FHIR server: HAPI FHIR Server
2024-09-06 12:00:01,000 - __main__ - INFO - Found 15 NDJSON.gz files
2024-09-06 12:00:01,100 - __main__ - INFO - Starting analysis of 15 files...
2024-09-06 12:00:02,000 - __main__ - INFO - Analyzing Patient.ndjson.gz...
2024-09-06 12:00:02,500 - __main__ - INFO - File Patient.ndjson.gz: 100 resources
2024-09-06 12:00:02,501 - __main__ - INFO -   - Patient: 100
...
2024-09-06 12:00:10,000 - __main__ - INFO - Total resources to import: 50000
2024-09-06 12:00:10,100 - __main__ - INFO - Creating import manifest...
2024-09-06 12:00:10,200 - __main__ - INFO - Starting bulk import job...
2024-09-06 12:00:10,500 - __main__ - INFO - Import job started: http://localhost:8080/fhir/$import-poll-status/abc123
2024-09-06 12:00:10,600 - __main__ - INFO - Monitoring import job progress...
2024-09-06 12:00:20,000 - __main__ - INFO - Import job status: in-progress
2024-09-06 12:00:30,000 - __main__ - INFO - Import job status: in-progress
2024-09-06 12:02:40,000 - __main__ - INFO - Import job status: completed
2024-09-06 12:02:40,100 - __main__ - INFO - Bulk import completed successfully!
```

## File Structure

```
script/
├── fhir_bulk_loader.py    # Main loader script
├── config.py              # Configuration management
├── requirements.txt       # Python dependencies
└── README.md             # This file
```

## How It Works

1. **Discovery**: Scans the data directory for NDJSON.gz files matching the pattern
2. **Analysis**: Reads each compressed file to count resources by type
3. **Manifest Creation**: Creates a FHIR Parameters resource for the `$import` operation
4. **Job Submission**: Submits the import job to HAPI FHIR server
5. **Status Monitoring**: Polls the job status until completion or timeout
6. **Reporting**: Provides detailed progress and final status

## HAPI FHIR $import Operation

This script uses HAPI FHIR's bulk `$import` operation which:

- Accepts a FHIR Parameters resource describing the import job
- Processes files asynchronously on the server
- Returns a job URL for status monitoring
- Supports various file formats including NDJSON

### Import Manifest Format

The script creates a FHIR Parameters resource like this:

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "importJobId",
      "valueString": "uuid-here"
    },
    {
      "name": "importJobDescription",
      "valueString": "Bulk import of X FHIR NDJSON.gz files"
    },
    {
      "name": "input",
      "part": [
        {
          "name": "type",
          "valueCode": "ndjson"
        },
        {
          "name": "url",
          "valueUrl": "file:///absolute/path/to/file.ndjson.gz"
        },
        {
          "name": "format",
          "valueCode": "application/fhir+ndjson"
        },
        {
          "name": "resourceType",
          "valueString": "Patient"
        }
      ]
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. **Connection Failed**:
   - Ensure HAPI FHIR server is running
   - Check the URL and port configuration
   - Verify network connectivity

2. **Files Not Found**:
   - Check the data directory path
   - Ensure NDJSON.gz files exist in the directory
   - Verify file permissions

3. **Import Job Fails**:
   - Check HAPI FHIR server logs for detailed errors
   - Verify FHIR resource validity in NDJSON files
   - Ensure sufficient disk space and memory on server

4. **Timeout Issues**:
   - Increase `MAX_WAIT_TIME` for large datasets
   - Reduce `BATCH_SIZE` for memory-constrained environments
   - Check server performance and database connectivity

### Debugging

Enable debug logging:

```bash
export LOG_LEVEL="DEBUG"
python fhir_bulk_loader.py
```

Check HAPI FHIR server logs:

```bash
# If using Docker
docker logs hapi-fhir-server

# Check application logs
tail -f /path/to/hapi/logs/application.log
```

## Performance Considerations

- **File Size**: Large NDJSON.gz files will take longer to analyze
- **Resource Count**: More resources require longer processing time
- **Server Resources**: Ensure adequate CPU, memory, and disk space
- **Network**: Local server recommended for best performance
- **Concurrent Requests**: Adjust `MAX_CONCURRENT_REQUESTS` based on server capacity

## Security Notes

- The script uses file:// URLs which require server-side file access
- Ensure HAPI FHIR server has read permissions to the data files
- Consider using HTTP/HTTPS URLs for production deployments
- Validate FHIR resources before importing to prevent data corruption

## Contributing

To contribute to this script:

1. Follow PEP 8 coding standards
2. Add type hints to all functions
3. Include comprehensive error handling
4. Update documentation for new features
5. Add unit tests for new functionality

## License

This script is part of the FHIR Implementation Guide for Data Management project.