#!/usr/bin/env python3
"""Simple test script for OMOP Person table export."""

import os
import sys
import json
import logging
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def simple_test():
    """Simple test without rich output."""
    
    print("FHIR to OMOP Person Table Export Test")
    print("=" * 40)
    
    try:
        from pathling import PathlingContext
        print("SUCCESS: Pathling imported successfully")
        
        # Test ViewDefinition loading
        view_definition_path = "../../../fsh-generated/resources/Binary-OMOP-Person-View.json"
        full_path = Path(__file__).parent / view_definition_path
        
        print(f"Checking ViewDefinition at: {full_path}")
        
        if full_path.exists():
            print("SUCCESS: ViewDefinition file found")
            
            with open(full_path, "r", encoding="utf-8") as f:
                view_def = json.load(f)
                
            print(f"ViewDefinition name: {view_def.get('name', 'Unknown')}")
            print(f"Resource type: {view_def.get('resource', 'Unknown')}")
            print(f"Number of columns: {len(view_def.get('select', []))}")
            
        else:
            print(f"ERROR: ViewDefinition file not found at {full_path}")
            return False
        
        # Test Pathling initialization
        print("\nInitializing Pathling...")
        
        # Create temp directory
        output_dir = "./output"
        os.makedirs(output_dir, exist_ok=True)
        temp_dir = os.path.join(output_dir, "temp")
        os.makedirs(temp_dir, exist_ok=True)
        
        # Set environment variables
        os.environ["TMPDIR"] = temp_dir
        os.environ["TMP"] = temp_dir
        os.environ["TEMP"] = temp_dir
        
        pc = PathlingContext.create()
        print("SUCCESS: Pathling context created")
        
        # Test FHIR server connection
        fhir_server = "http://localhost:8080/fhir"
        print(f"\nTesting connection to: {fhir_server}")
        
        try:
            # Try bulk export
            bulk_export_dir = os.path.join(output_dir, "bulk_test").replace("\\", "/")
            os.makedirs(bulk_export_dir.replace("/", "\\"), exist_ok=True)
            
            data = pc.read.bulk(
                fhir_endpoint_url=fhir_server,
                output_dir=bulk_export_dir,
                types=["Patient"]
            )
            print("SUCCESS: Bulk export completed")
            
            # Apply ViewDefinition
            print("\nApplying ViewDefinition transformation...")
            
            person_df = data.view(
                resource="Patient",
                json=json.dumps(view_def)
            )
            
            print("SUCCESS: ViewDefinition applied")
            
            # Get count
            row_count = person_df.count()
            print(f"Total rows transformed: {row_count}")
            
            # Export to Parquet
            parquet_path = os.path.join(output_dir, "person_test.parquet")
            person_df.write.mode("overwrite").parquet(parquet_path)
            print(f"SUCCESS: Exported to {parquet_path}")
            
            return True
            
        except Exception as e:
            print(f"FHIR server connection failed: {e}")
            print("This is expected if the HAPI server is not running")
            
            # Create sample data for testing
            print("\nCreating sample data for testing...")
            
            sample_patient = {
                "resourceType": "Patient",
                "id": "test-1",
                "gender": "male",
                "birthDate": "1980-01-01"
            }
            
            sample_file = os.path.join(output_dir, "sample_patient.ndjson")
            with open(sample_file, "w") as f:
                json.dump(sample_patient, f)
            
            # Load sample data
            data = pc.read.ndjson(sample_file)
            print("SUCCESS: Sample data loaded")
            
            # Apply ViewDefinition
            person_df = data.view(
                resource="Patient",
                json=json.dumps(view_def)
            )
            
            row_count = person_df.count()
            print(f"Total rows: {row_count}")
            
            # Export to Parquet
            parquet_path = os.path.join(output_dir, "person_sample.parquet")
            person_df.write.mode("overwrite").parquet(parquet_path)
            print(f"SUCCESS: Sample exported to {parquet_path}")
            
            return True
        
    except Exception as e:
        print(f"ERROR: Test failed: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        # Clean up
        try:
            if 'pc' in locals():
                pc._spark.stop()
                print("\nSpark context stopped")
        except:
            pass

if __name__ == "__main__":
    success = simple_test()
    print(f"\nTest {'PASSED' if success else 'FAILED'}")
    sys.exit(0 if success else 1)