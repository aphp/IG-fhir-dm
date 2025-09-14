#!/usr/bin/env python3
"""Test DuckDB 1.3.2 features with OMOP data."""

import duckdb
import json
from pathlib import Path

def test_duckdb_latest_features():
    """Test latest DuckDB features for OMOP data processing."""
    
    print(f"Testing DuckDB version: {duckdb.__version__}")
    print("=" * 50)
    
    # Create in-memory database
    conn = duckdb.connect(':memory:')
    
    # Test 1: Create OMOP Person table with latest DuckDB DDL features
    print("\n1. Creating OMOP Person table with DuckDB 1.3.2...")
    
    create_table_sql = """
    CREATE TABLE person (
        person_id VARCHAR PRIMARY KEY,
        gender_concept_id INTEGER DEFAULT 0,
        year_of_birth INTEGER,
        month_of_birth INTEGER,
        day_of_birth INTEGER,
        birth_datetime TIMESTAMP,
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
    
    conn.execute(create_table_sql)
    print("   SUCCESS: OMOP Person table created successfully")
    
    # Test 2: Insert sample data using modern DuckDB syntax
    print("\n2. Inserting sample OMOP data...")
    
    insert_data_sql = """
    INSERT INTO person VALUES
        ('patient-001', 0, 1980, 1, 15, '1980-01-15 00:00:00', 0, 0, 'addr-001', NULL, 'org-001', 'patient-001', 'male', 0, NULL, 0, NULL, 0),
        ('patient-002', 0, 1990, 6, 20, '1990-06-20 00:00:00', 0, 0, 'addr-002', 'gp-001', NULL, 'patient-002', 'female', 0, NULL, 0, NULL, 0),
        ('patient-003', 0, 1985, 12, 5, '1985-12-05 00:00:00', 0, 0, 'addr-003', 'gp-002', 'org-002', 'patient-003', 'other', 0, NULL, 0, NULL, 0);
    """
    
    conn.execute(insert_data_sql)
    
    # Verify data
    count = conn.execute("SELECT COUNT(*) FROM person").fetchone()[0]
    print(f"   SUCCESS: Inserted {count} person records")
    
    # Test 3: Advanced analytics with DuckDB 1.3.2 features
    print("\n3. Testing advanced DuckDB 1.3.2 analytics...")
    
    # Age calculation with current date functions
    analytics_sql = """
    SELECT 
        person_id,
        gender_source_value,
        birth_datetime,
        EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE)) as current_age,
        CASE 
            WHEN EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE)) < 30 THEN 'Young Adult'
            WHEN EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE)) < 50 THEN 'Adult' 
            ELSE 'Senior'
        END as age_group,
        location_id IS NOT NULL as has_location,
        provider_id IS NOT NULL as has_provider,
        care_site_id IS NOT NULL as has_care_site
    FROM person
    ORDER BY birth_datetime;
    """
    
    results = conn.execute(analytics_sql).fetchall()
    
    print("   Analytics Results:")
    print("   " + "-" * 80)
    print("   ID          Gender    Age   Group        Location  Provider  Care Site")
    print("   " + "-" * 80)
    
    for row in results:
        print(f"   {row[0]:<10} {row[1]:<8} {row[3]:<4} {row[4]:<12} {row[5]:<8} {row[6]:<8} {row[7]}")
    
    # Test 4: Export to modern formats
    print("\n4. Testing modern export capabilities...")
    
    output_dir = Path("./output")
    output_dir.mkdir(exist_ok=True)
    
    # Export to Parquet with compression
    parquet_file = output_dir / "omop_person_duckdb132.parquet"
    conn.execute(f"COPY person TO '{parquet_file}' (FORMAT PARQUET, COMPRESSION SNAPPY)")
    print(f"   SUCCESS: Exported to Parquet: {parquet_file}")
    
    # Export to JSON with pretty formatting
    json_file = output_dir / "omop_person_duckdb132.json"
    json_results = conn.execute("SELECT * FROM person").fetchall()
    
    # Get column names
    columns = [desc[0] for desc in conn.description]
    
    # Convert to JSON
    json_data = []
    for row in json_results:
        record = dict(zip(columns, row))
        # Convert timestamp to string for JSON serialization
        if record['birth_datetime']:
            record['birth_datetime'] = str(record['birth_datetime'])
        json_data.append(record)
    
    with open(json_file, 'w') as f:
        json.dump(json_data, f, indent=2, default=str)
    
    print(f"   SUCCESS: Exported to JSON: {json_file}")
    
    # Test 5: DuckDB 1.3.2 performance features
    print("\n5. Testing performance features...")
    
    # Create index for better performance
    conn.execute("CREATE INDEX idx_person_birth_date ON person(birth_datetime)")
    print("   SUCCESS: Created performance index")
    
    # Query with explain for performance analysis
    explain_result = conn.execute("EXPLAIN SELECT * FROM person WHERE birth_datetime > '1985-01-01'").fetchall()
    print("   SUCCESS: Query optimization analysis completed")
    
    # Test 6: Data quality checks with DuckDB 1.3.2
    print("\n6. Data quality validation...")
    
    quality_checks = [
        ("Null person_id count", "SELECT COUNT(*) FROM person WHERE person_id IS NULL"),
        ("Invalid birth dates", "SELECT COUNT(*) FROM person WHERE birth_datetime > CURRENT_DATE"),
        ("Gender distribution", "SELECT gender_source_value, COUNT(*) FROM person GROUP BY gender_source_value"),
        ("Age statistics", "SELECT MIN(EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE))) as min_age, MAX(EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE))) as max_age, AVG(EXTRACT(year FROM age(CURRENT_DATE, birth_datetime::DATE))) as avg_age FROM person")
    ]
    
    for check_name, query in quality_checks:
        result = conn.execute(query).fetchall()
        print(f"   {check_name}: {result}")
    
    # Close connection
    conn.close()
    
    print("\n" + "=" * 50)
    print("SUCCESS: DuckDB 1.3.2 test completed successfully!")
    print("All modern features working correctly")
    print("=" * 50)
    
    return True

if __name__ == "__main__":
    test_duckdb_latest_features()