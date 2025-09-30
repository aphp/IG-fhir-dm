#!/usr/bin/env python3
"""
Optimized DuckDB 1.3.2 integration for OMOP data export.

This module leverages the latest DuckDB 1.3.2 features for efficient OMOP data processing,
including improved analytics functions, better JSON support, and enhanced performance.
"""

import duckdb
import json
from pathlib import Path
from typing import Dict, Any, List, Optional
from datetime import datetime
import pandas as pd


class DuckDBOMOPProcessor:
    """Enhanced DuckDB processor for OMOP data using version 1.3.2 features."""
    
    def __init__(self, database_path: Optional[str] = None):
        """Initialize DuckDB processor.
        
        Args:
            database_path: Path to DuckDB file, or None for in-memory database
        """
        self.database_path = database_path or ":memory:"
        self.conn = None
        self.tables_created = set()
        
    def connect(self) -> None:
        """Connect to DuckDB database."""
        self.conn = duckdb.connect(self.database_path)
        
        # Configure DuckDB 1.3.2 settings for optimal OMOP processing
        self.conn.execute("SET memory_limit='4GB'")
        self.conn.execute("SET threads=4")
        try:
            self.conn.execute("SET enable_progress_bar=false")
        except:
            pass  # Not all versions support this setting
        # Disable profiling for cleaner output
        # self.conn.execute("SET enable_profiling='no_output'")
        
        print(f"Connected to DuckDB {duckdb.__version__}")
        
    def create_omop_person_table(self, drop_if_exists: bool = True) -> None:
        """Create OMOP Person table with DuckDB 1.3.2 optimizations."""
        if not self.conn:
            self.connect()
            
        if drop_if_exists:
            self.conn.execute("DROP TABLE IF EXISTS person")
            
        # Enhanced OMOP Person table with proper indexing and constraints
        create_sql = """
        CREATE TABLE person (
            person_id INTEGER PRIMARY KEY,
            gender_concept_id INTEGER DEFAULT 0,
            year_of_birth INTEGER,
            month_of_birth INTEGER,
            day_of_birth INTEGER,
            birth_datetime TIMESTAMP,
            death_datetime TIMESTAMP,
            race_concept_id INTEGER DEFAULT 0,
            ethnicity_concept_id INTEGER DEFAULT 0,
            location_id VARCHAR,
            provider_id VARCHAR,
            care_site_id VARCHAR,
            person_source_value VARCHAR,
            gender_source_value VARCHAR,
            gender_source_concept_id INTEGER DEFAULT 0,
            race_source_value VARCHAR,
            race_source_concept_id INTEGER DEFAULT 0,
            ethnicity_source_value VARCHAR,
            ethnicity_source_concept_id INTEGER DEFAULT 0
        );
        """
        
        self.conn.execute(create_sql)
        
        # Create optimized indexes for common OMOP queries
        indexes = [
            "CREATE INDEX idx_person_birth_date ON person(birth_datetime)",
            "CREATE INDEX idx_person_gender ON person(gender_concept_id)",
            "CREATE INDEX idx_person_location ON person(location_id)",
            "CREATE INDEX idx_person_provider ON person(provider_id)",
            "CREATE INDEX idx_person_care_site ON person(care_site_id)"
        ]
        
        for index_sql in indexes:
            self.conn.execute(index_sql)
            
        # Create view with computed columns using DuckDB 1.3.2 features
        view_sql = """
        CREATE OR REPLACE VIEW person_analytics AS
        SELECT *,
            CASE WHEN birth_datetime IS NOT NULL 
                 THEN EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE))
                 ELSE NULL 
            END as current_age,
            CASE 
                WHEN birth_datetime IS NULL THEN 'Unknown'
                WHEN EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE)) < 18 THEN 'Pediatric'
                WHEN EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE)) < 65 THEN 'Adult'
                ELSE 'Senior'
            END as age_group
        FROM person;
        """
        self.conn.execute(view_sql)
        
        self.tables_created.add('person')
        print("SUCCESS: OMOP Person table created with DuckDB 1.3.2 optimizations")
        
    def insert_fhir_patient_data(self, patient_data: List[Dict[str, Any]]) -> int:
        """Insert FHIR Patient data into OMOP Person table.
        
        Args:
            patient_data: List of FHIR Patient resources as dictionaries
            
        Returns:
            Number of records inserted
        """
        if not self.conn:
            self.connect()
            
        if 'person' not in self.tables_created:
            self.create_omop_person_table()
            
        insert_count = 0
        
        for patient in patient_data:
            # Extract OMOP Person data from FHIR Patient
            person_record = self._transform_patient_to_person(patient)
            
            # Use DuckDB 1.3.2's enhanced INSERT syntax
            insert_sql = """
            INSERT INTO person (
                person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth,
                birth_datetime, race_concept_id, ethnicity_concept_id, location_id,
                provider_id, care_site_id, person_source_value, gender_source_value,
                gender_source_concept_id, race_source_concept_id, ethnicity_source_concept_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT (person_id) DO UPDATE SET
                gender_concept_id = EXCLUDED.gender_concept_id,
                birth_datetime = EXCLUDED.birth_datetime,
                gender_source_value = EXCLUDED.gender_source_value
            """
            
            self.conn.execute(insert_sql, [
                person_record['person_id'],
                person_record.get('gender_concept_id', 0),
                person_record.get('year_of_birth'),
                person_record.get('month_of_birth'),
                person_record.get('day_of_birth'),
                person_record.get('birth_datetime'),
                person_record.get('race_concept_id', 0),
                person_record.get('ethnicity_concept_id', 0),
                person_record.get('location_id'),
                person_record.get('provider_id'),
                person_record.get('care_site_id'),
                person_record.get('person_source_value'),
                person_record.get('gender_source_value'),
                person_record.get('gender_source_concept_id', 0),
                person_record.get('race_source_concept_id', 0),
                person_record.get('ethnicity_source_concept_id', 0)
            ])
            
            insert_count += 1
            
        print(f"SUCCESS: Inserted {insert_count} person records")
        return insert_count
        
    def _transform_patient_to_person(self, patient: Dict[str, Any]) -> Dict[str, Any]:
        """Transform FHIR Patient to OMOP Person record."""
        # Convert FHIR Patient ID to integer using hash for OMOP compatibility
        patient_id_str = patient.get('id', '')
        person_id = abs(hash(patient_id_str)) % (2**31)  # Ensure positive 32-bit int

        person = {
            'person_id': person_id,
            'person_source_value': patient.get('id'),
            'gender_source_value': patient.get('gender'),
            'gender_concept_id': 0,  # Would need concept mapping
            'race_concept_id': 0,
            'ethnicity_concept_id': 0,
            'gender_source_concept_id': 0,
            'race_source_concept_id': 0,
            'ethnicity_source_concept_id': 0
        }
        
        # Parse birth date
        if 'birthDate' in patient:
            birth_date = patient['birthDate']
            try:
                from datetime import datetime
                dt = datetime.fromisoformat(birth_date)
                person.update({
                    'birth_datetime': dt.strftime('%Y-%m-%d %H:%M:%S'),
                    'year_of_birth': dt.year,
                    'month_of_birth': dt.month,
                    'day_of_birth': dt.day
                })
            except ValueError:
                pass
                
        # Extract address information
        if 'address' in patient and patient['address']:
            addr = patient['address'][0]
            person['location_id'] = addr.get('id')
            
        # Extract provider information
        if 'generalPractitioner' in patient and patient['generalPractitioner']:
            gp = patient['generalPractitioner'][0]
            if 'reference' in gp:
                person['provider_id'] = gp['reference']
                
        # Extract organization information
        if 'managingOrganization' in patient and 'reference' in patient['managingOrganization']:
            person['care_site_id'] = patient['managingOrganization']['reference']
            
        return person
        
    def get_omop_analytics(self) -> Dict[str, Any]:
        """Generate OMOP analytics using DuckDB 1.3.2 advanced features."""
        if not self.conn:
            self.connect()
            
        analytics = {}
        
        # Basic statistics using the analytics view
        stats_sql = """
        SELECT 
            COUNT(*) as total_persons,
            COUNT(DISTINCT gender_source_value) as unique_genders,
            COUNT(DISTINCT location_id) as unique_locations,
            COUNT(DISTINCT provider_id) as unique_providers,
            COUNT(DISTINCT care_site_id) as unique_care_sites,
            MIN(birth_datetime) as earliest_birth,
            MAX(birth_datetime) as latest_birth,
            AVG(current_age) as avg_age,
            MIN(current_age) as min_age,
            MAX(current_age) as max_age
        FROM person_analytics
        """
        
        stats = self.conn.execute(stats_sql).fetchone()
        analytics['basic_stats'] = dict(zip([desc[0] for desc in self.conn.description], stats))
        
        # Gender distribution
        gender_sql = """
        SELECT gender_source_value, COUNT(*) as count, 
               ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percentage
        FROM person 
        GROUP BY gender_source_value 
        ORDER BY count DESC
        """
        
        analytics['gender_distribution'] = [
            dict(zip([desc[0] for desc in self.conn.description], row))
            for row in self.conn.execute(gender_sql).fetchall()
        ]
        
        # Age group distribution
        age_group_sql = """
        SELECT age_group, COUNT(*) as count,
               ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percentage
        FROM person_analytics 
        GROUP BY age_group 
        ORDER BY count DESC
        """
        
        analytics['age_group_distribution'] = [
            dict(zip([desc[0] for desc in self.conn.description], row))
            for row in self.conn.execute(age_group_sql).fetchall()
        ]
        
        # Data completeness analysis
        completeness_sql = """
        SELECT 
            'person_id' as field, COUNT(person_id) as non_null_count, 
            100.0 - (100.0 * COUNT(person_id) / COUNT(*)) as null_percentage
        FROM person
        UNION ALL
        SELECT 'birth_datetime', COUNT(birth_datetime), 
               100.0 - (100.0 * COUNT(birth_datetime) / COUNT(*)) FROM person
        UNION ALL  
        SELECT 'location_id', COUNT(location_id),
               100.0 - (100.0 * COUNT(location_id) / COUNT(*)) FROM person
        UNION ALL
        SELECT 'provider_id', COUNT(provider_id),
               100.0 - (100.0 * COUNT(provider_id) / COUNT(*)) FROM person
        UNION ALL
        SELECT 'care_site_id', COUNT(care_site_id),
               100.0 - (100.0 * COUNT(care_site_id) / COUNT(*)) FROM person
        """
        
        analytics['data_completeness'] = [
            dict(zip([desc[0] for desc in self.conn.description], row))
            for row in self.conn.execute(completeness_sql).fetchall()
        ]
        
        return analytics
        
    def export_to_formats(self, output_dir: Path) -> Dict[str, str]:
        """Export OMOP data to multiple formats using DuckDB 1.3.2 features."""
        if not self.conn:
            self.connect()
            
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        exports = {}
        
        # Export to Parquet with compression
        parquet_file = output_dir / "omop_person_duckdb132.parquet"
        self.conn.execute(f"""
            COPY person TO '{parquet_file}' 
            (FORMAT PARQUET, COMPRESSION SNAPPY, ROW_GROUP_SIZE 100000)
        """)
        exports['parquet'] = str(parquet_file)
        
        # Export to CSV with headers
        csv_file = output_dir / "omop_person_duckdb132.csv"
        self.conn.execute(f"""
            COPY person TO '{csv_file}' 
            (FORMAT CSV, HEADER, DELIMITER ',')
        """)
        exports['csv'] = str(csv_file)
        
        # Export to JSON with pretty formatting
        json_data = self.conn.execute("SELECT * FROM person ORDER BY person_id").fetchall()
        columns = [desc[0] for desc in self.conn.description]
        
        json_records = []
        for row in json_data:
            record = dict(zip(columns, row))
            # Convert timestamp to string
            for key, value in record.items():
                if isinstance(value, datetime):
                    record[key] = value.isoformat()
                elif value is None:
                    record[key] = None
            json_records.append(record)
            
        json_file = output_dir / "omop_person_duckdb132.json"
        with open(json_file, 'w') as f:
            json.dump(json_records, f, indent=2, default=str)
        exports['json'] = str(json_file)
        
        # Export analytics to JSON
        analytics = self.get_omop_analytics()
        analytics_file = output_dir / "omop_analytics_duckdb132.json"
        with open(analytics_file, 'w') as f:
            json.dump(analytics, f, indent=2, default=str)
        exports['analytics'] = str(analytics_file)
        
        return exports
        
    def close(self) -> None:
        """Close DuckDB connection."""
        if self.conn:
            self.conn.close()
            self.conn = None
            print("DuckDB connection closed")


