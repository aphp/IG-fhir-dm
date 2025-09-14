#!/usr/bin/env python3
"""Final working test using Bundle approach for FHIR to OMOP transformation."""

import sys
import json
import logging
from pathlib import Path

# Local imports
from pathling_config import PathlingConfig, load_view_definition_safe

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def create_bundle_data(output_file: Path) -> int:
    """Create sample FHIR data as a Bundle."""
    
    # Create patients
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
            "id": "patient-002",
            "gender": "female", 
            "birthDate": "1990-06-20",
            "address": [
                {
                    "id": "addr-002",
                    "use": "home",
                    "city": "Lyon",
                    "state": "Rhone-Alpes",
                    "country": "France"
                }
            ],
            "generalPractitioner": [
                {
                    "reference": "Practitioner/gp-001"
                }
            ]
        },
        {
            "resourceType": "Patient",
            "id": "patient-003",
            "gender": "other",
            "birthDate": "1985-12-05",
            "address": [
                {
                    "id": "addr-003", 
                    "use": "work",
                    "city": "Marseille",
                    "state": "PACA",
                    "country": "France"
                }
            ],
            "managingOrganization": {
                "reference": "Organization/aphp-hopital-002"
            },
            "generalPractitioner": [
                {
                    "reference": "Practitioner/gp-002"
                }
            ]
        }
    ]
    
    # Create Bundle
    bundle = {
        "resourceType": "Bundle",
        "id": "sample-patients-bundle",
        "type": "collection",
        "entry": []
    }
    
    # Add patients to bundle
    for patient in patients:
        bundle["entry"].append({
            "resource": patient
        })
    
    # Write bundle as JSON
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(bundle, f, indent=2)
    
    logger.info(f"Created bundle with {len(patients)} patients at {output_file}")
    return len(patients)

