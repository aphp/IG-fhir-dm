#!/usr/bin/env python3
"""Test script for small subset bulk import."""

import asyncio
import os
import shutil
from pathlib import Path
from config import Config
from fhir_bulk_loader import FhirBulkLoader

async def test_small_import():
    """Test importing a small subset of FHIR data."""
    
    # Create a temporary directory for small test files
    test_dir = Path("test_data_small")
    if test_dir.exists():
        shutil.rmtree(test_dir)
    test_dir.mkdir()
    
    source_dir = Path("../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir")
    
    # Copy the smallest files for testing
    small_files = [
        "MimicOrganization.ndjson.gz",  # 1 resource
        "MimicPatient.ndjson.gz",       # 100 resources  
        "MimicLocation.ndjson.gz"       # 31 resources
    ]
    
    print("Setting up test with small files...")
    for filename in small_files:
        source_file = source_dir / filename
        dest_file = test_dir / filename
        if source_file.exists():
            shutil.copy2(source_file, dest_file)
            print(f"Copied {filename}")
        else:
            print(f"Warning: {filename} not found")
    
    # Configure for small test
    config = Config.from_env()
    config.import_settings.data_directory = str(test_dir)
    config.import_settings.batch_size = 100
    config.import_settings.max_wait_time = 300  # 5 minutes max
    config.import_settings.poll_interval = 5   # Poll every 5 seconds
    
    print(f"HAPI FHIR URL: {config.hapi_fhir.base_url}")
    print(f"Test data directory: {config.import_settings.data_directory}")
    
    # Run the import
    async with FhirBulkLoader(config) as loader:
        # Test connection first
        print("Testing connection to HAPI FHIR server...")
        if not await loader.test_connection():
            print("❌ Failed to connect to HAPI FHIR server")
            return False
        
        print("✅ Connection successful")
        
        # Discover and analyze files
        files = loader.discover_ndjson_files()
        print(f"Found {len(files)} test files")
        
        total_resources = 0
        for file_path in files:
            print(f"Analyzing {file_path.name}...")
            resource_counts = await loader.analyze_ndjson_file(file_path)
            file_total = sum(resource_counts.values())
            total_resources += file_total
            print(f"  {file_path.name}: {file_total} resources - {resource_counts}")
        
        print(f"Total resources to import: {total_resources}")
        
        if total_resources == 0:
            print("❌ No resources found to import")
            return False
        
        # Start the import process
        print("🚀 Starting bulk import...")
        success = await loader.process_files(files)
        
        if success:
            print("✅ Small subset import completed successfully!")
        else:
            print("❌ Import failed!")
        
        return success

if __name__ == "__main__":
    success = asyncio.run(test_small_import())
    exit(0 if success else 1)