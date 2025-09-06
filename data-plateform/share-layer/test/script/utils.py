"""Utility functions for FHIR bulk loader.

This module provides helper functions for file processing, validation,
and FHIR resource manipulation.
"""

import gzip
import json
import logging
from pathlib import Path
from typing import Dict, Generator, List, Optional, Tuple, Union

logger = logging.getLogger(__name__)


class FhirResourceValidator:
    """Validates FHIR resources for common issues before import."""
    
    REQUIRED_FIELDS = {
        'Patient': ['id'],
        'Encounter': ['id', 'subject'],
        'Observation': ['id', 'subject', 'code'],
        'Condition': ['id', 'subject', 'code'],
        'Procedure': ['id', 'subject', 'code'],
        'MedicationRequest': ['id', 'subject', 'medicationCodeableConcept'],
        'DiagnosticReport': ['id', 'subject', 'code'],
        'Immunization': ['id', 'patient', 'vaccineCode'],
        'AllergyIntolerance': ['id', 'patient', 'code']
    }
    
    @staticmethod
    def validate_resource(resource: Dict) -> Tuple[bool, List[str]]:
        """Validate a single FHIR resource.
        
        Args:
            resource: FHIR resource as dictionary
            
        Returns:
            Tuple of (is_valid, list_of_errors)
        """
        errors = []
        
        # Check resource type
        resource_type = resource.get('resourceType')
        if not resource_type:
            errors.append("Missing resourceType")
            return False, errors
        
        # Check required fields for known resource types
        if resource_type in FhirResourceValidator.REQUIRED_FIELDS:
            required_fields = FhirResourceValidator.REQUIRED_FIELDS[resource_type]
            for field in required_fields:
                if field not in resource or not resource[field]:
                    errors.append(f"Missing required field: {field}")
        
        # Check ID format
        resource_id = resource.get('id')
        if resource_id and not isinstance(resource_id, str):
            errors.append("Resource ID must be a string")
        
        # Check for empty or null values in critical fields
        if resource_type == 'Patient':
            if not resource.get('gender') and not resource.get('birthDate'):
                errors.append("Patient should have at least gender or birthDate")
        
        return len(errors) == 0, errors
    
    @staticmethod
    def validate_ndjson_file(file_path: Path, max_errors: int = 10) -> Dict:
        """Validate all resources in an NDJSON.gz file.
        
        Args:
            file_path: Path to NDJSON.gz file
            max_errors: Maximum number of errors to collect
            
        Returns:
            Dictionary with validation results
        """
        results = {
            'total_resources': 0,
            'valid_resources': 0,
            'invalid_resources': 0,
            'errors': [],
            'resource_types': {}
        }
        
        try:
            with gzip.open(file_path, 'rt', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    if line.strip():
                        results['total_resources'] += 1
                        
                        try:
                            resource = json.loads(line.strip())
                            is_valid, resource_errors = FhirResourceValidator.validate_resource(resource)
                            
                            resource_type = resource.get('resourceType', 'Unknown')
                            results['resource_types'][resource_type] = results['resource_types'].get(resource_type, 0) + 1
                            
                            if is_valid:
                                results['valid_resources'] += 1
                            else:
                                results['invalid_resources'] += 1
                                if len(results['errors']) < max_errors:
                                    results['errors'].append({
                                        'line': line_num,
                                        'resource_type': resource_type,
                                        'errors': resource_errors
                                    })
                                    
                        except json.JSONDecodeError as e:
                            results['invalid_resources'] += 1
                            if len(results['errors']) < max_errors:
                                results['errors'].append({
                                    'line': line_num,
                                    'resource_type': 'JSON_ERROR',
                                    'errors': [f"JSON decode error: {e}"]
                                })
                                
        except Exception as e:
            logger.error(f"Failed to validate file {file_path}: {e}")
            results['errors'].append({
                'line': 0,
                'resource_type': 'FILE_ERROR',
                'errors': [f"File processing error: {e}"]
            })
        
        return results


class FileProcessor:
    """Processes NDJSON.gz files for analysis and transformation."""
    
    @staticmethod
    def read_ndjson_gz(file_path: Path) -> Generator[Dict, None, None]:
        """Generator that yields FHIR resources from NDJSON.gz file.
        
        Args:
            file_path: Path to NDJSON.gz file
            
        Yields:
            FHIR resource dictionaries
        """
        try:
            with gzip.open(file_path, 'rt', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    if line.strip():
                        try:
                            resource = json.loads(line.strip())
                            yield resource
                        except json.JSONDecodeError as e:
                            logger.warning(f"Invalid JSON at line {line_num} in {file_path}: {e}")
                            
        except Exception as e:
            logger.error(f"Failed to read file {file_path}: {e}")
    
    @staticmethod
    def get_file_stats(file_path: Path) -> Dict:
        """Get detailed statistics for an NDJSON.gz file.
        
        Args:
            file_path: Path to NDJSON.gz file
            
        Returns:
            Dictionary with file statistics
        """
        stats = {
            'file_name': file_path.name,
            'file_size_bytes': file_path.stat().st_size,
            'file_size_mb': round(file_path.stat().st_size / (1024 * 1024), 2),
            'resource_counts': {},
            'total_resources': 0,
            'processing_errors': 0
        }
        
        for resource in FileProcessor.read_ndjson_gz(file_path):
            resource_type = resource.get('resourceType', 'Unknown')
            stats['resource_counts'][resource_type] = stats['resource_counts'].get(resource_type, 0) + 1
            stats['total_resources'] += 1
        
        return stats
    
    @staticmethod
    def split_large_file(file_path: Path, max_resources: int = 10000, 
                        output_dir: Optional[Path] = None) -> List[Path]:
        """Split a large NDJSON.gz file into smaller chunks.
        
        Args:
            file_path: Path to large NDJSON.gz file
            max_resources: Maximum resources per chunk
            output_dir: Directory for output files (default: same as input)
            
        Returns:
            List of paths to created chunk files
        """
        if output_dir is None:
            output_dir = file_path.parent
        
        output_dir.mkdir(parents=True, exist_ok=True)
        
        base_name = file_path.stem.replace('.ndjson', '')  # Remove .ndjson from .ndjson.gz
        chunk_files = []
        
        current_chunk = 0
        current_resources = 0
        current_file = None
        
        try:
            for resource in FileProcessor.read_ndjson_gz(file_path):
                # Start new chunk if needed
                if current_resources == 0:
                    chunk_filename = f"{base_name}_chunk_{current_chunk:03d}.ndjson.gz"
                    chunk_path = output_dir / chunk_filename
                    current_file = gzip.open(chunk_path, 'wt', encoding='utf-8')
                    chunk_files.append(chunk_path)
                
                # Write resource to current chunk
                json.dump(resource, current_file, separators=(',', ':'))
                current_file.write('\n')
                current_resources += 1
                
                # Close chunk if max resources reached
                if current_resources >= max_resources:
                    current_file.close()
                    current_file = None
                    current_resources = 0
                    current_chunk += 1
            
            # Close final chunk if open
            if current_file:
                current_file.close()
                
        except Exception as e:
            logger.error(f"Failed to split file {file_path}: {e}")
            # Clean up partial files
            for chunk_file in chunk_files:
                if chunk_file.exists():
                    chunk_file.unlink()
            return []
        
        logger.info(f"Split {file_path} into {len(chunk_files)} chunks")
        return chunk_files


class ProgressReporter:
    """Reports progress and statistics during bulk import."""
    
    def __init__(self):
        self.start_time = None
        self.files_processed = 0
        self.total_files = 0
        self.resources_processed = 0
        self.total_resources = 0
    
    def start(self, total_files: int, total_resources: int):
        """Start progress tracking."""
        import time
        self.start_time = time.time()
        self.total_files = total_files
        self.total_resources = total_resources
        self.files_processed = 0
        self.resources_processed = 0
    
    def update_file_progress(self, files_completed: int):
        """Update file processing progress."""
        self.files_processed = files_completed
    
    def update_resource_progress(self, resources_completed: int):
        """Update resource processing progress."""
        self.resources_processed = resources_completed
    
    def get_progress_report(self) -> Dict:
        """Get current progress report."""
        import time
        
        if self.start_time is None:
            return {}
        
        elapsed = time.time() - self.start_time
        file_percent = (self.files_processed / self.total_files * 100) if self.total_files > 0 else 0
        resource_percent = (self.resources_processed / self.total_resources * 100) if self.total_resources > 0 else 0
        
        resources_per_second = self.resources_processed / elapsed if elapsed > 0 else 0
        
        return {
            'elapsed_seconds': round(elapsed, 2),
            'files_processed': self.files_processed,
            'total_files': self.total_files,
            'file_progress_percent': round(file_percent, 2),
            'resources_processed': self.resources_processed,
            'total_resources': self.total_resources,
            'resource_progress_percent': round(resource_percent, 2),
            'resources_per_second': round(resources_per_second, 2)
        }
    
    def print_progress(self):
        """Print current progress to console."""
        report = self.get_progress_report()
        if report:
            print(f"Progress: {report['file_progress_percent']:.1f}% files, "
                  f"{report['resource_progress_percent']:.1f}% resources, "
                  f"{report['resources_per_second']:.0f} resources/sec")


def format_file_size(size_bytes: int) -> str:
    """Format file size in human-readable format."""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} PB"


def estimate_import_time(total_resources: int, resources_per_second: float = 100.0) -> str:
    """Estimate import completion time."""
    if resources_per_second <= 0:
        return "Unknown"
    
    seconds = total_resources / resources_per_second
    
    if seconds < 60:
        return f"{seconds:.0f} seconds"
    elif seconds < 3600:
        minutes = seconds / 60
        return f"{minutes:.0f} minutes"
    else:
        hours = seconds / 3600
        return f"{hours:.1f} hours"