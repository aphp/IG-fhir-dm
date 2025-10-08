#!/usr/bin/env python3
"""
HAPI FHIR Batch Uploader
Upload FHIR NDJSON files to HAPI FHIR server using batch transactions.
Respects referential integrity by uploading resources in dependency order.
"""

import json
import argparse
import sys
import time
import logging
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Tuple

# Add common directory to path
sys.path.insert(0, str(Path(__file__).parent))

from common.config import Config
from common.fhir_client import FHIRClientWrapper
from common.utils import format_duration, get_resource_type_from_filename

# Global logger
logger = None

# Resource loading order (from Config)
RESOURCE_ORDER = Config.RESOURCE_ORDER


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Upload FHIR NDJSON files to HAPI FHIR server using batch transactions',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                                  # Upload from default directory
  %(prog)s --input ./data/fhir-files        # Upload from custom directory
  %(prog)s --batch-size 50                  # Use smaller batches
  %(prog)s -i /tmp/data -s 200              # Combine options
  %(prog)s --log-file upload.log            # Specify custom log file
        """
    )

    parser.add_argument(
        '--input', '-i',
        type=str,
        help='Source directory containing NDJSON files (overrides .env)'
    )

    parser.add_argument(
        '--batch-size', '-s',
        type=int,
        help='Number of resources per batch transaction (default: 100)'
    )

    parser.add_argument(
        '--log-file', '-l',
        type=str,
        default='fhir_upload.log',
        help='Log file path (default: fhir_upload.log)'
    )

    return parser.parse_args()


def setup_logging(log_file):
    """
    Setup logging configuration.

    Args:
        log_file: Path to log file

    Returns:
        Logger instance
    """
    global logger

    # Create logger
    logger = logging.getLogger('fhir_uploader')
    logger.setLevel(logging.DEBUG)

    # Remove existing handlers
    logger.handlers = []

    # Create file handler
    file_handler = logging.FileHandler(log_file, mode='w', encoding='utf-8')
    file_handler.setLevel(logging.DEBUG)

    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(formatter)

    # Add handler to logger
    logger.addHandler(file_handler)

    logger.info("=" * 80)
    logger.info("FHIR Upload Session Started")
    logger.info("=" * 80)

    return logger


def load_config(input_override=None, batch_size_override=None):
    """
    Load environment variables from .env file.

    Args:
        input_override: Optional source directory to override .env value
        batch_size_override: Optional batch size to override .env value

    Returns:
        Config object with loaded configuration
    """
    try:
        config = Config()

        # Override upload directory if specified
        if input_override:
            config.upload_dir = Path(input_override)

        # Override batch size if specified
        if batch_size_override:
            config.batch_size = batch_size_override

        return config

    except ValueError as e:
        print(f"❌ Configuration error: {e}")
        print("\nPlease ensure your .env file is configured correctly.")
        print("See .env.example for reference.")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error loading configuration: {e}")
        sys.exit(1)


def create_fhir_client(config):
    """
    Create FHIR client from configuration.

    Args:
        config: Config object

    Returns:
        FHIRClientWrapper instance
    """
    try:
        client = FHIRClientWrapper(
            base_url=config.fhir_base_url,
            auth_enabled=config.fhir_auth_enabled,
            username=config.fhir_username,
            password=config.fhir_password
        )
        return client

    except Exception as e:
        print(f"❌ Error creating FHIR client: {e}")
        sys.exit(1)


def test_fhir_server(client):
    """
    Test FHIR server connectivity.

    Args:
        client: FHIRClientWrapper instance

    Returns:
        True if connection successful, False otherwise
    """
    print("Testing FHIR server... ", end='', flush=True)
    success, version = client.test_connection()

    if success:
        print(f"✓ (version: {version})")
        return True
    else:
        print("✗")
        return False


def count_resources_in_file(filepath):
    """
    Count total resources in an NDJSON file.

    Args:
        filepath: Path to NDJSON file

    Returns:
        Number of resources
    """
    count = 0
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line:
                    count += 1
    except Exception as e:
        logger.warning(f"Error counting resources in {filepath.name}: {e}")
    return count


def group_files_by_resource_type(directory):
    """
    Scan directory and group NDJSON files by resource type.

    Args:
        directory: Path to directory

    Returns:
        Dict mapping resource type to list of (filepath, resource_count) tuples
    """
    if not directory.exists():
        print(f"❌ Directory does not exist: {directory}")
        return {}

    if not directory.is_dir():
        print(f"❌ Not a directory: {directory}")
        return {}

    # Find all NDJSON files
    ndjson_files = list(directory.glob('*.ndjson'))

    if not ndjson_files:
        return {}

    # Group by resource type
    grouped = {}
    unknown_files = []

    for filepath in ndjson_files:
        resource_type = get_resource_type_from_filename(filepath.name)

        if resource_type:
            if resource_type not in grouped:
                grouped[resource_type] = []

            # Count resources in file
            resource_count = count_resources_in_file(filepath)
            grouped[resource_type].append((filepath, resource_count))
        else:
            unknown_files.append(filepath.name)

    # Warn about unknown files
    if unknown_files:
        logger.warning(f"Files with unknown resource types (will be skipped): {unknown_files}")
        print(f"⚠️  Warning: {len(unknown_files)} file(s) with unknown resource type will be skipped")

    return grouped


def sort_files_by_dependency_order(grouped_files):
    """
    Sort grouped files according to RESOURCE_ORDER for referential integrity.

    Args:
        grouped_files: Dict mapping resource type to list of (filepath, count) tuples

    Returns:
        List of steps, where each step is:
        {
            'step_num': int,
            'resource_types': list of str,
            'files': list of (filepath, count) tuples,
            'total_resources': int
        }
    """
    steps = []
    step_num = 0

    for order_item in RESOURCE_ORDER:
        # order_item can be a single resource type (str) or a list of types
        if isinstance(order_item, list):
            # Clinical resources - group multiple types together
            resource_types = order_item
            step_files = []
            total_resources = 0

            for resource_type in resource_types:
                if resource_type in grouped_files:
                    files_with_counts = grouped_files[resource_type]
                    step_files.extend(files_with_counts)
                    total_resources += sum(count for _, count in files_with_counts)

            if step_files:
                step_num += 1
                steps.append({
                    'step_num': step_num,
                    'resource_types': resource_types,
                    'files': sorted(step_files, key=lambda x: x[0].name),
                    'total_resources': total_resources
                })

        else:
            # Single resource type
            resource_type = order_item
            if resource_type in grouped_files:
                files_with_counts = grouped_files[resource_type]
                total_resources = sum(count for _, count in files_with_counts)

                step_num += 1
                steps.append({
                    'step_num': step_num,
                    'resource_types': [resource_type],
                    'files': sorted(files_with_counts, key=lambda x: x[0].name),
                    'total_resources': total_resources
                })

    return steps


def scan_ndjson_files(directory):
    """
    Scan directory for NDJSON files and sort by dependency order.

    Args:
        directory: Path to directory

    Returns:
        List of steps (sorted by dependency order)
    """
    # Group files by resource type
    grouped = group_files_by_resource_type(directory)

    if not grouped:
        return []

    # Sort by dependency order
    steps = sort_files_by_dependency_order(grouped)

    return steps


def read_ndjson_file(filepath):
    """
    Read NDJSON file and yield resources.

    Args:
        filepath: Path to NDJSON file

    Yields:
        Parsed FHIR resource (dict)
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue

                try:
                    resource = json.loads(line)
                    yield resource
                except json.JSONDecodeError as e:
                    print(f"⚠️  Skipping invalid JSON at line {line_num}: {e}")
                    continue

    except Exception as e:
        print(f"❌ Error reading file {filepath}: {e}")


