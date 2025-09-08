#!/usr/bin/env python3
"""
Test queries and data validation for the loaded DuckDB database.

This module provides comprehensive testing and validation capabilities
for data loaded into DuckDB with OMOP CDM schema.
"""

from typing import Dict, Any, List, Optional, Tuple
from pathlib import Path
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from loguru import logger

from config import DatabaseConfig, config
from db_utils import DuckDBManager


console = Console()


class DataValidator:
    """Comprehensive data validation for OMOP CDM in DuckDB."""
    
    def __init__(self, config: DatabaseConfig, db_manager: DuckDBManager):
        """Initialize data validator.
        
        Args:
            config: Database configuration
            db_manager: DuckDB database manager
        """
        self.config = config
        self.db_manager = db_manager
    
    def validate_table_exists(self, table_name: str) -> Dict[str, Any]:
        """Validate that a table exists and has data.
        
        Args:
            table_name: Name of the table to validate
            
        Returns:
            Validation result dictionary
        """
        try:
            exists = self.db_manager.table_exists(table_name)
            
            if not exists:
                return {
                    "passed": False,
                    "message": f"Table {table_name} does not exist",
                    "details": {"exists": False, "row_count": 0}
                }
            
            # Check row count
            full_table_name = f"{self.config.schema_name}.{table_name}"
            row_count = self.db_manager.execute_query(f"SELECT COUNT(*) FROM {full_table_name}")[0][0]
            
            return {
                "passed": row_count > 0,
                "message": f"Table has {row_count:,} rows" if row_count > 0 else "Table is empty",
                "details": {"exists": True, "row_count": row_count}
            }
            
        except Exception as e:
            return {
                "passed": False,
                "message": f"Error validating table: {e}",
                "details": {"error": str(e)}
            }
    
    def validate_person_data(self) -> Dict[str, Any]:
        """Validate person table data quality.
        
        Returns:
            Validation result dictionary
        """
        try:
            table_name = f"{self.config.schema_name}.person"
            
            # Check if person table exists
            if not self.db_manager.table_exists("person"):
                return {
                    "passed": False,
                    "message": "Person table does not exist",
                    "details": {}
                }
            
            validations = {}
            
            # 1. Check for duplicate person_ids
            duplicate_query = f"""
                SELECT COUNT(*) as duplicates 
                FROM (
                    SELECT person_id, COUNT(*) as cnt 
                    FROM {table_name} 
                    GROUP BY person_id 
                    HAVING COUNT(*) > 1
                )
            """
            duplicates = self.db_manager.execute_query(duplicate_query)[0][0]
            validations["duplicates"] = duplicates
            
            # 2. Check for NULL person_ids
            null_query = f"SELECT COUNT(*) FROM {table_name} WHERE person_id IS NULL"
            null_ids = self.db_manager.execute_query(null_query)[0][0]
            validations["null_person_ids"] = null_ids
            
            # 3. Check birth year distribution
            birth_year_query = f"""
                SELECT 
                    MIN(year_of_birth) as min_year,
                    MAX(year_of_birth) as max_year,
                    COUNT(*) as total_with_birth_year
                FROM {table_name} 
                WHERE year_of_birth IS NOT NULL
            """
            birth_year_result = self.db_manager.execute_query(birth_year_query)[0]
            validations["birth_years"] = {
                "min_year": birth_year_result[0],
                "max_year": birth_year_result[1],
                "total_with_birth_year": birth_year_result[2]
            }
            
            # 4. Gender distribution
            gender_query = f"""
                SELECT 
                    gender_source_value, 
                    COUNT(*) as count 
                FROM {table_name} 
                WHERE gender_source_value IS NOT NULL
                GROUP BY gender_source_value 
                ORDER BY count DESC
            """
            gender_results = self.db_manager.execute_query(gender_query)
            validations["gender_distribution"] = dict(gender_results)
            
            # Determine if validation passed
            passed = (
                duplicates == 0 and 
                null_ids == 0 and 
                validations["birth_years"]["total_with_birth_year"] > 0
            )
            
            message_parts = []
            if duplicates > 0:
                message_parts.append(f"{duplicates} duplicate person_ids")
            if null_ids > 0:
                message_parts.append(f"{null_ids} NULL person_ids")
            if validations["birth_years"]["total_with_birth_year"] == 0:
                message_parts.append("No birth years found")
            
            message = "Data quality issues: " + ", ".join(message_parts) if message_parts else "All validations passed"
            
            return {
                "passed": passed,
                "message": message,
                "details": validations
            }
            
        except Exception as e:
            return {
                "passed": False,
                "message": f"Error validating person data: {e}",
                "details": {"error": str(e)}
            }
    
    def validate_data_types(self) -> Dict[str, Any]:
        """Validate data types are appropriate for OMOP CDM.
        
        Returns:
            Validation result dictionary
        """
        try:
            # Get all tables in the schema
            tables_query = f"""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = '{self.config.schema_name}'
            """
            tables = [row[0] for row in self.db_manager.execute_query(tables_query)]
            
            validation_results = {}
            
            for table_name in tables:
                # Get column information
                columns_query = f"DESCRIBE {self.config.schema_name}.{table_name}"
                columns = self.db_manager.execute_query(columns_query)
                
                table_validations = {}
                for column_info in columns:
                    col_name, col_type, nullable = column_info[0], column_info[1], column_info[2]
                    
                    # Validate specific column types
                    if col_name.endswith('_id') and 'integer' not in col_type.lower():
                        table_validations[col_name] = f"ID column should be integer, got {col_type}"
                    elif col_name.endswith('_date') and 'date' not in col_type.lower():
                        table_validations[col_name] = f"Date column should be date type, got {col_type}"
                    elif col_name.endswith('_datetime') and 'timestamp' not in col_type.lower():
                        table_validations[col_name] = f"DateTime column should be timestamp, got {col_type}"
                
                validation_results[table_name] = table_validations
            
            # Check if any issues were found
            total_issues = sum(len(issues) for issues in validation_results.values())
            
            return {
                "passed": total_issues == 0,
                "message": f"Found {total_issues} data type issues" if total_issues > 0 else "All data types are valid",
                "details": validation_results
            }
            
        except Exception as e:
            return {
                "passed": False,
                "message": f"Error validating data types: {e}",
                "details": {"error": str(e)}
            }
    
    def validate_referential_integrity(self) -> Dict[str, Any]:
        """Validate basic referential integrity for key relationships.
        
        Returns:
            Validation result dictionary
        """
        try:
            integrity_checks = {}
            
            # Check if person table exists first
            if not self.db_manager.table_exists("person"):
                return {
                    "passed": False,
                    "message": "Cannot check referential integrity: person table missing",
                    "details": {}
                }
            
            # Define key relationships to check
            relationships = [
                ("observation", "person_id", "person", "person_id"),
                ("visit_occurrence", "person_id", "person", "person_id"),
                ("condition_occurrence", "person_id", "person", "person_id"),
                ("drug_exposure", "person_id", "person", "person_id"),
                ("measurement", "person_id", "person", "person_id"),
            ]
            
            for child_table, child_col, parent_table, parent_col in relationships:
                if not self.db_manager.table_exists(child_table):
                    continue  # Skip if child table doesn't exist
                
                # Check for orphaned records
                orphan_query = f"""
                    SELECT COUNT(*) 
                    FROM {self.config.schema_name}.{child_table} c
                    LEFT JOIN {self.config.schema_name}.{parent_table} p 
                        ON c.{child_col} = p.{parent_col}
                    WHERE p.{parent_col} IS NULL 
                        AND c.{child_col} IS NOT NULL
                """
                
                orphan_count = self.db_manager.execute_query(orphan_query)[0][0]
                integrity_checks[f"{child_table}_{child_col}"] = orphan_count
            
            total_orphans = sum(integrity_checks.values())
            
            return {
                "passed": total_orphans == 0,
                "message": f"Found {total_orphans} orphaned records" if total_orphans > 0 else "No referential integrity issues",
                "details": integrity_checks
            }
            
        except Exception as e:
            return {
                "passed": False,
                "message": f"Error validating referential integrity: {e}",
                "details": {"error": str(e)}
            }
    
    def run_all_validations(self) -> Dict[str, Dict[str, Any]]:
        """Run all validation checks.
        
        Returns:
            Dictionary of validation results
        """
        logger.info("Starting comprehensive data validation...")
        
        validations = {}
        
        # Core table existence checks
        core_tables = ["person", "observation", "visit_occurrence", "condition_occurrence"]
        for table in core_tables:
            validations[f"table_exists_{table}"] = self.validate_table_exists(table)
        
        # Data quality checks
        validations["person_data_quality"] = self.validate_person_data()
        validations["data_types"] = self.validate_data_types()
        validations["referential_integrity"] = self.validate_referential_integrity()
        
        # Summary
        passed_count = sum(1 for result in validations.values() if result["passed"])
        total_count = len(validations)
        
        logger.info(f"Validation complete: {passed_count}/{total_count} checks passed")
        
        return validations


