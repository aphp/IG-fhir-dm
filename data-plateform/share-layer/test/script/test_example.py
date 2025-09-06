"""Example test script for FHIR Bulk Loader.

This script demonstrates how to use the FHIR bulk loader programmatically
and shows basic usage patterns.
"""

import asyncio
import json
import tempfile
import gzip
from pathlib import Path
from config import Config, HapiFhirConfig, ImportConfig
from fhir_bulk_loader import FhirBulkLoader
from utils import FhirResourceValidator, FileProcessor


def create_test_ndjson_file(file_path: Path, resources: list) -> None:
    """Create a test NDJSON.gz file with sample FHIR resources."""
    with gzip.open(file_path, 'wt', encoding='utf-8') as f:
        for resource in resources:
            json.dump(resource, f, separators=(',', ':'))
            f.write('\n')


def create_sample_fhir_resources() -> list:
    """Create sample FHIR resources for testing."""
    return [
        {
            "resourceType": "Patient",
            "id": "patient-1",
            "gender": "male",
            "birthDate": "1980-01-01",
            "name": [
                {
                    "use": "official",
                    "family": "Doe",
                    "given": ["John"]
                }
            ]
        },
        {
            "resourceType": "Patient", 
            "id": "patient-2",
            "gender": "female",
            "birthDate": "1990-05-15",
            "name": [
                {
                    "use": "official",
                    "family": "Smith",
                    "given": ["Jane"]
                }
            ]
        },
        {
            "resourceType": "Encounter",
            "id": "encounter-1",
            "status": "finished",
            "class": {
                "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
                "code": "IMP",
                "display": "inpatient encounter"
            },
            "subject": {
                "reference": "Patient/patient-1"
            },
            "period": {
                "start": "2023-01-01T10:00:00Z",
                "end": "2023-01-03T14:00:00Z"
            }
        },
        {
            "resourceType": "Observation",
            "id": "observation-1",
            "status": "final",
            "category": [
                {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                            "code": "vital-signs",
                            "display": "Vital Signs"
                        }
                    ]
                }
            ],
            "code": {
                "coding": [
                    {
                        "system": "http://loinc.org",
                        "code": "8867-4",
                        "display": "Heart rate"
                    }
                ]
            },
            "subject": {
                "reference": "Patient/patient-1"
            },
            "valueQuantity": {
                "value": 72,
                "unit": "beats/minute",
                "system": "http://unitsofmeasure.org",
                "code": "/min"
            }
        }
    ]


async def test_connection():
    """Test connection to HAPI FHIR server."""
    print("Testing HAPI FHIR connection...")
    
    config = Config.from_env()
    
    async with FhirBulkLoader(config) as loader:
        success = await loader.test_connection()
        if success:
            print("✅ Connection test passed")
            return True
        else:
            print("❌ Connection test failed")
            return False


def test_file_validation():
    """Test file validation functionality."""
    print("Testing file validation...")
    
    # Create temporary test file
    with tempfile.NamedTemporaryFile(suffix='.ndjson.gz', delete=False) as temp_file:
        temp_path = Path(temp_file.name)
    
    try:
        # Create test data
        resources = create_sample_fhir_resources()
        create_test_ndjson_file(temp_path, resources)
        
        # Test file stats
        stats = FileProcessor.get_file_stats(temp_path)
        print(f"File stats: {stats}")
        
        # Test validation
        validation = FhirResourceValidator.validate_ndjson_file(temp_path)
        print(f"Validation results: {validation}")
        
        if validation['invalid_resources'] == 0:
            print("✅ Validation test passed")
            return True
        else:
            print("❌ Validation test failed")
            return False
            
    finally:
        # Clean up
        if temp_path.exists():
            temp_path.unlink()


def test_configuration():
    """Test configuration management."""
    print("Testing configuration...")
    
    # Test default config
    config = Config.from_env()
    try:
        # This will fail because data directory doesn't exist
        config.validate()
        print("❌ Config validation should have failed")
        return False
    except ValueError:
        print("✅ Config validation works correctly")
        return True


async def main():
    """Run all tests."""
    print("🧪 Running FHIR Bulk Loader Tests\n")
    
    tests = [
        ("Configuration", test_configuration),
        ("File Validation", test_file_validation),
        ("Connection Test", test_connection),
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n📋 {test_name}")
        print("-" * 40)
        
        try:
            if asyncio.iscoroutinefunction(test_func):
                result = await test_func()
            else:
                result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} failed with error: {e}")
            results.append((test_name, False))
    
    # Summary
    print(f"\n📊 Test Summary")
    print("=" * 40)
    passed = 0
    for test_name, result in results:
        status = "PASS" if result else "FAIL"
        emoji = "✅" if result else "❌"
        print(f"{emoji} {test_name}: {status}")
        if result:
            passed += 1
    
    print(f"\nResult: {passed}/{len(results)} tests passed")
    
    if passed == len(results):
        print("🎉 All tests passed!")
    else:
        print("❌ Some tests failed. Check the output above.")


if __name__ == "__main__":
    asyncio.run(main())