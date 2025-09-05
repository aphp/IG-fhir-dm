"""
Main FHIR data loader script.
Transfers data from PostgreSQL FHIR Semantic Layer to MinIO S3 storage in NDJSON format.
"""

import sys
import asyncio
from typing import Dict, List, Any, Optional
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import uuid
from tqdm import tqdm
from loguru import logger

from config import settings
from database import DatabaseConnection, FHIRDataExtractor
from storage import MinIOStorage, FHIRStorageManager
from transformer import FHIRTransformer


class FHIRDataLoader:
    """Main loader class for transferring FHIR data to S3."""
    
    def __init__(self):
        self.config = settings
        self.db = DatabaseConnection()
        self.storage = MinIOStorage()
        self.transformer = FHIRTransformer()
        self.fhir_extractor = None
        self.fhir_storage = None
        self.export_id = None
        self.stats = {}
        
    def initialize(self) -> bool:
        """Initialize all connections and validate configuration."""
        try:
            # Validate configuration
            self.config.validate()
            
            # Set up logging
            self._setup_logging()
            
            # Connect to database
            logger.info("Connecting to PostgreSQL database...")
            self.db.connect()
            
            # Connect to MinIO
            logger.info("Connecting to MinIO storage...")
            self.storage.connect()
            
            # Create bucket if needed
            self.storage.create_bucket()
            
            # Initialize specialized handlers
            self.fhir_extractor = FHIRDataExtractor(self.db)
            self.fhir_storage = FHIRStorageManager(self.storage)
            
            # Generate export ID
            self.export_id = datetime.now().strftime("%Y%m%d_%H%M%S") + "_" + str(uuid.uuid4())[:8]
            
            logger.info(f"Initialization complete. Export ID: {self.export_id}")
            return True
            
        except Exception as e:
            logger.error(f"Initialization failed: {e}")
            return False
    
    def _setup_logging(self):
        """Configure logging based on settings."""
        logger.remove()  # Remove default handler
        
        # Add console handler
        logger.add(
            sys.stderr,
            level=self.config.loader.log_level,
            format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan> - <level>{message}</level>"
        )
        
        # Add file handler
        log_file = f"logs/loader_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        logger.add(
            log_file,
            level="DEBUG",
            rotation="500 MB",
            retention="7 days"
        )
    
    def load_table(self, table_name: str) -> Dict[str, Any]:
        """
        Load data from a single table to S3.
        
        Args:
            table_name: Name of the table to load
            
        Returns:
            Statistics dictionary for the table
        """
        stats = {
            "table": table_name,
            "start_time": datetime.now().isoformat(),
            "records_processed": 0,
            "batches_processed": 0,
            "errors": []
        }
        
        try:
            # Get resource type
            resource_type = self.transformer.TABLE_TO_RESOURCE.get(table_name, table_name)
            
            # Get total count for progress bar
            total_count = self.db.get_table_count(table_name)
            stats["total_records"] = total_count
            
            logger.info(f"Loading {table_name} ({total_count} records)...")
            
            # Create progress bar
            with tqdm(total=total_count, desc=f"Loading {table_name}", unit="records") as pbar:
                
                # Process data in batches
                for batch in self.db.extract_table_data(
                    table_name,
                    batch_size=self.config.loader.batch_size
                ):
                    try:
                        # Transform batch to FHIR format
                        fhir_batch = self.transformer.transform_batch(batch, table_name)
                        
                        # Generate filename with timestamp and batch number
                        timestamp = datetime.now()
                        batch_num = stats["batches_processed"]
                        object_name = f"fhir/{resource_type}/{self.export_id}/{resource_type}_{batch_num:04d}.ndjson"
                        
                        # Upload to S3
                        if self.config.loader.output_format == "ndjson":
                            success = self.storage.upload_ndjson(fhir_batch, object_name)
                        else:
                            # For JSON format, wrap in a bundle
                            bundle = {
                                "resourceType": "Bundle",
                                "type": "collection",
                                "entry": [{"resource": r} for r in fhir_batch]
                            }
                            object_name = object_name.replace(".ndjson", ".json")
                            success = self.storage.upload_json(bundle, object_name)
                        
                        if success:
                            stats["records_processed"] += len(batch)
                            stats["batches_processed"] += 1
                            pbar.update(len(batch))
                        else:
                            error_msg = f"Failed to upload batch {batch_num} for {table_name}"
                            stats["errors"].append(error_msg)
                            logger.error(error_msg)
                    
                    except Exception as e:
                        error_msg = f"Error processing batch for {table_name}: {e}"
                        stats["errors"].append(error_msg)
                        logger.error(error_msg)
            
            stats["end_time"] = datetime.now().isoformat()
            stats["status"] = "completed" if not stats["errors"] else "completed_with_errors"
            
            logger.info(f"Completed loading {table_name}: {stats['records_processed']}/{total_count} records")
            
        except Exception as e:
            stats["end_time"] = datetime.now().isoformat()
            stats["status"] = "failed"
            stats["errors"].append(str(e))
            logger.error(f"Failed to load {table_name}: {e}")
        
        return stats
    
    def load_all_tables(self) -> Dict[str, Dict[str, Any]]:
        """
        Load all configured tables to S3.
        
        Returns:
            Dictionary of statistics for all tables
        """
        # Validate tables exist
        valid_tables = self.db.validate_tables(self.config.loader.export_tables_list)
        
        if not valid_tables:
            logger.error("No valid tables found to export")
            return {}
        
        logger.info(f"Starting export of {len(valid_tables)} tables")
        
        all_stats = {}
        
        # Use ThreadPoolExecutor for parallel loading
        with ThreadPoolExecutor(max_workers=self.config.loader.max_workers) as executor:
            # Submit all tasks
            future_to_table = {
                executor.submit(self.load_table, table): table
                for table in valid_tables
            }
            
            # Process completed tasks
            for future in as_completed(future_to_table):
                table = future_to_table[future]
                try:
                    stats = future.result()
                    all_stats[table] = stats
                except Exception as e:
                    logger.error(f"Exception loading {table}: {e}")
                    all_stats[table] = {
                        "table": table,
                        "status": "failed",
                        "error": str(e)
                    }
        
        return all_stats
    
    def create_export_summary(self, table_stats: Dict[str, Dict[str, Any]]) -> bool:
        """
        Create and upload export summary.
        
        Args:
            table_stats: Statistics for all exported tables
            
        Returns:
            True if successful
        """
        try:
            summary = {
                "export_id": self.export_id,
                "timestamp": datetime.now().isoformat(),
                "configuration": {
                    "database": {
                        "host": self.config.database.host,
                        "database": self.config.database.database,
                        "schema": self.config.database.schema
                    },
                    "storage": {
                        "endpoint": self.config.minio.endpoint,
                        "bucket": self.config.minio.bucket_name
                    },
                    "loader": {
                        "batch_size": self.config.loader.batch_size,
                        "output_format": self.config.loader.output_format
                    }
                },
                "tables": table_stats,
                "summary": {
                    "total_tables": len(table_stats),
                    "successful_tables": sum(1 for s in table_stats.values() if s.get("status") != "failed"),
                    "failed_tables": sum(1 for s in table_stats.values() if s.get("status") == "failed"),
                    "total_records": sum(s.get("records_processed", 0) for s in table_stats.values()),
                    "total_errors": sum(len(s.get("errors", [])) for s in table_stats.values())
                }
            }
            
            # Upload summary
            summary_path = f"exports/{self.export_id}/summary.json"
            success = self.storage.upload_json(summary, summary_path)
            
            if success:
                logger.info(f"Export summary uploaded to {summary_path}")
            
            return success
            
        except Exception as e:
            logger.error(f"Failed to create export summary: {e}")
            return False
    
    def cleanup(self):
        """Clean up connections."""
        try:
            if self.db:
                self.db.disconnect()
            
            logger.info("Cleanup complete")
            
        except Exception as e:
            logger.error(f"Error during cleanup: {e}")
    
    def run(self) -> bool:
        """
        Run the complete data loading process.
        
        Returns:
            True if successful
        """
        try:
            # Initialize
            if not self.initialize():
                return False
            
            # Load all tables
            logger.info("Starting data export...")
            start_time = datetime.now()
            
            table_stats = self.load_all_tables()
            
            # Create summary
            self.create_export_summary(table_stats)
            
            # Calculate duration
            duration = (datetime.now() - start_time).total_seconds()
            
            # Print summary
            logger.info("=" * 60)
            logger.info("EXPORT SUMMARY")
            logger.info("=" * 60)
            logger.info(f"Export ID: {self.export_id}")
            logger.info(f"Duration: {duration:.2f} seconds")
            logger.info(f"Tables processed: {len(table_stats)}")
            
            total_records = sum(s.get("records_processed", 0) for s in table_stats.values())
            logger.info(f"Total records exported: {total_records}")
            
            failed_tables = [t for t, s in table_stats.items() if s.get("status") == "failed"]
            if failed_tables:
                logger.warning(f"Failed tables: {failed_tables}")
            
            logger.info("=" * 60)
            
            return len(failed_tables) == 0
            
        except Exception as e:
            logger.error(f"Export failed: {e}")
            return False
        
        finally:
            self.cleanup()


def main():
    """Main entry point."""
    loader = FHIRDataLoader()
    success = loader.run()
    
    if success:
        logger.info("Export completed successfully")
        sys.exit(0)
    else:
        logger.error("Export completed with errors")
        sys.exit(1)


if __name__ == "__main__":
    main()