class QueryRunner:
    """Execute predefined test queries against the OMOP CDM database."""
    
    def __init__(self, config: DatabaseConfig, db_manager: DuckDBManager):
        """Initialize query runner.
        
        Args:
            config: Database configuration
            db_manager: DuckDB database manager
        """
        self.config = config
        self.db_manager = db_manager
    
    def get_sample_queries(self) -> Dict[str, str]:
        """Get a collection of sample OMOP queries.
        
        Returns:
            Dictionary of query names to SQL statements
        """
        schema = self.config.schema_name
        
        queries = {
            "person_count": f"SELECT COUNT(*) as total_persons FROM {schema}.person",
            
            "age_distribution": f"""
                SELECT 
                    CASE 
                        WHEN (2024 - year_of_birth) < 18 THEN 'Under 18'
                        WHEN (2024 - year_of_birth) BETWEEN 18 AND 30 THEN '18-30'
                        WHEN (2024 - year_of_birth) BETWEEN 31 AND 50 THEN '31-50'
                        WHEN (2024 - year_of_birth) BETWEEN 51 AND 70 THEN '51-70'
                        ELSE 'Over 70'
                    END as age_group,
                    COUNT(*) as count
                FROM {schema}.person 
                WHERE year_of_birth IS NOT NULL
                GROUP BY age_group
                ORDER BY age_group
            """,
            
            "gender_distribution": f"""
                SELECT 
                    COALESCE(gender_source_value, 'Unknown') as gender,
                    COUNT(*) as count,
                    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
                FROM {schema}.person
                GROUP BY gender_source_value
                ORDER BY count DESC
            """,
            
            "birth_year_range": f"""
                SELECT 
                    MIN(year_of_birth) as earliest_birth_year,
                    MAX(year_of_birth) as latest_birth_year,
                    COUNT(*) as total_with_birth_year,
                    COUNT(*) - COUNT(year_of_birth) as missing_birth_years
                FROM {schema}.person
            """,
            
            "data_completeness": f"""
                SELECT 
                    'person_id' as field,
                    COUNT(*) as total_records,
                    COUNT(person_id) as non_null_count,
                    ROUND(100.0 * COUNT(person_id) / COUNT(*), 2) as completeness_pct
                FROM {schema}.person
                UNION ALL
                SELECT 
                    'gender_source_value' as field,
                    COUNT(*) as total_records,
                    COUNT(gender_source_value) as non_null_count,
                    ROUND(100.0 * COUNT(gender_source_value) / COUNT(*), 2) as completeness_pct
                FROM {schema}.person
                UNION ALL
                SELECT 
                    'year_of_birth' as field,
                    COUNT(*) as total_records,
                    COUNT(year_of_birth) as non_null_count,
                    ROUND(100.0 * COUNT(year_of_birth) / COUNT(*), 2) as completeness_pct
                FROM {schema}.person
            """,
        }
        
        # Add observation queries if table exists
        if self.db_manager.table_exists("observation"):
            queries.update({
                "observation_count": f"SELECT COUNT(*) as total_observations FROM {schema}.observation",
                
                "observations_per_person": f"""
                    SELECT 
                        person_id,
                        COUNT(*) as observation_count
                    FROM {schema}.observation
                    GROUP BY person_id
                    ORDER BY observation_count DESC
                    LIMIT 10
                """,
            })
        
        return queries
    
    def execute_query(self, query_name: str, query: str) -> Dict[str, Any]:
        """Execute a single query and format results.
        
        Args:
            query_name: Name of the query for identification
            query: SQL query string
            
        Returns:
            Query execution result
        """
        try:
            logger.info(f"Executing query: {query_name}")
            
            results = self.db_manager.execute_query(query)
            
            # Get column names from the query (basic approach)
            column_names = []
            if results and hasattr(results, 'description'):
                column_names = [desc[0] for desc in results.description]
            elif results:
                # Try to infer column names from simple queries
                if "SELECT COUNT(*)" in query.upper():
                    column_names = ["count"]
                else:
                    column_names = [f"col_{i}" for i in range(len(results[0]))]
            
            return {
                "query_name": query_name,
                "success": True,
                "row_count": len(results),
                "results": results,
                "column_names": column_names,
                "execution_time": None  # DuckDB doesn't provide timing info by default
            }
            
        except Exception as e:
            logger.error(f"Query {query_name} failed: {e}")
            return {
                "query_name": query_name,
                "success": False,
                "error": str(e),
                "results": [],
                "column_names": []
            }
    
    def run_all_queries(self) -> Dict[str, Dict[str, Any]]:
        """Execute all sample queries.
        
        Returns:
            Dictionary of query results
        """
        queries = self.get_sample_queries()
        results = {}
        
        logger.info(f"Executing {len(queries)} test queries...")
        
        for query_name, query_sql in queries.items():
            results[query_name] = self.execute_query(query_name, query_sql)
        
        return results
    
    def display_query_results(self, results: Dict[str, Dict[str, Any]]):
        """Display query results in a formatted table.
        
        Args:
            results: Dictionary of query execution results
        """
        for query_name, result in results.items():
            console.print(f"\n[bold blue]Query: {query_name}[/bold blue]")
            
            if not result["success"]:
                console.print(f"[red]Error: {result['error']}[/red]")
                continue
            
            if not result["results"]:
                console.print("[yellow]No results returned[/yellow]")
                continue
            
            # Create table for results
            table = Table(border_style="green")
            
            # Add columns
            column_names = result.get("column_names", [])
            if not column_names:
                column_names = [f"Column {i}" for i in range(len(result["results"][0]))]
            
            for col_name in column_names:
                table.add_column(str(col_name), style="cyan")
            
            # Add rows (limit to first 10 for display)
            for i, row in enumerate(result["results"][:10]):
                table.add_row(*[str(val) for val in row])
            
            console.print(table)
            
            if len(result["results"]) > 10:
                console.print(f"[dim]... and {len(result['results']) - 10} more rows[/dim]")


