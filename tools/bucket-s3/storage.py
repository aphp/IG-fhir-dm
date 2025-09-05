"""
MinIO S3 storage module for FHIR data.
"""

import io
import json
from typing import List, Dict, Any, Optional
from datetime import datetime
from pathlib import Path
import orjson
from minio import Minio
from minio.error import S3Error
from loguru import logger
from config import settings


class MinIOStorage:
    """Manages MinIO S3 storage operations for FHIR data."""
    
    def __init__(self):
        self.config = settings.minio
        self.client: Optional[Minio] = None
        
    def connect(self) -> None:
        """Establish connection to MinIO server."""
        try:
            self.client = Minio(
                self.config.endpoint,
                access_key=self.config.access_key,
                secret_key=self.config.secret_key,
                secure=self.config.secure
            )
            
            # Test connection by listing buckets
            buckets = self.client.list_buckets()
            logger.info(f"Connected to MinIO at {self.config.endpoint}")
            logger.debug(f"Available buckets: {[b.name for b in buckets]}")
            
        except Exception as e:
            logger.error(f"Failed to connect to MinIO: {e}")
            raise
    
    def create_bucket(self, bucket_name: Optional[str] = None) -> None:
        """
        Create a bucket if it doesn't exist.
        
        Args:
            bucket_name: Name of the bucket to create (uses config default if not provided)
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            if not self.client.bucket_exists(bucket):
                self.client.make_bucket(bucket, location=self.config.region)
                logger.info(f"Created bucket: {bucket}")
            else:
                logger.info(f"Bucket already exists: {bucket}")
                
        except S3Error as e:
            logger.error(f"Failed to create bucket {bucket}: {e}")
            raise
    
    def upload_ndjson(
        self,
        data: List[Dict[str, Any]],
        object_name: str,
        bucket_name: Optional[str] = None
    ) -> bool:
        """
        Upload data as NDJSON (Newline Delimited JSON) to MinIO.
        
        Args:
            data: List of dictionaries to upload
            object_name: Name of the object in the bucket
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            True if successful, False otherwise
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            # Convert to NDJSON format
            ndjson_lines = []
            for item in data:
                # Use orjson for faster JSON serialization
                json_line = orjson.dumps(item).decode('utf-8')
                ndjson_lines.append(json_line)
            
            ndjson_content = '\n'.join(ndjson_lines)
            
            # Create a BytesIO object
            data_stream = io.BytesIO(ndjson_content.encode('utf-8'))
            data_size = len(ndjson_content.encode('utf-8'))
            
            # Upload to MinIO
            self.client.put_object(
                bucket,
                object_name,
                data_stream,
                data_size,
                content_type='application/x-ndjson'
            )
            
            logger.info(f"Uploaded {len(data)} records to {bucket}/{object_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to upload NDJSON to {bucket}/{object_name}: {e}")
            return False
    
    def upload_json(
        self,
        data: Dict[str, Any],
        object_name: str,
        bucket_name: Optional[str] = None
    ) -> bool:
        """
        Upload data as JSON to MinIO.
        
        Args:
            data: Dictionary to upload
            object_name: Name of the object in the bucket
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            True if successful, False otherwise
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            # Convert to JSON
            json_content = orjson.dumps(data, option=orjson.OPT_INDENT_2).decode('utf-8')
            
            # Create a BytesIO object
            data_stream = io.BytesIO(json_content.encode('utf-8'))
            data_size = len(json_content.encode('utf-8'))
            
            # Upload to MinIO
            self.client.put_object(
                bucket,
                object_name,
                data_stream,
                data_size,
                content_type='application/json'
            )
            
            logger.info(f"Uploaded JSON to {bucket}/{object_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to upload JSON to {bucket}/{object_name}: {e}")
            return False
    
    def upload_file(
        self,
        file_path: str,
        object_name: str,
        bucket_name: Optional[str] = None
    ) -> bool:
        """
        Upload a file to MinIO.
        
        Args:
            file_path: Path to the file to upload
            object_name: Name of the object in the bucket
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            True if successful, False otherwise
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            self.client.fput_object(bucket, object_name, file_path)
            logger.info(f"Uploaded file {file_path} to {bucket}/{object_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to upload file {file_path}: {e}")
            return False
    
    def download_ndjson(
        self,
        object_name: str,
        bucket_name: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Download and parse NDJSON data from MinIO.
        
        Args:
            object_name: Name of the object in the bucket
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            List of dictionaries parsed from NDJSON
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            # Download object
            response = self.client.get_object(bucket, object_name)
            content = response.read().decode('utf-8')
            response.close()
            response.release_conn()
            
            # Parse NDJSON
            data = []
            for line in content.strip().split('\n'):
                if line:
                    data.append(orjson.loads(line))
            
            logger.info(f"Downloaded {len(data)} records from {bucket}/{object_name}")
            return data
            
        except Exception as e:
            logger.error(f"Failed to download NDJSON from {bucket}/{object_name}: {e}")
            return []
    
    def list_objects(
        self,
        prefix: Optional[str] = None,
        bucket_name: Optional[str] = None
    ) -> List[str]:
        """
        List objects in a bucket.
        
        Args:
            prefix: Prefix to filter objects
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            List of object names
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            objects = self.client.list_objects(bucket, prefix=prefix)
            object_names = [obj.object_name for obj in objects]
            
            logger.info(f"Found {len(object_names)} objects in {bucket}")
            return object_names
            
        except Exception as e:
            logger.error(f"Failed to list objects in {bucket}: {e}")
            return []
    
    def delete_object(
        self,
        object_name: str,
        bucket_name: Optional[str] = None
    ) -> bool:
        """
        Delete an object from MinIO.
        
        Args:
            object_name: Name of the object to delete
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            True if successful, False otherwise
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            self.client.remove_object(bucket, object_name)
            logger.info(f"Deleted object {bucket}/{object_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to delete object {bucket}/{object_name}: {e}")
            return False
    
    def get_object_info(
        self,
        object_name: str,
        bucket_name: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Get information about an object.
        
        Args:
            object_name: Name of the object
            bucket_name: Name of the bucket (uses config default if not provided)
            
        Returns:
            Dictionary containing object metadata
        """
        bucket = bucket_name or self.config.bucket_name
        
        try:
            stat = self.client.stat_object(bucket, object_name)
            
            return {
                "name": stat.object_name,
                "size": stat.size,
                "etag": stat.etag,
                "content_type": stat.content_type,
                "last_modified": stat.last_modified.isoformat() if stat.last_modified else None,
                "metadata": stat.metadata
            }
            
        except Exception as e:
            logger.error(f"Failed to get info for {bucket}/{object_name}: {e}")
            return {}


class FHIRStorageManager:
    """Manages FHIR-specific storage operations."""
    
    def __init__(self, storage: MinIOStorage):
        self.storage = storage
        
    def store_fhir_resources(
        self,
        resources: List[Dict[str, Any]],
        resource_type: str,
        timestamp: Optional[datetime] = None
    ) -> bool:
        """
        Store FHIR resources with proper naming convention.
        
        Args:
            resources: List of FHIR resource dictionaries
            resource_type: Type of FHIR resource
            timestamp: Timestamp for the export (uses current time if not provided)
            
        Returns:
            True if successful, False otherwise
        """
        if not timestamp:
            timestamp = datetime.now()
        
        # Generate object name with timestamp
        date_str = timestamp.strftime("%Y%m%d_%H%M%S")
        object_name = f"fhir/{resource_type}/{date_str}_{resource_type}.ndjson"
        
        # Upload to storage
        return self.storage.upload_ndjson(resources, object_name)
    
    def store_batch(
        self,
        batch_data: Dict[str, List[Dict[str, Any]]],
        batch_id: str
    ) -> Dict[str, bool]:
        """
        Store a batch of different FHIR resource types.
        
        Args:
            batch_data: Dictionary mapping resource types to lists of resources
            batch_id: Unique identifier for this batch
            
        Returns:
            Dictionary mapping resource types to success status
        """
        results = {}
        timestamp = datetime.now()
        
        for resource_type, resources in batch_data.items():
            if resources:
                success = self.store_fhir_resources(resources, resource_type, timestamp)
                results[resource_type] = success
                
                # Also store a manifest
                if success:
                    manifest = {
                        "batch_id": batch_id,
                        "resource_type": resource_type,
                        "count": len(resources),
                        "timestamp": timestamp.isoformat(),
                        "object_name": f"fhir/{resource_type}/{timestamp.strftime('%Y%m%d_%H%M%S')}_{resource_type}.ndjson"
                    }
                    
                    manifest_name = f"manifests/{batch_id}/{resource_type}_manifest.json"
                    self.storage.upload_json(manifest, manifest_name)
        
        return results
    
    def create_export_summary(
        self,
        export_id: str,
        table_stats: Dict[str, Dict[str, Any]]
    ) -> bool:
        """
        Create and store an export summary.
        
        Args:
            export_id: Unique identifier for this export
            table_stats: Statistics for each exported table
            
        Returns:
            True if successful, False otherwise
        """
        summary = {
            "export_id": export_id,
            "timestamp": datetime.now().isoformat(),
            "tables": table_stats,
            "total_records": sum(stats.get("count", 0) for stats in table_stats.values()),
            "status": "completed"
        }
        
        summary_name = f"exports/{export_id}/summary.json"
        return self.storage.upload_json(summary, summary_name)