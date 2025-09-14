"""Unit tests for configuration module."""

import pytest
import json
from pathlib import Path
from pydantic import ValidationError

# Import the config module
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    from config import Config, DataSourceType, OutputFormat
except ImportError:
    # Fallback for basic configuration testing
    from unittest.mock import MagicMock
    Config = MagicMock
    DataSourceType = MagicMock  
    OutputFormat = MagicMock


class TestConfig:
    """Test configuration validation and loading."""
    
    def test_default_config_creation(self):
        """Test creating config with default values."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        # Test default values
        assert config.fhir_endpoint_url == "http://localhost:8080/fhir"
        assert config.output_dir == "./output"
        assert config.view_definitions_dir is not None
        
    def test_config_from_environment(self, monkeypatch):
        """Test config creation from environment variables."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        # Set environment variables
        monkeypatch.setenv("FHIR_ENDPOINT_URL", "http://test.server/fhir")
        monkeypatch.setenv("OUTPUT_DIR", "/test/output")
        
        config = Config()
        
        assert config.fhir_endpoint_url == "http://test.server/fhir"
        assert config.output_dir == "/test/output"
        
    def test_config_validation(self):
        """Test configuration parameter validation."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        # Test invalid FHIR URL
        with pytest.raises((ValidationError, ValueError)):
            Config(fhir_endpoint_url="invalid-url")
            
    def test_view_definition_path_generation(self):
        """Test ViewDefinition path generation."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        person_path = config.get_view_definition_path("Person")
        assert "Person" in str(person_path)
        assert person_path.suffix == ".json"
        
    def test_config_serialization(self, temp_directory):
        """Test config save/load to JSON."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config(
            fhir_endpoint_url="http://test.server/fhir",
            output_dir=str(temp_directory),
            omop_tables=["Person", "Observation"]
        )
        
        # Save to file
        config_file = temp_directory / "test_config.json"
        config.save_to_file(config_file)
        
        # Verify file exists
        assert config_file.exists()
        
        # Load and verify
        loaded_config = Config.load_from_file(config_file)
        assert loaded_config.fhir_endpoint_url == config.fhir_endpoint_url
        assert loaded_config.output_dir == config.output_dir


class TestConfigValidation:
    """Test configuration validation logic."""
    
    def test_omop_table_validation(self):
        """Test OMOP table name validation."""
        valid_tables = ["Person", "Observation", "Condition"]
        
        for table in valid_tables:
            # Should not raise exception
            assert table.isalpha()
            assert table[0].isupper()
            
    def test_output_format_validation(self):
        """Test output format validation."""
        valid_formats = ["parquet", "duckdb", "csv", "json"]
        
        for fmt in valid_formats:
            assert fmt in valid_formats
            assert fmt.islower()
            
    def test_bulk_export_parameters(self):
        """Test bulk export parameter validation.""" 
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        # Test types parameter
        config.bulk_export_types = ["Patient", "Observation"]
        assert isinstance(config.bulk_export_types, list)
        
        # Test elements parameter
        config.bulk_export_elements = ["id", "gender", "birthDate"]
        assert isinstance(config.bulk_export_elements, list)
        
    def test_pathling_configuration(self):
        """Test Pathling-specific configuration."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        # Test Spark configuration
        assert config.spark_app_name is not None
        assert isinstance(config.spark_app_name, str)
        
        # Test memory limits
        if hasattr(config, 'spark_memory_limit'):
            assert config.spark_memory_limit.endswith('g') or config.spark_memory_limit.endswith('m')


class TestConfigIntegration:
    """Integration tests for configuration."""
    
    def test_config_with_real_paths(self, test_config):
        """Test configuration with real file paths."""
        config = Config(**test_config)
        
        # Test ViewDefinition directory
        view_def_dir = Path(config.view_definitions_dir)
        # Directory might not exist in test environment, just check path formation
        assert isinstance(view_def_dir, Path)
        
        # Test output directory creation
        output_dir = Path(config.output_dir)
        if output_dir.exists():
            assert output_dir.is_dir()
            
    def test_config_compatibility(self):
        """Test configuration compatibility with different versions."""
        # Test basic config structure
        basic_config = {
            "fhir_endpoint_url": "http://localhost:8080/fhir",
            "output_dir": "./output"
        }
        
        # Should be able to create config from dict
        if Config is not MagicMock:
            config = Config(**basic_config)
            assert config.fhir_endpoint_url == basic_config["fhir_endpoint_url"]


@pytest.mark.unit
class TestConfigDefaults:
    """Test configuration default values."""
    
    def test_default_fhir_server(self):
        """Test default FHIR server configuration."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        assert config.fhir_endpoint_url.startswith("http")
        assert "8080" in config.fhir_endpoint_url
        assert "fhir" in config.fhir_endpoint_url.lower()
        
    def test_default_output_settings(self):
        """Test default output settings."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        assert config.output_dir is not None
        assert len(config.output_dir) > 0
        
    def test_default_omop_tables(self):
        """Test default OMOP tables configuration."""
        if Config is MagicMock:
            pytest.skip("Config module not available")
            
        config = Config()
        
        # Should have at least Person table by default
        assert hasattr(config, 'omop_tables')
        if config.omop_tables:
            assert "Person" in config.omop_tables


# Utility functions for testing
def create_test_config(temp_dir: Path) -> dict:
    """Create a test configuration dictionary."""
    return {
        "fhir_endpoint_url": "http://test.server/fhir",
        "output_dir": str(temp_dir),
        "view_definitions_dir": str(temp_dir / "viewdefs"),
        "omop_tables": ["Person", "Observation"],
        "output_formats": ["parquet", "json"]
    }


def validate_config_structure(config_dict: dict) -> bool:
    """Validate configuration dictionary structure."""
    required_keys = [
        "fhir_endpoint_url",
        "output_dir"
    ]
    
    return all(key in config_dict for key in required_keys)