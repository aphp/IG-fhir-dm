"""FHIR to OMOP transformation engine with ViewDefinition and post-processing support."""

import json
import pandas as pd
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
import structlog

from pathling import PathlingContext
from utils import (
    FHIRExportError, TransformationError, ValidationError,
    safe_json_load, log_execution_time, ProgressReporter
)
from post_processor import PostProcessingPipeline, PostProcessingContext
from schema_validator import SchemaValidator, TableDefinition

logger = structlog.get_logger(__name__)


class ViewDefinitionProcessor:
    """Processor for FHIR ViewDefinition transformations."""
    
    def __init__(self):
        self.logger = logger.bind(component="ViewDefinitionProcessor")
    
    def load_view_definition(self, view_definition_path: Union[str, Path]) -> Dict[str, Any]:
        """Load and validate ViewDefinition from file.
        
        Args:
            view_definition_path: Path to ViewDefinition JSON file
            
        Returns:
            Parsed ViewDefinition dictionary
            
        Raises:
            ValidationError: If ViewDefinition is invalid
        """
        try:
            view_def = safe_json_load(view_definition_path)
            self._validate_view_definition(view_def)
            
            self.logger.info(
                "Loaded ViewDefinition",
                url=view_def.get("url"),
                resource=view_def.get("resource"),
                columns=len(view_def.get("select", [{}])[0].get("column", []))
            )
            
            return view_def
            
        except Exception as e:
            raise ValidationError(
                f"Failed to load ViewDefinition: {view_definition_path}",
                details={"error": str(e)}
            ) from e
    
    def _validate_view_definition(self, view_def: Dict[str, Any]) -> None:
        """Validate ViewDefinition structure.
        
        Args:
            view_def: ViewDefinition dictionary to validate
            
        Raises:
            ValidationError: If ViewDefinition is invalid
        """
        required_fields = ["resource", "select"]
        for field in required_fields:
            if field not in view_def:
                raise ValidationError(
                    f"Missing required field in ViewDefinition: {field}"
                )
        
        # Validate select structure
        select_list = view_def.get("select", [])
        if not isinstance(select_list, list) or not select_list:
            raise ValidationError("ViewDefinition select must be a non-empty list")
        
        # Validate columns
        for select_item in select_list:
            if "column" not in select_item:
                raise ValidationError("ViewDefinition select item must contain 'column'")
            
            columns = select_item["column"]
            if not isinstance(columns, list):
                raise ValidationError("ViewDefinition columns must be a list")
            
            for column in columns:
                if not isinstance(column, dict) or "name" not in column:
                    raise ValidationError("ViewDefinition column must have 'name' field")
    
    @log_execution_time("view_definition_application")
    def apply_view_definition(
        self,
        pathling_data: Any,
        view_definition: Dict[str, Any],
        resource_type: Optional[str] = None
    ) -> pd.DataFrame:
        """Apply ViewDefinition transformation to Pathling data.
        
        Args:
            pathling_data: Pathling dataset with FHIR resources
            view_definition: ViewDefinition configuration
            resource_type: Override resource type from ViewDefinition
            
        Returns:
            Transformed DataFrame in OMOP format
            
        Raises:
            TransformationError: If transformation fails
        """
        try:
            # Determine resource type
            target_resource = resource_type or view_definition.get("resource", "Patient")
            
            self.logger.info(
                "Applying ViewDefinition transformation",
                resource_type=target_resource,
                columns=len(view_definition.get("select", [{}])[0].get("column", []))
            )
            
            # Apply the ViewDefinition using Pathling
            with ProgressReporter("Applying ViewDefinition transformation"):
                result = pathling_data.view(
                    resource=target_resource,
                    json=json.dumps(view_definition)
                )
            
            # Convert to pandas DataFrame
            df = result.toPandas()
            
            self.logger.info(
                "ViewDefinition transformation completed",
                output_rows=len(df),
                output_columns=len(df.columns)
            )
            
            return df
            
        except Exception as e:
            error_msg = f"ViewDefinition transformation failed: {str(e)}"
            self.logger.error(error_msg)
            raise TransformationError(
                error_msg,
                details={
                    "resource_type": target_resource,
                    "view_definition_url": view_definition.get("url")
                }
            ) from e
    
    def extract_column_metadata(
        self, 
        view_definition: Dict[str, Any]
    ) -> Dict[str, Dict[str, Any]]:
        """Extract column metadata from ViewDefinition.
        
        Args:
            view_definition: ViewDefinition configuration
            
        Returns:
            Dictionary mapping column names to metadata
        """
        column_metadata = {}
        
        select_list = view_definition.get("select", [])
        for select_item in select_list:
            columns = select_item.get("column", [])
            
            for column in columns:
                column_name = column.get("name")
                if column_name:
                    column_metadata[column_name] = {
                        "path": column.get("path"),
                        "type": column.get("type"),
                        "description": column.get("description"),
                        "tags": column.get("tag", [])
                    }
        
        return column_metadata


