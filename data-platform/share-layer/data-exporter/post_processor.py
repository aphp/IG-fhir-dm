"""Post-processing framework for FHIR to OMOP data transformation."""

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional, Type, Union, Callable
from dataclasses import dataclass, field
import pandas as pd
from pathlib import Path
import importlib
import structlog

from utils import FHIRExportError, TransformationError, log_execution_time

logger = structlog.get_logger(__name__)


@dataclass
class PostProcessingContext:
    """Context information for post-processing operations."""
    table_name: str
    source_data_info: Dict[str, Any] = field(default_factory=dict)
    transformation_metadata: Dict[str, Any] = field(default_factory=dict)
    processing_parameters: Dict[str, Any] = field(default_factory=dict)
    previous_results: Dict[str, Any] = field(default_factory=dict)
    
    def get_parameter(self, key: str, default: Any = None) -> Any:
        """Get processing parameter with default value."""
        return self.processing_parameters.get(key, default)
    
    def set_result(self, key: str, value: Any) -> None:
        """Set result for use by subsequent processors."""
        self.previous_results[key] = value
    
    def get_result(self, key: str, default: Any = None) -> Any:
        """Get result from previous processors."""
        return self.previous_results.get(key, default)


class PostProcessor(ABC):
    """Abstract base class for post-processing operations."""
    
    def __init__(self, name: str, priority: int = 100):
        """Initialize post-processor.
        
        Args:
            name: Unique name for the processor
            priority: Processing priority (lower numbers execute first)
        """
        self.name = name
        self.priority = priority
        self.logger = logger.bind(processor=name)
    
    @abstractmethod
    def process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Process the data and return modified DataFrame.
        
        Args:
            data: Input DataFrame to process
            context: Processing context with metadata and parameters
            
        Returns:
            Processed DataFrame
            
        Raises:
            TransformationError: If processing fails
        """
        pass
    
    def validate_prerequisites(self, context: PostProcessingContext) -> bool:
        """Validate that prerequisites for processing are met.
        
        Args:
            context: Processing context
            
        Returns:
            True if prerequisites are met
        """
        return True
    
    def should_process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> bool:
        """Determine if this processor should run for the given data.
        
        Args:
            data: Input DataFrame
            context: Processing context
            
        Returns:
            True if processor should run
        """
        return True
    
    def get_metadata(self) -> Dict[str, Any]:
        """Get processor metadata for reporting."""
        return {
            "name": self.name,
            "priority": self.priority,
            "type": self.__class__.__name__
        }


class DataCleaningProcessor(PostProcessor):
    """Processor for data cleaning operations."""
    
    def __init__(self, priority: int = 10):
        super().__init__("data_cleaning", priority)
        
    def process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Clean data by handling nulls, duplicates, and invalid values."""
        self.logger.info("Starting data cleaning", rows=len(data))
        
        original_row_count = len(data)
        
        # Remove completely empty rows
        data = data.dropna(how='all')
        
        # Handle duplicate records if primary key is available
        if context.table_name.lower() == 'person':
            # For Person table, remove duplicates based on person_id
            if 'person_id' in data.columns:
                before_dedup = len(data)
                data = data.drop_duplicates(subset=['person_id'], keep='first')
                after_dedup = len(data)
                
                if before_dedup != after_dedup:
                    self.logger.info(
                        "Removed duplicate persons",
                        duplicates_removed=before_dedup - after_dedup
                    )
        
        # Clean string columns
        string_columns = data.select_dtypes(include=['object']).columns
        for col in string_columns:
            # Strip whitespace
            data[col] = data[col].astype(str).str.strip()
            # Replace empty strings with NaN
            data[col] = data[col].replace('', pd.NA)
        
        # Log cleaning results
        final_row_count = len(data)
        context.set_result("cleaning_stats", {
            "original_rows": original_row_count,
            "final_rows": final_row_count,
            "rows_removed": original_row_count - final_row_count
        })
        
        self.logger.info(
            "Data cleaning completed",
            original_rows=original_row_count,
            final_rows=final_row_count
        )
        
        return data


