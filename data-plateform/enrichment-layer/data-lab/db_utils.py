"""Database utilities for DuckDB operations."""

import re
from pathlib import Path
from typing import List, Optional, Dict, Any
import duckdb
from loguru import logger

from config import DatabaseConfig


class DuckDBManager:
    """Manages DuckDB database operations and OMOP CDM schema creation."""
    
    def __init__(self, config: DatabaseConfig):
        """Initialize DuckDB manager with configuration.
        
        Args:
            config: Database configuration settings
        """
        self.config = config
        self.connection: Optional[duckdb.DuckDBPyConnection] = None
        
    def __enter__(self):
        """Context manager entry."""
        self.connect()
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.disconnect()
        
    def connect(self) -> duckdb.DuckDBPyConnection:
        """Establish connection to DuckDB database.
        
        Returns:
            DuckDB connection object
        """
        try:
            logger.info(f"Connecting to DuckDB database: {self.config.database_path}")
            
            # Create connection
            self.connection = duckdb.connect(str(self.config.database_path))
            
            # Configure DuckDB settings for optimal performance
            self._configure_database()
            
            logger.info("Successfully connected to DuckDB database")
            return self.connection
            
        except Exception as e:
            logger.error(f"Failed to connect to DuckDB database: {e}")
            raise
    
    def disconnect(self) -> None:
        """Close database connection."""
        if self.connection:
            self.connection.close()
            self.connection = None
            logger.info("Disconnected from DuckDB database")
    
    def _configure_database(self) -> None:
        """Configure DuckDB settings for optimal performance."""
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        settings = {
            'memory_limit': self.config.memory_limit,
            'threads': self.config.threads,
            'enable_progress_bar': self.config.enable_progress_bar,
            'preserve_insertion_order': False,  # Optimize for analytical queries
        }
        
        for setting, value in settings.items():
            try:
                if isinstance(value, bool):
                    value = str(value).lower()
                self.connection.execute(f"SET {setting}='{value}'")
                logger.debug(f"Set DuckDB setting: {setting}={value}")
            except Exception as e:
                logger.warning(f"Failed to set DuckDB setting {setting}={value}: {e}")
    
    def create_schema(self) -> None:
        """Create OMOP CDM schema if it doesn't exist."""
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        try:
            # Create schema
            self.connection.execute(f"CREATE SCHEMA IF NOT EXISTS {self.config.schema_name}")
            logger.info(f"Created/verified schema: {self.config.schema_name}")
            
        except Exception as e:
            logger.error(f"Failed to create schema: {e}")
            raise
    
    def load_omop_ddl(self) -> None:
        """Load OMOP CDM DDL from SQL files."""
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        ddl_file = self.config.omop_sql_directory / "OMOPCDM_duckdb_5.4_ddl.sql"
        
        if not ddl_file.exists():
            raise FileNotFoundError(f"OMOP DDL file not found: {ddl_file}")
        
        try:
            logger.info("Loading OMOP CDM DDL...")
            
            # Read and process DDL file
            ddl_content = ddl_file.read_text(encoding='utf-8')
            
            # Replace schema placeholder with actual schema name
            ddl_content = ddl_content.replace('@cdmDatabaseSchema', self.config.schema_name)
            
            # Split into individual statements and execute
            statements = self._split_sql_statements(ddl_content)
            
            for i, statement in enumerate(statements):
                if statement.strip():
                    try:
                        self.connection.execute(statement)
                        logger.debug(f"Executed DDL statement {i+1}/{len(statements)}")
                    except Exception as e:
                        logger.warning(f"Failed to execute DDL statement {i+1}: {e}")
                        logger.debug(f"Problematic statement: {statement[:100]}...")
            
            logger.info("Successfully loaded OMOP CDM DDL")
            
        except Exception as e:
            logger.error(f"Failed to load OMOP DDL: {e}")
            raise
    
    def load_omop_constraints(self) -> None:
        """Load OMOP CDM constraints and indices."""
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        constraint_files = [
            "OMOPCDM_duckdb_5.4_primary_keys.sql",
            "OMOPCDM_duckdb_5.4_indices.sql",
            "OMOPCDM_duckdb_5.4_constraints.sql"
        ]
        
        for file_name in constraint_files:
            constraint_file = self.config.omop_sql_directory / file_name
            
            if not constraint_file.exists():
                logger.warning(f"Constraint file not found: {constraint_file}")
                continue
                
            try:
                logger.info(f"Loading {file_name}...")
                
                content = constraint_file.read_text(encoding='utf-8')
                content = content.replace('@cdmDatabaseSchema', self.config.schema_name)
                
                statements = self._split_sql_statements(content)
                
                for statement in statements:
                    if statement.strip():
                        try:
                            self.connection.execute(statement)
                        except Exception as e:
                            logger.debug(f"Constraint/index creation failed (expected for some): {e}")
                
                logger.info(f"Processed {file_name}")
                
            except Exception as e:
                logger.warning(f"Failed to process {file_name}: {e}")
    
    def _split_sql_statements(self, sql_content: str) -> List[str]:
        """Split SQL content into individual statements.
        
        Args:
            sql_content: Raw SQL content
            
        Returns:
            List of SQL statements
        """
        # Remove comments
        sql_content = re.sub(r'--.*$', '', sql_content, flags=re.MULTILINE)
        
        # Split by semicolon (basic approach)
        statements = sql_content.split(';')
        
        # Clean up statements
        cleaned_statements = []
        for stmt in statements:
            stmt = stmt.strip()
            if stmt and not stmt.startswith('--'):
                cleaned_statements.append(stmt)
        
        return cleaned_statements
    
    def table_exists(self, table_name: str, schema: Optional[str] = None) -> bool:
        """Check if a table exists in the database.
        
        Args:
            table_name: Name of the table
            schema: Schema name (uses default if not provided)
            
        Returns:
            True if table exists, False otherwise
        """
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        schema = schema or self.config.schema_name
        
        try:
            result = self.connection.execute(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = ?",
                [schema, table_name]
            ).fetchone()
            
            return result[0] > 0 if result else False
            
        except Exception as e:
            logger.error(f"Failed to check if table exists: {e}")
            return False
    
    def get_table_info(self, table_name: str, schema: Optional[str] = None) -> Dict[str, Any]:
        """Get information about a table.
        
        Args:
            table_name: Name of the table
            schema: Schema name (uses default if not provided)
            
        Returns:
            Dictionary with table information
        """
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        schema = schema or self.config.schema_name
        full_table_name = f"{schema}.{table_name}"
        
        try:
            # Get table statistics
            count_result = self.connection.execute(f"SELECT COUNT(*) FROM {full_table_name}").fetchone()
            row_count = count_result[0] if count_result else 0
            
            # Get column information
            columns_result = self.connection.execute(f"DESCRIBE {full_table_name}").fetchall()
            columns = [{"name": row[0], "type": row[1], "null": row[2]} for row in columns_result]
            
            return {
                "table_name": table_name,
                "schema": schema,
                "row_count": row_count,
                "column_count": len(columns),
                "columns": columns
            }
            
        except Exception as e:
            logger.error(f"Failed to get table info for {full_table_name}: {e}")
            return {}
    
    def execute_query(self, query: str, parameters: Optional[List] = None) -> List[tuple]:
        """Execute a SQL query and return results.
        
        Args:
            query: SQL query string
            parameters: Query parameters
            
        Returns:
            List of result tuples
        """
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        try:
            if parameters:
                result = self.connection.execute(query, parameters)
            else:
                result = self.connection.execute(query)
                
            return result.fetchall()
            
        except Exception as e:
            logger.error(f"Failed to execute query: {e}")
            raise
    
    def get_database_info(self) -> Dict[str, Any]:
        """Get overall database information.
        
        Returns:
            Dictionary with database statistics
        """
        if not self.connection:
            raise RuntimeError("Database connection not established")
            
        try:
            # Get all tables in the OMOP schema
            tables_query = """
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = ?
                ORDER BY table_name
            """
            tables = self.connection.execute(tables_query, [self.config.schema_name]).fetchall()
            table_names = [table[0] for table in tables]
            
            # Get total row counts
            total_rows = 0
            table_stats = {}
            
            for table_name in table_names:
                try:
                    count_query = f"SELECT COUNT(*) FROM {self.config.schema_name}.{table_name}"
                    count = self.connection.execute(count_query).fetchone()[0]
                    table_stats[table_name] = count
                    total_rows += count
                except Exception as e:
                    logger.debug(f"Failed to get count for {table_name}: {e}")
                    table_stats[table_name] = 0
            
            return {
                "database_path": str(self.config.database_path),
                "schema_name": self.config.schema_name,
                "total_tables": len(table_names),
                "total_rows": total_rows,
                "table_statistics": table_stats,
                "table_names": table_names
            }
            
        except Exception as e:
            logger.error(f"Failed to get database info: {e}")
            return {}