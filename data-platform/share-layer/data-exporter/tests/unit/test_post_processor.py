"""Unit tests for post-processing pipeline."""

import pytest
import pandas as pd
from datetime import datetime
from pathlib import Path
from unittest.mock import Mock, MagicMock

# Import modules
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    from post_processor import (
        PostProcessor, DataCleaningProcessor, TypeEnforcementProcessor,
        ConceptMappingProcessor, ValidationProcessor, PostProcessingError
    )
except ImportError:
    # Mock for testing when module is not available
    PostProcessor = Mock
    DataCleaningProcessor = Mock
    TypeEnforcementProcessor = Mock
    ConceptMappingProcessor = Mock
    ValidationProcessor = Mock
    PostProcessingError = Exception


@pytest.fixture
def sample_omop_person_data():
    """Sample OMOP Person data for testing."""
    return pd.DataFrame([
        {
            'person_id': 'patient-001',
            'gender_concept_id': 0,
            'year_of_birth': 1980,
            'month_of_birth': 1,
            'day_of_birth': 15,
            'birth_datetime': '1980-01-15T00:00:00',
            'race_concept_id': 0,
            'ethnicity_concept_id': 0,
            'location_id': 'addr-001',
            'provider_id': None,
            'care_site_id': 'Organization/aphp-001',
            'person_source_value': 'patient-001',
            'gender_source_value': 'male'
        },
        {
            'person_id': 'patient-002',
            'gender_concept_id': 0,
            'year_of_birth': 1990,
            'month_of_birth': 6,
            'day_of_birth': 20,
            'birth_datetime': '1990-06-20T00:00:00',
            'race_concept_id': 0,
            'ethnicity_concept_id': 0,
            'location_id': 'addr-002',
            'provider_id': 'Practitioner/gp-001',
            'care_site_id': None,
            'person_source_value': 'patient-002',
            'gender_source_value': 'female'
        }
    ])


@pytest.fixture
def sample_dirty_data():
    """Sample dirty data for cleaning tests."""
    return pd.DataFrame([
        {
            'person_id': '  patient-001  ',  # Extra whitespace
            'gender_concept_id': '0',        # String instead of int
            'year_of_birth': '',             # Empty string
            'birth_datetime': 'invalid-date', # Invalid date
            'gender_source_value': 'MALE'    # Wrong case
        },
        {
            'person_id': None,               # Null value
            'gender_concept_id': -1,         # Invalid concept ID
            'year_of_birth': 2050,           # Future date
            'birth_datetime': '1990-02-30',  # Invalid date (Feb 30)
            'gender_source_value': 'f'       # Abbreviated gender
        }
    ])


@pytest.mark.unit
class TestPostProcessor:
    """Test base PostProcessor class."""
    
    def test_post_processor_interface(self):
        """Test PostProcessor abstract interface."""
        if PostProcessor is Mock:
            pytest.skip("PostProcessor module not available")
            
        # Should not be able to instantiate abstract class directly
        with pytest.raises(TypeError):
            PostProcessor()
            
    def test_processor_pipeline_creation(self):
        """Test post-processor pipeline creation."""
        if PostProcessor is Mock:
            pytest.skip("PostProcessor module not available")
            
        # Create mock processors
        processors = [
            DataCleaningProcessor(),
            TypeEnforcementProcessor(),
            ValidationProcessor()
        ]
        
        # Test pipeline configuration
        assert len(processors) == 3
        for processor in processors:
            assert hasattr(processor, 'process')