class DataTypeEnforcementProcessor(PostProcessor):
    """Processor for enforcing correct data types."""
    
    def __init__(self, priority: int = 20):
        super().__init__("data_type_enforcement", priority)
        
    def process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Enforce correct data types based on OMOP schema."""
        self.logger.info("Enforcing data types", table=context.table_name)
        
        type_conversions = self._get_type_conversions(context.table_name)
        conversion_errors = {}
        
        for column, target_type in type_conversions.items():
            if column in data.columns:
                try:
                    original_dtype = data[column].dtype
                    data[column] = self._convert_column_type(data[column], target_type)
                    
                    self.logger.debug(
                        "Converted column type",
                        column=column,
                        from_type=str(original_dtype),
                        to_type=target_type
                    )
                    
                except Exception as e:
                    conversion_errors[column] = str(e)
                    self.logger.warning(
                        "Failed to convert column type",
                        column=column,
                        target_type=target_type,
                        error=str(e)
                    )
        
        if conversion_errors:
            context.set_result("type_conversion_errors", conversion_errors)
        
        self.logger.info("Data type enforcement completed")
        return data
    
    def _get_type_conversions(self, table_name: str) -> Dict[str, str]:
        """Get type conversion mappings for OMOP tables."""
        # Common OMOP data type mappings
        common_types = {
            # ID columns should be integers or strings
            'person_id': 'int64',
            'provider_id': 'int64',
            'care_site_id': 'int64',
            'location_id': 'int64',
            'visit_occurrence_id': 'int64',
            'condition_occurrence_id': 'int64',
            'drug_exposure_id': 'int64',
            'procedure_occurrence_id': 'int64',
            'measurement_id': 'int64',
            'observation_id': 'int64',
            
            # Concept IDs are integers
            'gender_concept_id': 'int64',
            'race_concept_id': 'int64',
            'ethnicity_concept_id': 'int64',
            'condition_concept_id': 'int64',
            'drug_concept_id': 'int64',
            'procedure_concept_id': 'int64',
            
            # Date columns
            'birth_datetime': 'datetime64[ns]',
            'condition_start_date': 'datetime64[ns]',
            'condition_end_date': 'datetime64[ns]',
            'drug_exposure_start_date': 'datetime64[ns]',
            'drug_exposure_end_date': 'datetime64[ns]',
            'procedure_date': 'datetime64[ns]',
            'measurement_date': 'datetime64[ns]',
            'observation_date': 'datetime64[ns]',
            
            # Numeric values
            'year_of_birth': 'int64',
            'month_of_birth': 'int64',
            'day_of_birth': 'int64',
            'quantity': 'float64',
            'value_as_number': 'float64',
            'range_low': 'float64',
            'range_high': 'float64',
        }
        
        # Table-specific type mappings could be added here
        table_specific = {}
        
        return {**common_types, **table_specific}
    
    def _convert_column_type(self, series: pd.Series, target_type: str) -> pd.Series:
        """Convert pandas series to target type."""
        if target_type == 'int64':
            # Handle conversion to integer with null preservation
            return pd.to_numeric(series, errors='coerce').astype('Int64')
        elif target_type == 'float64':
            return pd.to_numeric(series, errors='coerce')
        elif target_type.startswith('datetime64'):
            return pd.to_datetime(series, errors='coerce')
        elif target_type == 'string':
            return series.astype('string')
        else:
            return series.astype(target_type)


class ConceptMappingProcessor(PostProcessor):
    """Processor for OMOP concept mapping and enrichment."""
    
    def __init__(self, concept_mapping_file: Optional[Path] = None, priority: int = 30):
        super().__init__("concept_mapping", priority)
        self.concept_mapping_file = concept_mapping_file
        self.concept_mappings = {}
        self._load_concept_mappings()
    
    def _load_concept_mappings(self) -> None:
        """Load concept mappings from file."""
        if self.concept_mapping_file and self.concept_mapping_file.exists():
            try:
                import json
                with open(self.concept_mapping_file, 'r') as f:
                    self.concept_mappings = json.load(f)
                self.logger.info("Loaded concept mappings", count=len(self.concept_mappings))
            except Exception as e:
                self.logger.warning("Failed to load concept mappings", error=str(e))
    
    def process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Apply concept mappings to appropriate columns."""
        if not self.concept_mappings:
            self.logger.info("No concept mappings available, skipping")
            return data
        
        self.logger.info("Applying concept mappings")
        
        mappings_applied = 0
        
        # Apply gender concept mapping
        if 'gender_source_value' in data.columns and 'gender_concept_id' in data.columns:
            mappings_applied += self._apply_gender_concepts(data)
        
        # Apply other concept mappings as needed
        # This would be extended based on available concept mapping data
        
        context.set_result("concept_mappings_applied", mappings_applied)
        self.logger.info("Concept mapping completed", mappings_applied=mappings_applied)
        
        return data
    
    def _apply_gender_concepts(self, data: pd.DataFrame) -> int:
        """Apply gender concept mappings."""
        gender_mapping = {
            'male': 8507,
            'female': 8532,
            'unknown': 8551,
            'other': 8521
        }
        
        mappings_applied = 0
        
        for idx, row in data.iterrows():
            gender_source = str(row.get('gender_source_value', '')).lower().strip()
            if gender_source in gender_mapping and pd.isna(row.get('gender_concept_id')):
                data.at[idx, 'gender_concept_id'] = gender_mapping[gender_source]
                mappings_applied += 1
        
        return mappings_applied


