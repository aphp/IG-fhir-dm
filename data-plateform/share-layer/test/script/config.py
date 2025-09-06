"""Configuration module for FHIR bulk loader.

This module contains configuration settings for connecting to HAPI FHIR server
and managing the bulk import process.
"""

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


@dataclass
class HapiFhirConfig:
    """Configuration for HAPI FHIR server connection."""
    
    base_url: str = "http://localhost:8080/fhir"
    version: str = "8.4.0"
    fhir_version: str = "R4"
    database_type: str = "PostgreSQL"
    timeout: int = 30
    max_retries: int = 3
    retry_delay: int = 5


@dataclass
class ImportConfig:
    """Configuration for bulk import process."""
    
    data_directory: str = "../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir"
    file_pattern: str = "*.ndjson.gz"
    batch_size: int = 1000
    max_concurrent_requests: int = 5
    poll_interval: int = 10  # seconds to wait between status checks
    max_wait_time: int = 3600  # maximum time to wait for import completion (1 hour)


@dataclass
class Config:
    """Main configuration class combining all settings."""
    
    hapi_fhir: HapiFhirConfig
    import_settings: ImportConfig
    log_level: str = "INFO"
    log_file: Optional[str] = None
    
    @classmethod
    def from_env(cls) -> 'Config':
        """Create configuration from environment variables."""
        hapi_config = HapiFhirConfig(
            base_url=os.getenv("HAPI_FHIR_URL", "http://localhost:8080/fhir"),
            version=os.getenv("HAPI_FHIR_VERSION", "8.4.0"),
            fhir_version=os.getenv("FHIR_VERSION", "R4"),
            database_type=os.getenv("HAPI_DB_TYPE", "PostgreSQL"),
            timeout=int(os.getenv("HAPI_TIMEOUT", "30")),
            max_retries=int(os.getenv("HAPI_MAX_RETRIES", "3")),
            retry_delay=int(os.getenv("HAPI_RETRY_DELAY", "5"))
        )
        
        import_config = ImportConfig(
            data_directory=os.getenv("DATA_DIRECTORY", "../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir"),
            file_pattern=os.getenv("FILE_PATTERN", "*.ndjson.gz"),
            batch_size=int(os.getenv("BATCH_SIZE", "1000")),
            max_concurrent_requests=int(os.getenv("MAX_CONCURRENT_REQUESTS", "5")),
            poll_interval=int(os.getenv("POLL_INTERVAL", "10")),
            max_wait_time=int(os.getenv("MAX_WAIT_TIME", "3600"))
        )
        
        return cls(
            hapi_fhir=hapi_config,
            import_settings=import_config,
            log_level=os.getenv("LOG_LEVEL", "INFO"),
            log_file=os.getenv("LOG_FILE")
        )
    
    def validate(self) -> None:
        """Validate configuration settings."""
        # Validate data directory exists
        data_path = Path(self.import_settings.data_directory)
        if not data_path.exists():
            raise ValueError(f"Data directory does not exist: {data_path}")
        
        # Validate batch size
        if self.import_settings.batch_size <= 0:
            raise ValueError("Batch size must be positive")
        
        # Validate timeout values
        if self.hapi_fhir.timeout <= 0:
            raise ValueError("Timeout must be positive")
        
        if self.import_settings.poll_interval <= 0:
            raise ValueError("Poll interval must be positive")
        
        if self.import_settings.max_wait_time <= 0:
            raise ValueError("Max wait time must be positive")


# Default configuration instance
DEFAULT_CONFIG = Config(
    hapi_fhir=HapiFhirConfig(),
    import_settings=ImportConfig()
)