def create_batch_bundle(resources: List[Dict]) -> Dict:
    """
    Create FHIR Bundle of type 'batch'.

    Uses PUT method to preserve original resource IDs.

    Args:
        resources: List of FHIR resources

    Returns:
        FHIR Bundle resource
    """
    entries = []
    for resource in resources:
        resource_type = resource.get('resourceType', 'Unknown')
        resource_id = resource.get('id')

        # Build URL with resource ID
        if resource_id:
            # Use PUT with full URL to preserve the original resource ID
            url = f"{resource_type}/{resource_id}"
            method = "PUT"
        else:
            # If no ID, use POST and let server assign one
            url = resource_type
            method = "POST"
            logger.warning(f"Resource {resource_type} has no ID, using POST instead of PUT")

        entry = {
            "request": {
                "method": method,
                "url": url
            },
            "resource": resource
        }
        entries.append(entry)

    bundle = {
        "resourceType": "Bundle",
        "type": "batch",
        "entry": entries
    }

    return bundle


def parse_bundle_response(response_bundle: Dict, batch_num: int, filename: str) -> Tuple[int, int]:
    """
    Parse bundle response to count successes and failures.

    Args:
        response_bundle: Response Bundle from FHIR server
        batch_num: Batch number for logging
        filename: Filename for logging

    Returns:
        Tuple of (success_count, failure_count)
    """
    success_count = 0
    failure_count = 0

    logger.info(f"\n--- Batch {batch_num} Response for {filename} ---")

    entries = response_bundle.get('entry', [])
    for idx, entry in enumerate(entries, 1):
        response = entry.get('response', {})
        status = response.get('status', '')
        location = response.get('location', '')
        outcome = response.get('outcome', {})

        # Check if status starts with 2xx (success)
        # 200 OK = resource updated (PUT)
        # 201 Created = resource created (POST)
        if status.startswith('2'):
            success_count += 1
            action = "created/updated" if status.startswith('20') else "processed"
            logger.info(f"  [{idx}] SUCCESS - Status: {status} ({action}), Location: {location}")
        else:
            failure_count += 1
            logger.error(f"  [{idx}] FAILED - Status: {status}")
            logger.error(f"       Location: {location}")

            # Log outcome details if available
            if outcome:
                logger.error(f"       Outcome: {json.dumps(outcome, indent=6)}")

    logger.info(f"Batch {batch_num} Summary: {success_count} succeeded, {failure_count} failed")

    return success_count, failure_count


