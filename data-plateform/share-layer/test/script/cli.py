"""Command Line Interface for FHIR Bulk Loader.

This module provides a CLI wrapper around the FHIR bulk loader with
additional features like validation, file analysis, and enhanced output.
"""

import asyncio
import sys
from pathlib import Path
from typing import List, Optional

import click
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn

from config import Config
from fhir_bulk_loader import FhirBulkLoader
from utils import FhirResourceValidator, FileProcessor, ProgressReporter, format_file_size, estimate_import_time

console = Console()


@click.group()
@click.version_option(version="1.0.0", prog_name="FHIR Bulk Loader")
def cli():
    """FHIR Bulk Loader - Import NDJSON.gz files into HAPI FHIR server."""
    pass


@cli.command()
@click.option('--url', default='http://localhost:8080/fhir', help='HAPI FHIR server URL')
@click.option('--timeout', default=30, help='Connection timeout in seconds')
async def test_connection(url: str, timeout: int):
    """Test connection to HAPI FHIR server."""
    config = Config.from_env()
    config.hapi_fhir.base_url = url
    config.hapi_fhir.timeout = timeout
    
    console.print(f"Testing connection to {url}...", style="blue")
    
    async with FhirBulkLoader(config) as loader:
        success = await loader.test_connection()
        if success:
            console.print("✅ Connection successful!", style="green")
        else:
            console.print("❌ Connection failed!", style="red")
            sys.exit(1)


@cli.command()
@click.option('--data-dir', default='../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir', 
              help='Directory containing NDJSON.gz files')
@click.option('--pattern', default='*.ndjson.gz', help='File pattern to match')
@click.option('--validate', is_flag=True, help='Validate FHIR resources in files')
def analyze(data_dir: str, pattern: str, validate: bool):
    """Analyze NDJSON.gz files without importing."""
    data_path = Path(data_dir)
    
    if not data_path.exists():
        console.print(f"❌ Data directory not found: {data_path}", style="red")
        sys.exit(1)
    
    files = list(data_path.glob(pattern))
    if not files:
        console.print(f"❌ No files found matching pattern: {pattern}", style="red")
        sys.exit(1)
    
    console.print(f"Found {len(files)} files to analyze", style="blue")
    
    # Create summary table
    table = Table(title="File Analysis Summary")
    table.add_column("File", style="cyan")
    table.add_column("Size", justify="right")
    table.add_column("Resources", justify="right")
    table.add_column("Resource Types", justify="right")
    
    if validate:
        table.add_column("Valid", justify="right", style="green")
        table.add_column("Invalid", justify="right", style="red")
    
    total_size = 0
    total_resources = 0
    total_valid = 0
    total_invalid = 0
    all_resource_types = set()
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        console=console
    ) as progress:
        task = progress.add_task("Analyzing files...", total=len(files))
        
        for file_path in files:
            progress.update(task, description=f"Analyzing {file_path.name}")
            
            stats = FileProcessor.get_file_stats(file_path)
            total_size += stats['file_size_bytes']
            total_resources += stats['total_resources']
            all_resource_types.update(stats['resource_counts'].keys())
            
            resource_types_str = ", ".join(f"{k}({v})" for k, v in stats['resource_counts'].items())
            
            if validate:
                validation = FhirResourceValidator.validate_ndjson_file(file_path)
                total_valid += validation['valid_resources']
                total_invalid += validation['invalid_resources']
                
                table.add_row(
                    file_path.name,
                    format_file_size(stats['file_size_bytes']),
                    str(stats['total_resources']),
                    resource_types_str,
                    str(validation['valid_resources']),
                    str(validation['invalid_resources'])
                )
            else:
                table.add_row(
                    file_path.name,
                    format_file_size(stats['file_size_bytes']),
                    str(stats['total_resources']),
                    resource_types_str
                )
            
            progress.update(task, advance=1)
    
    console.print(table)
    
    # Summary statistics
    console.print("\n📊 Summary:", style="bold blue")
    console.print(f"  Total files: {len(files)}")
    console.print(f"  Total size: {format_file_size(total_size)}")
    console.print(f"  Total resources: {total_resources:,}")
    console.print(f"  Resource types: {', '.join(sorted(all_resource_types))}")
    console.print(f"  Estimated import time: {estimate_import_time(total_resources)}")
    
    if validate:
        console.print(f"  Valid resources: {total_valid:,}", style="green")
        console.print(f"  Invalid resources: {total_invalid:,}", style="red")
        if total_invalid > 0:
            console.print("⚠️  Some resources have validation errors. Check logs for details.", style="yellow")


@cli.command()
@click.option('--data-dir', default='../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir',
              help='Directory containing NDJSON.gz files')
