#!/usr/bin/env python3
"""
Main script for loading Parquet files into DuckDB with OMOP CDM schema.

This script provides a complete solution for:
1. Loading Parquet files from a configurable directory
2. Creating DuckDB database with OMOP CDM schema
3. Loading and transforming data into OMOP-compatible format
4. Performance optimization for large datasets
"""

import sys
from pathlib import Path
from typing import Optional
import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from loguru import logger

from config import DatabaseConfig, config
from db_utils import DuckDBManager
from loader import ParquetLoader


app = typer.Typer(help="Load Parquet files into DuckDB with OMOP CDM schema")
console = Console()


def display_banner():
    """Display application banner."""
    banner = """
[bold blue]Parquet to DuckDB Loader[/bold blue]
[dim]OMOP CDM Schema Support | High Performance Analytics[/dim]
"""
    console.print(Panel(banner, border_style="blue"))


def display_config_info(config: DatabaseConfig):
    """Display configuration information."""
    table = Table(title="Configuration", border_style="green")
    table.add_column("Setting", style="bold")
    table.add_column("Value", style="cyan")
    
    table.add_row("Input Directory", str(config.input_directory))
    table.add_row("Output Directory", str(config.output_directory))
    table.add_row("Database Name", config.database_name)
    table.add_row("Schema Name", config.schema_name)
    table.add_row("Memory Limit", config.memory_limit)
    table.add_row("Threads", str(config.threads))
    table.add_row("Log Level", config.log_level)
    
    console.print(table)


def display_results_summary(results: dict, db_info: dict):
    """Display loading results summary."""
    # Loading results table
    results_table = Table(title="Loading Results", border_style="green")
    results_table.add_column("Metric", style="bold")
    results_table.add_column("Value", style="cyan")
    
    results_table.add_row("Total Files", str(results["total_files"]))
    results_table.add_row("Successful Loads", str(results["successful_loads"]))
    results_table.add_row("Failed Loads", str(results["failed_loads"]))
    results_table.add_row("Loaded Tables", ", ".join(results["loaded_tables"]))
    
    console.print(results_table)
    
    # Database info table
    if db_info:
        db_table = Table(title="Database Information", border_style="blue")
        db_table.add_column("Metric", style="bold")
        db_table.add_column("Value", style="cyan")
        
        db_table.add_row("Database Path", db_info["database_path"])
        db_table.add_row("Schema Name", db_info["schema_name"])
        db_table.add_row("Total Tables", str(db_info["total_tables"]))
        db_table.add_row("Total Rows", f"{db_info['total_rows']:,}")
        
        console.print(db_table)
        
        # Table statistics
        if db_info["table_statistics"]:
            stats_table = Table(title="Table Statistics", border_style="yellow")
            stats_table.add_column("Table Name", style="bold")
            stats_table.add_column("Row Count", style="cyan", justify="right")
            
            for table_name, count in db_info["table_statistics"].items():
                if count > 0:  # Only show tables with data
                    stats_table.add_row(table_name, f"{count:,}")
            
            console.print(stats_table)
    
    # Errors if any
    if results["errors"]:
        console.print("\n[bold red]Errors encountered:[/bold red]")
        for error in results["errors"]:
            console.print(f"  • {error}", style="red")


