"""
Configuration management for FHIR data loader.
"""

import os
from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field, field_validator
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class DatabaseConfig(BaseSettings):
    """PostgreSQL database configuration."""
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False, extra="ignore", env_prefix="DBT_")
    
    host: str = Field(default="localhost")
    port: int = Field(default=5432)
    user: str = Field(default="postgres")
    password: str = Field(default="123456")
    database: str = Field(default="data_core")
    schema: str = Field(default="dbt_fhir_semantic_layer")
    
    @property
    def connection_string(self) -> str:
        """Generate PostgreSQL connection string."""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"
    
    @property
    def sqlalchemy_url(self) -> str:
        """Generate SQLAlchemy connection URL."""
        return f"postgresql+psycopg2://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"


class MinioConfig(BaseSettings):
    """MinIO S3 configuration."""
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False, extra="ignore", env_prefix="MINIO_")
    
    endpoint: str = Field(default="127.0.0.1:9000")
    access_key: str = Field(default="minioadmin")
    secret_key: str = Field(default="minioadmin123")
    secure: bool = Field(default=False)
    bucket_name: str = Field(default="fhir-data")
    region: str = Field(default="us-east-1")
    
    @field_validator("secure", mode="before")
    def parse_secure(cls, v):
        """Parse secure flag from string."""
        if isinstance(v, str):
            return v.lower() in ("true", "1", "yes", "on")
        return v


class LoaderConfig(BaseSettings):
    """Loader configuration."""
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False, extra="ignore")
    
    batch_size: int = Field(default=1000)
    max_workers: int = Field(default=4)
    log_level: str = Field(default="INFO")
    output_format: str = Field(default="ndjson")
    export_tables: str = Field(
        default="fhir_patient,fhir_encounter,fhir_condition,fhir_procedure,fhir_observation,fhir_medication_request,fhir_medication_administration,fhir_organization,fhir_location,fhir_practitioner,fhir_practitioner_role,fhir_episode_of_care,fhir_claim"
    )
    
    @property
    def export_tables_list(self) -> List[str]:
        """Parse export tables from comma-separated string."""
        return [t.strip() for t in self.export_tables.split(",") if t.strip()]
    
    @field_validator("log_level")
    def validate_log_level(cls, v):
        """Validate log level."""
        valid_levels = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
        if v.upper() not in valid_levels:
            raise ValueError(f"Log level must be one of {valid_levels}")
        return v.upper()
    
    @field_validator("output_format")
    def validate_output_format(cls, v):
        """Validate output format."""
        valid_formats = ["ndjson", "json"]
        if v.lower() not in valid_formats:
            raise ValueError(f"Output format must be one of {valid_formats}")
        return v.lower()


class Settings:
    """Application settings."""
    
    def __init__(self):
        self.database = DatabaseConfig()
        self.minio = MinioConfig()  
        self.loader = LoaderConfig()
    
    def validate(self) -> bool:
        """Validate all configuration settings."""
        try:
            # Validate database config
            if not self.database.user or not self.database.password:
                raise ValueError("Database user and password are required")
            
            # Validate MinIO config
            if not self.minio.access_key or not self.minio.secret_key:
                raise ValueError("MinIO access key and secret key are required")
            
            # Validate loader config
            if self.loader.batch_size <= 0:
                raise ValueError("Batch size must be positive")
            
            if self.loader.max_workers <= 0:
                raise ValueError("Max workers must be positive")
            
            return True
        except Exception as e:
            raise ValueError(f"Configuration validation failed: {e}")


# Create global settings instance
settings = Settings()