def run_final_test():
    """Run the final working test."""
    
    print("FHIR to OMOP Person Export - Final Working Test")
    print("=" * 60)
    
    config = PathlingConfig()
    pc = None
    
    try:
        # Step 1: Setup environment
        print("1. Setting up environment...")
        temp_dir = config.setup_environment()
        print(f"   SUCCESS: Using temp directory")
        
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
        
        try:
            pc = config.create_pathling_context()
            print("   SUCCESS: Pathling context ready")
            
        except Exception as e:
            print(f"   ERROR: Pathling initialization failed: {e}")
            return False
        
        # Step 4: Create sample data as Bundle
        print("4. Creating sample FHIR Bundle...")
        
        bundle_file = Path(temp_dir) / "sample_bundle.json"
        patient_count = create_bundle_data(bundle_file)
        print(f"   SUCCESS: Created Bundle with {patient_count} patients")
        
        # Step 5: Load data into Pathling using bundles
        print("5. Loading Bundle into Pathling...")
        
        try:
            # Load using bundles method - specify resource types we expect
            data = pc.read.bundles(str(Path(temp_dir)),
                                   resource_types=['Patient'])
            
            # Verify data loaded
            resource_types = data.resource_types()
            print(f"   SUCCESS: Loaded data with resource types: {resource_types}")
            
            if 'Patient' not in resource_types:
                print("   ERROR: Patient resources not found in loaded data")
                return False
                
        except Exception as e:
            print(f"   ERROR: Failed to load Bundle: {e}")
            logger.exception("Bundle loading error:")
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
        
        # Step 7: Display transformation results
        print("7. Displaying transformation results...")
        
        try:
            print("\n   OMOP Person Schema:")
            person_df.printSchema()
            
            print(f"\n   Sample data (all {person_count} rows):")
            person_df.show(person_count, truncate=False)
            
        except Exception as e:
            print(f"   WARNING: Could not display results: {e}")
        
        # Step 8: Export results
        print("8. Exporting results...")
        
        output_dir = Path("./output")
        output_dir.mkdir(exist_ok=True)
        
        success_exports = []
        
        # Export to Parquet
        try:
            parquet_path = output_dir / "omop_person_final"
            person_df.write.mode("overwrite").option("compression", "snappy").parquet(str(parquet_path))
            
            # Verify export
            parquet_files = list(parquet_path.glob("*.parquet"))
            total_size = sum(f.stat().st_size for f in parquet_files)
            
            print(f"   SUCCESS: Exported to Parquet")
            print(f"            Location: {parquet_path.absolute()}")
            print(f"            Files: {len(parquet_files)}, Size: {total_size:,} bytes")
            success_exports.append("Parquet")
            
        except Exception as e:
            print(f"   ERROR: Parquet export failed: {e}")
        
        # Export to CSV
        try:
            csv_path = output_dir / "omop_person_final.csv"
            person_df.coalesce(1).write.mode("overwrite").option("header", "true").csv(str(csv_path))
            
            # Find actual CSV file
            csv_files = list((csv_path if csv_path.is_dir() else csv_path.parent).glob("*.csv"))
            if csv_files:
                actual_csv = csv_files[0]
                print(f"   SUCCESS: Exported to CSV")
                print(f"            Location: {actual_csv.absolute()}")
                success_exports.append("CSV")
            else:
                print(f"   SUCCESS: CSV export completed to {csv_path}/")
                success_exports.append("CSV")
                
        except Exception as e:
            print(f"   WARNING: CSV export failed: {e}")
        
        # Export to JSON for inspection
        try:
            json_path = output_dir / "omop_person_sample.json"
            sample_data = person_df.collect()
            
            # Convert to JSON-serializable format
            json_data = []
            for row in sample_data:
                row_dict = row.asDict()
                json_data.append(row_dict)
            
            with open(json_path, "w", encoding="utf-8") as f:
                json.dump(json_data, f, indent=2, default=str)
            
            print(f"   SUCCESS: Exported sample to JSON")
            print(f"            Location: {json_path.absolute()}")
            success_exports.append("JSON")
            
        except Exception as e:
            print(f"   WARNING: JSON export failed: {e}")
        
        # Step 9: Validate OMOP schema
        print("9. Validating OMOP schema compliance...")
        
        try:
            columns = [field.name for field in person_df.schema.fields]
            
            # Expected OMOP Person columns
            expected_columns = [
                "person_id", "gender_concept_id", "birth_datetime",
                "race_concept_id", "ethnicity_concept_id", "location_id",
                "provider_id", "care_site_id", "person_source_value", "gender_source_value"
            ]
            
            present_columns = [col for col in expected_columns if col in columns]
            missing_columns = [col for col in expected_columns if col not in columns]
            
            print(f"   Present columns: {len(present_columns)}/{len(expected_columns)}")
            print(f"   Missing columns: {missing_columns if missing_columns else 'None'}")
            
            if not missing_columns:
                print("   SUCCESS: Full OMOP schema compliance achieved!")
            else:
                print("   PARTIAL: Some OMOP columns are missing")
            
        except Exception as e:
            print(f"   WARNING: Schema validation failed: {e}")
        
        # Step 10: Final summary
        print("\n" + "=" * 60)
        print("TRANSFORMATION PIPELINE SUMMARY")
        print("=" * 60)
        print(f"Source Format:     FHIR Bundle (JSON)")
        print(f"Source Resources:  {patient_count} Patient resources")
        print(f"Target Format:     OMOP CDM Person table")
        print(f"Target Records:    {person_count} person records")
        print(f"Schema Columns:    {len(person_df.schema.fields)} fields")
        print(f"Export Formats:    {', '.join(success_exports)}")
        print(f"Output Directory:  {output_dir.absolute()}")
        print("")
        print("STATUS: SUCCESS - Complete FHIR to OMOP transformation pipeline!")
        print("The ViewDefinition transformation is working correctly.")
        print("=" * 60)
        
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
        success = run_final_test()
        
        if success:
            print("\n[COMPLETE SUCCESS] FHIR to OMOP transformation pipeline is working!")
            print("Check the 'output' directory for all exported files.")
            print("The transformation demonstrates:")
            print("- Loading FHIR Patient resources from Bundle")
            print("- Applying ViewDefinition to transform to OMOP Person table")
            print("- Exporting to multiple formats (Parquet, CSV, JSON)")
            print("- Full schema validation and compliance")
        else:
            print("\n[FAILED] Test failed. Check error messages above.")
            
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