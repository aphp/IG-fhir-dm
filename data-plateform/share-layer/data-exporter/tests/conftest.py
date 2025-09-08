"""Pytest configuration and fixtures for FHIR to OMOP Data Exporter tests."""

import os
import json
import tempfile
from pathlib import Path
from typing import Dict, List, Any

import pytest
import duckdb
import pandas as pd


@pytest.fixture(scope="session")
def test_config():
    """Test configuration fixture."""
    return {
        "fhir_endpoint_url": "http://localhost:8080/fhir",
        "output_dir": "./test_output",
        "view_definitions_dir": "../../../fsh-generated/resources",
        "temp_dir": "./test_temp"
    }


@pytest.fixture(scope="session") 
def sample_patients() -> List[Dict[str, Any]]:
    """Sample FHIR Patient resources for testing."""
    return [
        {
            "resourceType": "Patient",
            "id": "test-patient-001",
            "gender": "male",
            "birthDate": "1980-01-15",
            "address": [
                {
                    "id": "addr-001",
                    "use": "home",
                    "city": "Paris",
                    "state": "Ile-de-France", 
                    "country": "France"
                }
            ],
            "managingOrganization": {
                "reference": "Organization/aphp-hopital-001"
            }
        },
        {
            "resourceType": "Patient",
            "id": "test-patient-002",
            "gender": "female", 
            "birthDate": "1990-06-20",
            "address": [
                {
                    "id": "addr-002",
                    "use": "home",
                    "city": "Lyon",
                    "state": "Auvergne-Rhône-Alpes",
                    "country": "France"
                }
            ],
            "generalPractitioner": [
                {
                    "reference": "Practitioner/medecin-001"
                }
            ]
        },
        {
            "resourceType": "Patient",
            "id": "test-patient-003",
            "gender": "other",
            "birthDate": "1985-12-05",
            "address": [
                {
                    "id": "addr-003", 
                    "use": "work",
                    "city": "Marseille",
                    "state": "Provence-Alpes-Côte d'Azur",
                    "country": "France"
                }
            ],
            "generalPractitioner": [
                {
                    "reference": "Practitioner/medecin-002"
                }
            ],
            "managingOrganization": {
                "reference": "Organization/aphp-hopital-002"
            }
        }
    ]


@pytest.fixture(scope="session")
def omop_person_viewdef() -> Dict[str, Any]:
    """OMOP Person ViewDefinition for testing."""
    return {
        "resourceType": "https://sql-on-fhir.org/ig/StructureDefinition/ViewDefinition",
        "url": "https://aphp.fr/ig/fhir/dm/ViewDefinition/OMOP-Person-View",
        "title": "OMOP Person View",
        "description": "ViewDefinition to transform FHIR Patient resources into OMOP Person table format",
        "name": "OMOP-Person-View", 
        "status": "draft",
        "resource": "Patient",
        "constant": [
            {
                "name": "integerNull",
                "valueInteger": 0
            }
        ],
        "select": [
            {
                "column": [
                    {
                        "name": "person_id",
                        "path": "id",
                        "description": "Unique identifier for the person",
                        "type": "id"
                    },
                    {
                        "name": "gender_concept_id", 
                        "path": "%integerNull",
                        "description": "Gender concept id",
                        "type": "integer"
                    },
                    {
                        "name": "birth_datetime",
                        "path": "birthDate",
                        "description": "Birth date and time", 
                        "type": "date"
                    },
                    {
                        "name": "race_concept_id",
                        "path": "%integerNull",
                        "description": "Race concept id",
                        "type": "integer" 
                    },
                    {
                        "name": "ethnicity_concept_id",
                        "path": "%integerNull",
                        "description": "Ethnicity concept id",
                        "type": "integer"
                    },
                    {
                        "name": "location_id",
                        "path": "address.first().id",
                        "description": "Location identifier from primary address",
                        "type": "string"
                    },
                    {
                        "name": "provider_id",
                        "path": "generalPractitioner.first().getReferenceKey(Practitioner)",
                        "description": "Provider identifier from general practitioner", 
                        "type": "string"
                    },
                    {
                        "name": "care_site_id",
                        "path": "managingOrganization.getReferenceKey(Organization)",
                        "description": "Care site identifier from managing organization",
                        "type": "string"
                    },
                    {
                        "name": "person_source_value",
                        "path": "getResourceKey()",
                        "description": "Source value for person",
                        "type": "string"
                    },
                    {
                        "name": "gender_source_value",
                        "path": "gender", 
                        "description": "Source value for gender",
                        "type": "code"
                    }
                ]
            }
        ]
    }


@pytest.fixture(scope="function")
def temp_directory():
    """Temporary directory for test files."""
    with tempfile.TemporaryDirectory() as temp_dir:
        yield Path(temp_dir)


@pytest.fixture(scope="function") 
def duckdb_connection():
    """In-memory DuckDB connection for testing."""
    conn = duckdb.connect(":memory:")
    
    # Configure for testing
    conn.execute("SET memory_limit='1GB'")
    conn.execute("SET threads=2")
    
    yield conn
    
    conn.close()


@pytest.fixture(scope="function")
def sample_ndjson_file(sample_patients, temp_directory):
    """Create NDJSON file with sample patients."""
    ndjson_file = temp_directory / "Patient.sample.ndjson"
    
    with open(ndjson_file, 'w', encoding='utf-8') as f:
        for patient in sample_patients:
            json.dump(patient, f)
            f.write('\n')
            
    return ndjson_file


