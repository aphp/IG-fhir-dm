"""Configuration management for Parquet to DuckDB loader."""

import os
from pathlib import Path
from typing import Optional
from pydantic import Field, validator
from pydantic_settings import BaseSettings
from loguru import logger


class DatabaseConfig(BaseSettings):
    """Database configuration settings."""
    
    # Input/Output directories
    input_directory: Path = Field(
        default=Path("../script/output"),
        description="Directory containing Parquet files"
    )
    output_directory: Path = Field(
        default=Path("./output"),
        description="Directory for DuckDB database output"
    )
    
    # Database settings
    database_name: str = Field(
        default="omop_cdm",
        description="Name of the DuckDB database file"
    )
    schema_name: str = Field(
        default="omop",
        description="Schema name for OMOP CDM tables"
    )
    
    # SQL files location
    omop_sql_directory: Path = Field(
        default=Path("../sql/omop"),
        description="Directory containing OMOP DDL files"
    )
    
    # Performance settings
    memory_limit: str = Field(
        default="4GB",
        description="DuckDB memory limit"
    )
    threads: int = Field(
        default=4,
        description="Number of threads for DuckDB"
    )
    
    # Logging configuration
    log_level: str = Field(
        default="INFO",
        description="Logging level"
    )
    log_file: Optional[Path] = Field(
        default=None,
        description="Log file path (if None, logs to console only)"
    )
    
    # Processing options
    batch_size: int = Field(
        default=10000,
        description="Batch size for data processing"
    )
    enable_progress_bar: bool = Field(
        default=True,
        description="Enable progress bar during processing"
    )
    
    class Config:
        env_prefix = "PARQUET_DUCKDB_"
        env_file = ".env"
        case_sensitive = False

    @validator('input_directory', 'output_directory', 'omop_sql_directory', pre=True)
    def resolve_paths(cls, v):
        """Resolve relative paths to absolute paths."""
        if isinstance(v, str):
            v = Path(v)
        return v.resolve()

    @validator('log_file', pre=True)
    def resolve_log_file(cls, v):
        """Resolve log file path."""
        if v is not None:
            if isinstance(v, str):
                v = Path(v)
            return v.resolve()
        return v

    def setup_logging(self) -> None:
        """Configure logging based on settings."""
        logger.remove()  # Remove default handler
        
        # Console handler
        logger.add(
            sink=lambda msg: print(msg, end=""),
            level=self.log_level,
            format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
            colorize=True
        )
        
        # File handler (if specified)
        if self.log_file:
            self.log_file.parent.mkdir(parents=True, exist_ok=True)
            logger.add(
                sink=str(self.log_file),
                level=self.log_level,
                format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
                rotation="10 MB",
                retention="1 week"
            )

    def create_directories(self) -> None:
        """Create necessary directories if they don't exist."""
        self.output_directory.mkdir(parents=True, exist_ok=True)
        
        if self.log_file:
            self.log_file.parent.mkdir(parents=True, exist_ok=True)

    @property
    def database_path(self) -> Path:
        """Get the full path to the DuckDB database file."""
        return self.output_directory / f"{self.database_name}.duckdb"

    def validate_directories(self) -> bool:
        """Validate that required directories exist."""
        if not self.input_directory.exists():
            logger.error(f"Input directory does not exist: {self.input_directory}")
            return False
            
        if not self.omop_sql_directory.exists():
            logger.error(f"OMOP SQL directory does not exist: {self.omop_sql_directory}")
            return False
            
        return True


# Global configuration instance
config = DatabaseConfig()