def upload_batch(client, bundle: Dict, batch_num: int, filename: str) -> Tuple[int, int, bool]:
    """
    Upload batch bundle to FHIR server.

    Args:
        client: FHIRClientWrapper instance
        bundle: FHIR Bundle to upload
        batch_num: Batch number for logging
        filename: Filename for logging

    Returns:
        Tuple of (success_count, failure_count, upload_success)
    """
    # Log the request
    logger.info(f"\n>>> Uploading Batch {batch_num} for {filename}")
    logger.debug(f"Request Bundle:\n{json.dumps(bundle, indent=2)}")

    success, response_bundle = client.post_bundle(bundle)

    if not success or not response_bundle:
        # Entire batch failed
        resource_count = len(bundle.get('entry', []))
        logger.error(f"!!! Batch {batch_num} completely failed - no response from server")
        return 0, resource_count, False

    # Log the response
    logger.debug(f"Response Bundle:\n{json.dumps(response_bundle, indent=2)}")

    # Parse individual resource responses
    success_count, failure_count = parse_bundle_response(response_bundle, batch_num, filename)
    return success_count, failure_count, True


def upload_mixed_resources(files_with_counts, resource_types, client, batch_size, indent="  "):
    """
    Upload resources from multiple files, mixing them in the same batches.

    This is used when multiple resource types should be uploaded together
    (e.g., Organization + Location in the same batch bundles).

    Args:
        files_with_counts: List of (filepath, count) tuples
        resource_types: List of resource type names being processed
        client: FHIRClientWrapper instance
        batch_size: Number of resources per batch
        indent: Indentation string for console output

    Returns:
        Dict with upload statistics
    """
    all_resources = []
    total_resources = 0

    # Collect all resources from all files
    for filepath, _count in files_with_counts:
        filename = filepath.name
        logger.info(f"Reading {filename}...")

        for resource in read_ndjson_file(filepath):
            all_resources.append(resource)
            total_resources += 1

    if total_resources == 0:
        logger.warning(f"No resources found in files: {[f.name for f, _ in files_with_counts]}")
        return {
            'total_resources': 0,
            'total_success': 0,
            'total_failed': 0,
            'batches': 0
        }

    logger.info(f"Total resources collected: {total_resources}")

    # Upload in batches
    batch_num = 0
    total_batches = (total_resources + batch_size - 1) // batch_size
    total_success = 0
    total_failed = 0
    processed = 0

    while processed < total_resources:
        batch_resources = all_resources[processed:processed + batch_size]
        batch_num += 1

        print(f"{indent}Batch {batch_num}/{total_batches} ({len(batch_resources)} resources)... ", end='', flush=True)

        start_time = time.time()

        # Create and upload batch
        bundle = create_batch_bundle(batch_resources)
        success_count, failure_count, upload_ok = upload_batch(
            client, bundle, batch_num,
            f"{', '.join(resource_types)}"
        )

        duration = time.time() - start_time

        # Display result
        if upload_ok:
            total_success += success_count
            total_failed += failure_count
            print(f"✓ ({success_count} created/updated, {failure_count} failed) - {format_duration(duration)}")
        else:
            total_failed += len(batch_resources)
            print(f"✗ (batch failed) - {format_duration(duration)}")

        processed += len(batch_resources)

    logger.info(f"Mixed resources upload completed: {total_success} succeeded, {total_failed} failed")

    return {
        'total_resources': total_resources,
        'total_success': total_success,
        'total_failed': total_failed,
        'batches': batch_num
    }