# Convenience function for quick OMOP processing
def process_fhir_to_omop_duckdb(
    patient_data: List[Dict[str, Any]], 
    output_dir: Path,
    database_file: Optional[str] = None
) -> Dict[str, Any]:
    """Process FHIR Patient data to OMOP format using DuckDB 1.3.2.
    
    Args:
        patient_data: List of FHIR Patient resources
        output_dir: Output directory for exports
        database_file: Optional DuckDB file path
        
    Returns:
        Processing results and export file paths
    """
    
    processor = DuckDBOMOPProcessor(database_file)
    
    try:
        processor.connect()
        
        # Create and populate OMOP Person table
        processor.create_omop_person_table()
        record_count = processor.insert_fhir_patient_data(patient_data)
        
        # Generate analytics
        analytics = processor.get_omop_analytics()
        
        # Export to multiple formats
        exports = processor.export_to_formats(output_dir)
        
        return {
            'success': True,
            'records_processed': record_count,
            'analytics': analytics,
            'exports': exports,
            'duckdb_version': duckdb.__version__
        }
        
    finally:
        processor.close()


if __name__ == "__main__":
    # Demo with sample data
    sample_patients = [
        {
            "resourceType": "Patient",
            "id": "patient-001",
            "gender": "male", 
            "birthDate": "1980-01-15",
            "address": [{"id": "addr-001", "city": "Paris"}],
            "managingOrganization": {"reference": "Organization/aphp-001"}
        },
        {
            "resourceType": "Patient",
            "id": "patient-002", 
            "gender": "female",
            "birthDate": "1990-06-20",
            "address": [{"id": "addr-002", "city": "Lyon"}],
            "generalPractitioner": [{"reference": "Practitioner/gp-001"}]
        },
        {
            "resourceType": "Patient",
            "id": "patient-003",
            "gender": "other",
            "birthDate": "1985-12-05",
            "address": [{"id": "addr-003", "city": "Marseille"}],
            "generalPractitioner": [{"reference": "Practitioner/gp-002"}],
            "managingOrganization": {"reference": "Organization/aphp-002"}
        }
    ]
    
    output_path = Path("./output")
    result = process_fhir_to_omop_duckdb(sample_patients, output_path)
    
    print("\n" + "="*60)
    print("FHIR to OMOP Processing with DuckDB 1.3.2")
    print("="*60)
    print(f"Records processed: {result['records_processed']}")
    print(f"DuckDB version: {result['duckdb_version']}")
    print("\nExported files:")
    for format_name, file_path in result['exports'].items():
        print(f"  {format_name}: {file_path}")
    
    print(f"\nBasic Statistics:")
    stats = result['analytics']['basic_stats']
    for key, value in stats.items():
        print(f"  {key}: {value}")