class FHIRToOMOPTransformer:
    """Main transformer class coordinating ViewDefinition and post-processing."""
    
    def __init__(
        self,
        pathling_context: PathlingContext,
        view_definitions_dir: Union[str, Path],
        schema_validator: Optional[SchemaValidator] = None,
        post_processing_pipeline: Optional[PostProcessingPipeline] = None
    ):
        """Initialize transformer.
        
        Args:
            pathling_context: Initialized Pathling context
            view_definitions_dir: Directory containing ViewDefinition files
            schema_validator: Optional schema validator for validation
            post_processing_pipeline: Optional post-processing pipeline
        """
        self.pc = pathling_context
        self.view_definitions_dir = Path(view_definitions_dir)
        self.schema_validator = schema_validator
        self.post_processing_pipeline = post_processing_pipeline or PostProcessingPipeline()
        
        # Initialize components
        self.view_processor = ViewDefinitionProcessor()
        
        self.logger = logger.bind(component="FHIRToOMOPTransformer")
        
        # Configure default post-processing if none provided
        if not self.post_processing_pipeline.processors:
            self.post_processing_pipeline.configure_default_pipeline()
    
    def get_view_definition_path(self, table_name: str) -> Path:
        """Get path to ViewDefinition file for OMOP table.
        
        Args:
            table_name: Name of OMOP table
            
        Returns:
            Path to ViewDefinition file
        """
        return self.view_definitions_dir / f"Binary-OMOP-{table_name}-View.json"
    
    @log_execution_time("table_transformation")
    def transform_table(
        self,
        pathling_data: Any,
        table_name: str,
        transformation_params: Optional[Dict[str, Any]] = None
    ) -> pd.DataFrame:
        """Transform FHIR data to OMOP table format.
        
        Args:
            pathling_data: Pathling dataset with FHIR resources
            table_name: Name of target OMOP table
            transformation_params: Optional transformation parameters
            
        Returns:
            Transformed and post-processed DataFrame
            
        Raises:
            TransformationError: If transformation fails
        """
        transformation_params = transformation_params or {}
        
        self.logger.info(
            "Starting table transformation",
            table=table_name,
            has_params=bool(transformation_params)
        )
        
        try:
            # Step 1: Load ViewDefinition
            view_def_path = self.get_view_definition_path(table_name)
            if not view_def_path.exists():
                raise ValidationError(f"ViewDefinition not found: {view_def_path}")
            
            view_definition = self.view_processor.load_view_definition(view_def_path)
            
            # Step 2: Apply ViewDefinition transformation
            transformed_df = self.view_processor.apply_view_definition(
                pathling_data, view_definition
            )
            
            if transformed_df.empty:
                self.logger.warning("ViewDefinition transformation produced empty result")
                return transformed_df
            
            # Step 3: Create post-processing context
            context = PostProcessingContext(
                table_name=table_name,
                transformation_metadata={
                    "view_definition_url": view_definition.get("url"),
                    "source_resource": view_definition.get("resource"),
                    "column_metadata": self.view_processor.extract_column_metadata(view_definition)
                },
                processing_parameters=transformation_params
            )
            
            # Step 4: Apply post-processing pipeline
            if self.post_processing_pipeline.processors:
                self.logger.info("Applying post-processing pipeline")
                processed_df = self.post_processing_pipeline.process(transformed_df, context)
            else:
                self.logger.info("No post-processing configured, skipping")
                processed_df = transformed_df
            
            # Step 5: Schema validation (if available)
            if self.schema_validator:
                self.logger.info("Performing schema validation")
                validation_report = self.schema_validator.validate_table_schema(
                    table_name, processed_df
                )
                
                # Log validation results
                if validation_report["summary"]["is_valid"]:
                    self.logger.info("Schema validation passed")
                else:
                    self.logger.warning(
                        "Schema validation issues found",
                        issues=validation_report["summary"]["total_issues"]
                    )
                
                # Store validation results in context for potential use
                context.set_result("schema_validation", validation_report)
            
            self.logger.info(
                "Table transformation completed successfully",
                table=table_name,
                final_rows=len(processed_df),
                final_columns=len(processed_df.columns)
            )
            
            return processed_df
            
        except Exception as e:
            error_msg = f"Table transformation failed for {table_name}: {str(e)}"
            self.logger.error(error_msg)
            raise TransformationError(
                error_msg,
                details={
                    "table_name": table_name,
                    "error_type": type(e).__name__
                }
            ) from e
    
    def transform_multiple_tables(
        self,
        pathling_data: Any,
        table_names: List[str],
        transformation_params: Optional[Dict[str, Dict[str, Any]]] = None
    ) -> Dict[str, pd.DataFrame]:
        """Transform multiple OMOP tables from FHIR data.
        
        Args:
            pathling_data: Pathling dataset with FHIR resources
            table_names: List of OMOP table names to transform
            transformation_params: Optional per-table transformation parameters
            
        Returns:
            Dictionary mapping table names to transformed DataFrames
        """
        transformation_params = transformation_params or {}
        results = {}
        
        self.logger.info(
            "Starting multi-table transformation",
            table_count=len(table_names),
            tables=table_names
        )
        
        for table_name in table_names:
            try:
                table_params = transformation_params.get(table_name, {})
                
                self.logger.info("Processing table", table=table_name)
                
                transformed_df = self.transform_table(
                    pathling_data, table_name, table_params
                )
                
                results[table_name] = transformed_df
                
                self.logger.info(
                    "Table transformation completed",
                    table=table_name,
                    rows=len(transformed_df)
                )
                
            except Exception as e:
                self.logger.error(
                    "Table transformation failed",
                    table=table_name,
                    error=str(e)
                )
                # Continue with other tables
                results[table_name] = None
        
        successful_tables = [name for name, df in results.items() if df is not None]
        
        self.logger.info(
            "Multi-table transformation completed",
            total_tables=len(table_names),
            successful_tables=len(successful_tables),
            failed_tables=len(table_names) - len(successful_tables)
        )
        
        return results
    
    def validate_view_definitions(self, table_names: List[str]) -> Dict[str, Any]:
        """Validate ViewDefinitions for specified tables.
        
        Args:
            table_names: List of table names to validate
            
        Returns:
            Validation report dictionary
        """
        validation_report = {
            "validated_tables": [],
            "missing_view_definitions": [],
            "invalid_view_definitions": [],
            "validation_timestamp": pd.Timestamp.now().isoformat()
        }
        
        self.logger.info("Validating ViewDefinitions", tables=table_names)
        
        for table_name in table_names:
            view_def_path = self.get_view_definition_path(table_name)
            
            if not view_def_path.exists():
                validation_report["missing_view_definitions"].append({
                    "table": table_name,
                    "path": str(view_def_path)
                })
                continue
            
            try:
                view_definition = self.view_processor.load_view_definition(view_def_path)
                validation_report["validated_tables"].append({
                    "table": table_name,
                    "resource": view_definition.get("resource"),
                    "columns": len(view_definition.get("select", [{}])[0].get("column", []))
                })
            except Exception as e:
                validation_report["invalid_view_definitions"].append({
                    "table": table_name,
                    "path": str(view_def_path),
                    "error": str(e)
                })
        
        self.logger.info(
            "ViewDefinition validation completed",
            valid=len(validation_report["validated_tables"]),
            missing=len(validation_report["missing_view_definitions"]),
            invalid=len(validation_report["invalid_view_definitions"])
        )
        
        return validation_report
    
    def get_transformation_summary(
        self, 
        results: Dict[str, pd.DataFrame]
    ) -> Dict[str, Any]:
        """Generate transformation summary report.
        
        Args:
            results: Dictionary of transformation results
            
        Returns:
            Summary report dictionary
        """
        summary = {
            "total_tables": len(results),
            "successful_tables": 0,
            "failed_tables": 0,
            "total_rows": 0,
            "table_details": [],
            "post_processing_summary": {},
            "timestamp": pd.Timestamp.now().isoformat()
        }
        
        for table_name, df in results.items():
            if df is not None:
                summary["successful_tables"] += 1
                summary["total_rows"] += len(df)
                
                table_detail = {
                    "table": table_name,
                    "status": "success",
                    "rows": len(df),
                    "columns": len(df.columns),
                    "column_names": list(df.columns)
                }
            else:
                summary["failed_tables"] += 1
                table_detail = {
                    "table": table_name,
                    "status": "failed",
                    "rows": 0,
                    "columns": 0,
                    "column_names": []
                }
            
            summary["table_details"].append(table_detail)
        
        # Add post-processing pipeline summary
        if self.post_processing_pipeline:
            summary["post_processing_summary"] = self.post_processing_pipeline.get_pipeline_summary()
        
        return summary
    
    def cleanup_resources(self) -> None:
        """Clean up transformation resources."""
        try:
            # Clean up any temporary resources if needed
            self.logger.info("Cleaning up transformation resources")
        except Exception as e:
            self.logger.warning("Error during transformation cleanup", error=str(e))