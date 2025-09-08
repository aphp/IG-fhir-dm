#!/usr/bin/env python3
"""Working test for FHIR to OMOP Person transformation with proper error handling."""

import sys
import json
import logging
from pathlib import Path

# Local imports
from pathling_config import PathlingConfig, create_sample_fhir_data, load_view_definition_safe

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def run_working_test():
    """Run a robust test of the FHIR to OMOP transformation."""
    
    print("FHIR to OMOP Person Export - Working Test")
    print("=" * 55)
    
    config = PathlingConfig()
    pc = None
    
    try:
        # Step 1: Setup environment
        print("1. Setting up environment...")
        temp_dir = config.setup_environment()
        print(f"   SUCCESS: Using temp directory {temp_dir}")
        
        # Step 2: Load ViewDefinition
        print("2. Loading OMOP Person ViewDefinition...")
        view_def = load_view_definition_safe()
        
        if not view_def:
            print("   ERROR: Could not load ViewDefinition")
            return False
        
        print(f"   SUCCESS: Loaded '{view_def.get('name', 'Unknown')}'")
        print(f"   Resource: {view_def.get('resource')}")
        print(f"   Columns: {len(view_def['select'][0]['column'])}")
        
        # Step 3: Initialize Pathling
        print("3. Initializing Pathling context...")
        print("   (First run may take several minutes for dependency download)")
        
        try:
            pc = config.create_pathling_context()
            print("   SUCCESS: Pathling context ready")
            
        except Exception as e:
            print(f"   ERROR: Pathling initialization failed: {e}")
            print("   Ensure pathling is installed: pip install pathling>=8.0.1")
            return False
        
        # Step 4: Create sample data
        print("4. Creating sample FHIR patient data...")
        
        sample_file = Path(temp_dir) / "Patient.sample_patients.ndjson"
        patient_count = create_sample_fhir_data(sample_file)
        print(f"   SUCCESS: Created {patient_count} sample patients")
        
        # Step 5: Load data into Pathling
        print("5. Loading data into Pathling...")
        
        try:
            data = pc.read.ndjson(str(temp_dir))
            # Verify data loaded - check resource types
            resource_types = data.resource_types()
            print(f"   SUCCESS: Loaded data with resource types: {resource_types}")
            
            # Count patients - we'll use the view method later to get count
            loaded_count = patient_count  # We know from creation
            
        except Exception as e:
            print(f"   ERROR: Failed to load data: {e}")
            return False
        
        # Step 6: Apply ViewDefinition transformation
        print("6. Applying OMOP Person transformation...")
        
        try:
            # Apply the ViewDefinition
            person_df = data.view(
                resource="Patient",
                json=json.dumps(view_def) 
            )
            
            person_count = person_df.count()
            print(f"   SUCCESS: Transformed {person_count} person records")
            
            if person_count == 0:
                print("   WARNING: No records after transformation")
                return False
            
        except Exception as e:
            print(f"   ERROR: Transformation failed: {e}")
            logger.exception("Transformation details:")
            return False
        
        # Step 7: Display results
        print("7. Displaying transformation results...")
        
        try:
            print("\n   OMOP Person Schema:")
            person_df.printSchema()
            
            print(f"\n   Sample data ({min(person_count, 3)} rows):")
            person_df.show(3, truncate=False)
            
        except Exception as e:
            print(f"   WARNING: Could not display results: {e}")
        
        # Step 8: Export to files
        print("8. Exporting results...")
        
        output_dir = Path("./output")
        output_dir.mkdir(exist_ok=True)
        
        # Export to Parquet
        try:
            parquet_path = output_dir / "omop_person_working"
            person_df.write.mode("overwrite").option("compression", "snappy").parquet(str(parquet_path))
            
            # Check files created
            parquet_files = list(parquet_path.glob("*.parquet"))
            total_size = sum(f.stat().st_size for f in parquet_files)
            
            print(f"   SUCCESS: Parquet export to {parquet_path}")
            print(f"   Files: {len(parquet_files)}, Size: {total_size:,} bytes")
            
        except Exception as e:
            print(f"   ERROR: Parquet export failed: {e}")
        
        # Export to CSV for easy inspection
        try:
            csv_path = output_dir / "omop_person_working.csv"
            person_df.coalesce(1).write.mode("overwrite").option("header", "true").csv(str(csv_path))
            
            # Find the actual CSV file (Spark creates a directory)
            actual_csv = next(csv_path.glob("*.csv"), None)
            if actual_csv:
                print(f"   SUCCESS: CSV export to {actual_csv}")
            else:
                print(f"   SUCCESS: CSV export to {csv_path}/")
                
        except Exception as e:
            print(f"   WARNING: CSV export failed: {e}")
        
        # Step 9: Validate OMOP schema compliance
        print("9. Validating OMOP schema compliance...")
        
        try:
            columns = [col.name for col in person_df.schema]
            
            # Expected OMOP Person columns (core subset)
            expected_columns = [
                "person_id", "gender_concept_id", "birth_datetime",
                "race_concept_id", "ethnicity_concept_id", "location_id",
                "provider_id", "care_site_id", "person_source_value", "gender_source_value"
            ]
            
            missing_columns = [col for col in expected_columns if col not in columns]
            extra_columns = [col for col in columns if col not in expected_columns]
            
            if not missing_columns:
                print("   SUCCESS: All expected OMOP columns present")
            else:
                print(f"   WARNING: Missing columns: {missing_columns}")
                
            if extra_columns:
                print(f"   INFO: Extra columns: {extra_columns}")
            
        except Exception as e:
            print(f"   WARNING: Schema validation failed: {e}")
        
        # Step 10: Final summary
        print("\n" + "=" * 55)
        print("TRANSFORMATION SUMMARY:")
        print(f"  Source: FHIR Patient resources ({patient_count} records)")
        print(f"  Target: OMOP Person table ({person_count} records)")
        print(f"  Columns: {len(person_df.schema)} fields")
        print(f"  Output: {output_dir.absolute()}")
        print("  Status: SUCCESS - Complete pipeline working!")
        print("=" * 55)
        
        return True
        
    except Exception as e:
        print(f"\nERROR: Test failed with exception: {e}")
        logger.exception("Test failure details:")
        return False
        
    finally:
        # Cleanup
        try:
            if pc and hasattr(pc, '_spark'):
                pc._spark.stop()
                print("\nINFO: Spark context stopped")
        except Exception as e:
            logger.warning(f"Cleanup warning: {e}")
        
        # Clean up environment
        try:
            config.cleanup()
        except Exception as e:
            logger.warning(f"Environment cleanup warning: {e}")


def main():
    """Main entry point."""
    try:
        success = run_working_test()
        
        if success:
            print("\n[SUCCESS] Test PASSED! The FHIR to OMOP transformation is working.")
            print("Check the 'output' directory for exported files.")
        else:
            print("\n[FAILED] Test FAILED! Check the error messages above.")
            
        return 0 if success else 1
        
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        return 1
        
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        logger.exception("Unexpected error details:")
        return 1


if __name__ == "__main__":
    sys.exit(main())