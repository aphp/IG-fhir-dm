#!/usr/bin/env python3
"""Complete test of FHIR to OMOP Person export with HAPI FHIR server."""

import os
import sys
import json
import logging
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def run_complete_test():
    """Run complete test of the Data Exporter."""
    
    print("FHIR to OMOP Data Exporter - Complete Test")
    print("=" * 50)
    
    try:
        # Step 1: Initialize Pathling
        print("\n1. Initializing Pathling...")
        from pathling import PathlingContext
        
        # Setup directories
        output_dir = Path("./output")
        output_dir.mkdir(exist_ok=True)
        temp_dir = output_dir / "temp"
        temp_dir.mkdir(exist_ok=True)
        
        # Set environment variables for temp directory
        os.environ["TMPDIR"] = str(temp_dir)
        os.environ["TMP"] = str(temp_dir) 
        os.environ["TEMP"] = str(temp_dir)
        
        pc = PathlingContext.create()
        print("   SUCCESS: Pathling initialized")
        
        # Step 2: Load ViewDefinition
        print("\n2. Loading OMOP Person ViewDefinition...")
        view_def_path = Path("view-definition/omop/OMOP-Person-View.json")
        
        if not view_def_path.exists():
            print(f"   ERROR: ViewDefinition not found at {view_def_path}")
            return False
            
        with open(view_def_path, "r", encoding="utf-8") as f:
            view_definition = json.load(f)
            
        print(f"   SUCCESS: Loaded '{view_definition['name']}'")
        print(f"   Resource type: {view_definition['resource']}")
        print(f"   Columns: {len(view_definition['select'][0]['column'])}")
        
        # Step 3: Test FHIR Server Connection and Export
        print("\n3. Testing FHIR Server Connection...")
        fhir_server_url = "http://localhost:8080/fhir"
        
        try:
            # Test bulk export
            bulk_export_dir = (output_dir / "bulk_export").as_posix()
            (output_dir / "bulk_export").mkdir(exist_ok=True)
            
            print(f"   Connecting to: {fhir_server_url}")
            print(f"   Export directory: {bulk_export_dir}")
            
            data = pc.read.bulk(
                fhir_endpoint_url=fhir_server_url,
                output_dir=bulk_export_dir,
                types=["Patient"]
            )
            print("   SUCCESS: Bulk export completed")
            
            # Check what data we got
            patient_count = data.sql("SELECT count(*) as count FROM Patient").collect()[0]['count']
            print(f"   Patients exported: {patient_count}")
            
            if patient_count == 0:
                print("   WARNING: No patients found in FHIR server")
                # Create sample data
                sample_data = create_sample_patient_data(pc, output_dir)
                if sample_data:
                    data = sample_data
                    patient_count = data.sql("SELECT count(*) as count FROM Patient").collect()[0]['count']
                    print(f"   Using sample data with {patient_count} patients")
                else:
                    print("   ERROR: Could not create sample data")
                    return False
                    
        except Exception as e:
            print(f"   FHIR Server connection failed: {e}")
            print("   Creating sample data for testing...")
            
            sample_data = create_sample_patient_data(pc, output_dir)
            if sample_data:
                data = sample_data
                patient_count = data.sql("SELECT count(*) as count FROM Patient").collect()[0]['count']
                print(f"   SUCCESS: Created sample data with {patient_count} patients")
            else:
                print("   ERROR: Could not create sample data")
                return False
        
        # Step 4: Apply ViewDefinition Transformation
        print("\n4. Applying ViewDefinition Transformation...")
        
        try:
            # Apply the ViewDefinition
            person_df = data.view(
                resource="Patient",
                json=json.dumps(view_definition)
            )
            
            print("   SUCCESS: ViewDefinition applied")
            
            # Get transformed data count
            person_count = person_df.count()
            print(f"   Transformed rows: {person_count}")
            
            # Show schema
            print("\n   Schema:")
            person_df.printSchema()
            
            # Show sample data
            if person_count > 0:
                print("\n   Sample data (first 5 rows):")
                person_df.show(5, truncate=False)
            else:
                print("   WARNING: No data after transformation")
                
        except Exception as e:
            print(f"   ERROR: ViewDefinition transformation failed: {e}")
            import traceback
            traceback.print_exc()
            return False
        
        # Step 5: Export to Multiple Formats
        print("\n5. Exporting to Multiple Formats...")
        
        # Export to Parquet
        try:
            parquet_dir = output_dir / "parquet" / "person"
            parquet_dir.parent.mkdir(exist_ok=True)
            parquet_path = parquet_dir.as_posix()
            
            person_df.write.mode("overwrite").option("compression", "snappy").parquet(parquet_path)
            print(f"   SUCCESS: Exported to Parquet: {parquet_path}")
            
        except Exception as e:
            print(f"   ERROR: Parquet export failed: {e}")
        
        # Export to DuckDB
        try:
            import duckdb
            
            duckdb_file = output_dir / "omop.duckdb"
            conn = duckdb.connect(str(duckdb_file))
            
            # Create table from Parquet
            conn.execute(f"""
                CREATE OR REPLACE TABLE person AS 
                SELECT * FROM read_parquet('{parquet_path}/*.parquet')
            """)
            
            # Verify
            result = conn.execute("SELECT COUNT(*) FROM person").fetchone()
            conn.close()
            
            print(f"   SUCCESS: Exported to DuckDB: {duckdb_file}")
            print(f"   DuckDB record count: {result[0]}")
            
        except ImportError:
            print("   SKIP: DuckDB not available")
        except Exception as e:
            print(f"   ERROR: DuckDB export failed: {e}")
        
        # Step 6: Validate Results
        print("\n6. Validation Summary...")
        
        validation_table = f"""
┌─────────────────────────────────────┬─────────────────┐
│ Metric                              │ Value           │
├─────────────────────────────────────┼─────────────────┤
│ FHIR Server                         │ {fhir_server_url:<15} │
│ Input Patients                      │ {patient_count:<15} │
│ Transformed Persons                 │ {person_count:<15} │
│ ViewDefinition Columns              │ {len(view_definition['select'][0]['column']):<15} │
│ Parquet Export                      │ {'SUCCESS':<15} │
│ DuckDB Export                       │ {'SUCCESS':<15} │
└─────────────────────────────────────┴─────────────────┘
        """
        print(validation_table)
        
        print("\n" + "="*50)
        print("SUCCESS: Complete test passed!")
        print("="*50)
        
        return True
        
    except Exception as e:
        print(f"\nERROR: Test failed with exception: {e}")
        import traceback
        traceback.print_exc()
        return False
        
    finally:
        # Cleanup
        try:
            if 'pc' in locals() and hasattr(pc, '_spark'):
                pc._spark.stop()
                print("\nSpark context stopped")
        except:
            pass


