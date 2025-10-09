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
    # Known FHIR resource types - ORDER MATTERS!
    # Longer/more specific names must come before shorter ones
    known_types = [
        'MedicationAdministration',
        'MedicationStatement',
        'MedicationDispense',
        'MedicationRequest',
        'PractitionerRole',
        'DiagnosticReport',
        'Organization',
        'Observation',
        'Practitioner',
        'Medication',
        'Procedure',
        'Encounter',
        'Condition',
        'Specimen',
        'Location',
        'Patient',
        'Device',
        'Immunization'
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
