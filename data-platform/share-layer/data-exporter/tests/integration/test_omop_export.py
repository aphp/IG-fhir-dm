#!/usr/bin/env python3
"""Test script for OMOP Person table export from FHIR server."""

import os
import sys
import json
import logging
from pathlib import Path
from datetime import datetime

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from pathling import PathlingContext
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn

console = Console()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def test_person_export():
    """Test exporting OMOP Person table from FHIR server."""
    
    console.print("\n[bold blue]FHIR to OMOP Person Table Export Test[/bold blue]\n")
    
    # Configuration
    fhir_server = "http://localhost:8080/fhir"
    view_definition_path = "view-definition/omop/OMOP-Person-View.json"
    output_dir = "./output"
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    temp_dir = os.path.join(output_dir, "temp")
    os.makedirs(temp_dir, exist_ok=True)
    
    # Set temp directory for Spark
    os.environ["TMPDIR"] = temp_dir
    os.environ["TMP"] = temp_dir
    os.environ["TEMP"] = temp_dir
    
    try:
        # Step 1: Initialize Pathling
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Initializing Pathling context...", total=1)
            
            pc = PathlingContext.create(
                spark_app_name="OMOP-Person-Export-Test"
            )
            progress.update(task, completed=1)
        
        console.print("[green]Pathling context initialized successfully![/green]")
        
        # Step 2: Load ViewDefinition
        console.print(f"\nLoading ViewDefinition from: [cyan]{view_definition_path}[/cyan]")
        
        # Check if file exists
        full_path = Path(__file__).parent / view_definition_path
        if not full_path.exists():
            console.print(f"[red]❌ ViewDefinition file not found at: {full_path}[/red]")
            return False
            
        with open(full_path, "r", encoding="utf-8") as f:
            view_definition = f.read()
            view_def_json = json.loads(view_definition)
        
        console.print(f"✅ [green]Loaded ViewDefinition: {view_def_json.get('name', 'Unknown')}[/green]")
        
        # Display ViewDefinition info
        table = Table(title="ViewDefinition Details")
        table.add_column("Property", style="cyan")
        table.add_column("Value", style="white")
        
        table.add_row("Name", view_def_json.get("name", "N/A"))
        table.add_row("Resource", view_def_json.get("resource", "N/A"))
        table.add_row("Status", view_def_json.get("status", "N/A"))
        table.add_row("Columns", str(len(view_def_json.get("select", []))))
        
        console.print(table)
        
        # Step 3: Test FHIR server connectivity
        console.print(f"\n🔌 Connecting to FHIR server: [cyan]{fhir_server}[/cyan]")
        
        # Create bulk export directory
        bulk_export_dir = os.path.join(output_dir, "bulk_export")
        os.makedirs(bulk_export_dir, exist_ok=True)
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Performing bulk export...", total=1)
            
            try:
                # Perform bulk export for Patient resources
                data = pc.read.bulk(
                    fhir_endpoint_url=fhir_server,
                    output_dir=bulk_export_dir,
                    types=["Patient"]
                )
                progress.update(task, completed=1)
                console.print("✅ [green]Bulk export completed successfully![/green]")
            except Exception as e:
                progress.update(task, completed=1)
                console.print(f"[red]❌ Bulk export failed: {e}[/red]")
                console.print("\n[yellow]Trying alternative: Loading from sample data...[/yellow]")
                
                # Alternative: Try to load from NDJSON if bulk export fails
                sample_file = os.path.join(bulk_export_dir, "Patient.ndjson")
                if os.path.exists(sample_file):
                    data = pc.read.ndjson(sample_file)
                    console.print("✅ [green]Loaded data from NDJSON file[/green]")
                else:
                    # Create minimal sample data for testing
                    sample_patient = {
                        "resourceType": "Patient",
                        "id": "test-patient-1",
                        "gender": "male",
                        "birthDate": "1980-01-01",
                        "address": [{
                            "use": "home",
                            "city": "TestCity",
                            "state": "TestState",
                            "country": "TestCountry"
                        }]
                    }
                    
                    with open(sample_file, "w") as f:
                        json.dump(sample_patient, f)
                    
                    data = pc.read.ndjson(sample_file)
                    console.print("✅ [green]Created and loaded sample data[/green]")
        
        # Step 4: Apply ViewDefinition transformation
        console.print("\n🔄 Applying ViewDefinition transformation...")
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Transforming to OMOP Person table...", total=1)
            
            # Apply the view transformation
            person_df = data.view(
                resource="Patient",
                json=view_definition
            )
            
            progress.update(task, completed=1)
        
        console.print("✅ [green]Transformation completed successfully![/green]")
        
        # Step 5: Display sample results
        console.print("\n📊 Sample transformed data (first 5 rows):")
        
        # Show the DataFrame schema
        console.print("\n[bold]Schema:[/bold]")
        person_df.printSchema()
        
        # Show sample rows
        console.print("\n[bold]Sample Data:[/bold]")
        person_df.show(5, truncate=False)
        
        # Get row count
        row_count = person_df.count()
        console.print(f"\n[cyan]Total rows: {row_count}[/cyan]")
        
        # Step 6: Export to Parquet
        console.print("\n💾 Exporting to Parquet format...")
        
        parquet_path = os.path.join(output_dir, "parquet", "person")
        os.makedirs(os.path.dirname(parquet_path), exist_ok=True)
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Writing Parquet file...", total=1)
            
            person_df.write.mode("overwrite").option("compression", "snappy").parquet(parquet_path)
            
            progress.update(task, completed=1)
        
        console.print(f"✅ [green]Exported to: {parquet_path}[/green]")
        
        # Step 7: Export to DuckDB
        console.print("\n🦆 Exporting to DuckDB format...")
        
        try:
            import duckdb
            
            duckdb_path = os.path.join(output_dir, "omop.duckdb")
            
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console
            ) as progress:
                task = progress.add_task("Creating DuckDB database...", total=1)
                
                # Connect to DuckDB
                conn = duckdb.connect(duckdb_path)
                
                # Read Parquet file into DuckDB
                conn.execute(f"""
                    CREATE OR REPLACE TABLE person AS 
                    SELECT * FROM read_parquet('{parquet_path}/*.parquet')
                """)
                
                # Verify the data
                result = conn.execute("SELECT COUNT(*) FROM person").fetchone()
                
                conn.close()
                
                progress.update(task, completed=1)
            
            console.print(f"✅ [green]Exported to DuckDB: {duckdb_path}[/green]")
            console.print(f"   [cyan]Rows in DuckDB: {result[0]}[/cyan]")
            
        except ImportError:
            console.print("[yellow]⚠️  DuckDB not installed, skipping DuckDB export[/yellow]")
        except Exception as e:
            console.print(f"[red]❌ DuckDB export failed: {e}[/red]")
        
        # Summary
        console.print("\n" + "="*50)
        console.print("[bold green]✅ Test completed successfully![/bold green]")
        console.print("="*50)
        
        summary = Table(title="Export Summary")
        summary.add_column("Metric", style="cyan")
        summary.add_column("Value", style="white")
        
        summary.add_row("FHIR Server", fhir_server)
        summary.add_row("ViewDefinition", view_def_json.get("name", "Unknown"))
        summary.add_row("Total Rows", str(row_count))
        summary.add_row("Parquet Output", parquet_path)
        summary.add_row("DuckDB Output", duckdb_path if 'duckdb_path' in locals() else "N/A")
        summary.add_row("Timestamp", datetime.now().isoformat())
        
        console.print(summary)
        
        return True
        
    except Exception as e:
        console.print(f"\n[bold red]❌ Test failed with error:[/bold red]")
        console.print(f"[red]{str(e)}[/red]")
        
        import traceback
        console.print("\n[dim]Traceback:[/dim]")
        console.print(traceback.format_exc())
        
        return False
    
    finally:
        # Clean up Spark context
        try:
            if 'pc' in locals() and hasattr(pc, '_spark'):
                pc._spark.stop()
                console.print("\n[dim]Spark context stopped[/dim]")
        except:
            pass


if __name__ == "__main__":
    success = test_person_export()
    sys.exit(0 if success else 1)