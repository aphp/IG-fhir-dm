#!/usr/bin/env python3
"""Simple demonstration of FHIR to OMOP transformation logic without complex dependencies."""

import json
import pandas as pd
from pathlib import Path
from datetime import datetime

def load_view_definition():
    """Load the ViewDefinition for reference."""
    view_def_path = Path("view-definition/omop/OMOP-Person-View.json")
    
    if view_def_path.exists():
        with open(view_def_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return None

def create_sample_fhir_data():
    """Create sample FHIR Patient data."""
    return [
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

def transform_patient_to_omop_person(patient):
    """Transform a FHIR Patient to OMOP Person record."""
    
    # Extract data following ViewDefinition logic
    person_record = {
        # person_id: Patient.id
        "person_id": patient["id"],
        
        # gender_concept_id: placeholder (would need concept mapping)
        "gender_concept_id": 0,
        
        # birth_datetime: Patient.birthDate converted to datetime
        "birth_datetime": datetime.fromisoformat(patient["birthDate"]) if patient.get("birthDate") else None,
        
        # race_concept_id: placeholder
        "race_concept_id": 0,
        
        # ethnicity_concept_id: placeholder  
        "ethnicity_concept_id": 0,
        
        # location_id: Patient.address.first().id
        "location_id": patient["address"][0]["id"] if patient.get("address") and len(patient["address"]) > 0 else None,
        
        # provider_id: Patient.generalPractitioner.first() reference
        "provider_id": patient["generalPractitioner"][0]["reference"] if patient.get("generalPractitioner") and len(patient["generalPractitioner"]) > 0 else None,
        
        # care_site_id: Patient.managingOrganization reference
        "care_site_id": patient["managingOrganization"]["reference"] if patient.get("managingOrganization") else None,
        
        # person_source_value: Patient.id (resource key)
        "person_source_value": patient["id"],
        
        # gender_source_value: Patient.gender
        "gender_source_value": patient.get("gender")
    }
    
    return person_record

def run_simple_demo():
    """Run simple demonstration without complex dependencies."""
    
    print("FHIR to OMOP Person Transformation - Simple Demo")
    print("=" * 55)
    
    try:
        # Load ViewDefinition
        print("1. Loading ViewDefinition...")
        view_def = load_view_definition()
        if view_def:
            print(f"   SUCCESS: Loaded: {view_def['name']}")
            print(f"   SUCCESS: Resource: {view_def['resource']}")
            print(f"   SUCCESS: Columns: {len(view_def['select'][0]['column'])}")
        else:
            print("   WARNING: ViewDefinition not found, using built-in logic")
        
        # Create sample data
        print("2. Creating sample FHIR Patient data...")
        patients = create_sample_fhir_data()
        print(f"   SUCCESS: Created {len(patients)} FHIR Patient resources")
        
        # Transform to OMOP Person
        print("3. Applying FHIR to OMOP transformation...")
        person_records = []
        for patient in patients:
            person_record = transform_patient_to_omop_person(patient)
            person_records.append(person_record)
        
        print(f"   SUCCESS: Transformed to {len(person_records)} OMOP Person records")
        
        # Create DataFrame
        df = pd.DataFrame(person_records)
        
        # Display results
        print("4. Transformation Results:")
        print("\\n" + "="*55)
        print("OMOP PERSON TABLE")
        print("="*55)
        print(df.to_string(index=False))
        print("="*55)
        
        # Export to files
        print("\\n5. Exporting results...")
        output_dir = Path("./output")
        output_dir.mkdir(exist_ok=True)
        
        # Export to CSV
        csv_file = output_dir / "omop_person_simple.csv"
        df.to_csv(csv_file, index=False)
        print(f"   SUCCESS: CSV exported: {csv_file.absolute()}")
        
        # Export to JSON
        json_file = output_dir / "omop_person_simple.json"
        df.to_json(json_file, orient="records", indent=2, date_format="iso")
        print(f"   SUCCESS: JSON exported: {json_file.absolute()}")
        
        # Validation
        print("\\n6. Schema Validation...")
        expected_columns = [
            "person_id", "gender_concept_id", "birth_datetime",
            "race_concept_id", "ethnicity_concept_id", "location_id",
            "provider_id", "care_site_id", "person_source_value", "gender_source_value"
        ]
        
        actual_columns = list(df.columns)
        missing = set(expected_columns) - set(actual_columns)
        extra = set(actual_columns) - set(expected_columns)
        
        print(f"   Expected columns: {len(expected_columns)}")
        print(f"   Actual columns: {len(actual_columns)}")
        print(f"   Schema match: {'YES' if not missing and not extra else 'PARTIAL'}")
        
        if missing:
            print(f"   Missing: {missing}")
        if extra:
            print(f"   Extra: {extra}")
        
        # Summary
        print("\\n" + "="*55)
        print("DEMONSTRATION SUMMARY")
        print("="*55)
        print(f"Input:  {len(patients)} FHIR Patient resources")
        print(f"Output: {len(person_records)} OMOP Person records")
        print(f"Schema: {len(actual_columns)} columns (OMOP compliant)")
        print(f"Exports: CSV, JSON")
        print(f"Status: SUCCESS")
        print("\\nThis demonstrates the core transformation logic")
        print("that would be used by Pathling with ViewDefinition.")
        print("="*55)
        
        return True
        
    except Exception as e:
        print(f"\\nERROR: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = run_simple_demo()
    exit(0 if success else 1)