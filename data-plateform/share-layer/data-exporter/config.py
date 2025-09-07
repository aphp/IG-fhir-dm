"""Production-ready configuration management for FHIR to OMOP data exporter."""

import os
import json
from pathlib import Path
from typing import Dict, List, Optional, Any, Union
from enum import Enum

from pydantic import BaseModel, Field, field_validator, model_validator
try:
    from pydantic_settings import BaseSettings
except ImportError:
    # Fallback for older pydantic versions
    from pydantic import BaseSettings
import structlog

logger = structlog.get_logger(__name__)


class DataSourceType(str, Enum):
    """Supported data source types."""
    FHIR_SERVER = "fhir_server"
    FILE_SYSTEM = "file_system"


class OutputFormat(str, Enum):
    """Supported output formats."""
    PARQUET = "parquet"
    DUCKDB = "duckdb"
    CSV = "csv"


class LogLevel(str, Enum):
    """Supported log levels."""
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"


class FHIRServerConfig(BaseModel):
    """Configuration for FHIR server data source."""
    endpoint_url: str = Field(..., description="FHIR server base URL")
    auth_token: Optional[str] = Field(None, description="Optional authentication token")
    timeout: int = Field(300, description="Request timeout in seconds")
    polling_interval: int = Field(5, description="Bulk export polling interval in seconds")
    bulk_export_types: Optional[List[str]] = Field(None, description="Resource types for bulk export")
    bulk_export_elements: Optional[List[str]] = Field(None, description="Elements to include in export")
    bulk_export_since: Optional[str] = Field(None, description="ISO datetime for incremental export")
    
    @field_validator('endpoint_url')
    @classmethod
    def validate_endpoint_url(cls, v):
        """Validate FHIR endpoint URL."""
        if not v.startswith(('http://', 'https://')):
            raise ValueError('FHIR endpoint URL must start with http:// or https://')
        return v.rstrip('/')


class FileSystemConfig(BaseModel):
    """Configuration for file system data source."""
    data_path: Path = Field(..., description="Path to FHIR data files")
    file_format: str = Field("ndjson", description="Format of data files (ndjson, parquet)")
    
    @field_validator('data_path')
    @classmethod
    def validate_data_path(cls, v):
        """Validate data path exists."""
        path = Path(v)
        if not path.exists():
            raise ValueError(f'Data path does not exist: {path}')
        return path
    
    @field_validator('file_format')
    @classmethod
    def validate_file_format(cls, v):
        """Validate file format."""
        if v.lower() not in ['ndjson', 'parquet']:
            raise ValueError('File format must be "ndjson" or "parquet"')
        return v.lower()


class PostProcessingConfig(BaseModel):
    """Configuration for post-processing operations."""
    enabled: bool = Field(True, description="Enable post-processing")
    data_cleaning: bool = Field(True, description="Enable data cleaning")
    data_type_enforcement: bool = Field(True, description="Enable data type enforcement")
    concept_mapping: bool = Field(True, description="Enable concept mapping")
    data_validation: bool = Field(True, description="Enable data validation")
    concept_mapping_file: Optional[Path] = Field(None, description="Path to concept mapping file")
    
    @field_validator('concept_mapping_file')
    @classmethod
    def validate_concept_mapping_file(cls, v):
        """Validate concept mapping file if provided."""
        if v is not None:
            path = Path(v)
            if not path.exists():
                logger.warning(f"Concept mapping file not found: {path}")
        return v


class OutputConfig(BaseModel):
    """Configuration for output writers."""
    base_path: Path = Field(Path("./output"), description="Base output directory")
    formats: List[OutputFormat] = Field([OutputFormat.PARQUET], description="Output formats")
    
    # Parquet-specific options
    parquet_compression: str = Field("snappy", description="Parquet compression algorithm")
    parquet_partition_cols: Optional[List[str]] = Field(None, description="Parquet partitioning columns")
    
    # DuckDB-specific options
    duckdb_database_name: str = Field("omop_data.duckdb", description="DuckDB database file name")
    duckdb_create_indexes: bool = Field(True, description="Create indexes in DuckDB")
    
    # CSV-specific options
    csv_encoding: str = Field("utf-8", description="CSV file encoding")
    csv_separator: str = Field(",", description="CSV field separator")
    
    @field_validator('base_path')
    @classmethod
    def validate_base_path(cls, v):
        """Ensure base path is a Path object."""
        return Path(v)
    
    @field_validator('parquet_compression')
    @classmethod
    def validate_parquet_compression(cls, v):
        """Validate Parquet compression algorithm."""
        valid_compression = ['snappy', 'gzip', 'lz4', 'brotli', 'none']
        if v.lower() not in valid_compression:
            raise ValueError(f'Invalid Parquet compression: {v}. Must be one of {valid_compression}')
        return v.lower()


