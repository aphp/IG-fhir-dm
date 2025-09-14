# FHIR to OMOP Data Exporter

This Python application exports FHIR resources from a HAPI FHIR server and transforms them into OMOP Common Data Model format using Pathling and SQL-on-FHIR ViewDefinitions.

## Features

- **Asynchronous FHIR Bulk Export**: Uses FHIR Bulk Data Access API (`$export`) to efficiently retrieve large datasets
- **SQL-on-FHIR Transformation**: Leverages ViewDefinitions to transform FHIR resources into OMOP tables
- **Parquet Output**: Exports data in Apache Parquet format for efficient storage and analysis
- **Configurable**: Supports various configuration options via command line or environment variables

## Requirements

- Python 3.8+
- Apache Spark (automatically handled by Pathling)
- HAPI FHIR Server with Bulk Data Export support

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Ensure your HAPI FHIR server is running and accessible

## Usage

### Basic Usage (Person Table)

Export the OMOP Person table from FHIR Patient resources:

```bash
python main.py
```

### Advanced Usage

```bash
python main.py \
    --fhir-endpoint http://localhost:8080/fhir \
    --output-dir ./output \
    --tables Person VisitOccurrence \
    --resource-types Patient Encounter \
    --verbose
```

### Command Line Options

- `--fhir-endpoint`: FHIR server endpoint URL (default: http://localhost:8080/fhir)
- `--output-dir`: Output directory for Parquet files (default: ./output)
- `--view-definitions-dir`: Directory containing ViewDefinition files
- `--tables`: OMOP tables to export (default: Person)
- `--resource-types`: FHIR resource types for bulk export (default: all types)
- `--verbose`: Enable verbose logging

### Environment Variables

You can also configure the application using environment variables:

- `FHIR_ENDPOINT_URL`: FHIR server endpoint
- `OUTPUT_DIR`: Output directory
- `VIEW_DEFINITIONS_DIR`: ViewDefinition files directory

## Architecture

The application consists of several components:

1. **Config**: Configuration management
2. **FHIRExporter**: Main export logic using Pathling
3. **ViewDefinitions**: JSON files defining FHIR to OMOP transformations

### Workflow

1. **Bulk Export**: Retrieve FHIR resources using the `$export` operation
2. **Transform**: Apply SQL-on-FHIR ViewDefinitions to transform resources
3. **Export**: Save transformed data as Parquet files

## ViewDefinitions

ViewDefinition files are located in `fsh-generated/resources/` and follow the naming pattern:
`Binary-OMOP-{TableName}-View.json`

Each ViewDefinition specifies how to map FHIR resource fields to OMOP table columns.

## Output

The application creates Parquet files in the specified output directory:
```
output/
├── parquet/
│   ├── person.parquet
│   ├── visit_occurrence.parquet
│   └── ...
└── bulk_export_temp/
    └── (temporary NDJSON files from bulk export)
```

## Testing

Start with the Person table to test the basic functionality:

```bash
python main.py --tables Person --verbose
```

## Troubleshooting

1. **Spark Issues**: Ensure Java is installed and JAVA_HOME is set
2. **FHIR Server**: Verify the server supports Bulk Data Export
3. **ViewDefinitions**: Check that ViewDefinition files exist and are valid JSON
4. **Permissions**: Ensure write permissions for the output directory

## Configuration

The default configuration connects to a HAPI FHIR server at `http://localhost:8080/fhir` and exports to the `./output` directory. Modify `config.py` for additional customization options.