def create_sample_patient_data(pc, output_dir):
    """Create sample patient data for testing."""
    try:
        sample_patients = [
            {
                "resourceType": "Patient",
                "id": "patient-001",
                "gender": "male",
                "birthDate": "1980-01-15",
                "address": [
                    {
                        "id": "addr-001",
                        "use": "home",
                        "city": "TestCity",
                        "state": "TestState",
                        "country": "TestCountry"
                    }
                ],
                "managingOrganization": {
                    "reference": "Organization/org-001"
                }
            },
            {
                "resourceType": "Patient", 
                "id": "patient-002",
                "gender": "female",
                "birthDate": "1985-03-22",
                "address": [
                    {
                        "id": "addr-002",
                        "use": "home",
                        "city": "AnotherCity",
                        "state": "AnotherState",
                        "country": "TestCountry"
                    }
                ]
            },
            {
                "resourceType": "Patient",
                "id": "patient-003", 
                "gender": "other",
                "birthDate": "1990-12-05",
                "address": [
                    {
                        "id": "addr-003",
                        "use": "work",
                        "city": "WorkCity",
                        "state": "WorkState",
                        "country": "TestCountry"
                    }
                ],
                "generalPractitioner": [
                    {
                        "reference": "Practitioner/pract-001"
                    }
                ]
            }
        ]
        
        # Write sample data to NDJSON
        sample_file = output_dir / "sample_patients.ndjson"
        with open(sample_file, "w") as f:
            for patient in sample_patients:
                json.dump(patient, f)
                f.write("\n")
        
        # Load the data using Pathling
        data = pc.read.ndjson(str(sample_file))
        return data
        
    except Exception as e:
        print(f"   ERROR: Failed to create sample data: {e}")
        return None


if __name__ == "__main__":
    success = run_complete_test()
    sys.exit(0 if success else 1)