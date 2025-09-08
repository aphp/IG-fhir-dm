"""Production-ready CLI for FHIR to OMOP data exporter."""

import argparse
import json
import sys
import signal
from pathlib import Path
from typing import Optional, Dict, Any
import structlog
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn
from rich import print as rprint

from config import Config, DataSourceType, OutputFormat, LogLevel
from fhir_exporter import FHIRExporter
from utils import FHIRExportError, create_error_report, format_file_size, set_main_progress_active

console = Console()
logger = structlog.get_logger(__name__)

class GracefulKiller:
    """Handle graceful shutdown on SIGINT/SIGTERM."""
    
    def __init__(self):
        self.kill_now = False
        signal.signal(signal.SIGINT, self._exit_gracefully)
        signal.signal(signal.SIGTERM, self._exit_gracefully)
    
    def _exit_gracefully(self, signum, frame):
        """Handle shutdown signals."""
        console.print("\n[yellow]Received shutdown signal. Cleaning up...[/yellow]")
        self.kill_now = True


def create_argument_parser() -> argparse.ArgumentParser:
    """Create and configure argument parser."""
    parser = argparse.ArgumentParser(
        description="Production-ready FHIR to OMOP data exporter",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Export Person table from local FHIR server
  %(prog)s --tables Person
  
  # Export multiple tables with custom configuration
  %(prog)s --config config.json --tables Person ConditionOccurrence
  
  # Export from file system with multiple output formats
  %(prog)s --data-source file_system --data-path ./fhir_data --formats parquet duckdb
  
  # Generate default configuration file
  %(prog)s --generate-config config.json
        """
    )
    
    # Configuration options
    config_group = parser.add_argument_group("Configuration")
    config_group.add_argument(
        "--config", "-c",
        type=Path,
        help="Load configuration from JSON file"
    )
    config_group.add_argument(
        "--generate-config",
        type=Path,
        help="Generate default configuration file and exit"
    )
    
    # Data source options
    source_group = parser.add_argument_group("Data Source")
    source_group.add_argument(
        "--data-source",
        choices=["fhir_server", "file_system"],
        default="fhir_server",
        help="Type of data source (default: fhir_server)"
    )
    source_group.add_argument(
        "--fhir-endpoint",
        default="http://localhost:8080/fhir",
        help="FHIR server endpoint URL (default: http://localhost:8080/fhir)"
    )
    source_group.add_argument(
        "--auth-token",
        help="Authentication token for FHIR server"
    )
    source_group.add_argument(
        "--data-path",
        type=Path,
        help="Path to FHIR data files (for file_system data source)"
    )
    source_group.add_argument(
        "--file-format",
        choices=["ndjson", "parquet"],
        default="ndjson",
        help="Format of data files (default: ndjson)"
    )
    
    # Processing options
    process_group = parser.add_argument_group("Processing")
    process_group.add_argument(
        "--tables",
        nargs="+",
        default=["Person"],
        help="OMOP tables to export (default: Person)"
    )
    process_group.add_argument(
        "--view-definitions-dir",
        type=Path,
        default="../../../fsh-generated/resources",
        help="Directory containing ViewDefinition files"
    )
    process_group.add_argument(
        "--resource-types",
        nargs="*",
        help="FHIR resource types for bulk export (default: all types)"
    )
    process_group.add_argument(
        "--disable-post-processing",
        action="store_true",
        help="Disable post-processing pipeline"
    )
    process_group.add_argument(
        "--disable-schema-validation",
        action="store_true",
        help="Disable schema validation"
    )
    
    # Output options
    output_group = parser.add_argument_group("Output")
    output_group.add_argument(
        "--output-dir",
        type=Path,
        default="./output",
        help="Base output directory (default: ./output)"
    )
    output_group.add_argument(
        "--formats",
        nargs="+",
        choices=["parquet", "duckdb", "csv"],
        default=["parquet"],
        help="Output formats (default: parquet)"
    )
    output_group.add_argument(
        "--compression",
        choices=["snappy", "gzip", "lz4", "brotli", "none"],
        default="snappy",
        help="Parquet compression algorithm (default: snappy)"
    )
    
    # Schema validation options
    schema_group = parser.add_argument_group("Schema Validation")
    schema_group.add_argument(
        "--ddl-file",
        type=Path,
        help="Path to OMOP DDL file for schema validation"
    )
    
    # Logging options
    log_group = parser.add_argument_group("Logging")
    log_group.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging level (default: INFO)"
    )
    log_group.add_argument(
        "--log-file",
        type=Path,
        help="Write logs to file"
    )
    log_group.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Suppress progress output"
    )
    log_group.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose logging"
    )
    
    # Performance options
    perf_group = parser.add_argument_group("Performance")
    perf_group.add_argument(
        "--max-memory",
        type=int,
        default=4096,
        help="Maximum memory usage in MB (default: 4096)"
    )
    perf_group.add_argument(
        "--executor-memory",
        default="2g",
        help="Spark executor memory (default: 2g)"
    )
    perf_group.add_argument(
        "--driver-memory",
        default="2g",
        help="Spark driver memory (default: 2g)"
    )
    
    return parser


def generate_default_config(output_path: Path) -> None:
    """Generate default configuration file."""
    try:
        config = Config()
        config.to_file(output_path)
        console.print(f"[green]OK[/green] Default configuration generated: {output_path}")
    except Exception as e:
        console.print(f"[red]ERROR[/red] Failed to generate configuration: {e}")
        sys.exit(1)


def load_config_from_args(args: argparse.Namespace) -> Config:
    """Load configuration from command line arguments."""
    if args.config:
        # Load from file and override with CLI args
        config = Config.from_file(args.config)
    else:
        # Create default config
        config = Config()
    
    # Override with CLI arguments
    if hasattr(args, 'data_source') and args.data_source:
        config.data_source_type = DataSourceType(args.data_source)
    
    # FHIR Server configuration
    if args.fhir_endpoint:
        config.fhir_server.endpoint_url = args.fhir_endpoint
    if args.auth_token:
        config.fhir_server.auth_token = args.auth_token
    if args.resource_types is not None:
        config.fhir_server.bulk_export_types = args.resource_types
    
    # File system configuration
    if args.data_path:
        from config import FileSystemConfig
        config.file_system = FileSystemConfig(
            data_path=args.data_path,
            file_format=args.file_format or "ndjson"
        )
    
    # Processing configuration
    if args.tables:
        config.omop_tables = args.tables
    if args.view_definitions_dir:
        config.view_definitions_dir = args.view_definitions_dir
    
    # Post-processing configuration
    if args.disable_post_processing:
        config.post_processing.enabled = False
    
    # Schema validation configuration
    if args.disable_schema_validation:
        config.schema_validation.enabled = False
    if args.ddl_file:
        config.schema_validation.ddl_file = args.ddl_file
    
    # Output configuration
    if args.output_dir:
        config.output.base_path = args.output_dir
    if args.formats:
        config.output.formats = [OutputFormat(fmt) for fmt in args.formats]
    if args.compression:
        config.output.parquet_compression = args.compression
    
    # Logging configuration
    if args.log_level:
        config.log_level = LogLevel(args.log_level)
    if args.verbose:
        config.log_level = LogLevel.DEBUG
    if args.log_file:
        config.log_file = args.log_file
    
    # Performance configuration
    if args.max_memory:
        config.max_memory_usage_mb = args.max_memory
    if args.executor_memory:
        config.pathling.executor_memory = args.executor_memory
    if args.driver_memory:
        config.pathling.driver_memory = args.driver_memory
    
    return config


def display_export_summary(results: Dict[str, Any], quiet: bool = False) -> None:
    """Display export summary in a formatted table."""
    if quiet:
        return
    
    console.print("\n[bold]Export Summary[/bold]")
    
    # Create summary table
    table = Table(show_header=True, header_style="bold magenta")
    table.add_column("Table", style="cyan", no_wrap=True)
    table.add_column("Status", justify="center")
    table.add_column("Rows", justify="right", style="green")
    table.add_column("Formats", justify="center")
    
    for table_name, result in results["table_results"].items():
        status = result["status"]
        if status == "success":
            status_display = "[green]OK Success[/green]"
            rows_display = str(result["rows"])
            formats_display = str(len(result["output_files"]))
        elif status == "empty_result":
            status_display = "[yellow]⚠ Empty[/yellow]"
            rows_display = "0"
            formats_display = "0"
        else:
            status_display = "[red]ERROR Failed[/red]"
            rows_display = "0"
            formats_display = "0"
        
        table.add_row(table_name, status_display, rows_display, formats_display)
    
    console.print(table)
    
    # Overall statistics
    console.print(f"\n[bold]Overall Results:[/bold]")
    console.print(f"  - Total tables: {results['total_tables']}")
    console.print(f"  - Successful: [green]{results['successful_exports']}[/green]")
    console.print(f"  - Failed: [red]{results['failed_exports']}[/red]")
    
    # Output summary
    if "output_summary" in results:
        output_summary = results["output_summary"]
        console.print(f"  - Total output size: [cyan]{output_summary['total_size_formatted']}[/cyan]")
        console.print(f"  - Output formats: {', '.join(output_summary['formats'])}")


def handle_export_error(error: Exception, verbose: bool = False) -> None:
    """Handle and display export errors."""
    if isinstance(error, FHIRExportError):
        console.print(f"[red]ERROR Export Error:[/red] {error.message}")
        
        if error.details:
            console.print("\n[yellow]Error Details:[/yellow]")
            if "error_report" in error.details:
                error_report = error.details["error_report"]
                console.print(f"  - Error Type: {error_report['error_type']}")
                console.print(f"  - Timestamp: {error_report['timestamp']}")
                if verbose and "traceback" in error_report:
                    console.print("\n[dim]Traceback:[/dim]")
                    console.print(error_report["traceback"])
    else:
        console.print(f"[red]ERROR Unexpected Error:[/red] {str(error)}")
        if verbose:
            import traceback
            console.print("\n[dim]Traceback:[/dim]")
            console.print(traceback.format_exc())


def main() -> None:
    """Main entry point."""
    parser = create_argument_parser()
    args = parser.parse_args()
    
    # Handle configuration generation
    if args.generate_config:
        generate_default_config(args.generate_config)
        return
    
    # Set up graceful shutdown handling
    killer = GracefulKiller()
    
    try:
        # Load configuration
        config = load_config_from_args(args)
        
        # Validate configuration
        config_issues = config.validate_configuration()
        if config_issues:
            console.print("[yellow]⚠ Configuration Issues:[/yellow]")
            for issue in config_issues:
                console.print(f"  - {issue}")
            
            if not console.confirm("\nContinue despite configuration issues?"):
                sys.exit(1)
        
        # Display configuration summary if verbose
        if args.verbose and not args.quiet:
            console.print("\n[bold]Configuration Summary:[/bold]")
            summary = config.get_configuration_summary()
            for key, value in summary.items():
                console.print(f"  - {key}: {value}")
        
        # Create and initialize exporter
        console.print(f"\n[bold]Initializing FHIR to Analytisc Exporter[/bold]")
        
        with FHIRExporter(config) as exporter:
            # Check for shutdown signal during initialization
            if killer.kill_now:
                console.print("[yellow]Shutdown requested during initialization[/yellow]")
                return
            
            console.print("Initializing components...")
            exporter.initialize()
            
            if not args.quiet:
                console.print(f"[green]OK[/green] Initialization completed")
                console.print(f"  - Data source: {config.data_source_type.value}")
                console.print(f"  - Tables to export: {', '.join(config.omop_tables)}")
                console.print(f"  - Output formats: {', '.join([fmt.value for fmt in config.output.formats])}")
            
            # Check for shutdown signal before export
            if killer.kill_now:
                console.print("[yellow]Shutdown requested before export[/yellow]")
                return
            
            # Run export
            console.print(f"\n[bold]Starting Export Process[/bold]")
            
            if args.quiet:
                results = exporter.export_all_tables()
            else:
                set_main_progress_active(True)
                try:
                    with Progress(
                        TextColumn("[progress.description]{task.description}"),
                        BarColumn(),
                        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
                        TimeRemainingColumn(),
                        console=console
                    ) as progress:
                        task = progress.add_task("Exporting tables...", total=len(config.omop_tables))
                        
                        # Export tables one by one to show progress
                        results = {"table_results": {}, "successful_exports": 0, "failed_exports": 0}
                        
                        for i, table_name in enumerate(config.omop_tables):
                            if killer.kill_now:
                                console.print(f"[yellow]Shutdown requested during export of {table_name}[/yellow]")
                                break
                            
                            progress.update(task, description=f"Exporting {table_name}...")
                            
                            try:
                                result = exporter.export_table(table_name)
                                results["table_results"][table_name] = result
                                
                                if result["status"] == "success":
                                    results["successful_exports"] += 1
                                else:
                                    results["failed_exports"] += 1
                                    
                            except Exception as e:
                                results["table_results"][table_name] = {
                                    "table_name": table_name,
                                    "status": "failed",
                                    "error": str(e),
                                    "rows": 0,
                                    "output_files": {}
                                }
                                results["failed_exports"] += 1
                            
                            progress.advance(task)
                        
                        # Calculate totals
                        results["total_tables"] = len(config.omop_tables)
                        
                        # Get output summary for successful exports
                        if results["successful_exports"] > 0:
                            try:
                                successful_tables = [
                                    name for name, result in results["table_results"].items() 
                                    if result["status"] == "success"
                                ]
                                results["output_summary"] = exporter.output_writer.get_output_summary(successful_tables)
                            except Exception:
                                pass  # Skip output summary if it fails
                finally:
                    set_main_progress_active(False)
            
            # Display results
            if not killer.kill_now:
                display_export_summary(results, args.quiet)
                
                # Exit with appropriate code
                if results["failed_exports"] > 0:
                    console.print(f"\n[red]Export completed with {results['failed_exports']} failures[/red]")
                    sys.exit(1)
                else:
                    console.print(f"\n[green]OK All exports completed successfully![/green]")
    
    except KeyboardInterrupt:
        console.print("\n[yellow]Export interrupted by user[/yellow]")
        sys.exit(130)
    
    except Exception as e:
        handle_export_error(e, args.verbose if hasattr(args, 'verbose') else False)
        sys.exit(1)


if __name__ == "__main__":
    main()