@app.command()
def load(
    input_dir: Optional[Path] = typer.Option(
        None, "--input", "-i", help="Input directory containing Parquet files"
    ),
    output_dir: Optional[Path] = typer.Option(
        None, "--output", "-o", help="Output directory for DuckDB database"
    ),
    db_name: Optional[str] = typer.Option(
        None, "--database", "-d", help="Database name"
    ),
    schema_name: Optional[str] = typer.Option(
        None, "--schema", "-s", help="Schema name for OMOP tables"
    ),
    memory_limit: Optional[str] = typer.Option(
        None, "--memory", "-m", help="DuckDB memory limit (e.g., '4GB')"
    ),
    threads: Optional[int] = typer.Option(
        None, "--threads", "-t", help="Number of threads for DuckDB"
    ),
    log_level: Optional[str] = typer.Option(
        None, "--log-level", "-l", help="Logging level (DEBUG, INFO, WARNING, ERROR)"
    ),
    skip_ddl: bool = typer.Option(
        False, "--skip-ddl", help="Skip OMOP DDL creation (use existing schema)"
    ),
    skip_constraints: bool = typer.Option(
        False, "--skip-constraints", help="Skip loading OMOP constraints and indices"
    ),
    force: bool = typer.Option(
        False, "--force", "-f", help="Force overwrite existing database"
    )
):
    """Load Parquet files into DuckDB with OMOP CDM schema."""
    
    display_banner()
    
    try:
        # Override configuration with command line arguments
        if input_dir:
            config.input_directory = input_dir.resolve()
        if output_dir:
            config.output_directory = output_dir.resolve()
        if db_name:
            config.database_name = db_name
        if schema_name:
            config.schema_name = schema_name
        if memory_limit:
            config.memory_limit = memory_limit
        if threads:
            config.threads = threads
        if log_level:
            config.log_level = log_level.upper()
        
        # Setup logging and directories
        config.setup_logging()
        config.create_directories()
        
        # Validate configuration
        if not config.validate_directories():
            console.print("[bold red]Configuration validation failed![/bold red]")
            raise typer.Exit(1)
        
        display_config_info(config)
        
        # Check if database exists and handle force flag
        if config.database_path.exists() and not force:
            console.print(f"\n[yellow]Database already exists: {config.database_path}[/yellow]")
            if not typer.confirm("Do you want to continue and potentially modify the existing database?"):
                console.print("Operation cancelled.")
                raise typer.Exit(0)
        elif force and config.database_path.exists():
            logger.info(f"Force flag enabled, will overwrite existing database: {config.database_path}")
            config.database_path.unlink()
        
        # Initialize database manager
        with DuckDBManager(config) as db_manager:
            logger.info("Initializing database and schema...")
            
            # Create schema
            db_manager.create_schema()
            
            # Load OMOP DDL if not skipping
            if not skip_ddl:
                console.print("\n[bold yellow]Loading OMOP CDM DDL...[/bold yellow]")
                db_manager.load_omop_ddl()
            else:
                logger.info("Skipping OMOP DDL creation")
            
            # Load constraints and indices if not skipping
            if not skip_constraints:
                console.print("[bold yellow]Loading OMOP constraints and indices...[/bold yellow]")
                db_manager.load_omop_constraints()
            else:
                logger.info("Skipping OMOP constraints and indices")
            
            # Initialize Parquet loader
            parquet_loader = ParquetLoader(config, db_manager)
            
            # Load all Parquet files
            console.print("\n[bold yellow]Loading Parquet files...[/bold yellow]")
            results = parquet_loader.load_all_parquet_files()
            
            # Get database information
            db_info = db_manager.get_database_info()
            
        # Display results
        console.print("\n")
        display_results_summary(results, db_info)
        
        # Final status
        if results["success"]:
            console.print("\n[bold green]SUCCESS: Loading completed successfully![/bold green]")
            console.print(f"Database created at: [cyan]{config.database_path}[/cyan]")
        else:
            console.print("\n[bold red]ERROR: Loading failed![/bold red]")
            raise typer.Exit(1)
            
    except KeyboardInterrupt:
        console.print("\n[yellow]Operation cancelled by user[/yellow]")
        raise typer.Exit(130)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        console.print(f"\n[bold red]Error: {e}[/bold red]")
        raise typer.Exit(1)


@app.command()
def info(
    database: Optional[Path] = typer.Option(
        None, "--database", "-d", help="Path to DuckDB database file"
    )
):
    """Display information about an existing DuckDB database."""
    
    db_path = database or config.database_path
    
    if not db_path.exists():
        console.print(f"[bold red]Database not found: {db_path}[/bold red]")
        raise typer.Exit(1)
    
    try:
        # Temporarily override database path
        temp_config = config.model_copy()
        temp_config.database_name = db_path.stem
        temp_config.output_directory = db_path.parent
        
        with DuckDBManager(temp_config) as db_manager:
            db_info = db_manager.get_database_info()
            
            if db_info:
                display_results_summary({"total_files": 0, "successful_loads": 0, "failed_loads": 0, "loaded_tables": [], "errors": []}, db_info)
            else:
                console.print("[bold red]Failed to retrieve database information[/bold red]")
                
    except Exception as e:
        console.print(f"[bold red]Error accessing database: {e}[/bold red]")
        raise typer.Exit(1)


@app.command()
def validate(
    database: Optional[Path] = typer.Option(
        None, "--database", "-d", help="Path to DuckDB database file"
    )
):
    """Validate the loaded data and run basic quality checks."""
    
    db_path = database or config.database_path
    
    if not db_path.exists():
        console.print(f"[bold red]Database not found: {db_path}[/bold red]")
        raise typer.Exit(1)
    
    console.print("[bold blue]Running data validation...[/bold blue]")
    
    try:
        from test_queries import DataValidator
        
        # Temporarily override database path
        temp_config = config.model_copy()
        temp_config.database_name = db_path.stem
        temp_config.output_directory = db_path.parent
        
        with DuckDBManager(temp_config) as db_manager:
            validator = DataValidator(temp_config, db_manager)
            validation_results = validator.run_all_validations()
            
            # Display validation results
            results_table = Table(title="Validation Results", border_style="green")
            results_table.add_column("Check", style="bold")
            results_table.add_column("Status", style="cyan")
            results_table.add_column("Details")
            
            for check, result in validation_results.items():
                status = "PASS" if result["passed"] else "FAIL"
                results_table.add_row(check, status, result.get("message", ""))
            
            console.print(results_table)
            
    except ImportError:
        console.print("[yellow]Data validation module not available[/yellow]")
    except Exception as e:
        console.print(f"[bold red]Validation error: {e}[/bold red]")
        raise typer.Exit(1)


if __name__ == "__main__":
    app()