"""Data source abstraction layer for FHIR to OMOP exporter."""

import os
import json
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
from datetime import datetime
import structlog

from pathling import PathlingContext
from utils import FHIRExportError, retry_with_backoff


logger = structlog.get_logger(__name__)


class DataSource(ABC):
    """Abstract base class for data sources."""
    
    def __init__(self, pathling_context: PathlingContext):
        """Initialize data source with Pathling context.
        
        Args:
            pathling_context: Initialized Pathling context for data processing
        """
        self.pc = pathling_context
        self.logger = logger.bind(source_type=self.__class__.__name__)
    
    @abstractmethod
    def load_data(self, resource_types: Optional[List[str]] = None, **kwargs) -> Any:
        """Load FHIR data from the data source.
        
        Args:
            resource_types: List of FHIR resource types to load
            **kwargs: Additional source-specific parameters
            
        Returns:
            Pathling dataset containing FHIR resources
            
        Raises:
            FHIRExportError: If data loading fails
        """
        pass
    
    @abstractmethod
    def validate_source(self) -> bool:
        """Validate that the data source is accessible and properly configured.
        
        Returns:
            True if source is valid, False otherwise
        """
        pass


class FHIRServerDataSource(DataSource):
    """Data source implementation for FHIR servers using bulk export."""
    
    def __init__(
        self,
        pathling_context: PathlingContext,
        fhir_endpoint_url: str,
        output_dir: str,
        auth_token: Optional[str] = None,
        timeout: int = 300,
        polling_interval: int = 5
    ):
        """Initialize FHIR server data source.
        
        Args:
            pathling_context: Initialized Pathling context
            fhir_endpoint_url: Base URL of the FHIR server
            output_dir: Directory for temporary bulk export files
            auth_token: Optional authentication token
            timeout: Timeout for bulk export operation in seconds
            polling_interval: Polling interval for bulk export status in seconds
        """
        super().__init__(pathling_context)
        self.fhir_endpoint_url = fhir_endpoint_url
        self.output_dir = Path(output_dir)
        self.auth_token = auth_token
        self.timeout = timeout
        self.polling_interval = polling_interval
        
        # Create bulk export temporary directory
        self.bulk_export_dir = self.output_dir / "bulk_export_temp"
        self.bulk_export_dir.mkdir(parents=True, exist_ok=True)
        
        self.logger = logger.bind(
            source_type="FHIRServer",
            endpoint=fhir_endpoint_url
        )
    
    def validate_source(self) -> bool:
        """Validate FHIR server connectivity and capabilities."""
        try:
            import requests
            
            # Check server metadata
            metadata_url = f"{self.fhir_endpoint_url}/metadata"
            headers = {}
            if self.auth_token:
                headers["Authorization"] = f"Bearer {self.auth_token}"
            
            response = requests.get(metadata_url, headers=headers, timeout=30)
            response.raise_for_status()
            
            metadata = response.json()
            
            # Check if server supports bulk export
            has_bulk_export = False
            for rest in metadata.get("rest", []):
                for operation in rest.get("operation", []):
                    if "$export" in operation.get("name", ""):
                        has_bulk_export = True
                        break
                if has_bulk_export:
                    break
            
            if not has_bulk_export:
                self.logger.warning("FHIR server may not support bulk export operation")
            
            self.logger.info("FHIR server validation successful")
            return True
            
        except Exception as e:
            self.logger.error("FHIR server validation failed", error=str(e))
            return False
    
    @retry_with_backoff(max_retries=3, backoff_factor=2)
    def load_data(
        self,
        resource_types: Optional[List[str]] = None,
        elements: Optional[List[str]] = None,
        since: Optional[str] = None,
        **kwargs
    ) -> Any:
        """Load data from FHIR server using bulk export.
        
        Args:
            resource_types: List of resource types to export
            elements: List of elements to include in export
            since: ISO datetime string for incremental export
            **kwargs: Additional bulk export parameters
            
        Returns:
            Pathling dataset containing FHIR resources
            
        Raises:
            FHIRExportError: If bulk export fails
        """
        try:
            self.logger.info(
                "Starting bulk export",
                resource_types=resource_types,
                elements=elements,
                since=since
            )
            
            # Convert Windows paths for Pathling compatibility
            bulk_export_path = str(self.bulk_export_dir).replace("\\", "/")
            
            # Prepare bulk export parameters
            bulk_params = {
                "fhir_endpoint_url": self.fhir_endpoint_url,
                "output_dir": bulk_export_path
            }
            
            if resource_types:
                bulk_params["types"] = resource_types
            if elements:
                bulk_params["elements"] = elements
            if since:
                bulk_params["since"] = since
            if self.auth_token:
                bulk_params["headers"] = {"Authorization": f"Bearer {self.auth_token}"}
            
            # Perform bulk export
            data = self.pc.read.bulk(**bulk_params)
            
            self.logger.info("Bulk export completed successfully")
            return data
            
        except Exception as e:
            error_msg = f"Bulk export failed: {str(e)}"
            self.logger.error(error_msg)
            raise FHIRExportError(error_msg) from e
    
    def cleanup_temp_files(self) -> None:
        """Clean up temporary bulk export files."""
        try:
            import shutil
            if self.bulk_export_dir.exists():
                shutil.rmtree(self.bulk_export_dir)
                self.logger.info("Cleaned up bulk export temporary files")
        except Exception as e:
            self.logger.warning("Failed to cleanup temp files", error=str(e))


