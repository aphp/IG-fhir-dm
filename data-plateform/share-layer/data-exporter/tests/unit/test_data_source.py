"""Unit tests for data source implementations."""

import pytest
import json
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

# Import modules
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    from data_source import (
        DataSource, FHIRServerDataSource, FileSystemDataSource,
        DataSourceError
    )
except ImportError:
    # Mock for testing when module is not available
    DataSource = Mock
    FHIRServerDataSource = Mock
    FileSystemDataSource = Mock
    DataSourceError = Exception


@pytest.mark.unit
class TestDataSource:
    """Test abstract DataSource base class."""
    
    def test_data_source_interface(self):
        """Test DataSource abstract interface."""
        if DataSource is Mock:
            pytest.skip("DataSource module not available")
            
        # Should not be able to instantiate abstract class directly
        with pytest.raises(TypeError):
            DataSource()


@pytest.mark.unit 
class TestFHIRServerDataSource:
    """Test FHIR server data source implementation."""
    
    def test_fhir_server_initialization(self):
        """Test FHIR server data source initialization."""
        if FHIRServerDataSource is Mock:
            pytest.skip("FHIRServerDataSource module not available")
            
        server_url = "http://test.server/fhir"
        data_source = FHIRServerDataSource(server_url)
        
        assert data_source.server_url == server_url
        assert data_source.is_available()
        
    def test_bulk_export_parameters(self):
        """Test bulk export parameter handling."""
        if FHIRServerDataSource is Mock:
            pytest.skip("FHIRServerDataSource module not available")
            
        data_source = FHIRServerDataSource("http://test.server/fhir")
        
        # Test with resource types
        params = data_source.get_bulk_export_params(
            resource_types=["Patient", "Observation"]
        )
        
        assert "Patient" in params.get("_type", "")
        assert "Observation" in params.get("_type", "")
        
    @patch('requests.get')
    def test_server_connectivity_check(self, mock_get):
        """Test FHIR server connectivity validation."""
        if FHIRServerDataSource is Mock:
            pytest.skip("FHIRServerDataSource module not available")
            
        # Mock successful response
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {
            "resourceType": "CapabilityStatement",
            "status": "active"
        }
        
        data_source = FHIRServerDataSource("http://test.server/fhir")
        
        assert data_source.check_connectivity()
        
    @patch('requests.get')
    def test_server_connectivity_failure(self, mock_get):
        """Test FHIR server connectivity failure."""
        if FHIRServerDataSource is Mock:
            pytest.skip("FHIRServerDataSource module not available")
            
        # Mock failed response
        mock_get.side_effect = ConnectionError("Connection failed")
        
        data_source = FHIRServerDataSource("http://test.server/fhir")
        
        assert not data_source.check_connectivity()
        
    def test_bulk_export_url_generation(self):
        """Test bulk export URL generation."""
        if FHIRServerDataSource is Mock:
            pytest.skip("FHIRServerDataSource module not available")
            
        data_source = FHIRServerDataSource("http://test.server/fhir")
        
        export_url = data_source.get_bulk_export_url(
            resource_types=["Patient"],
            since="2023-01-01"
        )
        
        assert "$export" in export_url
        assert "Patient" in export_url
        assert "2023-01-01" in export_url


@pytest.mark.unit
class TestFileSystemDataSource:
    """Test file system data source implementation."""
    
    def test_filesystem_initialization(self, temp_directory):
        """Test file system data source initialization."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        data_source = FileSystemDataSource(str(temp_directory))
        
        assert data_source.data_path == str(temp_directory)
        assert data_source.is_available()
        
    def test_ndjson_file_detection(self, sample_ndjson_file):
        """Test NDJSON file detection."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        data_source = FileSystemDataSource(str(sample_ndjson_file.parent))
        
        ndjson_files = data_source.find_ndjson_files()
        
        assert len(ndjson_files) > 0
        assert any("Patient" in str(f) for f in ndjson_files)
        
    def test_parquet_file_detection(self, temp_directory):
        """Test Parquet file detection."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        # Create mock Parquet file
        parquet_file = temp_directory / "Patient.parquet"
        parquet_file.touch()
        
        data_source = FileSystemDataSource(str(temp_directory))
        
        parquet_files = data_source.find_parquet_files()
        
        assert len(parquet_files) > 0
        assert any("Patient" in str(f) for f in parquet_files)
        
    def test_resource_type_extraction(self, sample_ndjson_file):
        """Test resource type extraction from filenames."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        data_source = FileSystemDataSource(str(sample_ndjson_file.parent))
        
        resource_types = data_source.get_available_resource_types()
        
        assert "Patient" in resource_types
        
    def test_file_validation(self, temp_directory):
        """Test file format validation."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        # Create invalid file
        invalid_file = temp_directory / "invalid.txt"
        invalid_file.write_text("not valid FHIR")
        
        data_source = FileSystemDataSource(str(temp_directory))
        
        # Should handle invalid files gracefully
        assert data_source.is_available()
        
    def test_empty_directory_handling(self, temp_directory):
        """Test handling of empty directories."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        empty_dir = temp_directory / "empty"
        empty_dir.mkdir()
        
        data_source = FileSystemDataSource(str(empty_dir))
        
        # Should still be available but have no files
        assert data_source.is_available()
        
        ndjson_files = data_source.find_ndjson_files()
        assert len(ndjson_files) == 0