class DataValidationProcessor(PostProcessor):
    """Processor for final data validation."""
    
    def __init__(self, priority: int = 90):
        super().__init__("data_validation", priority)
    
    def process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Perform final validation checks on processed data."""
        self.logger.info("Performing data validation")
        
        validation_results = {
            "total_rows": len(data),
            "null_counts": {},
            "data_quality_issues": []
        }
        
        # Check null counts for important columns
        for column in data.columns:
            null_count = data[column].isnull().sum()
            if null_count > 0:
                validation_results["null_counts"][column] = null_count
        
        # Table-specific validations
        if context.table_name.lower() == 'person':
            validation_results.update(self._validate_person_table(data))
        
        # Check for obvious data quality issues
        validation_results["data_quality_issues"].extend(
            self._check_data_quality_issues(data, context.table_name)
        )
        
        context.set_result("validation_results", validation_results)
        
        self.logger.info(
            "Data validation completed",
            issues_found=len(validation_results["data_quality_issues"])
        )
        
        return data
    
    def _validate_person_table(self, data: pd.DataFrame) -> Dict[str, Any]:
        """Validate Person table specific constraints."""
        issues = []
        
        # Check for duplicate person IDs
        if 'person_id' in data.columns:
            duplicates = data['person_id'].duplicated().sum()
            if duplicates > 0:
                issues.append(f"Found {duplicates} duplicate person IDs")
        
        # Check birth year reasonableness
        if 'year_of_birth' in data.columns:
            current_year = pd.Timestamp.now().year
            invalid_years = data[
                (data['year_of_birth'] < 1900) | 
                (data['year_of_birth'] > current_year)
            ].shape[0]
            if invalid_years > 0:
                issues.append(f"Found {invalid_years} invalid birth years")
        
        return {"person_validation_issues": issues}
    
    def _check_data_quality_issues(
        self, 
        data: pd.DataFrame, 
        table_name: str
    ) -> List[str]:
        """Check for general data quality issues."""
        issues = []
        
        # Check for columns with all null values
        for column in data.columns:
            if data[column].isnull().all():
                issues.append(f"Column '{column}' contains only null values")
        
        # Check for unexpected data patterns
        # This could be extended with more sophisticated quality checks
        
        return issues


class PostProcessingPipeline:
    """Pipeline for orchestrating post-processing operations."""
    
    def __init__(self):
        self.processors: List[PostProcessor] = []
        self.logger = logger.bind(component="PostProcessingPipeline")
    
    def add_processor(self, processor: PostProcessor) -> None:
        """Add a processor to the pipeline.
        
        Args:
            processor: PostProcessor instance to add
        """
        self.processors.append(processor)
        # Sort by priority (lower numbers first)
        self.processors.sort(key=lambda p: p.priority)
        self.logger.debug("Added processor", processor=processor.name, priority=processor.priority)
    
    def remove_processor(self, processor_name: str) -> bool:
        """Remove a processor by name.
        
        Args:
            processor_name: Name of processor to remove
            
        Returns:
            True if processor was removed
        """
        original_count = len(self.processors)
        self.processors = [p for p in self.processors if p.name != processor_name]
        removed = len(self.processors) < original_count
        
        if removed:
            self.logger.debug("Removed processor", processor=processor_name)
        
        return removed
    
    def get_processor(self, processor_name: str) -> Optional[PostProcessor]:
        """Get processor by name."""
        for processor in self.processors:
            if processor.name == processor_name:
                return processor
        return None
    
    @log_execution_time("post_processing_pipeline")
    def process(
        self, 
        data: pd.DataFrame, 
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Execute the complete post-processing pipeline.
        
        Args:
            data: Input DataFrame
            context: Processing context
            
        Returns:
            Processed DataFrame
            
        Raises:
            TransformationError: If any processor fails
        """
        if not self.processors:
            self.logger.info("No processors configured, returning data unchanged")
            return data
        
        self.logger.info(
            "Starting post-processing pipeline",
            processor_count=len(self.processors),
            table=context.table_name,
            initial_rows=len(data)
        )
        
        processing_results = []
        current_data = data.copy()
        
        for processor in self.processors:
            try:
                # Check prerequisites
                if not processor.validate_prerequisites(context):
                    self.logger.warning(
                        "Processor prerequisites not met, skipping",
                        processor=processor.name
                    )
                    continue
                
                # Check if processor should run
                if not processor.should_process(current_data, context):
                    self.logger.info(
                        "Processor chose not to process data, skipping",
                        processor=processor.name
                    )
                    continue
                
                self.logger.info("Executing processor", processor=processor.name)
                
                # Execute processor
                before_rows = len(current_data)
                current_data = processor.process(current_data, context)
                after_rows = len(current_data)
                
                # Record processing results
                processing_results.append({
                    "processor": processor.name,
                    "rows_before": before_rows,
                    "rows_after": after_rows,
                    "rows_changed": after_rows - before_rows,
                    "metadata": processor.get_metadata()
                })
                
                self.logger.info(
                    "Processor completed",
                    processor=processor.name,
                    rows_before=before_rows,
                    rows_after=after_rows
                )
                
            except Exception as e:
                error_msg = f"Processor '{processor.name}' failed: {str(e)}"
                self.logger.error(error_msg, error=str(e))
                raise TransformationError(
                    error_msg,
                    details={
                        "processor": processor.name,
                        "table": context.table_name,
                        "error_type": type(e).__name__
                    }
                ) from e
        
        # Store processing results in context
        context.set_result("processing_results", processing_results)
        
        self.logger.info(
            "Post-processing pipeline completed",
            final_rows=len(current_data),
            processors_executed=len(processing_results)
        )
        
        return current_data
    
    def get_default_processors(self) -> List[PostProcessor]:
        """Get default set of processors for standard processing."""
        return [
            DataCleaningProcessor(priority=10),
            DataTypeEnforcementProcessor(priority=20),
            ConceptMappingProcessor(priority=30),
            DataValidationProcessor(priority=90)
        ]
    
    def configure_default_pipeline(self) -> None:
        """Configure pipeline with default processors."""
        for processor in self.get_default_processors():
            self.add_processor(processor)
        
        self.logger.info("Configured default processing pipeline")
    
    def get_pipeline_summary(self) -> Dict[str, Any]:
        """Get summary of configured pipeline."""
        return {
            "processor_count": len(self.processors),
            "processors": [
                {
                    "name": p.name,
                    "priority": p.priority,
                    "type": p.__class__.__name__
                }
                for p in self.processors
            ]
        }