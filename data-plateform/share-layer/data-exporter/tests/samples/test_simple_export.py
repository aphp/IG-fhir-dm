"""Simple export test with minimal sample data."""

import pytest
import json
from pathlib import Path
from unittest.mock import patch, MagicMock

# Import modules
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    from duckdb_omop_optimized import DuckDBOMOPProcessor, process_fhir_to_omop_duckdb
    DUCKDB_AVAILABLE = True
except ImportError:
    DUCKDB_AVAILABLE = False


@pytest.mark.unit
class TestSimpleExport:
    """Simple tests with minimal sample data."""
    
    def test_sample_data_creation(self, sample_patients):
        """Test that sample data is created correctly."""
        assert len(sample_patients) == 3
        
        # Check first patient
        patient1 = sample_patients[0]
        assert patient1["resourceType"] == "Patient"
        assert patient1["id"] == "test-patient-001"
        assert patient1["gender"] == "male"
        assert patient1["birthDate"] == "1980-01-15"
        
    def test_viewdef_loading(self, omop_person_viewdef):
        """Test ViewDefinition loading."""
        assert omop_person_viewdef["resourceType"] == "https://sql-on-fhir.org/ig/StructureDefinition/ViewDefinition"
        assert omop_person_viewdef["name"] == "OMOP-Person-View"
        assert omop_person_viewdef["resource"] == "Patient"
        
        # Check columns
        columns = omop_person_viewdef["select"][0]["column"]
        column_names = [col["name"] for col in columns]
        
        assert "person_id" in column_names
        assert "gender_source_value" in column_names
        assert "birth_datetime" in column_names
        
    def test_duckdb_simple_processing(self, sample_patients):
        """Test simple DuckDB processing."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available")
            
        output_dir = Path("./simple_test_output")
        output_dir.mkdir(exist_ok=True)
        
        try:
            result = process_fhir_to_omop_duckdb(sample_patients, output_dir)
            
            assert result['success'] is True
            assert result['records_processed'] == 3
            assert 'analytics' in result
            assert 'exports' in result
            
            # Check basic analytics
            stats = result['analytics']['basic_stats']
            assert stats['total_persons'] == 3
            assert stats['unique_genders'] == 3
            
        finally:
            # Cleanup
            import shutil
            shutil.rmtree(output_dir, ignore_errors=True)
            
    def test_export_files_creation(self, sample_patients):
        """Test that export files are created."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available")
            
        output_dir = Path("./export_test_output")
        output_dir.mkdir(exist_ok=True)
        
        try:
            result = process_fhir_to_omop_duckdb(sample_patients, output_dir)
            
            exports = result['exports']
            
            # Check that files were created
            for format_name, file_path in exports.items():
                file_obj = Path(file_path)
                assert file_obj.exists(), f"Export file not found: {file_path}"
                
                if format_name in ['parquet', 'csv', 'json']:
                    assert file_obj.stat().st_size > 0, f"Export file is empty: {file_path}"
                    
        finally:
            # Cleanup
            import shutil
            shutil.rmtree(output_dir, ignore_errors=True)
            
    def test_data_validation(self, sample_patients, expected_omop_person):
        """Test data validation against expected results."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available")
            
        output_dir = Path("./validation_test_output")
        output_dir.mkdir(exist_ok=True)
        
        try:
            result = process_fhir_to_omop_duckdb(sample_patients, output_dir)
            
            # Load exported JSON to validate
            json_file = Path(result['exports']['json'])
            with open(json_file, 'r') as f:
                exported_data = json.load(f)
                
            assert len(exported_data) == 3
            
            # Check first record structure
            first_record = exported_data[0]
            assert 'person_id' in first_record
            assert 'gender_source_value' in first_record
            assert 'birth_datetime' in first_record
            
            # Check data types and values
            assert isinstance(first_record['person_id'], str)
            assert first_record['gender_concept_id'] == 0  # Default value
            assert first_record['race_concept_id'] == 0    # Default value
            
        finally:
            # Cleanup
            import shutil
            shutil.rmtree(output_dir, ignore_errors=True)


@pytest.mark.unit 
class TestSimpleValidation:
    """Simple validation tests."""
    
    def test_patient_id_validation(self, sample_patients):
        """Test patient ID validation."""
        for patient in sample_patients:
            assert 'id' in patient
            assert isinstance(patient['id'], str)
            assert len(patient['id']) > 0
            assert patient['id'].startswith('test-patient-')
            
    def test_required_fields_present(self, sample_patients):
        """Test that required fields are present."""
        required_fields = ['resourceType', 'id', 'gender', 'birthDate']
        
        for patient in sample_patients:
            for field in required_fields:
                assert field in patient, f"Missing field {field} in patient {patient.get('id', 'unknown')}"
                
    def test_gender_values(self, sample_patients):
        """Test gender value validation."""
        valid_genders = ['male', 'female', 'other', 'unknown']
        
        for patient in sample_patients:
            assert patient['gender'] in valid_genders
            
    def test_birth_date_format(self, sample_patients):
        """Test birth date format validation."""
        import re
        
        date_pattern = re.compile(r'^\d{4}-\d{2}-\d{2}$')
        
        for patient in sample_patients:
            birth_date = patient['birthDate']
            assert date_pattern.match(birth_date), f"Invalid date format: {birth_date}"
            
            # Check date is reasonable
            year = int(birth_date.split('-')[0])
            assert 1900 <= year <= 2010, f"Unreasonable birth year: {year}"
            
    def test_address_structure(self, sample_patients):
        """Test address structure validation."""
        for patient in sample_patients:
            if 'address' in patient:
                addresses = patient['address']
                assert isinstance(addresses, list)
                
                for address in addresses:
                    assert 'id' in address
                    assert 'city' in address
                    assert 'country' in address
                    
    def test_reference_format(self, sample_patients):
        """Test FHIR reference format validation."""
        for patient in sample_patients:
            # Check general practitioner references
            if 'generalPractitioner' in patient:
                gp_list = patient['generalPractitioner']
                assert isinstance(gp_list, list)
                
                for gp in gp_list:
                    assert 'reference' in gp
                    ref = gp['reference']
                    assert ref.startswith('Practitioner/'), f"Invalid GP reference: {ref}"
                    
            # Check managing organization references
            if 'managingOrganization' in patient:
                org = patient['managingOrganization']
                assert 'reference' in org
                ref = org['reference']
                assert ref.startswith('Organization/'), f"Invalid org reference: {ref}"


@pytest.mark.unit
class TestSimpleConfiguration:
    """Simple configuration tests."""
    
    def test_test_config_structure(self, test_config):
        """Test test configuration structure."""
        required_keys = ['fhir_endpoint_url', 'output_dir']
        
        for key in required_keys:
            assert key in test_config
            assert isinstance(test_config[key], str)
            assert len(test_config[key]) > 0
            
    def test_temp_directory_creation(self, temp_directory):
        """Test temporary directory creation."""
        assert temp_directory.exists()
        assert temp_directory.is_dir()
        
        # Test can write to directory
        test_file = temp_directory / "test.txt"
        test_file.write_text("test content")
        assert test_file.exists()
        
    def test_sample_file_creation(self, sample_ndjson_file):
        """Test sample NDJSON file creation."""
        assert sample_ndjson_file.exists()
        assert sample_ndjson_file.suffix == '.ndjson'
        
        # Read and validate content
        with open(sample_ndjson_file, 'r') as f:
            lines = f.readlines()
            
        assert len(lines) == 3  # Should have 3 patients
        
        # Each line should be valid JSON
        for line in lines:
            patient = json.loads(line.strip())
            assert patient['resourceType'] == 'Patient'
            
    def test_bundle_file_creation(self, sample_bundle_file):
        """Test sample Bundle file creation."""
        assert sample_bundle_file.exists()
        assert sample_bundle_file.suffix == '.json'
        
        # Read and validate content
        with open(sample_bundle_file, 'r') as f:
            bundle = json.load(f)
            
        assert bundle['resourceType'] == 'Bundle'
        assert bundle['type'] == 'collection'
        assert len(bundle['entry']) == 3


@pytest.mark.unit
class TestMockIntegration:
    """Test with mock components."""
    
    def test_mock_pathling_context(self, mock_pathling_context, sample_patients):
        """Test mock Pathling context."""
        # This test uses mocked Pathling for environments where it's not available
        pc = mock_pathling_context
        
        # Test mock functionality
        assert hasattr(pc, 'read')
        
        # Test NDJSON reading
        data = pc.read.ndjson('./test_path')
        assert data is not None
        
        # Test resource types
        resource_types = data.resource_types()
        assert 'Patient' in resource_types
        
        # Test view transformation
        person_df = data.view('Patient', json='{}')
        assert person_df is not None
        assert person_df.count() == 3
        
    def test_error_handling(self, sample_patients):
        """Test error handling scenarios.""" 
        # Test with invalid data
        invalid_patients = [
            {
                "resourceType": "Patient",
                # Missing required 'id' field
                "gender": "male"
            }
        ]
        
        if DUCKDB_AVAILABLE:
            output_dir = Path("./error_test_output")
            output_dir.mkdir(exist_ok=True)
            
            try:
                # This should handle missing fields gracefully
                result = process_fhir_to_omop_duckdb(invalid_patients, output_dir)
                
                # Processing should still succeed but may have fewer records
                assert result['success'] is True
                assert result['records_processed'] >= 0
                
            finally:
                # Cleanup
                import shutil
                shutil.rmtree(output_dir, ignore_errors=True)
        else:
            # Just verify the data is invalid
            assert 'id' not in invalid_patients[0]
            
    def test_empty_dataset_handling(self):
        """Test handling of empty datasets."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available")
            
        empty_patients = []
        output_dir = Path("./empty_test_output")
        output_dir.mkdir(exist_ok=True)
        
        try:
            result = process_fhir_to_omop_duckdb(empty_patients, output_dir)
            
            assert result['success'] is True
            assert result['records_processed'] == 0
            
        finally:
            # Cleanup
            import shutil
            shutil.rmtree(output_dir, ignore_errors=True)


# Helper functions for simple tests
def validate_fhir_patient(patient):
    """Validate FHIR Patient resource structure."""
    required_fields = ['resourceType', 'id']
    
    for field in required_fields:
        if field not in patient:
            return False, f"Missing required field: {field}"
            
    if patient['resourceType'] != 'Patient':
        return False, f"Invalid resourceType: {patient['resourceType']}"
        
    return True, "Valid"


def create_minimal_patient(patient_id: str):
    """Create minimal valid FHIR Patient."""
    return {
        "resourceType": "Patient",
        "id": patient_id,
        "gender": "unknown",
        "birthDate": "2000-01-01"
    }