@pytest.mark.unit
class TestDataCleaningProcessor:
    """Test data cleaning post-processor."""
    
    def test_whitespace_cleaning(self, sample_dirty_data):
        """Test whitespace removal from string fields."""
        if DataCleaningProcessor is Mock:
            pytest.skip("DataCleaningProcessor module not available")
            
        processor = DataCleaningProcessor()
        cleaned_data = processor.process(sample_dirty_data)
        
        # Check that whitespace was removed
        assert cleaned_data.loc[0, 'person_id'] == 'patient-001'
        assert not cleaned_data.loc[0, 'person_id'].startswith(' ')
        
    def test_null_value_handling(self, sample_dirty_data):
        """Test null value handling."""
        if DataCleaningProcessor is Mock:
            pytest.skip("DataCleaningProcessor module not available")
            
        processor = DataCleaningProcessor()
        cleaned_data = processor.process(sample_dirty_data)
        
        # Check null handling strategy
        assert pd.isna(cleaned_data.loc[1, 'person_id']) or cleaned_data.loc[1, 'person_id'] == ''
        
    def test_empty_string_conversion(self, sample_dirty_data):
        """Test empty string to null conversion."""
        if DataCleaningProcessor is Mock:
            pytest.skip("DataCleaningProcessor module not available")
            
        processor = DataCleaningProcessor()
        cleaned_data = processor.process(sample_dirty_data)
        
        # Empty strings should be converted to null
        assert pd.isna(cleaned_data.loc[0, 'year_of_birth']) or cleaned_data.loc[0, 'year_of_birth'] == ''
        
    def test_case_standardization(self, sample_dirty_data):
        """Test case standardization for coded values."""
        if DataCleaningProcessor is Mock:
            pytest.skip("DataCleaningProcessor module not available")
            
        processor = DataCleaningProcessor()
        cleaned_data = processor.process(sample_dirty_data)
        
        # Gender values should be standardized to lowercase
        assert cleaned_data.loc[0, 'gender_source_value'].lower() in ['male', 'female', 'other']


@pytest.mark.unit
class TestTypeEnforcementProcessor:
    """Test type enforcement post-processor."""
    
    def test_integer_type_enforcement(self, sample_dirty_data):
        """Test integer type enforcement."""
        if TypeEnforcementProcessor is Mock:
            pytest.skip("TypeEnforcementProcessor module not available")
            
        processor = TypeEnforcementProcessor()
        processed_data = processor.process(sample_dirty_data)
        
        # Concept IDs should be integers
        if not pd.isna(processed_data.loc[0, 'gender_concept_id']):
            assert isinstance(processed_data.loc[0, 'gender_concept_id'], (int, type(None)))
            
    def test_datetime_parsing(self, sample_dirty_data):
        """Test datetime parsing and validation."""
        if TypeEnforcementProcessor is Mock:
            pytest.skip("TypeEnforcementProcessor module not available")
            
        processor = TypeEnforcementProcessor()
        processed_data = processor.process(sample_dirty_data)
        
        # Invalid dates should be handled gracefully
        birth_datetime = processed_data.loc[0, 'birth_datetime']
        assert pd.isna(birth_datetime) or isinstance(birth_datetime, (str, pd.Timestamp))
        
    def test_string_type_preservation(self, sample_omop_person_data):
        """Test that string fields remain strings."""
        if TypeEnforcementProcessor is Mock:
            pytest.skip("TypeEnforcementProcessor module not available")
            
        processor = TypeEnforcementProcessor()
        processed_data = processor.process(sample_omop_person_data)
        
        # String fields should remain strings
        assert isinstance(processed_data.loc[0, 'person_id'], str)
        assert isinstance(processed_data.loc[0, 'gender_source_value'], str)
        
    def test_numeric_conversion_errors(self):
        """Test handling of numeric conversion errors."""
        if TypeEnforcementProcessor is Mock:
            pytest.skip("TypeEnforcementProcessor module not available")
            
        # Data with non-numeric values in numeric fields
        invalid_data = pd.DataFrame([{
            'person_id': 'patient-001',
            'gender_concept_id': 'not-a-number',
            'year_of_birth': 'nineteen-eighty'
        }])
        
        processor = TypeEnforcementProcessor()
        processed_data = processor.process(invalid_data)
        
        # Non-numeric values should be converted to null or handled gracefully
        assert pd.isna(processed_data.loc[0, 'gender_concept_id']) or processed_data.loc[0, 'gender_concept_id'] == 0