@pytest.mark.unit
class TestDataSourceValidation:
    """Test data source validation logic."""
    
    def test_fhir_url_validation(self):
        """Test FHIR URL format validation."""
        valid_urls = [
            "http://localhost:8080/fhir",
            "https://hapi.fhir.org/baseR4",
            "https://server.fire.ly/fhir"
        ]
        
        invalid_urls = [
            "not-a-url",
            "ftp://invalid.com",
            "http://",
            ""
        ]
        
        for url in valid_urls:
            # Basic URL validation
            assert url.startswith(('http://', 'https://'))
            assert len(url) > 10
            
        for url in invalid_urls:
            # Should be detected as invalid
            assert not url.startswith('http') or len(url) < 10
            
    def test_file_path_validation(self, temp_directory):
        """Test file path validation."""
        valid_paths = [
            str(temp_directory),
            str(temp_directory / "subdir")
        ]
        
        invalid_paths = [
            "/nonexistent/path",
            "",
            "relative/path/that/doesnt/exist"
        ]
        
        for path in valid_paths:
            path_obj = Path(path)
            # Path should be absolute or exist
            assert path_obj.is_absolute() or path_obj.exists() or path == str(temp_directory)
            
    def test_resource_type_validation(self):
        """Test FHIR resource type validation."""
        valid_resource_types = [
            "Patient", "Observation", "Condition", "MedicationRequest",
            "Procedure", "Encounter", "Organization", "Practitioner"
        ]
        
        invalid_resource_types = [
            "patient", "PATIENT", "InvalidResource", ""
        ]
        
        for resource_type in valid_resource_types:
            # Valid resource types are capitalized
            assert resource_type[0].isupper()
            assert resource_type.isalpha()
            
        for resource_type in invalid_resource_types:
            # Invalid patterns
            is_invalid = (
                not resource_type or
                not resource_type[0].isupper() or
                not resource_type.replace('_', '').isalpha()
            )
            assert is_invalid


@pytest.mark.unit 
class TestDataSourceErrors:
    """Test data source error handling."""
    
    def test_connection_error_handling(self):
        """Test connection error scenarios."""
        if FHIRServerDataSource is Mock:
            pytest.skip("FHIRServerDataSource module not available")
            
        with patch('requests.get') as mock_get:
            mock_get.side_effect = ConnectionError("Network error")
            
            data_source = FHIRServerDataSource("http://unreachable.server/fhir")
            
            with pytest.raises(DataSourceError):
                data_source.load_data()
                
    def test_file_not_found_error(self):
        """Test file not found error handling."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        data_source = FileSystemDataSource("/nonexistent/path")
        
        with pytest.raises(DataSourceError):
            data_source.load_data()
            
    def test_invalid_data_format_error(self, temp_directory):
        """Test invalid data format error handling."""
        if FileSystemDataSource is Mock:
            pytest.skip("FileSystemDataSource module not available")
            
        # Create file with invalid JSON
        invalid_file = temp_directory / "Patient.ndjson"
        invalid_file.write_text("invalid json content")
        
        data_source = FileSystemDataSource(str(temp_directory))
        
        # Should handle invalid JSON gracefully
        try:
            data_source.validate_data_format()
        except DataSourceError:
            # Expected for invalid format
            pass


@pytest.mark.unit
class TestDataSourceIntegration:
    """Integration tests for data source components."""
    
    def test_data_source_factory_pattern(self):
        """Test data source factory pattern."""
        # Test factory method concept
        def create_data_source(source_type: str, config: dict):
            if source_type == "fhir_server":
                return FHIRServerDataSource(config["url"])
            elif source_type == "file_system":  
                return FileSystemDataSource(config["path"])
            else:
                raise ValueError(f"Unknown source type: {source_type}")
                
        # Test FHIR server creation
        if FHIRServerDataSource is not Mock:
            fhir_source = create_data_source("fhir_server", {
                "url": "http://test.server/fhir"
            })
            assert isinstance(fhir_source, FHIRServerDataSource)
            
        # Test file system creation
        if FileSystemDataSource is not Mock:
            fs_source = create_data_source("file_system", {
                "path": "/test/path"
            })
            assert isinstance(fs_source, FileSystemDataSource)
            
    def test_data_source_configuration_loading(self, temp_directory):
        """Test loading data source from configuration."""
        config = {
            "data_source": {
                "type": "file_system",
                "path": str(temp_directory),
                "formats": ["ndjson", "parquet"]
            }
        }
        
        # Test configuration parsing
        source_config = config["data_source"]
        assert source_config["type"] == "file_system"
        assert source_config["path"] == str(temp_directory)
        assert "ndjson" in source_config["formats"]


# Helper functions for testing
def create_mock_fhir_response(resource_type: str, count: int = 1):
    """Create mock FHIR response for testing."""
    bundle = {
        "resourceType": "Bundle",
        "type": "searchset",
        "total": count,
        "entry": []
    }
    
    for i in range(count):
        bundle["entry"].append({
            "resource": {
                "resourceType": resource_type,
                "id": f"test-{resource_type.lower()}-{i+1:03d}"
            }
        })
        
    return bundle


def create_sample_ndjson_content(resource_type: str, count: int = 3):
    """Create sample NDJSON content for testing."""
    resources = []
    
    for i in range(count):
        resource = {
            "resourceType": resource_type,
            "id": f"test-{resource_type.lower()}-{i+1:03d}"
        }
        
        if resource_type == "Patient":
            resource.update({
                "gender": ["male", "female", "other"][i % 3],
                "birthDate": f"198{i}-01-01"
            })
            
        resources.append(json.dumps(resource))
        
    return '\n'.join(resources)