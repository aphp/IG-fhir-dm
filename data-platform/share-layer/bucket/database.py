"""
Database connection and data extraction module for FHIR Semantic Layer.
"""

import json
from typing import Dict, List, Optional, Any, Generator
from datetime import datetime, date
from decimal import Decimal
import psycopg2
from psycopg2.extras import RealDictCursor
from sqlalchemy import create_engine, text, MetaData, Table
from sqlalchemy.engine import Engine
from loguru import logger
from config import settings


class DateTimeEncoder(json.JSONEncoder):
    """Custom JSON encoder for handling datetime and other special types."""
    
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        elif isinstance(obj, Decimal):
            return float(obj)
        elif isinstance(obj, bytes):
            return obj.decode('utf-8', errors='ignore')
        return super().default(obj)


class DatabaseConnection:
    """Manages PostgreSQL database connections and data extraction."""
    
    def __init__(self):
        self.config = settings.database
        self.engine: Optional[Engine] = None
        self.connection = None
        self.metadata = MetaData()
        
    def connect(self) -> None:
        """Establish database connection."""
        try:
            # Create SQLAlchemy engine
            self.engine = create_engine(
                self.config.sqlalchemy_url,
                pool_size=10,
                max_overflow=20,
                pool_pre_ping=True,
                echo=False,
                connect_args={'client_encoding': 'utf8'}
            )
            
            # Test connection
            with self.engine.connect() as conn:
                result = conn.execute(text("SELECT 1"))
                result.fetchone()
            
            logger.info(f"Connected to PostgreSQL database: {self.config.database}")
            
            # Load metadata
            self.metadata.reflect(bind=self.engine, schema=self.config.schema)
            logger.info(f"Loaded metadata for schema: {self.config.schema}")
            
        except Exception as e:
            logger.error(f"Failed to connect to database: {e}")
            raise
    
    def disconnect(self) -> None:
        """Close database connection."""
        if self.engine:
            self.engine.dispose()
            logger.info("Disconnected from database")
    
    def get_table_count(self, table_name: str) -> int:
        """Get the total number of records in a table."""
        try:
            with self.engine.connect() as conn:
                query = text(f"""
                    SELECT COUNT(*) as count 
                    FROM {self.config.schema}.{table_name}
                """)
                result = conn.execute(query)
                return result.fetchone()[0]
        except Exception as e:
            logger.error(f"Failed to get count for table {table_name}: {e}")
            return 0
    
    def extract_table_data(
        self, 
        table_name: str, 
        batch_size: int = 1000,
        offset: int = 0,
        limit: Optional[int] = None
    ) -> Generator[List[Dict[str, Any]], None, None]:
        """
        Extract data from a table in batches.
        
        Args:
            table_name: Name of the table to extract from
            batch_size: Number of records per batch
            offset: Starting offset
            limit: Maximum number of records to extract
            
        Yields:
            List of dictionaries representing table rows
        """
        try:
            total_count = self.get_table_count(table_name)
            logger.info(f"Extracting data from {table_name} (total: {total_count} records)")
            
            with psycopg2.connect(
                host=self.config.host,
                port=self.config.port,
                database=self.config.database,
                user=self.config.user,
                password=self.config.password
            ) as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cursor:
                    current_offset = offset
                    records_extracted = 0
                    
                    while True:
                        # Build query
                        query = f"""
                            SELECT * FROM {self.config.schema}.{table_name}
                            ORDER BY id
                            LIMIT {batch_size}
                            OFFSET {current_offset}
                        """
                        
                        cursor.execute(query)
                        rows = cursor.fetchall()
                        
                        if not rows:
                            break
                        
                        # Convert rows to dictionaries and handle special types
                        batch = []
                        for row in rows:
                            row_dict = dict(row)
                            # Convert special types to JSON-serializable format
                            for key, value in row_dict.items():
                                if isinstance(value, (datetime, date)):
                                    row_dict[key] = value.isoformat()
                                elif isinstance(value, Decimal):
                                    row_dict[key] = float(value)
                                elif isinstance(value, bytes):
                                    row_dict[key] = value.decode('utf-8', errors='ignore')
                            batch.append(row_dict)
                        
                        yield batch
                        
                        records_extracted += len(batch)
                        current_offset += batch_size
                        
                        logger.debug(f"Extracted {records_extracted}/{total_count} records from {table_name}")
                        
                        # Check if we've reached the limit
                        if limit and records_extracted >= limit:
                            break
                        
                    logger.info(f"Completed extraction from {table_name}: {records_extracted} records")
                    
        except Exception as e:
            logger.error(f"Failed to extract data from {table_name}: {e}")
            raise
    
    def get_table_schema(self, table_name: str) -> Dict[str, Any]:
        """
        Get the schema information for a table.
        
        Args:
            table_name: Name of the table
            
        Returns:
            Dictionary containing table schema information
        """
        try:
            with self.engine.connect() as conn:
                query = text("""
                    SELECT 
                        column_name,
                        data_type,
                        is_nullable,
                        column_default,
                        character_maximum_length
                    FROM information_schema.columns
                    WHERE table_schema = :schema
                    AND table_name = :table
                    ORDER BY ordinal_position
                """)
                
                result = conn.execute(
                    query,
                    {"schema": self.config.schema, "table": table_name}
                )
                
                columns = []
                for row in result:
                    columns.append({
                        "name": row[0],
                        "type": row[1],
                        "nullable": row[2] == "YES",
                        "default": row[3],
                        "max_length": row[4]
                    })
                
                return {
                    "table_name": table_name,
                    "schema": self.config.schema,
                    "columns": columns
                }
                
        except Exception as e:
            logger.error(f"Failed to get schema for table {table_name}: {e}")
            raise
    
    def validate_tables(self, table_names: List[str]) -> List[str]:
        """
        Validate that tables exist in the database.
        
        Args:
            table_names: List of table names to validate
            
        Returns:
            List of valid table names
        """
        valid_tables = []
        
        try:
            with self.engine.connect() as conn:
                query = text("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = :schema
                    AND table_name = ANY(:tables)
                """)
                
                result = conn.execute(
                    query,
                    {"schema": self.config.schema, "tables": table_names}
                )
                
                valid_tables = [row[0] for row in result]
                
                # Log missing tables
                missing_tables = set(table_names) - set(valid_tables)
                if missing_tables:
                    logger.warning(f"Tables not found: {missing_tables}")
                
                return valid_tables
                
        except Exception as e:
            logger.error(f"Failed to validate tables: {e}")
            raise
    
    def execute_query(self, query: str) -> List[Dict[str, Any]]:
        """
        Execute a custom SQL query.
        
        Args:
            query: SQL query to execute
            
        Returns:
            List of dictionaries representing query results
        """
        try:
            with self.engine.connect() as conn:
                result = conn.execute(text(query))
                
                # Convert to list of dictionaries
                columns = result.keys()
                rows = []
                for row in result:
                    row_dict = dict(zip(columns, row))
                    # Handle special types
                    for key, value in row_dict.items():
                        if isinstance(value, (datetime, date)):
                            row_dict[key] = value.isoformat()
                        elif isinstance(value, Decimal):
                            row_dict[key] = float(value)
                    rows.append(row_dict)
                
                return rows
                
        except Exception as e:
            logger.error(f"Failed to execute query: {e}")
            raise


class FHIRDataExtractor:
    """Specialized extractor for FHIR data with resource-specific handling."""
    
    def __init__(self, db_connection: DatabaseConnection):
        self.db = db_connection
        
    def extract_fhir_resource(
        self,
        resource_type: str,
        batch_size: int = 1000
    ) -> Generator[List[Dict[str, Any]], None, None]:
        """
        Extract FHIR resource data with proper formatting.
        
        Args:
            resource_type: FHIR resource type (e.g., 'Patient', 'Encounter')
            batch_size: Number of records per batch
            
        Yields:
            List of FHIR resource dictionaries
        """
        # Map resource type to table name
        table_mapping = {
            "Patient": "fhir_patient",
            "Encounter": "fhir_encounter",
            "Condition": "fhir_condition",
            "Procedure": "fhir_procedure",
            "Observation": "fhir_observation",
            "MedicationRequest": "fhir_medication_request",
            "MedicationAdministration": "fhir_medication_administration",
            "Organization": "fhir_organization",
            "Location": "fhir_location",
            "Practitioner": "fhir_practitioner",
            "PractitionerRole": "fhir_practitioner_role",
            "EpisodeOfCare": "fhir_episode_of_care",
            "Claim": "fhir_claim"
        }
        
        table_name = table_mapping.get(resource_type)
        if not table_name:
            raise ValueError(f"Unknown FHIR resource type: {resource_type}")
        
        # Extract data
        for batch in self.db.extract_table_data(table_name, batch_size):
            # Transform to FHIR format
            fhir_batch = []
            for row in batch:
                fhir_resource = self._transform_to_fhir(resource_type, row)
                fhir_batch.append(fhir_resource)
            
            yield fhir_batch
    
    def _transform_to_fhir(self, resource_type: str, row: Dict[str, Any]) -> Dict[str, Any]:
        """
        Transform database row to FHIR resource format.
        
        Args:
            resource_type: FHIR resource type
            row: Database row dictionary
            
        Returns:
            FHIR resource dictionary
        """
        # Basic FHIR resource structure
        fhir_resource = {
            "resourceType": resource_type,
            "id": row.get("id")
        }
        
        # Add meta information if available
        if row.get("version_id"):
            fhir_resource["meta"] = {
                "versionId": row.get("version_id"),
                "lastUpdated": row.get("last_updated")
            }
        
        # Add resource-specific fields
        # This is a simplified transformation - in production, you would
        # implement full FHIR resource mapping
        
        # Remove internal fields
        exclude_fields = ["created_at", "updated_at", "version_id", "last_updated"]
        
        for key, value in row.items():
            if key not in exclude_fields and value is not None:
                # Convert snake_case to camelCase
                camel_key = self._to_camel_case(key)
                
                # Handle JSONB fields
                if isinstance(value, str) and value.startswith('{'):
                    try:
                        value = json.loads(value)
                    except json.JSONDecodeError:
                        pass
                
                fhir_resource[camel_key] = value
        
        return fhir_resource
    
    def _to_camel_case(self, snake_str: str) -> str:
        """Convert snake_case to camelCase."""
        components = snake_str.split('_')
        return components[0] + ''.join(x.title() for x in components[1:])