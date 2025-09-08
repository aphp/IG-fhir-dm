#!/usr/bin/env python3
"""Minimal working test for FHIR to OMOP Person transformation."""

import os
import sys
import json
import logging
import tempfile
import shutil
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def setup_environment():
    """Setup environment variables for Windows compatibility."""
    # Use system temp directory to avoid path issues
    temp_dir = tempfile.mkdtemp(prefix="pathling_")
    
    # Set environment variables with proper Windows paths
    os.environ["TMPDIR"] = temp_dir
    os.environ["TMP"] = temp_dir
    os.environ["TEMP"] = temp_dir
    
    # Spark configuration for Windows
    os.environ["SPARK_LOCAL_DIRS"] = temp_dir
    os.environ["SPARK_WORKER_DIR"] = temp_dir
    
    # Disable Spark UI to avoid port conflicts
    os.environ["SPARK_UI_ENABLED"] = "false"
    
    logger.info(f"Using temp directory: {temp_dir}")
    return temp_dir

def create_minimal_patient_data():
    """Create minimal patient data for testing."""
    patients = [
        {
            "resourceType": "Patient",
            "id": "patient-001",
            "gender": "male",
            "birthDate": "1980-01-15",
            "address": [
                {
                    "id": "addr-001",
                    "use": "home",
                    "city": "Paris",
                    "state": "IDF",
                    "country": "FR"
                }
            ],
            "managingOrganization": {
                "reference": "Organization/aphp-001"
            }
        },
        {
            "resourceType": "Patient",
            "id": "patient-002", 
            "gender": "female",
            "birthDate": "1990-06-20",
            "address": [
                {
                    "id": "addr-002",
                    "use": "home",
                    "city": "Lyon",
                    "state": "RA",
                    "country": "FR"
                }
            ],
            "generalPractitioner": [
                {
                    "reference": "Practitioner/gp-001"
                }
            ]
        }
    ]
    
    return patients

def load_view_definition():
    """Load the OMOP Person ViewDefinition."""
    view_def_path = Path("../../../../../fsh-generated/resources/Binary-OMOP-Person-View.json")
    
    if not view_def_path.exists():
        logger.error(f"ViewDefinition not found at: {view_def_path}")
        return None
    
    try:
        with open(view_def_path, "r", encoding="utf-8") as f:
            view_def = json.load(f)
        
        logger.info(f"Loaded ViewDefinition: {view_def.get('name', 'Unknown')}")
        return view_def
        
    except Exception as e:
        logger.error(f"Failed to load ViewDefinition: {e}")
        return None

