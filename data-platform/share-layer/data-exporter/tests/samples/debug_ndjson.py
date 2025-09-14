#!/usr/bin/env python3
"""Debug NDJSON loading issues."""

from pathling_config import PathlingConfig, create_sample_fhir_data
from pathlib import Path

def debug_ndjson():
    """Debug NDJSON loading."""
    
    config = PathlingConfig()
    
    try:
        config.setup_environment()
        
        # Create sample data 
        sample_file = Path(config.temp_dir) / "Patient.debug_patients.ndjson"
        patient_count = create_sample_fhir_data(sample_file)
        
        print(f"Created {patient_count} patients")
        print(f"File: {sample_file}")
        print(f"File exists: {sample_file.exists()}")
        print(f"File size: {sample_file.stat().st_size} bytes")
        
        # Read file content
        print("\nFile content:")
        with open(sample_file, "r") as f:
            content = f.read()
            print(content)
        
        # Try loading with Pathling
        print("\nTesting Pathling load...")
        pc = config.create_pathling_context()
        
        data = pc.read.ndjson(str(Path(config.temp_dir)))
        resource_types = data.resource_types()
        print(f"Resource types found: {resource_types}")
        
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        try:
            if 'pc' in locals():
                pc._spark.stop()
        except:
            pass
        config.cleanup()

if __name__ == "__main__":
    debug_ndjson()