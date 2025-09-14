"""Performance tests for large dataset handling."""

import pytest
import time
import json
import random
from pathlib import Path
from datetime import datetime, timedelta
from typing import List, Dict, Any

# Import modules
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    import duckdb
    from duckdb_omop_optimized import DuckDBOMOPProcessor, process_fhir_to_omop_duckdb
    DUCKDB_AVAILABLE = True
except ImportError:
    DUCKDB_AVAILABLE = False


@pytest.fixture
def large_patient_dataset():
    """Generate large patient dataset for performance testing."""
    patients = []
    
    cities = ["Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Nantes", "Strasbourg", "Montpellier"]
    genders = ["male", "female", "other"]
    
    for i in range(1000):  # Generate 1000 patients
        birth_year = random.randint(1940, 2010)
        birth_month = random.randint(1, 12)
        birth_day = random.randint(1, 28)
        
        patient = {
            "resourceType": "Patient",
            "id": f"perf-patient-{i+1:04d}",
            "gender": random.choice(genders),
            "birthDate": f"{birth_year}-{birth_month:02d}-{birth_day:02d}",
            "address": [{
                "id": f"addr-{i+1:04d}",
                "city": random.choice(cities),
                "state": "Test State",
                "country": "France"
            }]
        }
        
        # Add provider reference for some patients
        if random.random() > 0.5:
            patient["generalPractitioner"] = [{
                "reference": f"Practitioner/gp-{random.randint(1, 100):03d}"
            }]
            
        # Add organization reference for some patients
        if random.random() > 0.4:
            patient["managingOrganization"] = {
                "reference": f"Organization/aphp-{random.randint(1, 50):03d}"
            }
            
        patients.append(patient)
        
    return patients


