"""
Configuration management for MinIO to FHIR pipeline.
Loads and validates environment variables.
"""

import os
from pathlib import Path
from dotenv import load_dotenv
from typing import Dict, Optional

class Config:
    """Configuration manager for the pipeline."""

    # FHIR resource loading order (maintains referential integrity)
    RESOURCE_ORDER = [
        'Organization',      # Step 1
        'Location',          # Step 2
        'Patient',           # Step 3
        'Encounter',         # Step 4
        'Condition',         # Step 5
        'Observation',       # Step 6
        'Procedure',         # Step 7
        'Medication',        # Step 8
        'Specimen',          # Step 9
        'MedicationRequest', # Step 10
        'MedicationDispense', # Step 11
        ['MedicationStatement', 'MedicationAdministration']  # Step 12 (grouped)
    ]

    def __init__(self, env_file: Optional[str] = None):
        """
        Initialize configuration.

        Args:
            env_file: Path to .env file (default: .env in current directory)
        """
        # Load .env file
        if env_file:
            load_dotenv(env_file)
        else:
            load_dotenv()

        # Load and validate configuration
        self._load_minio_config()
        self._load_fhir_config()
        self._load_directory_config()
        self._load_pipeline_config()

    def _load_minio_config(self):
        """Load MinIO configuration."""
        self.minio_endpoint = self._get_required_env('MINIO_ENDPOINT')
        self.minio_access_key = self._get_required_env('MINIO_ACCESS_KEY')
        self.minio_secret_key = self._get_required_env('MINIO_SECRET_KEY')
        self.minio_bucket_name = self._get_required_env('MINIO_BUCKET_NAME')
        self.minio_secure = self._get_env_bool('MINIO_SECURE', False)

    def _load_fhir_config(self):
        """Load FHIR server configuration."""
        self.fhir_base_url = self._get_required_env('FHIR_BASE_URL')
        self.fhir_auth_enabled = self._get_env_bool('FHIR_AUTH_ENABLED', False)
        self.fhir_username = os.getenv('FHIR_USERNAME', '')
        self.fhir_password = os.getenv('FHIR_PASSWORD', '')

    def _load_directory_config(self):
        """Load directory configuration."""
        self.download_dir = Path(os.getenv('DOWNLOAD_DIR', '/tmp/fhir-download'))
        self.upload_dir = Path(os.getenv('UPLOAD_DIR', '/tmp/fhir-upload'))

    def _load_pipeline_config(self):
        """Load pipeline configuration."""
        self.batch_size = int(os.getenv('BATCH_SIZE', '100'))
        self.continue_on_error = self._get_env_bool('CONTINUE_ON_ERROR', True)
        self.auto_cleanup = self._get_env_bool('AUTO_CLEANUP', True)
        self.keep_empty_dirs = self._get_env_bool('KEEP_EMPTY_DIRS', False)

    @staticmethod
    def _get_required_env(key: str) -> str:
        """Get required environment variable or raise error."""
        value = os.getenv(key)
        if not value:
            raise ValueError(f"Required environment variable not set: {key}")
        return value

    @staticmethod
    def _get_env_bool(key: str, default: bool = False) -> bool:
        """Get boolean environment variable."""
        value = os.getenv(key, str(default)).lower()
        return value in ('true', '1', 'yes', 'on')

    def get_minio_config(self) -> Dict:
        """Get MinIO configuration as dict."""
        return {
            'endpoint': self.minio_endpoint,
            'access_key': self.minio_access_key,
            'secret_key': self.minio_secret_key,
            'bucket_name': self.minio_bucket_name,
            'secure': self.minio_secure
        }

    def get_fhir_config(self) -> Dict:
        """Get FHIR configuration as dict."""
        return {
            'base_url': self.fhir_base_url,
            'auth_enabled': self.fhir_auth_enabled,
            'username': self.fhir_username,
            'password': self.fhir_password
        }

    def display_config(self, mask_credentials: bool = True):
        """Display configuration (with masked credentials)."""
        print("=" * 50)
        print("Configuration")
        print("=" * 50)
        print("\n[MinIO]")
        print(f"  Endpoint: {self.minio_endpoint}")
        print(f"  Bucket: {self.minio_bucket_name}")
        if mask_credentials:
            print(f"  Access Key: {'*' * 8}")
            print(f"  Secret Key: {'*' * 8}")
        else:
            print(f"  Access Key: {self.minio_access_key}")
            print(f"  Secret Key: {self.minio_secret_key}")
        print(f"  Secure: {self.minio_secure}")

        print("\n[FHIR Server]")
        print(f"  Base URL: {self.fhir_base_url}")
        print(f"  Authentication: {'Enabled' if self.fhir_auth_enabled else 'Disabled'}")
        if self.fhir_auth_enabled and mask_credentials:
            print(f"  Username: {self.fhir_username}")
            print(f"  Password: {'*' * 8}")

        print("\n[Directories]")
        print(f"  Download: {self.download_dir}")
        print(f"  Upload: {self.upload_dir}")

        print("\n[Pipeline]")
        print(f"  Batch Size: {self.batch_size}")
        print(f"  Continue on Error: {self.continue_on_error}")
        print(f"  Auto Cleanup: {self.auto_cleanup}")
        print("=" * 50)
