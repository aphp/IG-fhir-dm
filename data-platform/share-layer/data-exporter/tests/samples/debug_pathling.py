#!/usr/bin/env python3
"""Debug script to understand Pathling API structure."""

import sys
from pathling_config import PathlingConfig

def debug_pathling_api():
    """Debug the Pathling API to understand available methods."""
    
    config = PathlingConfig()
    pc = None
    
    try:
        # Setup and initialize
        config.setup_environment()
        pc = config.create_pathling_context()
        
        print("Pathling context created successfully")
        print("\nAvailable methods on PathlingContext:")
        methods = [method for method in dir(pc) if not method.startswith('_')]
        for method in sorted(methods):
            print(f"  - {method}")
        
        # Check read methods
        print("\nAvailable methods on pc.read:")
        read_methods = [method for method in dir(pc.read) if not method.startswith('_')]
        for method in sorted(read_methods):
            print(f"  - {method}")
        
        # Try reading sample data
        from pathlib import Path
        import json
        
        temp_dir = Path(config.temp_dir)
        sample_file = temp_dir / "debug_patient.ndjson"
        
        # Create simple patient
        patient = {
            "resourceType": "Patient",
            "id": "debug-001",
            "gender": "male",
            "birthDate": "1980-01-01"
        }
        
        with open(sample_file, "w") as f:
            json.dump(patient, f)
        
        print(f"\nReading data from {sample_file}")
        data = pc.read.ndjson(str(sample_file))
        
        print(f"Data type: {type(data)}")
        print("Available methods on data:")
        data_methods = [method for method in dir(data) if not method.startswith('_')]
        for method in sorted(data_methods):
            print(f"  - {method}")
        
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        if pc:
            try:
                pc._spark.stop()
                print("\nSpark stopped")
            except:
                pass
        config.cleanup()

if __name__ == "__main__":
    debug_pathling_api()