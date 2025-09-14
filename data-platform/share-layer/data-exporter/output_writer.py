"""Multi-format output writer for OMOP data (Parquet, DuckDB, CSV)."""

import os
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
import pandas as pd
import structlog

import duckdb
import pyarrow as pa
import pyarrow.parquet as pq

from utils import (
    FHIRExportError, OutputError, ensure_directory,
    format_file_size, log_execution_time, ProgressReporter
)
from schema_validator import SchemaValidator

logger = structlog.get_logger(__name__)


class OutputWriter(ABC):
    """Abstract base class for output writers."""
    
    def __init__(self, output_path: Union[str, Path]):
        """Initialize output writer.
        
        Args:
            output_path: Base output path for data files
        """
        self.output_path = Path(output_path)
        self.logger = logger.bind(writer_type=self.__class__.__name__)
    
    @abstractmethod
    def write_table(
        self,
        data: pd.DataFrame,
        table_name: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Write table data to output format.
        
        Args:
            data: DataFrame to write
            table_name: Name of the table
            metadata: Optional metadata to include
            
        Returns:
            Dictionary with write operation results
            
        Raises:
            OutputError: If write operation fails
        """
        pass
    
    @abstractmethod
    def get_output_info(self, table_name: str) -> Dict[str, Any]:
        """Get information about written output.
        
        Args:
            table_name: Name of the table
            
        Returns:
            Dictionary with output information
        """
        pass


class ParquetWriter(OutputWriter):
    """Writer for Parquet format output."""
    
    def __init__(
        self,
        output_path: Union[str, Path],
        compression: str = "snappy",
        partition_cols: Optional[List[str]] = None
    ):
        """Initialize Parquet writer.
        
        Args:
            output_path: Output directory for Parquet files
            compression: Compression algorithm (snappy, gzip, lz4, brotli)
            partition_cols: Optional columns to partition by
        """
        super().__init__(output_path)
        self.compression = compression
        self.partition_cols = partition_cols
        
        # Ensure output directory exists
        ensure_directory(self.output_path)
    
    @log_execution_time("parquet_write")
    def write_table(
        self,
        data: pd.DataFrame,
        table_name: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Write DataFrame to Parquet format.
        
        Args:
            data: DataFrame to write
            table_name: Name of the table
            metadata: Optional metadata to include in Parquet schema
            
        Returns:
            Dictionary with write operation results
        """
        try:
            table_name = table_name.lower()
            file_path = self.output_path / f"{table_name}.parquet"
            
            self.logger.info(
                "Writing Parquet file",
                table=table_name,
                rows=len(data),
                columns=len(data.columns),
                compression=self.compression
            )
            
            with ProgressReporter(f"Writing {table_name} to Parquet"):
                # Prepare metadata
                parquet_metadata = {}
                if metadata:
                    # Convert metadata to strings for Parquet schema
                    for key, value in metadata.items():
                        if isinstance(value, (dict, list)):
                            import json
                            parquet_metadata[key] = json.dumps(value)
                        else:
                            parquet_metadata[key] = str(value)
                
                # Convert to PyArrow Table
                table = pa.Table.from_pandas(data, preserve_index=False)
                
                # Add metadata to schema
                if parquet_metadata:
                    schema = table.schema
                    schema = schema.with_metadata(parquet_metadata)
                    table = table.cast(schema)
                
                # Write Parquet file
                if self.partition_cols:
                    # Write with partitioning
                    pq.write_to_dataset(
                        table,
                        root_path=str(file_path.parent),
                        partition_cols=self.partition_cols,
                        basename_template=f"{table_name}_{{i}}.parquet",
                        compression=self.compression
                    )
                else:
                    # Write single file
                    pq.write_table(
                        table,
                        file_path,
                        compression=self.compression
                    )
            
            # Get file information
            file_size = file_path.stat().st_size if file_path.exists() else 0
            
            result = {
                "format": "parquet",
                "file_path": str(file_path),
                "file_size_bytes": file_size,
                "file_size_formatted": format_file_size(file_size),
                "rows_written": len(data),
                "columns_written": len(data.columns),
                "compression": self.compression,
                "partitioned": bool(self.partition_cols)
            }
            
            self.logger.info(
                "Parquet write completed",
                table=table_name,
                file_size=result["file_size_formatted"]
            )
            
            return result
            
        except Exception as e:
            error_msg = f"Failed to write Parquet file for {table_name}: {str(e)}"
            self.logger.error(error_msg)
            raise OutputError(
                error_msg,
                details={
                    "table_name": table_name,
                    "output_path": str(file_path),
                    "compression": self.compression
                }
            ) from e
    
    def get_output_info(self, table_name: str) -> Dict[str, Any]:
        """Get information about written Parquet file."""
        table_name = table_name.lower()
        file_path = self.output_path / f"{table_name}.parquet"
        
        if not file_path.exists():
            return {"exists": False, "file_path": str(file_path)}
        
        try:
            # Read Parquet metadata
            parquet_file = pq.ParquetFile(file_path)
            
            return {
                "exists": True,
                "file_path": str(file_path),
                "file_size_bytes": file_path.stat().st_size,
                "file_size_formatted": format_file_size(file_path.stat().st_size),
                "num_rows": parquet_file.metadata.num_rows,
                "num_columns": parquet_file.metadata.num_columns,
                "schema": [field.name for field in parquet_file.schema],
                "compression": str(parquet_file.metadata.row_group(0).column(0).compression)
            }
            
        except Exception as e:
            self.logger.warning("Failed to read Parquet metadata", error=str(e))
            return {
                "exists": True,
                "file_path": str(file_path),
                "error": str(e)
            }


class DuckDBWriter(OutputWriter):
    """Writer for DuckDB format output."""
    
    def __init__(
        self,
        output_path: Union[str, Path],
        database_name: str = "omop_data.duckdb",
        schema_validator: Optional[SchemaValidator] = None,
        create_indexes: bool = True
    ):
        """Initialize DuckDB writer.
        
        Args:
            output_path: Output directory for DuckDB file
            database_name: Name of DuckDB database file
            schema_validator: Optional schema validator for table creation
            create_indexes: Whether to create indexes on written tables
        """
        super().__init__(output_path)
        self.database_name = database_name
        self.schema_validator = schema_validator
        self.create_indexes = create_indexes
        
        # Ensure output directory exists
        ensure_directory(self.output_path)
        
        self.db_path = self.output_path / self.database_name
        self._connection: Optional[duckdb.DuckDBPyConnection] = None
    
    def _get_connection(self) -> duckdb.DuckDBPyConnection:
        """Get or create DuckDB connection."""
        if self._connection is None:
            try:
                self._connection = duckdb.connect(str(self.db_path))
                self.logger.info("Connected to DuckDB", database=str(self.db_path))
            except Exception as e:
                raise OutputError(f"Failed to connect to DuckDB: {str(e)}") from e
        
        return self._connection
    
    @log_execution_time("duckdb_write")
    def write_table(
        self,
        data: pd.DataFrame,
        table_name: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Write DataFrame to DuckDB table.
        
        Args:
            data: DataFrame to write
            table_name: Name of the table
            metadata: Optional metadata (stored in separate metadata table)
            
        Returns:
            Dictionary with write operation results
        """
        try:
            table_name = table_name.lower()
            conn = self._get_connection()
            
            self.logger.info(
                "Writing DuckDB table",
                table=table_name,
                rows=len(data),
                columns=len(data.columns)
            )
            
            with ProgressReporter(f"Writing {table_name} to DuckDB"):
                # Create table schema if schema validator is available
                if self.schema_validator:
                    try:
                        self.schema_validator.create_duckdb_schema(conn, [table_name])
                    except Exception as e:
                        self.logger.warning(
                            "Failed to create schema, proceeding with auto schema",
                            error=str(e)
                        )
                
                # Drop existing table if it exists
                conn.execute(f"DROP TABLE IF EXISTS {table_name}")
                
                # Insert data
                conn.register('temp_df', data)
                conn.execute(f"CREATE TABLE {table_name} AS SELECT * FROM temp_df")
                conn.unregister('temp_df')
                
                # Create indexes if requested
                if self.create_indexes:
                    self._create_table_indexes(conn, table_name, data.columns)
                
                # Store metadata if provided
                if metadata:
                    self._store_metadata(conn, table_name, metadata)
            
            # Get table information
            table_info = conn.execute(
                f"SELECT COUNT(*) as row_count FROM {table_name}"
            ).fetchone()
            
            rows_written = table_info[0] if table_info else 0
            
            result = {
                "format": "duckdb",
                "database_path": str(self.db_path),
                "table_name": table_name,
                "rows_written": rows_written,
                "columns_written": len(data.columns),
                "indexes_created": self.create_indexes,
                "metadata_stored": bool(metadata)
            }
            
            self.logger.info(
                "DuckDB write completed",
                table=table_name,
                rows=rows_written
            )
            
            return result
            
        except Exception as e:
            error_msg = f"Failed to write DuckDB table {table_name}: {str(e)}"
            self.logger.error(error_msg)
            raise OutputError(
                error_msg,
                details={
                    "table_name": table_name,
                    "database_path": str(self.db_path)
                }
            ) from e
    
    def _create_table_indexes(
        self,
        conn: duckdb.DuckDBPyConnection,
        table_name: str,
        columns: List[str]
    ) -> None:
        """Create indexes for common OMOP columns."""
        index_patterns = {
            "person_id": "person_id",
            "visit_occurrence_id": "visit_occurrence_id",
            "condition_occurrence_id": "condition_occurrence_id",
            "drug_exposure_id": "drug_exposure_id",
            "procedure_occurrence_id": "procedure_occurrence_id",
            "measurement_id": "measurement_id",
            "observation_id": "observation_id"
        }
        
        for pattern, column in index_patterns.items():
            if column in columns:
                try:
                    index_name = f"idx_{table_name}_{column}"
                    conn.execute(
                        f"CREATE INDEX {index_name} ON {table_name} ({column})"
                    )
                    self.logger.debug("Created index", index=index_name)
                except Exception as e:
                    self.logger.warning(
                        "Failed to create index",
                        index=index_name,
                        error=str(e)
                    )
    
    def _store_metadata(
        self,
        conn: duckdb.DuckDBPyConnection,
        table_name: str,
        metadata: Dict[str, Any]
    ) -> None:
        """Store table metadata in dedicated metadata table."""
        try:
            # Create metadata table if it doesn't exist
            conn.execute("""
                CREATE TABLE IF NOT EXISTS table_metadata (
                    table_name VARCHAR PRIMARY KEY,
                    metadata JSON,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Convert metadata to JSON string
            import json
            metadata_json = json.dumps(metadata)
            
            # Insert or update metadata
            conn.execute("""
                INSERT OR REPLACE INTO table_metadata (table_name, metadata, updated_at)
                VALUES (?, ?, CURRENT_TIMESTAMP)
            """, [table_name, metadata_json])
            
        except Exception as e:
            self.logger.warning("Failed to store metadata", error=str(e))
    
    def get_output_info(self, table_name: str) -> Dict[str, Any]:
        """Get information about written DuckDB table."""
        table_name = table_name.lower()
        
        if not self.db_path.exists():
            return {"exists": False, "database_path": str(self.db_path)}
        
        try:
            conn = self._get_connection()
            
            # Check if table exists
            table_exists = conn.execute("""
                SELECT COUNT(*) FROM information_schema.tables 
                WHERE table_name = ?
            """, [table_name]).fetchone()[0] > 0
            
            if not table_exists:
                return {
                    "exists": False,
                    "database_path": str(self.db_path),
                    "table_name": table_name
                }
            
            # Get table information
            table_info = conn.execute(f"""
                SELECT COUNT(*) as row_count
                FROM {table_name}
            """).fetchone()
            
            column_info = conn.execute(f"""
                PRAGMA table_info('{table_name}')
            """).fetchall()
            
            return {
                "exists": True,
                "database_path": str(self.db_path),
                "database_size_bytes": self.db_path.stat().st_size,
                "database_size_formatted": format_file_size(self.db_path.stat().st_size),
                "table_name": table_name,
                "row_count": table_info[0] if table_info else 0,
                "column_count": len(column_info),
                "columns": [col[1] for col in column_info],  # column name is index 1
                "column_types": [col[2] for col in column_info]  # column type is index 2
            }
            
        except Exception as e:
            self.logger.warning("Failed to get DuckDB table info", error=str(e))
            return {
                "exists": True,
                "database_path": str(self.db_path),
                "table_name": table_name,
                "error": str(e)
            }
    
    def execute_query(self, query: str) -> List[tuple]:
        """Execute SQL query on DuckDB database.
        
        Args:
            query: SQL query to execute
            
        Returns:
            Query results as list of tuples
        """
        try:
            conn = self._get_connection()
            return conn.execute(query).fetchall()
        except Exception as e:
            raise OutputError(f"Query execution failed: {str(e)}") from e
    
    def close(self) -> None:
        """Close DuckDB connection."""
        if self._connection:
            try:
                self._connection.close()
                self._connection = None
                self.logger.info("DuckDB connection closed")
            except Exception as e:
                self.logger.warning("Error closing DuckDB connection", error=str(e))


class CSVWriter(OutputWriter):
    """Writer for CSV format output."""
    
    def __init__(
        self,
        output_path: Union[str, Path],
        encoding: str = "utf-8",
        separator: str = ","
    ):
        """Initialize CSV writer.
        
        Args:
            output_path: Output directory for CSV files
            encoding: File encoding
            separator: CSV separator character
        """
        super().__init__(output_path)
        self.encoding = encoding
        self.separator = separator
        
        # Ensure output directory exists
        ensure_directory(self.output_path)
    
    @log_execution_time("csv_write")
    def write_table(
        self,
        data: pd.DataFrame,
        table_name: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Write DataFrame to CSV format.
        
        Args:
            data: DataFrame to write
            table_name: Name of the table
            metadata: Optional metadata (written to separate metadata file)
            
        Returns:
            Dictionary with write operation results
        """
        try:
            table_name = table_name.lower()
            file_path = self.output_path / f"{table_name}.csv"
            
            self.logger.info(
                "Writing CSV file",
                table=table_name,
                rows=len(data),
                columns=len(data.columns)
            )
            
            with ProgressReporter(f"Writing {table_name} to CSV"):
                # Write CSV file
                data.to_csv(
                    file_path,
                    sep=self.separator,
                    encoding=self.encoding,
                    index=False
                )
                
                # Write metadata if provided
                if metadata:
                    metadata_path = self.output_path / f"{table_name}_metadata.json"
                    import json
                    with open(metadata_path, 'w', encoding=self.encoding) as f:
                        json.dump(metadata, f, indent=2, ensure_ascii=False)
            
            # Get file information
            file_size = file_path.stat().st_size
            
            result = {
                "format": "csv",
                "file_path": str(file_path),
                "file_size_bytes": file_size,
                "file_size_formatted": format_file_size(file_size),
                "rows_written": len(data),
                "columns_written": len(data.columns),
                "encoding": self.encoding,
                "separator": self.separator,
                "metadata_file": str(metadata_path) if metadata else None
            }
            
            self.logger.info(
                "CSV write completed",
                table=table_name,
                file_size=result["file_size_formatted"]
            )
            
            return result
            
        except Exception as e:
            error_msg = f"Failed to write CSV file for {table_name}: {str(e)}"
            self.logger.error(error_msg)
            raise OutputError(
                error_msg,
                details={
                    "table_name": table_name,
                    "output_path": str(file_path)
                }
            ) from e
    
    def get_output_info(self, table_name: str) -> Dict[str, Any]:
        """Get information about written CSV file."""
        table_name = table_name.lower()
        file_path = self.output_path / f"{table_name}.csv"
        
        if not file_path.exists():
            return {"exists": False, "file_path": str(file_path)}
        
        try:
            # Read first few lines to get column info
            sample_df = pd.read_csv(file_path, nrows=5, sep=self.separator, encoding=self.encoding)
            
            return {
                "exists": True,
                "file_path": str(file_path),
                "file_size_bytes": file_path.stat().st_size,
                "file_size_formatted": format_file_size(file_path.stat().st_size),
                "columns": list(sample_df.columns),
                "column_count": len(sample_df.columns),
                "encoding": self.encoding,
                "separator": self.separator
            }
            
        except Exception as e:
            self.logger.warning("Failed to read CSV info", error=str(e))
            return {
                "exists": True,
                "file_path": str(file_path),
                "error": str(e)
            }


class MultiFormatWriter:
    """Writer that supports multiple output formats simultaneously."""
    
    def __init__(
        self,
        output_path: Union[str, Path],
        formats: List[str],
        schema_validator: Optional[SchemaValidator] = None,
        **format_options
    ):
        """Initialize multi-format writer.
        
        Args:
            output_path: Base output directory
            formats: List of output formats ('parquet', 'duckdb', 'csv')
            schema_validator: Optional schema validator
            **format_options: Format-specific options
        """
        self.output_path = Path(output_path)
        self.formats = formats
        self.schema_validator = schema_validator
        
        self.writers: Dict[str, OutputWriter] = {}
        self.logger = logger.bind(component="MultiFormatWriter")
        
        # Initialize writers for each format
        self._initialize_writers(format_options)
    
    def _initialize_writers(self, format_options: Dict[str, Any]) -> None:
        """Initialize writers for requested formats."""
        for format_name in self.formats:
            format_name = format_name.lower()
            format_path = self.output_path / format_name
            
            try:
                if format_name == "parquet":
                    parquet_options = format_options.get("parquet", {})
                    self.writers["parquet"] = ParquetWriter(format_path, **parquet_options)
                
                elif format_name == "duckdb":
                    duckdb_options = format_options.get("duckdb", {})
                    duckdb_options["schema_validator"] = self.schema_validator
                    self.writers["duckdb"] = DuckDBWriter(format_path, **duckdb_options)
                
                elif format_name == "csv":
                    csv_options = format_options.get("csv", {})
                    self.writers["csv"] = CSVWriter(format_path, **csv_options)
                
                else:
                    self.logger.warning("Unsupported output format", format=format_name)
                    
            except Exception as e:
                self.logger.error(
                    "Failed to initialize writer",
                    format=format_name,
                    error=str(e)
                )
    
    @log_execution_time("multi_format_write")
    def write_table(
        self,
        data: pd.DataFrame,
        table_name: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Dict[str, Any]]:
        """Write table to all configured formats.
        
        Args:
            data: DataFrame to write
            table_name: Name of the table
            metadata: Optional metadata to include
            
        Returns:
            Dictionary mapping format names to write results
        """
        results = {}
        
        self.logger.info(
            "Writing table in multiple formats",
            table=table_name,
            formats=list(self.writers.keys()),
            rows=len(data),
            columns=len(data.columns)
        )
        
        for format_name, writer in self.writers.items():
            try:
                self.logger.info("Writing format", format=format_name, table=table_name)
                
                result = writer.write_table(data, table_name, metadata)
                results[format_name] = {
                    "status": "success",
                    "result": result
                }
                
                self.logger.info("Format write completed", format=format_name)
                
            except Exception as e:
                self.logger.error(
                    "Format write failed",
                    format=format_name,
                    table=table_name,
                    error=str(e)
                )
                
                results[format_name] = {
                    "status": "failed",
                    "error": str(e)
                }
        
        successful_formats = [f for f, r in results.items() if r["status"] == "success"]
        
        self.logger.info(
            "Multi-format write completed",
            table=table_name,
            successful_formats=len(successful_formats),
            total_formats=len(self.writers)
        )
        
        return results
    
    def get_output_summary(self, table_names: List[str]) -> Dict[str, Any]:
        """Get summary of all written outputs.
        
        Args:
            table_names: List of table names to summarize
            
        Returns:
            Summary dictionary
        """
        summary = {
            "formats": list(self.writers.keys()),
            "tables": {},
            "total_size_bytes": 0,
            "timestamp": pd.Timestamp.now().isoformat()
        }
        
        for table_name in table_names:
            table_summary = {}
            
            for format_name, writer in self.writers.items():
                try:
                    info = writer.get_output_info(table_name)
                    table_summary[format_name] = info
                    
                    # Add to total size if available
                    if info.get("file_size_bytes"):
                        summary["total_size_bytes"] += info["file_size_bytes"]
                    elif info.get("database_size_bytes"):
                        summary["total_size_bytes"] += info["database_size_bytes"]
                        
                except Exception as e:
                    table_summary[format_name] = {"error": str(e)}
            
            summary["tables"][table_name] = table_summary
        
        summary["total_size_formatted"] = format_file_size(summary["total_size_bytes"])
        
        return summary
    
    def cleanup(self) -> None:
        """Clean up all writers."""
        for format_name, writer in self.writers.items():
            try:
                if hasattr(writer, 'close'):
                    writer.close()
            except Exception as e:
                self.logger.warning(
                    "Error during writer cleanup",
                    format=format_name,
                    error=str(e)
                )