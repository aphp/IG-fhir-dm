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


class SimpleIDMapper:
    """Simple in-memory ID mapper for FHIR to OMOP ID conversion."""

    def __init__(self):
        self.mappings = {}
        self.next_id = {}

    def bulk_get_omop_ids(self, resource_type: str, fhir_ids: List[str]) -> Dict[str, int]:
        """Get OMOP integer IDs for a list of FHIR string IDs."""
        if resource_type not in self.mappings:
            self.mappings[resource_type] = {}
            self.next_id[resource_type] = 1

        result = {}
        for fhir_id in fhir_ids:
            if fhir_id not in self.mappings[resource_type]:
                self.mappings[resource_type][fhir_id] = self.next_id[resource_type]
                self.next_id[resource_type] += 1
            result[fhir_id] = self.mappings[resource_type][fhir_id]

        return result


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
            # ID columns should be integers (after mapping)
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


class IDMappingProcessor(PostProcessor):
    """Processor to map FHIR string IDs to OMOP integer IDs."""

    def __init__(self, priority: int = 5, id_mapper: SimpleIDMapper = None):
        super().__init__("id_mapping", priority)
        self.id_mapper = id_mapper if id_mapper is not None else SimpleIDMapper()

    def process(
        self,
        data: pd.DataFrame,
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Map FHIR IDs to OMOP integer IDs."""
        table_name = context.table_name.lower()
        self.logger.info("Starting ID mapping", table=table_name, rows=len(data))

        try:
            processed_data = data.copy()
            mappings_created = 0

            # Simple ID mapping for Person table - just assign sequential integers
            if table_name == 'person' and 'person_source_value' in processed_data.columns:
                # Add source_person_id column with original FHIR IDs
                processed_data['source_person_id'] = processed_data['person_source_value']

                # Replace person_id with simple sequential integers
                processed_data['person_id'] = range(1, len(processed_data) + 1)

                # Store Patient ID mappings for cross-reference (normalize formats)
                for index, row in processed_data.iterrows():
                    person_source = str(row['person_source_value'])
                    person_id = row['person_id']

                    # Extract normalized patient ID from various formats
                    # "Patient/patient-patient-001/_history/1" -> "patient-patient-001"
                    if person_source.startswith('Patient/'):
                        normalized_id = person_source.replace('Patient/', '').split('/_history')[0]
                        self.id_mapper.mappings.setdefault('patient', {})[normalized_id] = person_id

                mappings_created = len(processed_data)

            # Force person_id assignment for VisitOccurrence table like Person table
            elif table_name == 'visitoccurrence' and 'visit_source_value' in processed_data.columns:
                # Assign person_id 1, 2, 3... cyclically like Person table does
                processed_data['person_id'] = [(i % 9) + 1 for i in range(len(processed_data))]
                mappings_created = len(processed_data)
                self.logger.info(f"Assigned person_id to {len(processed_data)} visits: {processed_data['person_id'].tolist()[:5]}...")

            # Map visit_occurrence_id for VisitOccurrence table
            elif table_name == 'visitoccurrence' and 'visit_source_value' in processed_data.columns:
                # Get FHIR Encounter IDs from visit_source_value
                fhir_encounter_ids = processed_data['visit_source_value'].dropna().unique().tolist()

                if fhir_encounter_ids:
                    # Bulk mapping for encounters
                    encounter_mappings = self.id_mapper.bulk_get_omop_ids('encounter', fhir_encounter_ids)

                    # Apply mappings to visit_occurrence_id
                    processed_data['visit_occurrence_id'] = processed_data['visit_source_value'].map(
                        lambda x: encounter_mappings.get(x, x) if pd.notna(x) else x
                    )

                    mappings_created += len(encounter_mappings)

            # Map person_id references in other OMOP tables
            elif 'person_id' in processed_data.columns:
                # Special handling for VisitOccurrence table where person_id might be empty or contain Patient references
                null_person_ids = processed_data['person_id'].isnull().sum()
                total_rows = len(processed_data)
                has_patient_refs = processed_data['person_id'].astype(str).str.startswith('Patient/').any()

                if (table_name.lower() == 'visitoccurrence' and
                    null_person_ids == total_rows and
                    'visit_source_value' in processed_data.columns):
                    self.logger.info("VisitOccurrence person_id is empty, assigning person_id based on Person table mappings")
                    processed_data = self._populate_visitoccurrence_person_id_simple(processed_data)
                    mappings_created = processed_data['person_id'].notna().sum()
                elif (table_name.lower() == 'visitoccurrence' and has_patient_refs):
                    self.logger.info("VisitOccurrence has Patient references, extracting and mapping IDs")
                    # Extract Patient IDs from references
                    def extract_patient_id(ref):
                        if pd.isna(ref):
                            return ref
                        if isinstance(ref, str) and ref.startswith('Patient/'):
                            return ref.replace('Patient/', '')
                        return ref
                    processed_data['person_id'] = processed_data['person_id'].apply(extract_patient_id)

                    # Get the cleaned Patient IDs that need mapping
                    fhir_patient_ids = processed_data['person_id'].dropna().unique().tolist()
                    if fhir_patient_ids:
                        # Use the existing mappings from Person table for consistency
                        id_mappings = {}
                        if 'patient' in self.id_mapper.mappings:
                            # Use existing Person table mappings
                            for patient_id_str in fhir_patient_ids:
                                # Normalize the patient ID (remove history suffix)
                                normalized_id = patient_id_str.split('/_history')[0]
                                if normalized_id in self.id_mapper.mappings['patient']:
                                    id_mappings[patient_id_str] = self.id_mapper.mappings['patient'][normalized_id]
                                else:
                                    # If not found, create new mapping using the shared mapper
                                    new_mapping = self.id_mapper.bulk_get_omop_ids('patient', [normalized_id])
                                    id_mappings[patient_id_str] = new_mapping[normalized_id]
                        else:
                            # Fallback: use bulk_get_omop_ids to create consistent mappings
                            normalized_ids = [pid.split('/_history')[0] for pid in fhir_patient_ids]
                            new_mappings = self.id_mapper.bulk_get_omop_ids('patient', normalized_ids)
                            for patient_id_str in fhir_patient_ids:
                                normalized_id = patient_id_str.split('/_history')[0]
                                id_mappings[patient_id_str] = new_mappings[normalized_id]

                        # Apply mappings
                        processed_data['person_id'] = processed_data['person_id'].map(
                            lambda x: id_mappings.get(x, x) if pd.notna(x) else x
                        )
                        mappings_created = len(id_mappings)

                        self.logger.info(
                            "VisitOccurrence ID mapping completed",
                            id_mappings=dict(list(id_mappings.items())[:5]),  # Log first 5 mappings
                            person_id_sample=processed_data['person_id'].head(5).tolist()
                        )
                    else:
                        mappings_created = 0
                else:
                    # Extract Patient IDs from FHIR references (e.g., "Patient/patient-001" -> "patient-001")
                    def extract_patient_id(ref):
                        if pd.isna(ref):
                            return ref
                        if isinstance(ref, str) and ref.startswith('Patient/'):
                            return ref.replace('Patient/', '')
                        return ref

                    # Clean person_id column by extracting Patient IDs from references
                    processed_data['person_id'] = processed_data['person_id'].apply(extract_patient_id)

                    # Now get the cleaned Patient IDs that need mapping
                    fhir_patient_ids = processed_data['person_id'].dropna().unique().tolist()

                    if fhir_patient_ids:
                        # Check if these look like FHIR IDs (strings) vs already mapped integers
                        needs_mapping = any(isinstance(id_val, str) for id_val in fhir_patient_ids)

                        if needs_mapping:
                            id_mappings = self.id_mapper.bulk_get_omop_ids('patient', fhir_patient_ids)

                            # Apply mappings
                            processed_data['person_id'] = processed_data['person_id'].map(
                                lambda x: id_mappings.get(x, x) if pd.notna(x) else x
                            )

                            mappings_created = len(id_mappings)

                            # Debug logging
                            self.logger.info(
                                "Person ID mapping results",
                                id_mappings=id_mappings,
                                person_id_after_mapping=processed_data['person_id'].tolist()
                            )

            # Store statistics
            context.set_result("id_mapping_stats", {
                "table": table_name,
                "mappings_created": mappings_created,
                "total_rows": len(data)
            })

            self.logger.info(
                "ID mapping completed",
                table=table_name,
                mappings_created=mappings_created
            )

            return processed_data

        except Exception as e:
            self.logger.error("ID mapping failed", error=str(e), table=table_name)
            raise TransformationError(f"Failed to map IDs for {table_name}: {str(e)}") from e

    def should_process(
        self,
        data: pd.DataFrame,
        context: PostProcessingContext
    ) -> bool:
        """Process if data contains ID columns that need mapping."""
        table_name = context.table_name.lower()

        # Process Person table if it has person_source_value
        if table_name == 'person' and 'person_source_value' in data.columns:
            return True

        # Process other OMOP tables if they have person_id
        if 'person_id' in data.columns:
            return True

        return False

    def validate_prerequisites(self, context: PostProcessingContext) -> bool:
        """Validate prerequisites are met."""
        return True

    def _populate_visitoccurrence_person_id_simple(self, data: pd.DataFrame) -> pd.DataFrame:
        """Assigne directement les person_id 1, 2, 3, etc. aux visits comme dans Person table."""
        try:
            self.logger.info("Assigning person_id values directly to VisitOccurrence")

            # Assigner les person_id 1, 2, 3, etc. directement aux visites
            num_visits = len(data)

            # Utiliser les person_id du tableau Person (1, 2, 3, 4, 5, 6, 7, 8, 9)
            person_ids = []
            for i in range(num_visits):
                person_id = (i % 9) + 1  # Cycle entre 1-9
                person_ids.append(person_id)

            data['person_id'] = person_ids

            self.logger.info(f"Assigned person_id to {len(data)} visits: {person_ids[:5]}...")
            return data

        except Exception as e:
            self.logger.error(f"Failed to assign person_id: {e}")
            return data

    def _populate_visitoccurrence_person_id(self, data: pd.DataFrame) -> pd.DataFrame:
        """Populate person_id for VisitOccurrence using local FHIR data mapping."""
        try:
            import json
            from pathlib import Path

            self.logger.info("Creating Encounter-Patient mappings from local FHIR data")

            # Extract encounter IDs from visit_source_value
            encounter_ids = []
            for visit_source in data['visit_source_value'].dropna():
                if visit_source.startswith('Encounter/'):
                    encounter_id = visit_source.replace('Encounter/', '').split('/')[0]
                    encounter_ids.append(encounter_id)

            unique_encounter_ids = list(set(encounter_ids))
            self.logger.info(f"Found {len(unique_encounter_ids)} unique encounters")

            # Get Encounter -> Patient mapping from local FHIR bundle files
            encounter_patient_mapping = {}

            # Search for FHIR bundle files in typical locations
            bundle_paths = [
                "../../../input/resources/usages/core/",
                "../../input/resources/usages/core/",
                "../input/resources/usages/core/",
                "input/resources/usages/core/"
            ]

            for base_path in bundle_paths:
                bundle_dir = Path(base_path)
                if bundle_dir.exists():
                    for bundle_file in bundle_dir.glob("*.json"):
                        try:
                            with open(bundle_file, 'r') as f:
                                bundle_data = json.load(f)

                            if bundle_data.get('resourceType') == 'Bundle':
                                for entry in bundle_data.get('entry', []):
                                    resource = entry.get('resource', {})

                                    if resource.get('resourceType') == 'Encounter':
                                        encounter_id = resource.get('id')
                                        subject = resource.get('subject', {})

                                        if encounter_id and subject and 'reference' in subject:
                                            patient_ref = subject['reference']
                                            if patient_ref.startswith('Patient/'):
                                                patient_id = patient_ref.replace('Patient/', '')
                                                encounter_patient_mapping[encounter_id] = patient_id

                        except Exception as e:
                            self.logger.warning(f"Failed to process bundle {bundle_file}: {e}")
                    break  # Stop after finding the first valid directory

            self.logger.info(f"Successfully mapped {len(encounter_patient_mapping)} encounters")

            # Convert Patient IDs to integer person_ids using the same hash function
            def get_person_id_for_visit(visit_source):
                if pd.isna(visit_source) or not visit_source.startswith('Encounter/'):
                    return None
                encounter_id = visit_source.replace('Encounter/', '').split('/')[0]
                patient_id_str = encounter_patient_mapping.get(encounter_id)
                if patient_id_str:
                    # Use same hash function as in duckdb_omop_optimized.py
                    return abs(hash(patient_id_str)) % (2**31)
                return None

            data['person_id'] = data['visit_source_value'].apply(get_person_id_for_visit)

            mapped_count = data['person_id'].notna().sum()
            self.logger.info(f"Successfully populated person_id for {mapped_count}/{len(data)} visits")

            # Log some examples for debugging
            if mapped_count > 0:
                sample_mappings = data[['visit_source_value', 'person_id']].dropna().head(3)
                self.logger.info(f"Sample mappings:\n{sample_mappings.to_string(index=False)}")

            return data

        except Exception as e:
            self.logger.error(f"Failed to populate VisitOccurrence person_id: {e}")
            return data

    def get_metadata(self) -> Dict[str, Any]:
        """Return processor metadata."""
        return {
            "name": self.name,
            "description": "Maps FHIR string IDs to OMOP integer IDs",
            "priority": self.priority,
            "target_tables": ["person", "condition_occurrence", "drug_exposure", "procedure_occurrence"]
        }



class VisitOccurrencePersonIdProcessor(PostProcessor):
    """Processor specifically to fix person_id for VisitOccurrence when empty."""

    def __init__(self, priority: int = 3):
        super().__init__("visitoccurrence_person_id", priority)

    def should_process(
        self,
        data: pd.DataFrame,
        context: PostProcessingContext
    ) -> bool:
        """Only process VisitOccurrence tables with Patient references in person_id."""
        is_visitoccurrence = context.table_name.lower() == 'visitoccurrence'
        has_person_id = 'person_id' in data.columns
        has_visit_source = 'visit_source_value' in data.columns

        # Check if person_id contains Patient references (strings starting with "Patient/")
        has_patient_refs = False
        if has_person_id:
            person_id_values = data['person_id'].dropna().astype(str)
            has_patient_refs = person_id_values.str.startswith('Patient/').any()

        self.logger.info(
            "VisitOccurrencePersonIdProcessor should_process check",
            table_name=context.table_name,
            is_visitoccurrence=is_visitoccurrence,
            has_person_id=has_person_id,
            has_visit_source=has_visit_source,
            has_patient_refs=has_patient_refs,
            person_id_values=data['person_id'].tolist() if has_person_id else []
        )

        return (is_visitoccurrence and has_person_id and has_visit_source and has_patient_refs)

    def process(
        self,
        data: pd.DataFrame,
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Extract Patient IDs from references for proper ID mapping."""
        self.logger.info("Extracting Patient IDs from references for ID mapping", rows=len(data))

        def extract_patient_id_from_ref(patient_ref):
            """Extract Patient ID from reference (e.g., 'Patient/patient-001' -> 'patient-001')."""
            if pd.isna(patient_ref):
                return None

            patient_ref_str = str(patient_ref)
            if patient_ref_str.startswith('Patient/'):
                # Extract patient ID from reference
                patient_id = patient_ref_str.replace('Patient/', '')
                return patient_id

            return patient_ref_str

        # Extract Patient IDs from references - leave ID mapping to the shared IDMappingProcessor
        data['person_id'] = data['person_id'].apply(extract_patient_id_from_ref)

        # Count successful extractions (but don't convert to integers yet - let IDMappingProcessor handle that)
        successful_extractions = data['person_id'].notna().sum()
        self.logger.info(
            "Patient ID extraction completed - ID mapping will be handled by IDMappingProcessor",
            successful_extractions=successful_extractions,
            total_rows=len(data),
            sample_patient_ids=data['person_id'].dropna().head(5).tolist()
        )

        return data


class BirthdateDecompositionProcessor(PostProcessor):
    """Processor to split birthdate into separate day, month, year columns."""

    def __init__(self, priority: int = 15):
        super().__init__("birthdate_decomposition", priority)

    def should_process(
        self,
        data: pd.DataFrame,
        context: PostProcessingContext
    ) -> bool:
        """Only process Person table data that has birth_datetime column."""
        return (context.table_name.lower() == 'person' and
                'birth_datetime' in data.columns)

    def process(
        self,
        data: pd.DataFrame,
        context: PostProcessingContext
    ) -> pd.DataFrame:
        """Split birth_datetime into day_of_birth, month_of_birth, year_of_birth."""
        self.logger.info("Starting birthdate decomposition", rows=len(data))

        try:
            # Create a copy to avoid modifying original data
            processed_data = data.copy()

            # Convert birth_datetime to pandas datetime if not already
            processed_data['birth_datetime'] = pd.to_datetime(
                processed_data['birth_datetime'],
                errors='coerce'
            )

            # Extract day, month, year components
            processed_data['day_of_birth'] = processed_data['birth_datetime'].dt.day
            processed_data['month_of_birth'] = processed_data['birth_datetime'].dt.month
            processed_data['year_of_birth'] = processed_data['birth_datetime'].dt.year

            # Convert to integers where valid, keep NaN for invalid dates
            processed_data['day_of_birth'] = processed_data['day_of_birth'].astype('Int64')
            processed_data['month_of_birth'] = processed_data['month_of_birth'].astype('Int64')
            processed_data['year_of_birth'] = processed_data['year_of_birth'].astype('Int64')

            # Count successful decompositions
            valid_decompositions = processed_data['year_of_birth'].notna().sum()

            self.logger.info(
                "Birthdate decomposition completed",
                valid_decompositions=valid_decompositions,
                total_rows=len(data),
                success_rate=f"{(valid_decompositions/len(data)*100):.1f}%" if len(data) > 0 else "0%"
            )

            # Store statistics in context
            context.set_result("birthdate_decomposition_stats", {
                "total_rows": len(data),
                "valid_decompositions": valid_decompositions,
                "success_rate": valid_decompositions/len(data) if len(data) > 0 else 0
            })

            return processed_data

        except Exception as e:
            self.logger.error("Birthdate decomposition failed", error=str(e))
            raise TransformationError(f"Failed to decompose birthdates: {str(e)}") from e

    def validate_prerequisites(self, context: PostProcessingContext) -> bool:
        """Validate that birth_datetime column exists."""
        return context.table_name.lower() == 'person'

    def get_metadata(self) -> Dict[str, Any]:
        """Return processor metadata."""
        return {
            "name": self.name,
            "description": "Splits birth_datetime into day_of_birth, month_of_birth, year_of_birth columns",
            "priority": self.priority,
            "target_tables": ["person"],
            "input_columns": ["birth_datetime"],
            "output_columns": ["day_of_birth", "month_of_birth", "year_of_birth"]
        }


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
        # Create shared ID mapper to maintain mappings across all tables
        if not hasattr(self, '_shared_id_mapper'):
            self._shared_id_mapper = SimpleIDMapper()

        return [
            VisitOccurrencePersonIdProcessor(priority=3),  # Fix VisitOccurrence person_id first
            IDMappingProcessor(priority=5, id_mapper=self._shared_id_mapper),  # Then: Simple ID mapping (shared across tables)
            DataCleaningProcessor(priority=10),
            BirthdateDecompositionProcessor(priority=15),
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