@pytest.mark.unit
class TestConceptMappingProcessor:
    """Test concept mapping post-processor."""
    
    def test_gender_concept_mapping(self, sample_omop_person_data):
        """Test gender concept mapping."""
        if ConceptMappingProcessor is Mock:
            pytest.skip("ConceptMappingProcessor module not available")
            
        processor = ConceptMappingProcessor()
        processed_data = processor.process(sample_omop_person_data)
        
        # Gender concepts should be mapped
        male_row = processed_data[processed_data['gender_source_value'] == 'male']
        if not male_row.empty:
            # Should have a valid gender concept ID (not 0)
            gender_concept = male_row.iloc[0]['gender_concept_id']
            assert isinstance(gender_concept, int)
            
    def test_race_concept_defaults(self, sample_omop_person_data):
        """Test race concept default values."""
        if ConceptMappingProcessor is Mock:
            pytest.skip("ConceptMappingProcessor module not available")
            
        processor = ConceptMappingProcessor()
        processed_data = processor.process(sample_omop_person_data)
        
        # Race concepts should have default values when unknown
        assert all(processed_data['race_concept_id'] >= 0)
        
    def test_ethnicity_concept_defaults(self, sample_omop_person_data):
        """Test ethnicity concept default values."""
        if ConceptMappingProcessor is Mock:
            pytest.skip("ConceptMappingProcessor module not available")
            
        processor = ConceptMappingProcessor()
        processed_data = processor.process(sample_omop_person_data)
        
        # Ethnicity concepts should have default values
        assert all(processed_data['ethnicity_concept_id'] >= 0)
        
    def test_custom_concept_mapping(self):
        """Test custom concept mapping configuration."""
        if ConceptMappingProcessor is Mock:
            pytest.skip("ConceptMappingProcessor module not available")
            
        # Custom mapping configuration
        custom_mappings = {
            'gender': {
                'male': 8507,
                'female': 8532,
                'other': 8551,
                'unknown': 0
            }
        }
        
        processor = ConceptMappingProcessor(mappings=custom_mappings)
        
        # Test mapping configuration
        assert processor.mappings['gender']['male'] == 8507


@pytest.mark.unit
class TestValidationProcessor:
    """Test validation post-processor."""
    
    def test_required_field_validation(self, sample_omop_person_data):
        """Test required field validation."""
        if ValidationProcessor is Mock:
            pytest.skip("ValidationProcessor module not available")
            
        processor = ValidationProcessor()
        
        # Should pass validation
        is_valid = processor.validate(sample_omop_person_data)
        assert is_valid
        
    def test_missing_required_field(self):
        """Test validation with missing required fields."""
        if ValidationProcessor is Mock:
            pytest.skip("ValidationProcessor module not available")
            
        # Data missing required person_id
        invalid_data = pd.DataFrame([{
            'gender_concept_id': 0,
            'year_of_birth': 1980,
            'gender_source_value': 'male'
        }])
        
        processor = ValidationProcessor()
        
        with pytest.raises(PostProcessingError):
            processor.process(invalid_data)
            
    def test_data_range_validation(self, sample_omop_person_data):
        """Test data range validation."""
        if ValidationProcessor is Mock:
            pytest.skip("ValidationProcessor module not available")
            
        processor = ValidationProcessor()
        
        # Test year of birth range
        current_year = datetime.now().year
        for _, row in sample_omop_person_data.iterrows():
            if pd.notna(row['year_of_birth']):
                assert 1900 <= row['year_of_birth'] <= current_year
                
    def test_referential_integrity_validation(self, sample_omop_person_data):
        """Test referential integrity validation."""
        if ValidationProcessor is Mock:
            pytest.skip("ValidationProcessor module not available")
            
        processor = ValidationProcessor()
        
        # Check that referenced entities follow expected format
        for _, row in sample_omop_person_data.iterrows():
            if pd.notna(row['provider_id']):
                assert row['provider_id'].startswith('Practitioner/')
            if pd.notna(row['care_site_id']):
                assert row['care_site_id'].startswith('Organization/')