def upload_file(filepath, client, batch_size, indent="  "):
    """
    Upload all resources from a single NDJSON file.

    Args:
        filepath: Path to NDJSON file
        client: FHIRClientWrapper instance
        batch_size: Number of resources per batch
        indent: Indentation string for console output

    Returns:
        Dict with file upload statistics
    """
    filename = filepath.name
    resources = []
    batch_num = 0
    total_batches = 0
    total_resources = 0
    total_success = 0
    total_failed = 0

    logger.info(f"\n{'='*80}")
    logger.info(f"Processing file: {filename}")
    logger.info(f"{'='*80}")

    # First pass: count resources for batch calculation
    resource_count = sum(1 for _ in read_ndjson_file(filepath))
    if resource_count == 0:
        logger.warning(f"File {filename} contains no resources")
        return {
            'total_resources': 0,
            'total_success': 0,
            'total_failed': 0,
            'batches': 0
        }

    total_batches = (resource_count + batch_size - 1) // batch_size
    logger.info(f"Total resources: {resource_count}, Total batches: {total_batches}")

    # Second pass: upload in batches
    for resource in read_ndjson_file(filepath):
        resources.append(resource)
        total_resources += 1

        # When batch is full or last resource
        if len(resources) >= batch_size or total_resources == resource_count:
            batch_num += 1
            print(f"{indent}Batch {batch_num}/{total_batches} ({len(resources)} resources)... ", end='', flush=True)

            start_time = time.time()

            # Create and upload batch
            bundle = create_batch_bundle(resources)
            success_count, failure_count, upload_ok = upload_batch(client, bundle, batch_num, filename)

            duration = time.time() - start_time

            # Display result
            if upload_ok:
                total_success += success_count
                total_failed += failure_count
                print(f"✓ ({success_count} created/updated, {failure_count} failed) - {format_duration(duration)}")
            else:
                total_failed += len(resources)
                print(f"✗ (batch failed) - {format_duration(duration)}")

            # Reset batch
            resources = []

    logger.info(f"\nFile {filename} completed: {total_success} succeeded, {total_failed} failed")

    return {
        'total_resources': total_resources,
        'total_success': total_success,
        'total_failed': total_failed,
        'batches': batch_num
    }


def upload_all_files(steps, client, batch_size):
    """
    Upload all NDJSON files in dependency order.

    Args:
        steps: List of steps (each step contains files for specific resource types)
        client: FHIRClientWrapper instance
        batch_size: Number of resources per batch

    Returns:
        Dict with overall statistics
    """
    overall_start = time.time()

    total_steps = len(steps)
    total_files = 0
    total_resources = 0
    total_success = 0
    total_failed = 0

    for step in steps:
        step_num = step['step_num']
        resource_types = step['resource_types']
        files_with_counts = step['files']

        # Display step header
        if len(resource_types) == 1:
            # Single resource type
            resource_type = resource_types[0]
            print(f"\n[Step {step_num}/{total_steps}] {resource_type}")
            logger.info(f"\n{'='*80}")
            logger.info(f"Step {step_num}/{total_steps}: {resource_type}")
            logger.info(f"{'='*80}")
        else:
            # Multiple resource types (Clinical resources)
            types_str = ', '.join(resource_types)
            print(f"\n[Step {step_num}/{total_steps}] Clinical Resources ({types_str})")
            logger.info(f"\n{'='*80}")
            logger.info(f"Step {step_num}/{total_steps}: Clinical Resources")
            logger.info(f"  Types: {types_str}")
            logger.info(f"{'='*80}")

        # Upload each file in this step
        for filepath, _count in files_with_counts:
            total_files += 1

            # Determine indentation based on number of files in step
            if len(files_with_counts) > 1:
                # Multiple files - show filename and indent batches more
                print(f"  {filepath.name}")
                batch_indent = "    "
            else:
                # Single file - filename shown in step header
                batch_indent = "  "

            stats = upload_file(filepath, client, batch_size, indent=batch_indent)

            total_resources += stats['total_resources']
            total_success += stats['total_success']
            total_failed += stats['total_failed']

    overall_duration = time.time() - overall_start

    return {
        'total_files': total_files,
        'total_resources': total_resources,
        'total_success': total_success,
        'total_failed': total_failed,
        'duration': overall_duration
    }