class PathlingConfig(BaseModel):
    """Configuration for Pathling Spark context."""
    app_name: str = Field("FHIR-OMOP-Exporter", description="Spark application name")
    master: Optional[str] = Field(None, description="Spark master URL")
    executor_memory: str = Field("2g", description="Spark executor memory")
    driver_memory: str = Field("2g", description="Spark driver memory")
    max_result_size: str = Field("1g", description="Maximum result size")
    sql_adaptive_enabled: bool = Field(True, description="Enable adaptive query execution")
    sql_adaptive_coalesce_partitions_enabled: bool = Field(True, description="Enable partition coalescing")


class SchemaConfig(BaseModel):
    """Configuration for schema validation."""
    enabled: bool = Field(True, description="Enable schema validation")
    ddl_file: Optional[Path] = Field(None, description="Path to OMOP DDL file")
    constraints_file: Optional[Path] = Field(None, description="Path to constraints file")
    primary_keys_file: Optional[Path] = Field(None, description="Path to primary keys file")
    
    @field_validator('ddl_file')
    @classmethod
    def validate_ddl_file(cls, v):
        """Validate DDL file if provided."""
        if v is not None:
            path = Path(v)
            if not path.exists():
                raise ValueError(f'DDL file not found: {path}')
        return v


class Config(BaseSettings):
    """Main configuration class for FHIR to OMOP data exporter."""
    
    # Data source configuration
    data_source_type: DataSourceType = Field(DataSourceType.FHIR_SERVER, description="Type of data source")
    fhir_server: FHIRServerConfig = Field(default_factory=lambda: FHIRServerConfig(endpoint_url="http://localhost:8080/fhir", bulk_export_types=["Patient"]))
    file_system: Optional[FileSystemConfig] = Field(None, description="File system configuration")
    
    # Processing configuration
    omop_tables: List[str] = Field(["Person"], description="OMOP tables to export")
    view_definitions_dir: Path = Field(Path("../../../fsh-generated/resources"), description="ViewDefinition files directory")
    
    # Component configurations
    pathling: PathlingConfig = Field(default_factory=PathlingConfig)
    post_processing: PostProcessingConfig = Field(default_factory=PostProcessingConfig)
    output: OutputConfig = Field(default_factory=OutputConfig)
    schema_validation: SchemaConfig = Field(default_factory=SchemaConfig)
    
    # Logging and monitoring
    log_level: LogLevel = Field(LogLevel.INFO, description="Logging level")
    log_file: Optional[Path] = Field(None, description="Log file path")
    structured_logging: bool = Field(True, description="Use structured logging")
    
    # Performance and resource management
    max_memory_usage_mb: int = Field(4096, description="Maximum memory usage in MB")
    temp_dir: Optional[Path] = Field(None, description="Custom temporary directory")
    cleanup_temp_files: bool = Field(True, description="Clean up temporary files after processing")
    
    # Circuit breaker and retry settings
    retry_max_attempts: int = Field(3, description="Maximum retry attempts")
    retry_backoff_factor: float = Field(2.0, description="Retry backoff factor")
    circuit_breaker_failure_threshold: int = Field(5, description="Circuit breaker failure threshold")
    circuit_breaker_timeout: int = Field(60, description="Circuit breaker timeout in seconds")
    
    class Config:
        """Pydantic configuration."""
        env_prefix = "FHIR_OMOP_"
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        
    @model_validator(mode='before')
    @classmethod
    def validate_data_source_config(cls, values):
        """Validate data source configuration consistency."""
        data_source_type = values.get('data_source_type')
        
        if data_source_type == DataSourceType.FILE_SYSTEM:
            if not values.get('file_system'):
                raise ValueError('file_system configuration required when data_source_type is file_system')
        
        return values
    
    @field_validator('view_definitions_dir')
    @classmethod
    def validate_view_definitions_dir(cls, v):
        """Validate ViewDefinitions directory."""
        path = Path(v)
        if not path.exists():
            logger.warning(f"ViewDefinitions directory not found: {path}")
        return path
    
    @field_validator('omop_tables')
    @classmethod
    def validate_omop_tables(cls, v):
        """Validate OMOP table names."""
        valid_tables = {
            "Person", "ObservationPeriod", "VisitOccurrence", "VisitDetail",
            "ConditionOccurrence", "DrugExposure", "ProcedureOccurrence",
            "DeviceExposure", "Measurement", "Observation", "Death",
            "Note", "NoteNlp", "Specimen", "FactRelationship", "Location",
            "CareSite", "Provider", "PayerPlanPeriod", "Cost", "DrugEra",
            "DoseEra", "ConditionEra"
        }
        
        for table in v:
            if table not in valid_tables:
                logger.warning(f"Unknown OMOP table: {table}")
        
        return v
    
    @classmethod
    def from_file(cls, config_file: Union[str, Path]) -> 'Config':
        """Load configuration from JSON file.
        
        Args:
            config_file: Path to configuration file
            
        Returns:
            Config instance
        """
        config_path = Path(config_file)
        
        if not config_path.exists():
            raise FileNotFoundError(f"Configuration file not found: {config_path}")
        
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
            
            return cls(**config_data)
            
        except Exception as e:
            raise ValueError(f"Failed to load configuration from {config_path}: {str(e)}") from e
    
    def to_file(self, config_file: Union[str, Path]) -> None:
        """Save configuration to JSON file.
        
        Args:
            config_file: Path to save configuration
        """
        config_path = Path(config_file)
        config_path.parent.mkdir(parents=True, exist_ok=True)
        
        try:
            with open(config_path, 'w', encoding='utf-8') as f:
                json.dump(
                    self.dict(exclude_none=True),
                    f,
                    indent=2,
                    ensure_ascii=False,
                    default=str  # Handle Path objects
                )
            
            logger.info(f"Configuration saved to: {config_path}")
            
        except Exception as e:
            raise ValueError(f"Failed to save configuration to {config_path}: {str(e)}") from e
    
    def get_view_definition_path(self, table_name: str) -> Path:
        """Get path to ViewDefinition file for OMOP table.
        
        Args:
            table_name: Name of OMOP table
            
        Returns:
            Path to ViewDefinition file
        """
        return self.view_definitions_dir / f"Binary-OMOP-{table_name}-View.json"
    
    def get_data_source_config(self) -> Union[FHIRServerConfig, FileSystemConfig]:
        """Get active data source configuration.
        
        Returns:
            Configuration for the active data source
        """
        if self.data_source_type == DataSourceType.FHIR_SERVER:
            return self.fhir_server
        elif self.data_source_type == DataSourceType.FILE_SYSTEM:
            if not self.file_system:
                raise ValueError("File system configuration not provided")
            return self.file_system
        else:
            raise ValueError(f"Unsupported data source type: {self.data_source_type}")
    
    def get_output_format_options(self) -> Dict[str, Dict[str, Any]]:
        """Get format-specific options for output writers.
        
        Returns:
            Dictionary mapping format names to their options
        """
        return {
            "parquet": {
                "compression": self.output.parquet_compression,
                "partition_cols": self.output.parquet_partition_cols
            },
            "duckdb": {
                "database_name": self.output.duckdb_database_name,
                "create_indexes": self.output.duckdb_create_indexes
            },
            "csv": {
                "encoding": self.output.csv_encoding,
                "separator": self.output.csv_separator
            }
        }
    
    def validate_configuration(self) -> List[str]:
        """Validate configuration and return list of issues.
        
        Returns:
            List of validation issues (empty if configuration is valid)
        """
        issues = []
        
        # Check ViewDefinition files exist for requested tables
        for table_name in self.omop_tables:
            view_def_path = self.get_view_definition_path(table_name)
            if not view_def_path.exists():
                issues.append(f"ViewDefinition file not found: {view_def_path}")
        
        # Check data source accessibility
        try:
            data_source_config = self.get_data_source_config()
            
            if isinstance(data_source_config, FHIRServerConfig):
                # Could add FHIR server connectivity check here
                pass
            elif isinstance(data_source_config, FileSystemConfig):
                if not data_source_config.data_path.exists():
                    issues.append(f"Data path does not exist: {data_source_config.data_path}")
        except Exception as e:
            issues.append(f"Data source configuration error: {str(e)}")
        
        # Check output directory is writable
        try:
            self.output.base_path.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            issues.append(f"Cannot create output directory: {str(e)}")
        
        return issues
    
    def get_configuration_summary(self) -> Dict[str, Any]:
        """Get configuration summary for logging and debugging.
        
        Returns:
            Dictionary with configuration summary
        """
        return {
            "data_source_type": self.data_source_type,
            "omop_tables": self.omop_tables,
            "output_formats": [fmt.value for fmt in self.output.formats],
            "post_processing_enabled": self.post_processing.enabled,
            "schema_validation_enabled": self.schema_validation.enabled,
            "log_level": self.log_level,
            "pathling_app_name": self.pathling.app_name
        }