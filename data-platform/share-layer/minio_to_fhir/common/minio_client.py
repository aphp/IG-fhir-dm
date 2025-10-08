"""
MinIO client wrapper with common operations.
"""

from minio import Minio
from minio.error import S3Error
from pathlib import Path
from typing import List, Dict, Optional
import sys

class MinIOClientWrapper:
    """Wrapper for MinIO client with common operations."""

    def __init__(self, endpoint: str, access_key: str, secret_key: str,
                 secure: bool = False):
        """
        Initialize MinIO client.

        Args:
            endpoint: MinIO endpoint (e.g., 'localhost:9000')
            access_key: MinIO access key
            secret_key: MinIO secret key
            secure: Use HTTPS
        """
        self.client = Minio(
            endpoint,
            access_key=access_key,
            secret_key=secret_key,
            secure=secure
        )
        self.endpoint = endpoint

    def test_connection(self, bucket_name: str) -> bool:
        """
        Test connection to MinIO and check bucket exists.

        Args:
            bucket_name: Bucket name to test

        Returns:
            True if connection successful and bucket exists
        """
        try:
            if not self.client.bucket_exists(bucket_name):
                print(f"❌ Error: Bucket '{bucket_name}' does not exist")
                return False
            return True
        except S3Error as e:
            print(f"❌ MinIO connection error: {e}")
            return False
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            return False

    def list_ndjson_files(self, bucket_name: str) -> List[str]:
        """
        List all NDJSON files in bucket.

        Args:
            bucket_name: Bucket name

        Returns:
            List of NDJSON filenames
        """
        try:
            objects = self.client.list_objects(bucket_name)
            ndjson_files = [
                obj.object_name
                for obj in objects
                if obj.object_name.endswith('.ndjson')
            ]
            return ndjson_files
        except S3Error as e:
            print(f"❌ Error listing files: {e}")
            return []

    def list_ndjson_files_with_details(self, bucket_name: str) -> List[Dict]:
        """
        List all NDJSON files in bucket with metadata.

        Args:
            bucket_name: Bucket name

        Returns:
            List of dicts with file details (name, size, last_modified)
        """
        try:
            objects = self.client.list_objects(bucket_name)
            ndjson_files = []
            for obj in objects:
                if obj.object_name.endswith('.ndjson'):
                    ndjson_files.append({
                        'name': obj.object_name,
                        'size': obj.size,
                        'last_modified': obj.last_modified
                    })
            return ndjson_files
        except S3Error as e:
            print(f"❌ Error listing files: {e}")
            return []

    def download_file(self, bucket_name: str, object_name: str,
                     local_path: Path) -> bool:
        """
        Download file from MinIO.

        Args:
            bucket_name: Bucket name
            object_name: Object name in bucket
            local_path: Local destination path

        Returns:
            True if download successful
        """
        try:
            # Create parent directory if needed
            local_path.parent.mkdir(parents=True, exist_ok=True)

            # Download file
            self.client.fget_object(bucket_name, object_name, str(local_path))
            return True
        except S3Error as e:
            print(f"❌ Error downloading {object_name}: {e}")
            return False
