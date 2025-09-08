"""Production-ready FHIR to OMOP data exporter with modular architecture."""

import os
from pathlib import Path
from typing import Dict, List, Optional, Any, Union
import structlog
import pandas as pd

from pathling import PathlingContext

from config import Config
from data_source import DataSourceFactory, DataSource
from transformer import FHIRToOMOPTransformer
from output_writer import MultiFormatWriter
from schema_validator import SchemaValidator
from post_processor import PostProcessingPipeline
from utils import (
    FHIRExportError, setup_logging,
    log_execution_time, HealthCheck, create_error_report
)

logger = structlog.get_logger(__name__)


class FHIRExporter:
    """Production-ready FHIR to OMOP data exporter with modular architecture."""
    
    def __init__(self, config: Config):
        """Initialize the FHIR exporter.
        
        Args:
            config: Configuration object containing export settings
        """
        self.config = config
        self.logger = logger.bind(component="FHIRExporter")
        
        # Initialize components
        self.pc: Optional[PathlingContext] = None
        self.data_source: Optional[DataSource] = None
        self.transformer: Optional[FHIRToOMOPTransformer] = None
        self.output_writer: Optional[MultiFormatWriter] = None
        self.schema_validator: Optional[SchemaValidator] = None
        
        # Setup logging
        setup_logging(
            log_level=config.log_level.value,
            log_file=config.log_file,
            structured=config.structured_logging
        )
        
        self.logger.info(
            "FHIR Exporter initialized",
            config_summary=config.get_configuration_summary()
        )
    
    def initialize(self) -> None:
        """Initialize all exporter components."""
        try:
            self.logger.info("Initializing FHIR exporter components")
            
            # Validate configuration
            config_issues = self.config.validate_configuration()
            if config_issues:
                for issue in config_issues:
                    self.logger.warning("Configuration issue", issue=issue)
            
            # Perform health checks
            self._perform_health_checks()
            
            # Initialize Pathling context
            self._initialize_pathling_context()
            
            # Initialize schema validator
            self._initialize_schema_validator()
            
            # Initialize data source
            self._initialize_data_source()
            
            # Initialize transformer
            self._initialize_transformer()
            
            # Initialize output writer
            self._initialize_output_writer()
            
            self.logger.info("All components initialized successfully")
            
        except Exception as e:
            error_msg = f"Failed to initialize FHIR exporter: {str(e)}"
            self.logger.error(error_msg)
            raise FHIRExportError(error_msg) from e
    
    def _perform_health_checks(self) -> None:
        """Perform system health checks."""
        self.logger.info("Performing health checks")
        
        # Check disk space
        min_disk_space_gb = 2.0
        if not HealthCheck.check_disk_space(self.config.output.base_path, min_disk_space_gb):
            self.logger.warning(
                "Low disk space detected",
                path=str(self.config.output.base_path),
                min_required_gb=min_disk_space_gb
            )
        
        # Check memory
        min_memory_mb = 512.0
        if not HealthCheck.check_memory(min_memory_mb):
            self.logger.warning(
                "Low memory detected",
                min_required_mb=min_memory_mb
            )
    
    def _initialize_pathling_context(self) -> None:
        """Initialize Pathling context with configuration."""
        try:
            self.logger.info("Initializing Pathling context")
            
            # Set up temporary directory
            temp_dir = self.config.temp_dir or (self.config.output.base_path / "temp")
            temp_dir = Path(temp_dir)
            temp_dir.mkdir(parents=True, exist_ok=True)
            
            # Set environment variables for temp directory
            os.environ["TMPDIR"] = str(temp_dir)
            os.environ["TMP"] = str(temp_dir)
            os.environ["TEMP"] = str(temp_dir)
            
            # Configure Spark settings
            spark_config = {
                "spark.app.name": self.config.pathling.app_name,
                "spark.executor.memory": self.config.pathling.executor_memory,
                "spark.driver.memory": self.config.pathling.driver_memory,
                "spark.driver.maxResultSize": self.config.pathling.max_result_size,
                "spark.sql.adaptive.enabled": str(self.config.pathling.sql_adaptive_enabled).lower(),
                "spark.sql.adaptive.coalescePartitions.enabled": str(self.config.pathling.sql_adaptive_coalesce_partitions_enabled).lower(),
            }
            
            if self.config.pathling.master:
                spark_config["spark.master"] = self.config.pathling.master
            
            # Create Pathling context - try without config first
            try:
                self.pc = PathlingContext.create()
            except Exception:
                # Fallback to basic creation without configuration
                from pathling import PathlingContext
                self.pc = PathlingContext.create()
            
            # Validate context
            if not HealthCheck.check_pathling_context(self.pc):
                raise FHIRExportError("Pathling context validation failed")
            
            self.logger.info("Pathling context initialized successfully")
            
        except Exception as e:
            raise FHIRExportError(f"Failed to initialize Pathling context: {str(e)}") from e
    
    def _initialize_schema_validator(self) -> None:
        """Initialize schema validator if enabled."""
        if not self.config.schema_validation.enabled:
            self.logger.info("Schema validation disabled")
            return
        
        try:
            self.logger.info("Initializing schema validator")
            
            if self.config.schema_validation.ddl_file:
                self.schema_validator = SchemaValidator.from_ddl_files(
                    ddl_file=self.config.schema_validation.ddl_file,
                    constraints_file=self.config.schema_validation.constraints_file,
                    primary_keys_file=self.config.schema_validation.primary_keys_file
                )
                self.logger.info("Schema validator initialized with DDL files")
            else:
                self.logger.warning("No DDL file configured for schema validation")
                
        except Exception as e:
            self.logger.warning(f"Failed to initialize schema validator: {str(e)}")
            # Continue without schema validation
    
    def _initialize_data_source(self) -> None:
        """Initialize data source based on configuration."""
        try:
            self.logger.info("Initializing data source", type=self.config.data_source_type)
            
            data_source_config = self.config.get_data_source_config()
            
            if self.config.data_source_type.value == "fhir_server":
                self.data_source = DataSourceFactory.create_data_source(
                    source_type="fhir_server",
                    pathling_context=self.pc,
                    fhir_endpoint_url=data_source_config.endpoint_url,
                    output_dir=str(self.config.output.base_path),
                    auth_token=data_source_config.auth_token,
                    timeout=data_source_config.timeout,
                    polling_interval=data_source_config.polling_interval
                )
            else:  # file_system
                self.data_source = DataSourceFactory.create_data_source(
                    source_type="file_system",
                    pathling_context=self.pc,
                    data_path=data_source_config.data_path,
                    file_format=data_source_config.file_format
                )
            
            # Validate data source
            if not self.data_source.validate_source():
                raise FHIRExportError("Data source validation failed")
            
            self.logger.info("Data source initialized and validated")
            
        except Exception as e:
            raise FHIRExportError(f"Failed to initialize data source: {str(e)}") from e
    
    def _initialize_transformer(self) -> None:
        """Initialize FHIR to OMOP transformer."""
        try:
            self.logger.info("Initializing transformer")
            
            # Create post-processing pipeline if enabled
            post_processing_pipeline = None
            if self.config.post_processing.enabled:
                post_processing_pipeline = PostProcessingPipeline()
                post_processing_pipeline.configure_default_pipeline()
            
            # Create transformer
            self.transformer = FHIRToOMOPTransformer(
                pathling_context=self.pc,
                view_definitions_dir=self.config.view_definitions_dir,
                schema_validator=self.schema_validator,
                post_processing_pipeline=post_processing_pipeline
            )
            
            # Validate ViewDefinitions for requested tables
            validation_report = self.transformer.validate_view_definitions(self.config.omop_tables)
            
            if validation_report["missing_view_definitions"]:
                missing_tables = [vd["table"] for vd in validation_report["missing_view_definitions"]]
                self.logger.warning("Missing ViewDefinitions", tables=missing_tables)
            
            if validation_report["invalid_view_definitions"]:
                invalid_tables = [vd["table"] for vd in validation_report["invalid_view_definitions"]]
                self.logger.warning("Invalid ViewDefinitions", tables=invalid_tables)
            
            self.logger.info("Transformer initialized")
            
        except Exception as e:
            raise FHIRExportError(f"Failed to initialize transformer: {str(e)}") from e
    
    def _initialize_output_writer(self) -> None:
        """Initialize output writer."""
        try:
            self.logger.info("Initializing output writer")
            
            format_options = self.config.get_output_format_options()
            
            self.output_writer = MultiFormatWriter(
                output_path=self.config.output.base_path,
                formats=[fmt.value for fmt in self.config.output.formats],
                schema_validator=self.schema_validator,
                **format_options
            )
            
            self.logger.info(
                "Output writer initialized",
                formats=[fmt.value for fmt in self.config.output.formats]
            )
            
        except Exception as e:
            raise FHIRExportError(f"Failed to initialize output writer: {str(e)}") from e
    
    @log_execution_time("export_table")
    def export_table(
        self,
        table_name: str,
        transformation_params: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Export a single OMOP table.
        
        Args:
            table_name: Name of OMOP table to export
            transformation_params: Optional transformation parameters
            
        Returns:
            Dictionary with export results
            
        Raises:
            FHIRExportError: If export fails
        """
        if not all([self.pc, self.data_source, self.transformer, self.output_writer]):
            raise FHIRExportError("Exporter components not initialized. Call initialize() first.")
        
        try:
            self.logger.info("Starting table export", table=table_name)
            
            # Step 1: Load FHIR data
            self.logger.info("Loading FHIR data from data source")
            data_source_config = self.config.get_data_source_config()
            
            if self.config.data_source_type.value == "fhir_server":
                fhir_data = self.data_source.load_data(
                    resource_types=data_source_config.bulk_export_types,
                    elements=data_source_config.bulk_export_elements,
                    since=data_source_config.bulk_export_since
                )
            else:
                fhir_data = self.data_source.load_data()
            
            # Step 2: Transform to OMOP format
            self.logger.info("Transforming data to OMOP format")
            transformed_df = self.transformer.transform_table(
                fhir_data, table_name, transformation_params
            )
            
            if transformed_df.empty:
                self.logger.warning("Transformation produced empty result")
                return {
                    "table_name": table_name,
                    "status": "empty_result",
                    "rows": 0,
                    "output_files": {}
                }
            
            # Step 3: Write output in all configured formats
            self.logger.info("Writing output files")
            
            # Prepare metadata
            metadata = {
                "table_name": table_name,
                "export_timestamp": str(pd.Timestamp.now()),
                "data_source_type": self.config.data_source_type.value,
                "transformation_params": transformation_params or {},
                "config_summary": self.config.get_configuration_summary()
            }
            
            output_results = self.output_writer.write_table(
                transformed_df, table_name, metadata
            )
            
            result = {
                "table_name": table_name,
                "status": "success",
                "rows": len(transformed_df),
                "columns": len(transformed_df.columns),
                "output_files": output_results,
                "transformation_metadata": metadata
            }
            
            self.logger.info(
                "Table export completed successfully",
                table=table_name,
                rows=len(transformed_df),
                formats=len(output_results)
            )
            
            return result
            
        except Exception as e:
            error_msg = f"Failed to export table {table_name}: {str(e)}"
            self.logger.error(error_msg)
            
            error_report = create_error_report(
                e,
                context={
                    "table_name": table_name,
                    "transformation_params": transformation_params,
                    "config_summary": self.config.get_configuration_summary()
                }
            )
            
            raise FHIRExportError(
                error_msg,
                details={"error_report": error_report}
            ) from e
    
    @log_execution_time("export_all_tables")
    def export_all_tables(
        self,
        transformation_params: Optional[Dict[str, Dict[str, Any]]] = None
    ) -> Dict[str, Any]:
        """Export all configured OMOP tables.
        
        Args:
            transformation_params: Optional per-table transformation parameters
            
        Returns:
            Dictionary with export results for all tables
        """
        if not all([self.pc, self.data_source, self.transformer, self.output_writer]):
            raise FHIRExportError("Exporter components not initialized. Call initialize() first.")
        
        transformation_params = transformation_params or {}
        results = {}
        successful_exports = 0
        failed_exports = 0
        
        self.logger.info(
            "Starting multi-table export",
            tables=self.config.omop_tables,
            table_count=len(self.config.omop_tables)
        )
        
        for table_name in self.config.omop_tables:
            try:
                table_params = transformation_params.get(table_name, {})
                result = self.export_table(table_name, table_params)
                
                results[table_name] = result
                
                if result["status"] == "success":
                    successful_exports += 1
                else:
                    failed_exports += 1
                    
            except Exception as e:
                self.logger.error(
                    "Table export failed",
                    table=table_name,
                    error=str(e)
                )
                
                results[table_name] = {
                    "table_name": table_name,
                    "status": "failed",
                    "error": str(e),
                    "rows": 0,
                    "output_files": {}
                }
                failed_exports += 1
        
        # Generate summary report
        summary = {
            "total_tables": len(self.config.omop_tables),
            "successful_exports": successful_exports,
            "failed_exports": failed_exports,
            "export_timestamp": pd.Timestamp.now().isoformat(),
            "table_results": results
        }
        
        # Get output summary if any tables were successful
        if successful_exports > 0:
            try:
                summary["output_summary"] = self.output_writer.get_output_summary(
                    [name for name, result in results.items() if result["status"] == "success"]
                )
            except Exception as e:
                self.logger.warning("Failed to generate output summary", error=str(e))
        
        self.logger.info(
            "Multi-table export completed",
            successful=successful_exports,
            failed=failed_exports,
            total=len(self.config.omop_tables)
        )
        
        return summary
    
    def cleanup(self) -> None:
        """Clean up all resources."""
        self.logger.info("Cleaning up exporter resources")
        
        try:
            # Cleanup output writer
            if self.output_writer:
                self.output_writer.cleanup()
            
            # Cleanup data source
            if self.data_source and hasattr(self.data_source, 'cleanup_temp_files'):
                self.data_source.cleanup_temp_files()
            
            # Cleanup transformer
            if self.transformer:
                self.transformer.cleanup_resources()
            
            # Cleanup Pathling context
            if self.pc:
                try:
                    if hasattr(self.pc, '_spark') and self.pc._spark:
                        self.pc._spark.stop()
                except Exception as e:
                    self.logger.warning("Error stopping Spark context", error=str(e))
            
            # Cleanup temporary files if configured
            if self.config.cleanup_temp_files and self.config.temp_dir:
                import shutil
                temp_path = Path(self.config.temp_dir)
                if temp_path.exists():
                    shutil.rmtree(temp_path)
                    self.logger.info("Cleaned up temporary directory")
            
            self.logger.info("Resource cleanup completed")
            
        except Exception as e:
            self.logger.warning("Error during cleanup", error=str(e))
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit with cleanup."""
        self.cleanup()