@pytest.mark.performance
@pytest.mark.slow
class TestLargeDatasetPerformance:
    """Performance tests with large datasets."""
    
    def test_large_dataset_processing_time(self, large_patient_dataset):
        """Test processing time for large dataset."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        output_dir = Path("./perf_test_output")
        output_dir.mkdir(exist_ok=True)
        
        # Measure processing time
        start_time = time.time()
        
        result = process_fhir_to_omop_duckdb(
            large_patient_dataset, 
            output_dir,
            database_file=None  # Use in-memory for performance
        )
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        print(f"\nPerformance Results:")
        print(f"Records processed: {result['records_processed']}")
        print(f"Processing time: {processing_time:.2f} seconds")
        print(f"Records per second: {result['records_processed'] / processing_time:.2f}")
        
        # Performance assertions
        assert result['success'] is True
        assert result['records_processed'] == len(large_patient_dataset)
        assert processing_time < 60  # Should complete in under 1 minute
        
        # Cleanup
        import shutil
        shutil.rmtree(output_dir, ignore_errors=True)
        
    def test_memory_usage_large_dataset(self, large_patient_dataset):
        """Test memory usage with large dataset."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        import psutil
        import os
        
        process = psutil.Process(os.getpid())
        
        # Get initial memory usage
        initial_memory = process.memory_info().rss / 1024 / 1024  # MB
        
        output_dir = Path("./perf_test_output")
        output_dir.mkdir(exist_ok=True)
        
        # Process large dataset
        result = process_fhir_to_omop_duckdb(
            large_patient_dataset,
            output_dir,
            database_file=None
        )
        
        # Get peak memory usage
        peak_memory = process.memory_info().rss / 1024 / 1024  # MB
        memory_increase = peak_memory - initial_memory
        
        print(f"\nMemory Usage:")
        print(f"Initial memory: {initial_memory:.2f} MB")
        print(f"Peak memory: {peak_memory:.2f} MB") 
        print(f"Memory increase: {memory_increase:.2f} MB")
        print(f"Memory per record: {memory_increase / len(large_patient_dataset):.3f} MB")
        
        # Memory assertions
        assert result['success'] is True
        assert memory_increase < 2000  # Should not use more than 2GB additional memory
        
        # Cleanup
        import shutil
        shutil.rmtree(output_dir, ignore_errors=True)
        
    def test_concurrent_processing(self, large_patient_dataset):
        """Test concurrent processing of multiple datasets."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        import threading
        import concurrent.futures
        
        # Split dataset into chunks
        chunk_size = 250
        chunks = [
            large_patient_dataset[i:i + chunk_size]
            for i in range(0, len(large_patient_dataset), chunk_size)
        ]
        
        def process_chunk(chunk_data, chunk_id):
            output_dir = Path(f"./perf_test_output_chunk_{chunk_id}")
            output_dir.mkdir(exist_ok=True)
            
            result = process_fhir_to_omop_duckdb(
                chunk_data,
                output_dir,
                database_file=None
            )
            
            return {
                'chunk_id': chunk_id,
                'records_processed': result['records_processed'],
                'success': result['success']
            }
        
        start_time = time.time()
        
        # Process chunks concurrently
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            future_to_chunk = {
                executor.submit(process_chunk, chunk, i): i 
                for i, chunk in enumerate(chunks)
            }
            
            results = []
            for future in concurrent.futures.as_completed(future_to_chunk):
                chunk_id = future_to_chunk[future]
                try:
                    result = future.result()
                    results.append(result)
                except Exception as exc:
                    print(f'Chunk {chunk_id} generated exception: {exc}')
        
        end_time = time.time()
        concurrent_time = end_time - start_time
        
        # Verify results
        total_processed = sum(r['records_processed'] for r in results)
        all_successful = all(r['success'] for r in results)
        
        print(f"\nConcurrent Processing Results:")
        print(f"Chunks processed: {len(results)}")
        print(f"Total records processed: {total_processed}")
        print(f"Processing time: {concurrent_time:.2f} seconds")
        print(f"Records per second: {total_processed / concurrent_time:.2f}")
        
        assert all_successful
        assert total_processed == len(large_patient_dataset)
        assert concurrent_time < 30  # Should be faster with concurrency
        
        # Cleanup
        import shutil
        for i in range(len(chunks)):
            output_dir = Path(f"./perf_test_output_chunk_{i}")
            shutil.rmtree(output_dir, ignore_errors=True)


@pytest.mark.performance
class TestDuckDBQueryPerformance:
    """Test DuckDB query performance."""
    
    def test_analytics_query_performance(self, large_patient_dataset):
        """Test performance of analytics queries."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        processor = DuckDBOMOPProcessor()
        
        try:
            processor.connect()
            processor.create_omop_person_table()
            
            # Insert large dataset
            insert_start = time.time()
            record_count = processor.insert_fhir_patient_data(large_patient_dataset)
            insert_time = time.time() - insert_start
            
            print(f"\nInsert Performance:")
            print(f"Records inserted: {record_count}")
            print(f"Insert time: {insert_time:.2f} seconds")
            print(f"Records per second: {record_count / insert_time:.2f}")
            
            # Test analytics queries
            analytics_start = time.time()
            analytics = processor.get_omop_analytics()
            analytics_time = time.time() - analytics_start
            
            print(f"\nAnalytics Performance:")
            print(f"Analytics time: {analytics_time:.2f} seconds")
            print(f"Total persons: {analytics['basic_stats']['total_persons']}")
            
            # Performance assertions
            assert record_count == len(large_patient_dataset)
            assert insert_time < 30  # Should insert in under 30 seconds
            assert analytics_time < 10  # Analytics should complete quickly
            assert analytics['basic_stats']['total_persons'] == record_count
            
        finally:
            processor.close()
            
    def test_export_performance(self, large_patient_dataset):
        """Test export performance to different formats."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        processor = DuckDBOMOPProcessor()
        output_dir = Path("./perf_export_output")
        output_dir.mkdir(exist_ok=True)
        
        try:
            processor.connect()
            processor.create_omop_person_table()
            processor.insert_fhir_patient_data(large_patient_dataset)
            
            # Test export performance
            export_start = time.time()
            exports = processor.export_to_formats(output_dir)
            export_time = time.time() - export_start
            
            print(f"\nExport Performance:")
            print(f"Export time: {export_time:.2f} seconds")
            print(f"Formats exported: {list(exports.keys())}")
            
            # Verify exports exist
            for format_name, file_path in exports.items():
                file_obj = Path(file_path)
                assert file_obj.exists(), f"Export file missing: {file_path}"
                
                if format_name == 'parquet':
                    assert file_obj.stat().st_size > 0
                elif format_name == 'csv':
                    # Check CSV has header and data
                    with open(file_obj, 'r') as f:
                        lines = f.readlines()
                        assert len(lines) > len(large_patient_dataset)  # Header + data
                        
            assert export_time < 15  # Should export in under 15 seconds
            
        finally:
            processor.close()
            # Cleanup
            import shutil
            shutil.rmtree(output_dir, ignore_errors=True)
            
    def test_index_performance(self, large_patient_dataset):
        """Test index performance impact."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        processor = DuckDBOMOPProcessor()
        
        try:
            processor.connect()
            processor.create_omop_person_table()
            processor.insert_fhir_patient_data(large_patient_dataset)
            
            # Test query performance with indexes
            query_sql = """
            SELECT gender_source_value, COUNT(*) as count
            FROM person 
            WHERE birth_datetime > '1980-01-01'
            GROUP BY gender_source_value
            ORDER BY count DESC
            """
            
            # Execute query multiple times and measure average time
            times = []
            for _ in range(5):
                start_time = time.time()
                result = processor.conn.execute(query_sql).fetchall()
                times.append(time.time() - start_time)
                
            avg_time = sum(times) / len(times)
            
            print(f"\nQuery Performance (with indexes):")
            print(f"Average query time: {avg_time:.4f} seconds")
            print(f"Query result count: {len(result)}")
            
            # Should complete queries quickly with indexes
            assert avg_time < 0.1  # Should be under 100ms with indexes
            assert len(result) > 0
            
        finally:
            processor.close()


