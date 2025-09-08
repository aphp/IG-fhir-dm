"""
Test script to validate database and MinIO connections.
"""

import sys
from loguru import logger
from config import settings
from database import DatabaseConnection
from storage import MinIOStorage


def test_database_connection():
    """Test PostgreSQL database connection."""
    logger.info("Testing database connection...")
    
    try:
        db = DatabaseConnection()
        db.connect()
        
        # Test query
        with db.engine.connect() as conn:
            from sqlalchemy import text
            result = conn.execute(text("SELECT version()"))
            version = result.fetchone()[0]
            logger.success(f"Database connected successfully!")
            logger.info(f"PostgreSQL version: {version}")
        
        # List tables
        tables = db.validate_tables(settings.loader.export_tables_list)
        logger.info(f"Found {len(tables)} valid tables:")
        for table in tables:
            count = db.get_table_count(table)
            logger.info(f"  - {table}: {count} records")
        
        db.disconnect()
        return True
        
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return False


def test_minio_connection():
    """Test MinIO S3 connection."""
    logger.info("Testing MinIO connection...")
    
    try:
        storage = MinIOStorage()
        storage.connect()
        
        # Create test bucket
        test_bucket = "test-connection"
        storage.create_bucket(test_bucket)
        logger.success(f"MinIO connected successfully!")
        
        # Test upload
        test_data = [
            {"test": "data1", "id": 1},
            {"test": "data2", "id": 2}
        ]
        
        success = storage.upload_ndjson(test_data, "test.ndjson", test_bucket)
        if success:
            logger.info("Test upload successful")
            
            # Test download
            downloaded = storage.download_ndjson("test.ndjson", test_bucket)
            if len(downloaded) == len(test_data):
                logger.info("Test download successful")
            
            # Clean up
            storage.delete_object("test.ndjson", test_bucket)
            logger.info("Test cleanup successful")
        
        return True
        
    except Exception as e:
        logger.error(f"MinIO connection failed: {e}")
        return False


def test_configuration():
    """Test configuration validation."""
    logger.info("Testing configuration...")
    
    try:
        settings.validate()
        logger.success("Configuration is valid!")
        
        logger.info("Database configuration:")
        logger.info(f"  Host: {settings.database.host}")
        logger.info(f"  Port: {settings.database.port}")
        logger.info(f"  Database: {settings.database.database}")
        logger.info(f"  Schema: {settings.database.schema}")
        
        logger.info("MinIO configuration:")
        logger.info(f"  Endpoint: {settings.minio.endpoint}")
        logger.info(f"  Bucket: {settings.minio.bucket_name}")
        logger.info(f"  Secure: {settings.minio.secure}")
        
        logger.info("Loader configuration:")
        logger.info(f"  Batch size: {settings.loader.batch_size}")
        logger.info(f"  Max workers: {settings.loader.max_workers}")
        logger.info(f"  Output format: {settings.loader.output_format}")
        logger.info(f"  Tables to export: {len(settings.loader.export_tables_list)}")
        
        return True
        
    except Exception as e:
        logger.error(f"Configuration validation failed: {e}")
        return False


def main():
    """Run all connection tests."""
    logger.remove()
    logger.add(sys.stderr, level="INFO", format="<green>{time:HH:mm:ss}</green> | <level>{level: <8}</level> | <level>{message}</level>")
    
    logger.info("=" * 60)
    logger.info("FHIR Data Loader - Connection Test")
    logger.info("=" * 60)
    
    all_tests_passed = True
    
    # Test configuration
    if not test_configuration():
        all_tests_passed = False
        logger.error("Configuration test failed. Please check your .env file.")
    
    logger.info("-" * 60)
    
    # Test database
    if not test_database_connection():
        all_tests_passed = False
        logger.error("Database test failed. Please check your database configuration.")
    
    logger.info("-" * 60)
    
    # Test MinIO
    if not test_minio_connection():
        all_tests_passed = False
        logger.error("MinIO test failed. Please check your MinIO configuration.")
    
    logger.info("=" * 60)
    
    if all_tests_passed:
        logger.success("All tests passed! The system is ready to use.")
        logger.info("Run 'python loader.py' to start the data export.")
    else:
        logger.error("Some tests failed. Please fix the issues before running the loader.")
        sys.exit(1)


if __name__ == "__main__":
    main()