def display_summary(stats):
    """
    Display upload summary.

    Args:
        stats: Dict with overall statistics
    """
    print("\n" + "=" * 50)
    print("Summary")
    print("=" * 50)
    print(f"Total files: {stats['total_files']}")
    print(f"Total resources: {stats['total_resources']:,}")
    print(f"Successfully uploaded: {stats['total_success']:,}")
    print(f"Failed: {stats['total_failed']:,}")
    print(f"Duration: {format_duration(stats['duration'])}")
    print("=" * 50)

    # Log summary
    logger.info("\n" + "=" * 80)
    logger.info("UPLOAD SUMMARY")
    logger.info("=" * 80)
    logger.info(f"Total files: {stats['total_files']}")
    logger.info(f"Total resources: {stats['total_resources']:,}")
    logger.info(f"Successfully uploaded: {stats['total_success']:,}")
    logger.info(f"Failed: {stats['total_failed']:,}")
    logger.info(f"Duration: {format_duration(stats['duration'])}")
    logger.info("=" * 80)


def main():
    """Main entry point."""
    # Parse arguments
    args = parse_arguments()

    # Setup logging
    log = setup_logging(args.log_file)

    # Load configuration
    config = load_config(
        input_override=args.input,
        batch_size_override=args.batch_size
    )

    # Display header
    print("=" * 50)
    print("HAPI FHIR Batch Uploader")
    print("=" * 50)
    print(f"Source: {config.upload_dir}")
    print(f"Destination: {config.fhir_base_url}")
    print(f"Batch Size: {config.batch_size}")
    print(f"Log File: {args.log_file}")
    print()

    # Log configuration
    logger.info(f"Configuration:")
    logger.info(f"  Source Directory: {config.upload_dir}")
    logger.info(f"  FHIR Base URL: {config.fhir_base_url}")
    logger.info(f"  Batch Size: {config.batch_size}")
    logger.info(f"  Auth Enabled: {config.fhir_auth_enabled}")

    # Create FHIR client
    client = create_fhir_client(config)

    # Test FHIR server
    if not test_fhir_server(client):
        logger.error("FHIR server test failed")
        sys.exit(1)

    logger.info("FHIR server test passed")

    # Scan for NDJSON files and sort by dependency order
    print("\nScanning directory...")
    steps = scan_ndjson_files(config.upload_dir)

    if not steps:
        print("❌ No NDJSON files found")
        logger.error(f"No NDJSON files found in {config.upload_dir}")
        sys.exit(1)

    # Calculate totals
    total_files = sum(len(step['files']) for step in steps)
    total_resources = sum(step['total_resources'] for step in steps)

    print(f"Found {total_files} NDJSON files ({total_resources:,} resources total)")
    print("\nSorted by dependency order:")

    # Display grouped summary
    for step in steps:
        step_num = step['step_num']
        resource_types = step['resource_types']
        files_with_counts = step['files']
        step_resources = step['total_resources']

        if len(resource_types) == 1:
            # Single resource type
            type_name = resource_types[0]
        else:
            # Clinical or other multi-resource groups
            type_name = f"Clinical ({', '.join(resource_types[:3])}{'...' if len(resource_types) > 3 else ''})"

        print(f"  Step {step_num}: {type_name} ({len(files_with_counts)} file(s), {step_resources:,} resources)")

    # Log detailed file list
    logger.info(f"\nFound {total_files} NDJSON files ({total_resources:,} resources):")
    logger.info("Sorted by dependency order:")
    for step in steps:
        step_num = step['step_num']
        resource_types = step['resource_types']
        files_with_counts = step['files']

        logger.info(f"\n  Step {step_num}: {', '.join(resource_types)}")
        for filepath, count in files_with_counts:
            logger.info(f"    - {filepath.name} ({count} resources)")

    # Upload all files
    print("\nStarting upload...")
    stats = upload_all_files(steps, client, config.batch_size)

    # Display summary
    display_summary(stats)

    # Log completion
    logger.info("\n" + "=" * 80)
    if stats['total_failed'] > 0:
        logger.warning("Upload completed with errors")
    else:
        logger.info("Upload completed successfully")
    logger.info("=" * 80)

    print(f"\nDetailed log saved to: {args.log_file}")

    # Exit with error code if any uploads failed
    if stats['total_failed'] > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