def run_minimal_test():
    """Run minimal test with proper error handling."""
    print("FHIR to OMOP Person Export - Minimal Test")
    print("=" * 50)
    
    temp_dir = None
    try:
        # Step 1: Setup environment
        print("1. Setting up environment...")
        temp_dir = setup_environment()
        print("   SUCCESS: Environment configured")
        
        # Step 2: Load ViewDefinition  
        print("2. Loading ViewDefinition...")
        view_def = load_view_definition()
        if not view_def:
            print("   ERROR: Could not load ViewDefinition")
            return False
        print(f"   SUCCESS: Loaded '{view_def['name']}'")
        
        # Step 3: Initialize Pathling with timeout handling
        print("3. Initializing Pathling...")
        print("   (This may take a few minutes on first run)")
        
        try:
            # Import with timeout awareness
            import signal
            
            def timeout_handler(signum, frame):
                raise TimeoutError("Pathling initialization timed out")
            
            # Set alarm for 5 minutes (300 seconds)
            if hasattr(signal, 'SIGALRM'):
                signal.signal(signal.SIGALRM, timeout_handler)
                signal.alarm(300)
            
            from pathling import PathlingContext
            
            # Create context with minimal configuration
            pc = PathlingContext.create()
            
            if hasattr(signal, 'SIGALRM'):
                signal.alarm(0)  # Cancel alarm
                
            print("   SUCCESS: Pathling initialized")
            
        except ImportError as e:
            print(f"   ERROR: Pathling not available: {e}")
            print("   Install with: pip install pathling")
            return False
            
        except TimeoutError:
            print("   ERROR: Pathling initialization timed out")
            print("   This is common on first run - try again")
            return False
            
        except Exception as e:
            print(f"   ERROR: Pathling initialization failed: {e}")
            return False
        
        # Step 4: Create and load sample data
        print("4. Creating sample patient data...")
        patients = create_minimal_patient_data()
        
        # Write to NDJSON file
        sample_file = Path(temp_dir) / "Patient.sample_patients.ndjson"
        with open(sample_file, "w", encoding="utf-8") as f:
            for patient in patients:
                json.dump(patient, f)
                f.write("\n")
        
        # Load data using Pathling
        data = pc.read.ndjson(str(Path(temp_dir)))
        patient_count = data.read('Patient').count()
        print(f"   SUCCESS: Created {patient_count} sample patients")
        
        # Step 5: Apply ViewDefinition transformation
        print("5. Applying OMOP Person transformation...")
        
        try:
            person_df = data.view(
                resource="Patient",
                json=json.dumps(view_def)
            )
            
            person_count = person_df.count()
            print(f"   SUCCESS: Transformed {person_count} person records")
            
            # Show schema
            print("\n   OMOP Person Schema:")
            person_df.printSchema()
            
            # Show sample data
            if person_count > 0:
                print("\n   Sample transformed data:")
                person_df.show(truncate=False)
            
        except Exception as e:
            print(f"   ERROR: ViewDefinition transformation failed: {e}")
            logger.exception("Transformation error details:")
            return False
        
        # Step 6: Export results
        print("6. Exporting results...")
        
        output_dir = Path("./output")
        output_dir.mkdir(exist_ok=True)
        
        # Export to Parquet
        parquet_path = output_dir / "omop_person_minimal.parquet"
        person_df.write.mode("overwrite").option("compression", "snappy").parquet(str(parquet_path))
        print(f"   SUCCESS: Exported to {parquet_path}")
        
        # Verify export
        parquet_files = list(parquet_path.glob("*.parquet"))
        if parquet_files:
            file_size = sum(f.stat().st_size for f in parquet_files)
            print(f"   Parquet files: {len(parquet_files)}, Total size: {file_size} bytes")
        
        # Optional: Export to CSV for easy viewing
        try:
            csv_path = output_dir / "omop_person_minimal.csv"
            person_df.coalesce(1).write.mode("overwrite").option("header", "true").csv(str(csv_path))
            print(f"   SUCCESS: Also exported to CSV at {csv_path}")
        except Exception as e:
            print(f"   WARNING: CSV export failed: {e}")
        
        # Step 7: Summary
        print("\n" + "=" * 50)
        print("SUMMARY:")
        print(f"  Input patients: {patient_count}")
        print(f"  Output persons: {person_count}")
        print(f"  ViewDefinition columns: {len(view_def['select'][0]['column'])}")
        print(f"  Export location: {output_dir.absolute()}")
        print("SUCCESS: Minimal test completed!")
        print("=" * 50)
        
        return True
        
    except Exception as e:
        print(f"\nERROR: Test failed: {e}")
        logger.exception("Test failure details:")
        return False
        
    finally:
        # Cleanup
        try:
            if 'pc' in locals() and hasattr(pc, '_spark'):
                pc._spark.stop()
                print("\nSpark context stopped")
        except Exception as e:
            logger.warning(f"Cleanup warning: {e}")
        
        # Clean up temp directory
        if temp_dir and Path(temp_dir).exists():
            try:
                shutil.rmtree(temp_dir)
                logger.info(f"Cleaned up temp directory: {temp_dir}")
            except Exception as e:
                logger.warning(f"Could not clean temp directory: {e}")

if __name__ == "__main__":
    success = run_minimal_test()
    sys.exit(0 if success else 1)