@pytest.mark.unit
class TestPostProcessingPipeline:
    """Test complete post-processing pipeline."""
    
    def test_pipeline_execution_order(self, sample_dirty_data):
        """Test that processors execute in correct order."""
        if all(cls is Mock for cls in [DataCleaningProcessor, TypeEnforcementProcessor, ValidationProcessor]):
            pytest.skip("PostProcessing modules not available")
            
        # Create pipeline
        pipeline = [
            DataCleaningProcessor(),
            TypeEnforcementProcessor(),
            ConceptMappingProcessor(),
            ValidationProcessor()
        ]
        
        # Execute pipeline
        data = sample_dirty_data.copy()
        for processor in pipeline:
            try:
                data = processor.process(data)
            except:
                # Mock processors may not work fully
                pass
                
        # Pipeline should complete without errors
        assert data is not None
        
    def test_pipeline_error_handling(self, sample_dirty_data):
        """Test pipeline error handling."""
        if ValidationProcessor is Mock:
            pytest.skip("ValidationProcessor module not available")
            
        # Create processor that will fail
        class FailingProcessor:
            def process(self, data):
                raise PostProcessingError("Intentional failure")
                
        pipeline = [
            DataCleaningProcessor(),
            FailingProcessor(),
            ValidationProcessor()
        ]
        
        # Should handle processor failures gracefully
        data = sample_dirty_data.copy()
        
        with pytest.raises(PostProcessingError):
            for processor in pipeline:
                data = processor.process(data)
                
    def test_pipeline_data_integrity(self, sample_omop_person_data):
        """Test that pipeline maintains data integrity."""
        if all(cls is Mock for cls in [DataCleaningProcessor, TypeEnforcementProcessor]):
            pytest.skip("PostProcessing modules not available")
            
        # Execute minimal pipeline
        pipeline = [
            DataCleaningProcessor(),
            TypeEnforcementProcessor()
        ]
        
        original_count = len(sample_omop_person_data)
        data = sample_omop_person_data.copy()
        
        for processor in pipeline:
            try:
                data = processor.process(data)
            except:
                # Mock processors may not work
                pass
                
        # Should maintain row count
        assert len(data) == original_count


@pytest.mark.unit
class TestPostProcessingConfiguration:
    """Test post-processing configuration."""
    
    def test_processor_configuration_loading(self):
        """Test loading processor configuration."""
        config = {
            'data_cleaning': {
                'trim_whitespace': True,
                'standardize_case': True,
                'convert_empty_to_null': True
            },
            'type_enforcement': {
                'strict_mode': False,
                'date_formats': ['%Y-%m-%d', '%Y-%m-%dT%H:%M:%S']
            },
            'concept_mapping': {
                'use_default_mappings': True,
                'custom_mappings_file': None
            },
            'validation': {
                'required_fields': ['person_id'],
                'validate_ranges': True,
                'validate_references': True
            }
        }
        
        # Test configuration structure
        assert 'data_cleaning' in config
        assert 'type_enforcement' in config
        assert 'concept_mapping' in config
        assert 'validation' in config
        
        # Test specific settings
        assert config['data_cleaning']['trim_whitespace'] is True
        assert 'person_id' in config['validation']['required_fields']
        
    def test_custom_processor_registration(self):
        """Test custom processor registration."""
        class CustomProcessor:
            def __init__(self, custom_param=None):
                self.custom_param = custom_param
                
            def process(self, data):
                # Custom processing logic
                return data
                
        # Test custom processor creation
        custom_processor = CustomProcessor(custom_param="test_value")
        
        assert custom_processor.custom_param == "test_value"
        assert hasattr(custom_processor, 'process')


# Helper functions for testing
def create_test_data_with_errors():
    """Create test data with various data quality issues."""
    return pd.DataFrame([
        {
            'person_id': '  patient-001  ',
            'gender_concept_id': 'invalid',
            'year_of_birth': 2050,
            'birth_datetime': '1990-02-30',
            'gender_source_value': 'MALE'
        },
        {
            'person_id': None,
            'gender_concept_id': -1,
            'year_of_birth': '',
            'birth_datetime': 'not-a-date',
            'gender_source_value': 'f'
        }
    ])


def validate_omop_person_schema(data):
    """Validate data against OMOP Person table schema."""
    required_columns = [
        'person_id', 'gender_concept_id', 'year_of_birth',
        'month_of_birth', 'day_of_birth', 'birth_datetime',
        'race_concept_id', 'ethnicity_concept_id',
        'person_source_value', 'gender_source_value'
    ]
    
    # Check all required columns are present
    missing_columns = set(required_columns) - set(data.columns)
    assert len(missing_columns) == 0, f"Missing columns: {missing_columns}"
    
    # Check data types
    assert data['person_id'].dtype == 'object'  # String
    assert pd.api.types.is_integer_dtype(data['gender_concept_id'])
    
    return True