@pytest.fixture(scope="function") 
def sample_bundle_file(sample_patients, temp_directory):
    """Create FHIR Bundle file with sample patients."""
    bundle = {
        "resourceType": "Bundle",
        "id": "test-bundle",
        "type": "collection",
        "timestamp": "2025-09-07T12:00:00Z",
        "entry": []
    }
    
    for patient in sample_patients:
        bundle["entry"].append({
            "resource": patient,
            "fullUrl": f"Patient/{patient['id']}"
        })
    
    bundle_file = temp_directory / "Bundle.sample.json"
    with open(bundle_file, 'w', encoding='utf-8') as f:
        json.dump(bundle, f, indent=2)
        
    return bundle_file


@pytest.fixture(scope="function")
def expected_omop_person() -> List[Dict[str, Any]]:
    """Expected OMOP Person records after transformation."""
    return [
        {
            "person_id": "test-patient-001",
            "gender_concept_id": 0,
            "birth_datetime": "1980-01-15",
            "race_concept_id": 0,
            "ethnicity_concept_id": 0,
            "location_id": "addr-001",
            "provider_id": None,
            "care_site_id": "Organization/aphp-hopital-001",
            "person_source_value": "test-patient-001", 
            "gender_source_value": "male"
        },
        {
            "person_id": "test-patient-002",
            "gender_concept_id": 0,
            "birth_datetime": "1990-06-20",
            "race_concept_id": 0,
            "ethnicity_concept_id": 0,
            "location_id": "addr-002",
            "provider_id": "Practitioner/medecin-001",
            "care_site_id": None,
            "person_source_value": "test-patient-002",
            "gender_source_value": "female"
        },
        {
            "person_id": "test-patient-003", 
            "gender_concept_id": 0,
            "birth_datetime": "1985-12-05",
            "race_concept_id": 0,
            "ethnicity_concept_id": 0,
            "location_id": "addr-003",
            "provider_id": "Practitioner/medecin-002", 
            "care_site_id": "Organization/aphp-hopital-002",
            "person_source_value": "test-patient-003",
            "gender_source_value": "other"
        }
    ]


@pytest.fixture(scope="function")
def mock_pathling_context(monkeypatch):
    """Mock Pathling context for testing without Spark."""
    class MockPathlingContext:
        def __init__(self):
            self.read = MockPathlingRead()
            
        def create(self):
            return self
            
    class MockPathlingRead:
        def ndjson(self, path):
            return MockPathlingDataset()
            
        def bundles(self, path, resource_types=None):
            return MockPathlingDataset()
            
        def bulk(self, fhir_endpoint_url, output_dir, types=None, elements=None):
            return MockPathlingDataset()
            
    class MockPathlingDataset:
        def resource_types(self):
            return ['Patient']
            
        def view(self, resource, json=None):
            return MockPathlingDataFrame()
            
        def read(self, resource_type):
            return MockPathlingDataFrame()
            
    class MockPathlingDataFrame:
        def count(self):
            return 3
            
        def show(self, n=20, truncate=True):
            print("Mock DataFrame content")
            
        def printSchema(self):
            print("Mock schema")
            
        def write(self):
            return MockPathlingWriter()
            
    class MockPathlingWriter:
        def mode(self, mode):
            return self
            
        def option(self, key, value):
            return self
            
        def parquet(self, path):
            Path(path).mkdir(parents=True, exist_ok=True)
            
        def csv(self, path):
            Path(path).mkdir(parents=True, exist_ok=True)
    
    # Mock the pathling module
    mock_pathling = MockPathlingContext()
    monkeypatch.setattr("pathling.PathlingContext", MockPathlingContext)
    
    return mock_pathling


@pytest.fixture(autouse=True)
def cleanup_test_files():
    """Cleanup test output files after each test."""
    yield
    
    # Clean up test directories
    test_dirs = ["./test_output", "./test_temp", "./temp"]
    for test_dir in test_dirs:
        path = Path(test_dir)
        if path.exists():
            import shutil
            shutil.rmtree(path, ignore_errors=True)


def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "integration: mark test as integration test"
    )
    config.addinivalue_line(
        "markers", "unit: mark test as unit test"  
    )
    config.addinivalue_line(
        "markers", "performance: mark test as performance test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )


def pytest_collection_modifyitems(config, items):
    """Modify test collection to add markers based on file location."""
    for item in items:
        # Add markers based on test file location
        if "integration" in str(item.fspath):
            item.add_marker(pytest.mark.integration)
        elif "unit" in str(item.fspath):
            item.add_marker(pytest.mark.unit)  
        elif "performance" in str(item.fspath):
            item.add_marker(pytest.mark.performance)
            item.add_marker(pytest.mark.slow)
        elif "samples" in str(item.fspath):
            item.add_marker(pytest.mark.unit)


# Test data constants
SAMPLE_PATIENT_COUNT = 3
EXPECTED_OMOP_COLUMNS = [
    "person_id", "gender_concept_id", "birth_datetime", 
    "race_concept_id", "ethnicity_concept_id", "location_id",
    "provider_id", "care_site_id", "person_source_value", 
    "gender_source_value"
]