def main():
    """Main function for running test queries and validations."""
    console.print(Panel("[bold blue]OMOP CDM Data Validation and Testing[/bold blue]", border_style="blue"))
    
    # Setup configuration
    config.setup_logging()
    
    if not config.database_path.exists():
        console.print(f"[bold red]Database not found: {config.database_path}[/bold red]")
        console.print("Please run the main loader script first.")
        return
    
    try:
        with DuckDBManager(config) as db_manager:
            console.print("\n[bold yellow]Running Data Validation...[/bold yellow]")
            
            # Run validation
            validator = DataValidator(config, db_manager)
            validation_results = validator.run_all_validations()
            
            # Display validation results
            validation_table = Table(title="Validation Results", border_style="green")
            validation_table.add_column("Check", style="bold")
            validation_table.add_column("Status", style="cyan")
            validation_table.add_column("Message")
            
            for check_name, result in validation_results.items():
                status = "PASS" if result["passed"] else "FAIL"
                validation_table.add_row(check_name, status, result["message"])
            
            console.print(validation_table)
            
            console.print("\n[bold yellow]Running Test Queries...[/bold yellow]")
            
            # Run test queries
            query_runner = QueryRunner(config, db_manager)
            query_results = query_runner.run_all_queries()
            query_runner.display_query_results(query_results)
            
            # Summary
            passed_validations = sum(1 for r in validation_results.values() if r["passed"])
            total_validations = len(validation_results)
            successful_queries = sum(1 for r in query_results.values() if r["success"])
            total_queries = len(query_results)
            
            console.print(f"\n[bold green]Summary:[/bold green]")
            console.print(f"Validations: {passed_validations}/{total_validations} passed")
            console.print(f"Queries: {successful_queries}/{total_queries} successful")
            
    except Exception as e:
        console.print(f"[bold red]Error: {e}[/bold red]")
        logger.error(f"Unexpected error in testing: {e}")


if __name__ == "__main__":
    main()