@pytest.mark.performance
class TestScalabilityMetrics:
    """Test scalability characteristics."""
    
    @pytest.mark.parametrize("dataset_size", [100, 500, 1000])
    def test_processing_scalability(self, dataset_size):
        """Test how processing time scales with dataset size."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        # Generate dataset of specified size
        patients = []
        for i in range(dataset_size):
            patients.append({
                "resourceType": "Patient",
                "id": f"scale-patient-{i+1:04d}",
                "gender": "male" if i % 2 == 0 else "female",
                "birthDate": f"{1980 + (i % 40)}-01-01"
            })
        
        output_dir = Path(f"./scale_test_{dataset_size}")
        output_dir.mkdir(exist_ok=True)
        
        # Measure processing time
        start_time = time.time()
        result = process_fhir_to_omop_duckdb(patients, output_dir)
        processing_time = time.time() - start_time
        
        records_per_second = dataset_size / processing_time
        
        print(f"\nScalability Test - {dataset_size} records:")
        print(f"Processing time: {processing_time:.2f} seconds")
        print(f"Records per second: {records_per_second:.2f}")
        
        # Store metrics for comparison
        if not hasattr(test_processing_scalability, 'metrics'):
            test_processing_scalability.metrics = {}
        test_processing_scalability.metrics[dataset_size] = {
            'time': processing_time,
            'rps': records_per_second
        }
        
        assert result['success'] is True
        assert result['records_processed'] == dataset_size
        
        # Cleanup
        import shutil
        shutil.rmtree(output_dir, ignore_errors=True)
        
    def test_memory_scalability(self):
        """Test memory usage scaling characteristics."""
        if not DUCKDB_AVAILABLE:
            pytest.skip("DuckDB not available for performance testing")
            
        import psutil
        import os
        
        process = psutil.Process(os.getpid())
        
        dataset_sizes = [100, 500, 1000]
        memory_usage = {}
        
        for size in dataset_sizes:
            # Generate dataset
            patients = []
            for i in range(size):
                patients.append({
                    "resourceType": "Patient",
                    "id": f"mem-patient-{i+1:04d}",
                    "gender": "male" if i % 2 == 0 else "female",
                    "birthDate": f"{1980 + (i % 40)}-01-01"
                })
            
            # Measure memory before processing
            initial_memory = process.memory_info().rss / 1024 / 1024  # MB
            
            # Process data
            output_dir = Path(f"./mem_test_{size}")
            output_dir.mkdir(exist_ok=True)
            
            process_fhir_to_omop_duckdb(patients, output_dir)
            
            # Measure peak memory
            peak_memory = process.memory_info().rss / 1024 / 1024  # MB
            memory_increase = peak_memory - initial_memory
            
            memory_usage[size] = {
                'initial': initial_memory,
                'peak': peak_memory,
                'increase': memory_increase,
                'per_record': memory_increase / size
            }
            
            print(f"\nMemory Scalability - {size} records:")
            print(f"Memory increase: {memory_increase:.2f} MB")
            print(f"Memory per record: {memory_increase / size:.4f} MB")
            
            # Cleanup
            import shutil
            shutil.rmtree(output_dir, ignore_errors=True)
        
        # Verify memory usage scales reasonably
        for size in dataset_sizes:
            # Memory per record should be consistent
            per_record = memory_usage[size]['per_record']
            assert per_record < 1.0  # Should not use more than 1MB per record


# Helper functions for performance testing
def generate_realistic_patient_data(count: int) -> List[Dict[str, Any]]:
    """Generate realistic patient data for performance testing."""
    patients = []
    
    french_cities = [
        "Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Nantes",
        "Strasbourg", "Montpellier", "Bordeaux", "Lille", "Rennes"
    ]
    
    for i in range(count):
        # Generate realistic birth date
        birth_date = datetime(1940, 1, 1) + timedelta(
            days=random.randint(0, (datetime.now() - datetime(1940, 1, 1)).days)
        )
        
        patient = {
            "resourceType": "Patient",
            "id": f"perf-patient-{i+1:06d}",
            "gender": random.choice(["male", "female", "other"]),
            "birthDate": birth_date.strftime("%Y-%m-%d"),
            "address": [{
                "id": f"addr-{i+1:06d}",
                "city": random.choice(french_cities),
                "state": "Test State",
                "country": "France"
            }]
        }
        
        # Add optional references
        if random.random() > 0.6:
            patient["generalPractitioner"] = [{
                "reference": f"Practitioner/gp-{random.randint(1, 200):03d}"
            }]
            
        if random.random() > 0.5:
            patient["managingOrganization"] = {
                "reference": f"Organization/aphp-{random.randint(1, 100):03d}"
            }
            
        patients.append(patient)
        
    return patients


def measure_processing_performance(dataset, iterations=3):
    """Measure processing performance over multiple iterations."""
    times = []
    
    for i in range(iterations):
        output_dir = Path(f"./perf_measure_{i}")
        output_dir.mkdir(exist_ok=True)
        
        start_time = time.time()
        result = process_fhir_to_omop_duckdb(dataset, output_dir)
        end_time = time.time()
        
        times.append(end_time - start_time)
        
        # Cleanup
        import shutil
        shutil.rmtree(output_dir, ignore_errors=True)
    
    return {
        'min_time': min(times),
        'max_time': max(times),
        'avg_time': sum(times) / len(times),
        'records_processed': len(dataset)
    }