@click.option('--pattern', default='*.ndjson.gz', help='File pattern to match')
@click.option('--url', default='http://localhost:8080/fhir', help='HAPI FHIR server URL')
@click.option('--batch-size', default=1000, help='Batch size for processing')
@click.option('--max-wait', default=3600, help='Maximum wait time for import (seconds)')
@click.option('--validate-first', is_flag=True, help='Validate files before importing')
@click.option('--dry-run', is_flag=True, help='Show what would be imported without actually importing')
def import_data(data_dir: str, pattern: str, url: str, batch_size: int, max_wait: int,
               validate_first: bool, dry_run: bool):
    """Import FHIR NDJSON.gz files into HAPI FHIR server."""
    
    config = Config.from_env()
    config.hapi_fhir.base_url = url
    config.import_settings.data_directory = data_dir
    config.import_settings.file_pattern = pattern
    config.import_settings.batch_size = batch_size
    config.import_settings.max_wait_time = max_wait
    
    try:
        config.validate()
    except ValueError as e:
        console.print(f"❌ Configuration error: {e}", style="red")
        sys.exit(1)
    
    # Discover files
    data_path = Path(data_dir)
    files = list(data_path.glob(pattern))
    
    if not files:
        console.print(f"❌ No files found matching pattern: {pattern}", style="red")
        sys.exit(1)
    
    console.print(f"Found {len(files)} files for import", style="blue")
    
    # Validate files if requested
    if validate_first:
        console.print("🔍 Validating files before import...", style="blue")
        
        total_invalid = 0
        for file_path in files:
            validation = FhirResourceValidator.validate_ndjson_file(file_path, max_errors=5)
            if validation['invalid_resources'] > 0:
                total_invalid += validation['invalid_resources']
                console.print(f"⚠️  {file_path.name}: {validation['invalid_resources']} invalid resources", style="yellow")
        
        if total_invalid > 0:
            console.print(f"❌ Found {total_invalid} invalid resources across all files", style="red")
            if not click.confirm("Continue with import despite validation errors?"):
                sys.exit(1)
        else:
            console.print("✅ All files passed validation", style="green")
    
    if dry_run:
        console.print("🔍 Dry run - showing import plan:", style="blue")
        
        total_resources = 0
        for file_path in files:
            stats = FileProcessor.get_file_stats(file_path)
            total_resources += stats['total_resources']
            console.print(f"  📄 {file_path.name}: {stats['total_resources']} resources")
        
        console.print(f"\n📊 Total: {total_resources:,} resources would be imported", style="bold")
        console.print(f"⏱️  Estimated time: {estimate_import_time(total_resources)}")
        return
    
    # Confirm import
    if not click.confirm(f"Import {len(files)} files into {url}?"):
        console.print("Import cancelled", style="yellow")
        return
    
    # Run import
    console.print("🚀 Starting bulk import...", style="green")
    
    async def run_import():
        async with FhirBulkLoader(config) as loader:
            success = await loader.run()
            return success
    
    success = asyncio.run(run_import())
    
    if success:
        console.print("✅ Import completed successfully!", style="green")
    else:
        console.print("❌ Import failed!", style="red")
        sys.exit(1)


@cli.command()
@click.option('--file-path', required=True, help='Path to NDJSON.gz file to validate')
@click.option('--max-errors', default=10, help='Maximum number of errors to display')
def validate(file_path: str, max_errors: int):
    """Validate a single NDJSON.gz file."""
    path = Path(file_path)
    
    if not path.exists():
        console.print(f"❌ File not found: {path}", style="red")
        sys.exit(1)
    
    console.print(f"🔍 Validating {path.name}...", style="blue")
    
    with console.status("Analyzing file..."):
        validation = FhirResourceValidator.validate_ndjson_file(path, max_errors)
    
    # Results
    console.print("\n📊 Validation Results:", style="bold blue")
    console.print(f"  Total resources: {validation['total_resources']:,}")
    console.print(f"  Valid resources: {validation['valid_resources']:,}", style="green")
    console.print(f"  Invalid resources: {validation['invalid_resources']:,}", 
                 style="red" if validation['invalid_resources'] > 0 else "green")
    
    # Resource types
    if validation['resource_types']:
        console.print("\n📋 Resource Types:", style="bold blue")
        for resource_type, count in sorted(validation['resource_types'].items()):
            console.print(f"  {resource_type}: {count:,}")
    
    # Errors
    if validation['errors']:
        console.print(f"\n🚨 Validation Errors (showing first {len(validation['errors'])}):", style="bold red")
        for error in validation['errors']:
            console.print(f"  Line {error['line']} ({error['resource_type']}):")
            for err_msg in error['errors']:
                console.print(f"    • {err_msg}", style="red")
    
    if validation['invalid_resources'] == 0:
        console.print("\n✅ File validation passed!", style="green")
    else:
        console.print(f"\n❌ File has {validation['invalid_resources']} validation errors", style="red")
        sys.exit(1)


def main():
    """Main CLI entry point."""
    cli()


if __name__ == "__main__":
    main()