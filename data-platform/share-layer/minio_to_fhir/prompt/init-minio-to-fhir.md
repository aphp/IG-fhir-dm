# MinIO to FHIR - Project Initialization

## Objective
Initialize the technical framework for the MinIO to FHIR data pipeline project. Set up project structure, shared configuration, dependencies, and common utilities.

## Project Overview
This project provides a modular Python-based data pipeline to:
1. List FHIR resources in MinIO
2. Download FHIR NDJSON files from MinIO
3. Upload FHIR resources to HAPI FHIR server using batch transactions
4. Cleanup temporary files
5. Orchestrate the complete workflow

## Project Structure

Create the following directory structure:

```
data-platform/
└── share-layer/
      └── minio_to_fhir/
          ├── .env.example              # Configuration template
          ├── .env                      # Local config (gitignored)
          ├── .gitignore                # Git ignore rules
          ├── requirements.txt          # Python dependencies
          ├── README.md                 # Project documentation
          ├── common/                   # Shared utilities
          │   ├── __init__.py
          │   ├── config.py             # Configuration loader
          │   ├── minio_client.py       # MinIO client wrapper
          │   ├── fhir_client.py        # FHIR client wrapper
          │   └── utils.py              # Common utilities
          ├── list_minio_resources.py   # Feature 1: List
          ├── download_minio_resources.py # Feature 2: Download
          ├── upload_to_fhir.py         # Feature 3: Upload
          ├── cleanup_ndjson_files.py   # Feature 4: Cleanup
          └── minio_to_fhir.py          # Feature 5: Orchestrator
```

## Deliverables

### 1. Configuration Template (.env.example)

```bash
# ============================================
# MinIO Configuration
# ============================================
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET_NAME=fhir-data
MINIO_SECURE=false

# ============================================
# HAPI FHIR Server Configuration
# ============================================
FHIR_BASE_URL=http://localhost:8080/fhir
FHIR_AUTH_ENABLED=false
FHIR_USERNAME=
FHIR_PASSWORD=

# ============================================
# Directory Configuration
# ============================================
# Temporary directory for downloads from MinIO
DOWNLOAD_DIR=/tmp/fhir-download

# Source directory for uploads to FHIR
UPLOAD_DIR=/tmp/fhir-upload

# ============================================
# Upload Configuration
# ============================================
# Number of resources per batch transaction
BATCH_SIZE=100

# Continue processing if a batch fails
CONTINUE_ON_ERROR=true

# ============================================
# Cleanup Configuration
# ============================================
# Automatically cleanup downloaded files after upload
AUTO_CLEANUP=true

# Keep empty directories after cleanup
KEEP_EMPTY_DIRS=false
```

### 2. Dependencies (requirements.txt)

```txt
# MinIO SDK
minio>=7.2.0

# Environment configuration
python-dotenv>=1.0.0

# HTTP requests for FHIR API
requests>=2.31.0

# Progress bars (optional, nice to have)
tqdm>=4.66.0
```

### 3. Git Ignore (.gitignore)

```gitignore
# Environment configuration
.env

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
logs/

# Temporary data directories
/tmp/
/data/
/temp/
```

### 4. Common Utilities Module

#### 4.1 common/__init__.py
```python
"""
Common utilities for MinIO to FHIR pipeline.
"""
from .config import Config
from .minio_client import MinIOClientWrapper
from .fhir_client import FHIRClientWrapper
from .utils import (
    get_resource_type_from_filename,
    format_size,
    format_duration,
    setup_logging
)

__all__ = [
    'Config',
    'MinIOClientWrapper',
    'FHIRClientWrapper',
    'get_resource_type_from_filename',
    'format_size',
    'format_duration',
    'setup_logging'
]
```

#### 4.2 common/config.py
```python
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
        'Organization',
        'Location',
        'Medication',
        'Specimen',
        'Patient',
        'Encounter',
        ['Procedure', 'Observation', 'Condition', 
         'MedicationRequest', 'MedicationDispense', 'MedicationStatement']
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
```

#### 4.3 common/minio_client.py
```python
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
```

#### 4.4 common/fhir_client.py
```python
"""
FHIR client wrapper with common operations.
"""

import requests
from typing import Dict, Optional, Tuple
from requests.auth import HTTPBasicAuth

class FHIRClientWrapper:
    """Wrapper for FHIR server operations."""
    
    def __init__(self, base_url: str, auth_enabled: bool = False,
                 username: str = '', password: str = ''):
        """
        Initialize FHIR client.
        
        Args:
            base_url: FHIR server base URL
            auth_enabled: Enable authentication
            username: Username for basic auth
            password: Password for basic auth
        """
        self.base_url = base_url.rstrip('/')
        self.auth = None
        if auth_enabled and username and password:
            self.auth = HTTPBasicAuth(username, password)
    
    def test_connection(self) -> Tuple[bool, Optional[str]]:
        """
        Test connection to FHIR server.
        
        Returns:
            Tuple of (success, server_version)
        """
        try:
            response = requests.get(
                f"{self.base_url}/metadata",
                auth=self.auth,
                timeout=10
            )
            
            if response.status_code == 200:
                metadata = response.json()
                version = metadata.get('software', {}).get('version', 'unknown')
                return True, version
            else:
                print(f"❌ FHIR server returned status {response.status_code}")
                return False, None
                
        except requests.exceptions.ConnectionError:
            print(f"❌ Cannot connect to FHIR server at {self.base_url}")
            return False, None
        except Exception as e:
            print(f"❌ Error testing FHIR server: {e}")
            return False, None
    
    def post_bundle(self, bundle: Dict) -> Tuple[bool, Optional[Dict]]:
        """
        Post a batch bundle to FHIR server.
        
        Args:
            bundle: FHIR Bundle resource
            
        Returns:
            Tuple of (success, response_bundle)
        """
        try:
            response = requests.post(
                self.base_url,
                json=bundle,
                auth=self.auth,
                headers={'Content-Type': 'application/fhir+json'},
                timeout=300
            )
            
            if response.status_code in (200, 201):
                return True, response.json()
            else:
                print(f"❌ FHIR server returned status {response.status_code}")
                print(f"Response: {response.text[:500]}")
                return False, None
                
        except requests.exceptions.Timeout:
            print(f"❌ Request timeout")
            return False, None
        except Exception as e:
            print(f"❌ Error posting bundle: {e}")
            return False, None
```

