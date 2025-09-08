#!/usr/bin/env python3
"""
Demonstration script showing the Parquet to DuckDB solution.

This script demonstrates the key functionality without requiring
all dependencies to be installed.
"""

import sys
from pathlib import Path
import pandas as pd
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

console = Console()

def demo_parquet_analysis():
    """Demonstrate Parquet file analysis capabilities."""
    console.print(Panel("[bold blue]Parquet to DuckDB Analytics Demo[/bold blue]", border_style="blue"))
    
    # Check for existing Parquet files
    input_dir = Path("../script/output")
    parquet_files = list(input_dir.glob("*.parquet"))
    
    if not parquet_files:
        console.print(f"[yellow]No Parquet files found in {input_dir}[/yellow]")
        console.print("Please ensure Parquet files are available for the demo.")
        return
    
    console.print(f"\n[green]Found {len(parquet_files)} Parquet files:[/green]")
    
    for file_path in parquet_files:
        console.print(f"  • {file_path.name}")
    
    # Analyze the first Parquet file
    first_file = parquet_files[0]
    console.print(f"\n[bold]Analyzing: {first_file.name}[/bold]")
    
    try:
        # Load with pandas
        df = pd.read_parquet(first_file)
        
        # Display basic information
        info_table = Table(title="File Information", border_style="green")
        info_table.add_column("Property", style="bold")
        info_table.add_column("Value", style="cyan")
        
        info_table.add_row("File Size", f"{first_file.stat().st_size / 1024:.1f} KB")
        info_table.add_row("Row Count", f"{len(df):,}")
        info_table.add_row("Column Count", str(len(df.columns)))
        info_table.add_row("Memory Usage", f"{df.memory_usage(deep=True).sum() / 1024:.1f} KB")
        
        console.print(info_table)
        
        # Display column information
        columns_table = Table(title="Column Information", border_style="blue")
        columns_table.add_column("Column Name", style="bold")
        columns_table.add_column("Data Type", style="cyan")
        columns_table.add_column("Non-Null Count", style="green")
        
        for col in df.columns:
            non_null_count = df[col].count()
            columns_table.add_row(col, str(df[col].dtype), f"{non_null_count:,}")
        
        console.print(columns_table)
        
        # Display sample data
        if not df.empty:
            console.print("\n[bold]Sample Data (first 3 rows):[/bold]")
            
            sample_table = Table(border_style="yellow")
            
            # Add columns
            for col in df.columns:
                sample_table.add_column(col, style="cyan")
            
            # Add sample rows
            for i in range(min(3, len(df))):
                row = [str(df.iloc[i][col]) for col in df.columns]
                sample_table.add_row(*row)
            
            console.print(sample_table)
        
        # Demonstrate column mapping
        console.print("\n[bold]Potential OMOP CDM Mapping:[/bold]")
        
        mapping_table = Table(border_style="magenta")
        mapping_table.add_column("Source Column", style="bold")
        mapping_table.add_column("Suggested OMOP Column", style="cyan")
        mapping_table.add_column("OMOP Table", style="green")
        
        # Basic FHIR to OMOP mappings
        column_mappings = {
            'id': ('person_id', 'person'),
            'identifier': ('person_source_value', 'person'),
            'gender': ('gender_source_value', 'person'),
            'birthDate': ('birth_datetime', 'person'),
            'deceasedDateTime': ('death_datetime', 'death'),
        }
        
        for col in df.columns:
            if col in column_mappings:
                omop_col, omop_table = column_mappings[col]
                mapping_table.add_row(col, omop_col, omop_table)
            else:
                mapping_table.add_row(col, f"{col.lower()}", "person (or custom)")
        
        console.print(mapping_table)
        
        # Show what would happen next
        console.print("\n[bold yellow]Next Steps (when dependencies are installed):[/bold yellow]")
        steps = [
            "1. Install dependencies: pip install -r requirements.txt",
            "2. Create DuckDB database with OMOP CDM schema",
            "3. Load and transform Parquet data into OMOP tables", 
            "4. Run data validation and quality checks",
            "5. Execute analytical queries on the loaded data"
        ]
        
        for step in steps:
            console.print(f"   {step}")
            
        console.print("\n[bold green]Demo completed successfully![/bold green]")
        console.print("Run 'python parquet_to_duckdb.py load' to perform the actual loading.")
        
    except Exception as e:
        console.print(f"[bold red]Error analyzing Parquet file: {e}[/bold red]")

def demo_sql_generation():
    """Demonstrate SQL generation for OMOP queries."""
    console.print(f"\n[bold blue]Sample OMOP CDM Queries:[/bold blue]")
    
    sample_queries = {
        "Person Count": "SELECT COUNT(*) as total_persons FROM omop.person",
        
        "Age Distribution": """
SELECT 
    CASE 
        WHEN (2024 - year_of_birth) < 18 THEN 'Under 18'
        WHEN (2024 - year_of_birth) BETWEEN 18 AND 30 THEN '18-30'
        WHEN (2024 - year_of_birth) BETWEEN 31 AND 50 THEN '31-50'
        WHEN (2024 - year_of_birth) BETWEEN 51 AND 70 THEN '51-70'
        ELSE 'Over 70'
    END as age_group,
    COUNT(*) as count
FROM omop.person 
WHERE year_of_birth IS NOT NULL
GROUP BY age_group
ORDER BY age_group""",
        
        "Gender Distribution": """
SELECT 
    COALESCE(gender_source_value, 'Unknown') as gender,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM omop.person
GROUP BY gender_source_value
ORDER BY count DESC""",
        
        "Data Completeness": """
SELECT 
    'person_id' as field,
    COUNT(*) as total_records,
    COUNT(person_id) as non_null_count,
    ROUND(100.0 * COUNT(person_id) / COUNT(*), 2) as completeness_pct
FROM omop.person
UNION ALL
SELECT 
    'gender_source_value' as field,
    COUNT(*) as total_records,
    COUNT(gender_source_value) as non_null_count,
    ROUND(100.0 * COUNT(gender_source_value) / COUNT(*), 2) as completeness_pct
FROM omop.person"""
    }
    
    for query_name, sql in sample_queries.items():
        console.print(f"\n[bold green]{query_name}:[/bold green]")
        console.print(f"[dim]{sql}[/dim]")

if __name__ == "__main__":
    try:
        demo_parquet_analysis()
        demo_sql_generation()
    except KeyboardInterrupt:
        console.print("\n[yellow]Demo cancelled by user[/yellow]")
    except Exception as e:
        console.print(f"\n[bold red]Demo error: {e}[/bold red]")
        sys.exit(1)