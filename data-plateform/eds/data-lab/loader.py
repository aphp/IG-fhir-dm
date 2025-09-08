"""Parquet file loading and data processing utilities."""

import re
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple
import pandas as pd
import duckdb
from loguru import logger
from rich.progress import Progress, TaskID

from config import DatabaseConfig
from db_utils import DuckDBManager


class ParquetLoader:
    """Handles loading Parquet files into DuckDB with OMOP CDM mapping."""
    
    def __init__(self, config: DatabaseConfig, db_manager: DuckDBManager):
        """Initialize Parquet loader.
        
        Args:
            config: Database configuration
            db_manager: DuckDB database manager
        """
        self.config = config
        self.db_manager = db_manager
        
    def discover_parquet_files(self) -> List[Path]:
        """Discover all Parquet files in the input directory.
        
        Returns:
            List of Parquet file paths
        """
        parquet_files = list(self.config.input_directory.glob("*.parquet"))
        
        if not parquet_files:
            logger.warning(f"No Parquet files found in {self.config.input_directory}")
            return []
        
        logger.info(f"Found {len(parquet_files)} Parquet files")
        for file_path in parquet_files:
            logger.debug(f"  - {file_path.name} ({file_path.stat().st_size / 1024 / 1024:.2f} MB)")
        
        return sorted(parquet_files)
    
    def analyze_parquet_file(self, file_path: Path) -> Dict[str, Any]:
        """Analyze a Parquet file structure and content.
        
        Args:
            file_path: Path to the Parquet file
            
        Returns:
            Dictionary with file analysis information
        """
        try:
            # Read basic info using pandas
            df = pd.read_parquet(file_path)
            
            # Extract information
            info = {
                "file_path": str(file_path),
                "file_name": file_path.name,
                "file_size_mb": file_path.stat().st_size / 1024 / 1024,
                "row_count": len(df),
                "column_count": len(df.columns),
                "columns": list(df.columns),
                "dtypes": {col: str(dtype) for col, dtype in df.dtypes.items()},
                "memory_usage_mb": df.memory_usage(deep=True).sum() / 1024 / 1024,
                "estimated_table_name": self._extract_table_name_from_filename(file_path.name)
            }
            
            # Sample data preview
            if not df.empty:
                info["sample_data"] = df.head(3).to_dict('records')
                
                # Check for missing values
                info["missing_values"] = df.isnull().sum().to_dict()
                
                # Basic statistics for numeric columns
                numeric_cols = df.select_dtypes(include=['number']).columns
                if not numeric_cols.empty:
                    info["numeric_stats"] = df[numeric_cols].describe().to_dict()
            
            logger.info(f"Analyzed {file_path.name}: {info['row_count']:,} rows, {info['column_count']} columns")
            return info
            
        except Exception as e:
            logger.error(f"Failed to analyze Parquet file {file_path}: {e}")
            return {"file_path": str(file_path), "error": str(e)}
    
    def _extract_table_name_from_filename(self, filename: str) -> str:
        """Extract likely table name from filename.
        
        Args:
            filename: Name of the Parquet file
            
        Returns:
            Estimated table name
        """
        # Remove extension
        name = filename.replace('.parquet', '')
        
        # Remove timestamp patterns (e.g., "_20250906_160719")
        name = re.sub(r'_\d{8}_\d{6}$', '', name)
        
        # Remove other common suffixes
        name = re.sub(r'_(export|data|dump)$', '', name, flags=re.IGNORECASE)
        
        # Convert to lowercase and replace spaces/hyphens with underscores
        name = re.sub(r'[-\s]+', '_', name.lower())
        
        return name
    
    def map_columns_to_omop(self, columns: List[str], estimated_table: str) -> Dict[str, str]:
        """Map Parquet columns to OMOP CDM columns.
        
        Args:
            columns: List of column names from Parquet file
            estimated_table: Estimated OMOP table name
            
        Returns:
            Dictionary mapping Parquet columns to OMOP columns
        """
        # This is a basic mapping strategy - in production, you'd want more sophisticated mapping
        column_mapping = {}
        
        # Common FHIR to OMOP mappings
        fhir_to_omop_mappings = {
            'id': 'person_id',
            'identifier': 'person_source_value',
            'gender': 'gender_source_value',
            'birthDate': 'birth_datetime',
            'deceasedDateTime': 'death_datetime',
            'address': 'location_id',
            'telecom': 'provider_id',  # Simplified mapping
        }
        
        # Apply direct mappings
        for parquet_col in columns:
            # Direct mapping
            if parquet_col in fhir_to_omop_mappings:
                column_mapping[parquet_col] = fhir_to_omop_mappings[parquet_col]
            # Keep column name if it matches OMOP convention
            elif parquet_col.lower() in self._get_omop_columns(estimated_table):
                column_mapping[parquet_col] = parquet_col.lower()
            # Default: keep original name
            else:
                column_mapping[parquet_col] = parquet_col
        
        return column_mapping
    
    def _get_omop_columns(self, table_name: str) -> List[str]:
        """Get OMOP CDM column names for a given table.
        
        Args:
            table_name: OMOP table name
            
        Returns:
            List of column names for the table
        """
        # This would ideally be read from the DDL or a configuration file
        # For now, return common person table columns
        omop_columns = {
            'person': [
                'person_id', 'gender_concept_id', 'year_of_birth', 'month_of_birth',
                'day_of_birth', 'birth_datetime', 'race_concept_id', 'ethnicity_concept_id',
                'location_id', 'provider_id', 'care_site_id', 'person_source_value',
                'gender_source_value', 'gender_source_concept_id', 'race_source_value',
                'race_source_concept_id', 'ethnicity_source_value', 'ethnicity_source_concept_id'
            ],
            'observation': [
                'observation_id', 'person_id', 'observation_concept_id', 'observation_date',
                'observation_datetime', 'observation_type_concept_id', 'value_as_number',
                'value_as_string', 'value_as_concept_id', 'qualifier_concept_id',
                'unit_concept_id', 'provider_id', 'visit_occurrence_id', 'visit_detail_id',
                'observation_source_value', 'observation_source_concept_id',
                'unit_source_value', 'qualifier_source_value', 'value_source_value',
                'observation_event_id', 'obs_event_field_concept_id'
            ]
        }
        
        return omop_columns.get(table_name, [])
    
    def load_parquet_to_duckdb(self, file_path: Path, target_table: str, 
                              column_mapping: Optional[Dict[str, str]] = None,
                              progress: Optional[Progress] = None,
                              task_id: Optional[TaskID] = None) -> bool:
        """Load a Parquet file into DuckDB table.
        
        Args:
            file_path: Path to the Parquet file
            target_table: Target table name in DuckDB
            column_mapping: Optional column name mapping
            progress: Progress bar instance
            task_id: Progress task ID
            
        Returns:
            True if successful, False otherwise
        """
        if not self.db_manager.connection:
            raise RuntimeError("Database connection not established")
        
        try:
            logger.info(f"Loading {file_path.name} into table {target_table}")
            
            # Read Parquet file
            df = pd.read_parquet(file_path)
            
            if df.empty:
                logger.warning(f"Parquet file {file_path.name} is empty")
                return False
            
            # Apply column mapping if provided
            if column_mapping:
                df = df.rename(columns=column_mapping)
                logger.debug(f"Applied column mapping: {column_mapping}")
            
            # Data type conversions and cleaning
            df = self._clean_dataframe(df, target_table)
            
            # Create full table name with schema
            full_table_name = f"{self.config.schema_name}.{target_table}"
            
            # Check if table exists and handle accordingly
            if self.db_manager.table_exists(target_table):
                logger.info(f"Table {full_table_name} exists, appending data")
                insert_mode = "append"
            else:
                logger.info(f"Creating new table {full_table_name}")
                insert_mode = "replace"
            
            # Load data into DuckDB using pandas integration
            self.db_manager.connection.execute(f"CREATE SCHEMA IF NOT EXISTS {self.config.schema_name}")
            
            # Use DuckDB's efficient Parquet loading when possible
            if column_mapping is None and insert_mode == "replace":
                # Direct Parquet loading - most efficient
                query = f"""
                CREATE OR REPLACE TABLE {full_table_name} AS 
                SELECT * FROM read_parquet('{file_path.as_posix()}')
                """
                self.db_manager.connection.execute(query)
            else:
                # Use DuckDB's native insert capabilities instead of pandas to_sql
                # which can cause transaction issues
                try:
                    # Get the target table column names
                    table_info = self.db_manager.connection.execute(f"DESCRIBE {full_table_name}").fetchall()
                    target_columns = [row[0] for row in table_info]
                    
                    # Get DataFrame column names that match target table
                    df_columns = list(df.columns)
                    matching_columns = [col for col in df_columns if col in target_columns]
                    
                    if not matching_columns:
                        raise ValueError(f"No matching columns found between DataFrame and target table {full_table_name}")
                    
                    # Build column mapping for insert
                    column_list = ', '.join(matching_columns)
                    
                    if insert_mode == "replace":
                        # Create table from DataFrame with only matching columns
                        self.db_manager.connection.execute(f"DROP TABLE IF EXISTS {full_table_name}")
                        self.db_manager.connection.execute(f"CREATE TABLE {full_table_name} AS SELECT {column_list} FROM df")
                    else:
                        # Insert only matching columns into existing table
                        self.db_manager.connection.execute(f"INSERT INTO {full_table_name} ({column_list}) SELECT {column_list} FROM df")
                        
                    logger.info(f"Successfully inserted data using native DuckDB with columns: {column_list}")
                    
                except Exception as insert_error:
                    logger.warning(f"Native DuckDB insert failed: {insert_error}, falling back to pandas approach")
                    # Alternative approach: Use DuckDB's register and SQL
                    try:
                        # Register DataFrame with DuckDB
                        self.db_manager.connection.register('temp_df', df)
                        
                        if insert_mode == "replace":
                            self.db_manager.connection.execute(f"DROP TABLE IF EXISTS {full_table_name}")
                            self.db_manager.connection.execute(f"CREATE TABLE {full_table_name} AS SELECT * FROM temp_df")
                        else:
                            # Get common columns for insert
                            table_cols = self.db_manager.connection.execute(f"DESCRIBE {full_table_name}").fetchall()
                            table_columns = [row[0] for row in table_cols]
                            common_cols = [col for col in df.columns if col in table_columns]
                            
                            if common_cols:
                                col_list = ', '.join(common_cols)
                                self.db_manager.connection.execute(f"INSERT INTO {full_table_name} ({col_list}) SELECT {col_list} FROM temp_df")
                            else:
                                raise ValueError("No common columns found for insert")
                        
                        self.db_manager.connection.unregister('temp_df')
                        logger.info("Successfully loaded data using DuckDB register approach")
                        
                    except Exception as fallback_error:
                        logger.error(f"All loading approaches failed. Final error: {fallback_error}")
                        return False
            
            # Update progress
            if progress and task_id:
                progress.update(task_id, advance=1)
            
            # Verify loading
            row_count = self.db_manager.connection.execute(
                f"SELECT COUNT(*) FROM {full_table_name}"
            ).fetchone()[0]
            
            logger.info(f"Successfully loaded {row_count:,} rows into {full_table_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to load {file_path.name} into {target_table}: {e}")
            return False
    
    def _clean_dataframe(self, df: pd.DataFrame, target_table: str) -> pd.DataFrame:
        """Clean and transform DataFrame for OMOP compatibility.
        
        Args:
            df: Input DataFrame
            target_table: Target OMOP table name
            
        Returns:
            Cleaned DataFrame
        """
        df_cleaned = df.copy()
        
        try:
            # Convert object columns to string
            object_cols = df_cleaned.select_dtypes(include=['object']).columns
            for col in object_cols:
                df_cleaned[col] = df_cleaned[col].astype('string')
            
            # Handle datetime conversions
            datetime_patterns = ['date', 'datetime', 'time']
            for col in df_cleaned.columns:
                if any(pattern in col.lower() for pattern in datetime_patterns):
                    try:
                        if df_cleaned[col].dtype == 'object':
                            df_cleaned[col] = pd.to_datetime(df_cleaned[col], errors='coerce')
                    except Exception as e:
                        logger.debug(f"Could not convert {col} to datetime: {e}")
            
            # Handle specific OMOP requirements
            if target_table == 'person':
                # Ensure person_id is integer
                if 'person_id' in df_cleaned.columns:
                    df_cleaned['person_id'] = pd.to_numeric(df_cleaned['person_id'], errors='coerce').fillna(0).astype('int64')
                
                # Extract year from birth_datetime if exists
                if 'birth_datetime' in df_cleaned.columns and 'year_of_birth' not in df_cleaned.columns:
                    df_cleaned['year_of_birth'] = pd.to_datetime(df_cleaned['birth_datetime'], errors='coerce').dt.year
            
            # Remove rows with all null values
            df_cleaned = df_cleaned.dropna(how='all')
            
            logger.debug(f"Cleaned DataFrame: {len(df_cleaned)} rows, {len(df_cleaned.columns)} columns")
            
        except Exception as e:
            logger.warning(f"Data cleaning encountered issues: {e}")
            # Return original DataFrame if cleaning fails
            return df
        
        return df_cleaned
    
    def load_all_parquet_files(self) -> Dict[str, Any]:
        """Load all discovered Parquet files into DuckDB.
        
        Returns:
            Dictionary with loading results and statistics
        """
        parquet_files = self.discover_parquet_files()
        
        if not parquet_files:
            return {"success": False, "message": "No Parquet files found"}
        
        results = {
            "total_files": len(parquet_files),
            "successful_loads": 0,
            "failed_loads": 0,
            "loaded_tables": [],
            "errors": []
        }
        
        # Setup progress bar if enabled
        progress = None
        task_id = None
        if self.config.enable_progress_bar:
            from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
            progress = Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                BarColumn(),
                TaskProgressColumn(),
                console=None
            )
            progress.start()
            task_id = progress.add_task("Loading Parquet files...", total=len(parquet_files))
        
        try:
            for file_path in parquet_files:
                # Analyze file first
                file_info = self.analyze_parquet_file(file_path)
                
                if "error" in file_info:
                    results["failed_loads"] += 1
                    results["errors"].append(f"{file_path.name}: {file_info['error']}")
                    continue
                
                # Determine target table name
                target_table = file_info["estimated_table_name"]
                
                # Create column mapping
                column_mapping = self.map_columns_to_omop(file_info["columns"], target_table)
                
                # Load file
                success = self.load_parquet_to_duckdb(
                    file_path, target_table, column_mapping, progress, task_id
                )
                
                if success:
                    results["successful_loads"] += 1
                    results["loaded_tables"].append(target_table)
                else:
                    results["failed_loads"] += 1
                    results["errors"].append(f"{file_path.name}: Load failed")
            
        finally:
            if progress:
                progress.stop()
        
        results["success"] = results["successful_loads"] > 0
        
        logger.info(f"Loading complete: {results['successful_loads']}/{results['total_files']} files loaded successfully")
        
        return results