#### 4.5 common/utils.py
```python
"""
Common utility functions.
"""

import re
import logging
from pathlib import Path
from datetime import timedelta
from typing import Optional

def get_resource_type_from_filename(filename: str) -> Optional[str]:
    """
    Extract FHIR resource type from filename.
    
    Examples:
        'Patient.ndjson' -> 'Patient'
        'MimicPatient.ndjson' -> 'Patient'
        'Patient_part1.ndjson' -> 'Patient'
    
    Args:
        filename: NDJSON filename
        
    Returns:
        Resource type or None if not recognized
    """
    # Known FHIR resource types
    known_types = [
        'Organization', 'Location', 'Medication', 'Specimen',
        'Patient', 'Encounter', 'Procedure', 'Observation',
        'Condition', 'MedicationRequest', 'MedicationDispense',
        'MedicationStatement', 'Practitioner', 'PractitionerRole',
        'Device', 'DiagnosticReport', 'Immunization'
    ]
    
    # Remove .ndjson extension
    name = Path(filename).stem
    
    # Try to match known resource types
    for resource_type in known_types:
        if resource_type in name:
            return resource_type
    
    return None

def format_size(bytes: int) -> str:
    """
    Format bytes to human-readable size.
    
    Args:
        bytes: Size in bytes
        
    Returns:
        Formatted string (e.g., '1.2 MB')
    """
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes < 1024.0:
            return f"{bytes:.1f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.1f} PB"

def format_duration(seconds: float) -> str:
    """
    Format duration in seconds to human-readable string.
    
    Args:
        seconds: Duration in seconds
        
    Returns:
        Formatted string (e.g., '2m 35s')
    """
    td = timedelta(seconds=int(seconds))
    hours, remainder = divmod(td.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    
    parts = []
    if td.days > 0:
        parts.append(f"{td.days}d")
    if hours > 0:
        parts.append(f"{hours}h")
    if minutes > 0:
        parts.append(f"{minutes}m")
    if seconds > 0 or not parts:
        parts.append(f"{seconds}s")
    
    return ' '.join(parts)

def setup_logging(log_file: Optional[str] = None, verbose: bool = False):
    """
    Setup logging configuration.
    
    Args:
        log_file: Path to log file (optional)
        verbose: Enable verbose logging
    """
    level = logging.DEBUG if verbose else logging.INFO
    
    handlers = [logging.StreamHandler()]
    if log_file:
        handlers.append(logging.FileHandler(log_file))
    
    logging.basicConfig(
        level=level,
        format='[%(asctime)s] %(levelname)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        handlers=handlers
    )
```

### 5. Project Documentation (README.md)

```markdown
# MinIO to FHIR Data Pipeline

Modular Python pipeline for transferring FHIR NDJSON data from MinIO storage to HAPI FHIR server.

## Features

1. **List Resources** - View all NDJSON files in MinIO bucket
2. **Download Resources** - Download FHIR files from MinIO
3. **Upload to FHIR** - Batch upload resources to HAPI FHIR server
4. **Cleanup Files** - Remove temporary files after processing
5. **Full Pipeline** - Orchestrate complete workflow in one command

## Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Create configuration
cp .env.example .env
# Edit .env with your settings
```

## Configuration

Edit `.env` file with your MinIO and FHIR server settings:
- MinIO endpoint, credentials, and bucket name
- HAPI FHIR server URL and authentication
- Directory paths and batch size

## Usage

See individual script documentation:
- `python list_minio_resources.py --help`
- `python download_minio_resources.py --help`
- `python upload_to_fhir.py --help`
- `python cleanup_ndjson_files.py --help`
- `python minio_to_fhir_pipeline.py --help`

## Project Structure

```
minio_to_fhir/
├── common/              # Shared utilities
├── *.py                 # Feature scripts
├── .env                 # Configuration (not in git)
├── .env.example         # Configuration template
└── requirements.txt     # Dependencies
```

## FHIR Resource Order

Resources are loaded in dependency order to maintain referential integrity:
1. Organization
2. Location
3. Medication
4. Specimen
5. Patient
6. Encounter
7. Clinical Resources (Procedure, Observation, Condition, etc.)
```

## Success Criteria

✅ Project directory structure created  
✅ .env.example with all configuration options  
✅ .gitignore to protect sensitive files  
✅ requirements.txt with all dependencies  
✅ common/ module with shared utilities:
   - Configuration management
   - MinIO client wrapper
   - FHIR client wrapper
   - Utility functions  
✅ README.md with project overview  
✅ All files have proper docstrings and comments  
✅ Code follows Python best practices  
✅ Ready for feature scripts integration  