class FileSystemDataSource(DataSource):
    """Data source implementation for file system (NDJSON/Parquet files)."""
    
    def __init__(
        self,
        pathling_context: PathlingContext,
        data_path: Union[str, Path],
        file_format: str = "ndjson"
    ):
        """Initialize file system data source.
        
        Args:
            pathling_context: Initialized Pathling context
            data_path: Path to directory containing FHIR data files
            file_format: Format of data files ('ndjson' or 'parquet')
        """
        super().__init__(pathling_context)
        self.data_path = Path(data_path)
        self.file_format = file_format.lower()
        
        if self.file_format not in ["ndjson", "parquet"]:
            raise ValueError(f"Unsupported file format: {file_format}")
        
        self.logger = logger.bind(
            source_type="FileSystem",
            path=str(self.data_path),
            format=self.file_format
        )
    
    def validate_source(self) -> bool:
        """Validate that data path exists and contains expected files."""
        try:
            if not self.data_path.exists():
                self.logger.error("Data path does not exist")
                return False
            
            if not self.data_path.is_dir():
                self.logger.error("Data path is not a directory")
                return False
            
            # Check for data files
            pattern = f"*.{self.file_format}"
            if self.file_format == "ndjson":
                # Also check for compressed files
                files = list(self.data_path.glob("*.ndjson")) + \
                       list(self.data_path.glob("*.ndjson.gz"))
            else:
                files = list(self.data_path.glob(pattern))
            
            if not files:
                self.logger.error(f"No {self.file_format} files found in data path")
                return False
            
            self.logger.info(f"Found {len(files)} data files")
            return True
            
        except Exception as e:
            self.logger.error("File system validation failed", error=str(e))
            return False
    
    def load_data(
        self,
        resource_types: Optional[List[str]] = None,
        **kwargs
    ) -> Any:
        """Load data from file system.
        
        Args:
            resource_types: List of resource types to load (filters files)
            **kwargs: Additional parameters
            
        Returns:
            Pathling dataset containing FHIR resources
            
        Raises:
            FHIRExportError: If data loading fails
        """
        try:
            self.logger.info("Loading data from file system", resource_types=resource_types)
            
            # Convert Windows path for Pathling compatibility
            data_path_str = str(self.data_path).replace("\\", "/")
            
            if self.file_format == "ndjson":
                data = self.pc.read.ndjson(data_path_str)
            elif self.file_format == "parquet":
                data = self.pc.read.parquet(data_path_str)
            else:
                raise ValueError(f"Unsupported file format: {self.file_format}")
            
            # Filter by resource types if specified
            if resource_types:
                # This would require additional logic to filter the dataset
                # For now, we'll log the request
                self.logger.info("Resource type filtering requested", types=resource_types)
            
            self.logger.info("Data loading completed successfully")
            return data
            
        except Exception as e:
            error_msg = f"File system data loading failed: {str(e)}"
            self.logger.error(error_msg)
            raise FHIRExportError(error_msg) from e
    
    def discover_resource_types(self) -> List[str]:
        """Discover available resource types from file names.
        
        Returns:
            List of resource types found in the data directory
        """
        resource_types = set()
        
        try:
            if self.file_format == "ndjson":
                patterns = ["*.ndjson", "*.ndjson.gz"]
            else:
                patterns = [f"*.{self.file_format}"]
            
            for pattern in patterns:
                for file_path in self.data_path.glob(pattern):
                    # Extract resource type from filename
                    # Assuming format like "Patient.ndjson" or "MimicPatient.ndjson"
                    filename = file_path.stem.replace(".ndjson", "")
                    if filename.startswith("Mimic"):
                        resource_type = filename[5:]  # Remove "Mimic" prefix
                    else:
                        resource_type = filename
                    resource_types.add(resource_type)
            
            result = sorted(list(resource_types))
            self.logger.info("Discovered resource types", types=result)
            return result
            
        except Exception as e:
            self.logger.warning("Failed to discover resource types", error=str(e))
            return []


class DataSourceFactory:
    """Factory class for creating data source instances."""
    
    @staticmethod
    def create_data_source(
        source_type: str,
        pathling_context: PathlingContext,
        **kwargs
    ) -> DataSource:
        """Create a data source instance based on type.
        
        Args:
            source_type: Type of data source ('server' or 'filesystem')
            pathling_context: Initialized Pathling context
            **kwargs: Source-specific configuration parameters
            
        Returns:
            Configured data source instance
            
        Raises:
            ValueError: If source_type is not supported
        """
        source_type = source_type.lower()
        
        if source_type in ["server", "fhir_server"]:
            required_params = ["fhir_endpoint_url", "output_dir"]
            for param in required_params:
                if param not in kwargs:
                    raise ValueError(f"Missing required parameter for FHIR server: {param}")
            
            return FHIRServerDataSource(pathling_context, **kwargs)
        
        elif source_type in ["filesystem", "file_system", "files"]:
            required_params = ["data_path"]
            for param in required_params:
                if param not in kwargs:
                    raise ValueError(f"Missing required parameter for file system: {param}")
            
            return FileSystemDataSource(pathling_context, **kwargs)
        
        else:
            raise ValueError(f"Unsupported data source type: {source_type}")