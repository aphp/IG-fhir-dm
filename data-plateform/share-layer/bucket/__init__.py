"""
FHIR Data Loader Package
Transfer FHIR data from PostgreSQL to MinIO S3 storage.
"""

__version__ = "1.0.0"
__author__ = "APHP FHIR Data Management Team"

from .config import settings
from .database import DatabaseConnection, FHIRDataExtractor
from .storage import MinIOStorage, FHIRStorageManager
from .transformer import FHIRTransformer
from .loader import FHIRDataLoader

__all__ = [
    "settings",
    "DatabaseConnection",
    "FHIRDataExtractor",
    "MinIOStorage",
    "FHIRStorageManager",
    "FHIRTransformer",
    "FHIRDataLoader"
]