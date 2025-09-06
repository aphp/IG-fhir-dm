#!/usr/bin/env python3
"""
Simple test script for importing a small subset of FHIR data.
This script imports core resources first to avoid reference issues.
"""

import asyncio
import os
from pathlib import Path
from config import Config
from fhir_bulk_loader_fixed import FhirBulkLoaderFixed as FhirBulkLoader

# Define the order of files to import to resolve dependencies
IMPORT_ORDER = [
    "MimicOrganization.ndjson.gz",  # Base organization
    "MimicLocation.ndjson.gz",      # Locations
    "MimicPatient.ndjson.gz",       # Patients (100 resources)
    "MimicEncounter.ndjson.gz",     # Encounters (275 resources)
    "MimicMedication.ndjson.gz",    # Medications before requests (1480 resources)
    "MimicMedicationRequest.ndjson.gz",  # Medication requests (17552 resources)
]

async def test_small_dataset():
    """Test with a small, ordered dataset."""
    
    # Setup configuration
    config = Config.from_env()
    
    print(f"Testing FHIR Bulk Loader with small dataset")
    print(f"HAPI FHIR Server: {config.hapi_fhir.base_url}")
    print(f"Data Directory: {config.import_settings.data_directory}")
    print(f"Batch Size: {config.import_settings.batch_size}")
    print("-" * 60)
    
    # Create loader
    async with FhirBulkLoader(config) as loader:
        # Test connection first
        if not await loader.test_connection():
            print("Failed to connect to HAPI FHIR server")
            return False
        
        print("Connected to HAPI FHIR server successfully")
        print()
        
        data_dir = Path(config.import_settings.data_directory)
        successful_files = 0
        total_resources = 0
        
        # Process files in dependency order
        for filename in IMPORT_ORDER:
            file_path = data_dir / filename
            
            if not file_path.exists():
                print(f"File not found: {filename}")
                continue
                
            print(f"Processing {filename}...")
            
            try:
                # Load single file
                success = await loader.load_file_with_bundles(file_path)
                
                if success:
                    print(f"Successfully imported {filename}")
                    successful_files += 1
                    
                    # Note: Resource counting would require analyzing file again
                    print(f"   Status: Import successful")
                    
                else:
                    print(f"Failed to import {filename}")
                    
            except Exception as e:
                print(f"Error processing {filename}: {str(e)}")
            
            print()
        
        print("=" * 60)
        print(f"Import Summary:")
        print(f"   Successful files: {successful_files}/{len(IMPORT_ORDER)}")
        print(f"   Total resources imported: {total_resources}")
        
        if successful_files == len(IMPORT_ORDER):
            print("All test files imported successfully!")
            return True
        else:
            print("Some files failed to import")
            return False

def main():
    """Main entry point."""
    return asyncio.run(test_small_dataset())

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)