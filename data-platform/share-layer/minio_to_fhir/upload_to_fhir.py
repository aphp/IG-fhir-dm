#!/usr/bin/env python3
"""
HAPI FHIR Transaction Uploader
Upload FHIR Bundle JSON files to HAPI FHIR server using transaction bundles.
Follows upload-plan.json for dependency-based upload order.
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
from common.utils import format_duration

# Global logger
logger = None


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Upload FHIR Bundle JSON files to HAPI FHIR server',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --input ./tmp/fhir-upload
  %(prog)s --input ./tmp/fhir-upload --plan-file ./custom-plan.json
  %(prog)s -i ./bundles -p ./bundles/upload-plan.json
        """
    )

    parser.add_argument(
        '--input', '-i',
        type=str,
        required=True,
        help='Source directory containing upload-plan.json and level-XX/ directories'
    )

    parser.add_argument(
        '--plan-file', '-p',
        type=str,
        help='Path to upload-plan.json (default: <input>/upload-plan.json)'
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
    Setup logging to file and console.

    Args:
        log_file: Path to log file

    Returns:
        Logger instance
    """
    global logger

    # Create logger
    logger = logging.getLogger('FHIRUploader')
    logger.setLevel(logging.INFO)

    # File handler
    fh = logging.FileHandler(log_file, mode='w', encoding='utf-8')
    fh.setLevel(logging.INFO)

    # Console handler
    ch = logging.StreamHandler()
    ch.setLevel(logging.WARNING)

    # Formatter
    formatter = logging.Formatter('[%(asctime)s] %(levelname)s: %(message)s')
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)

    logger.addHandler(fh)
    logger.addHandler(ch)

    logger.info("=" * 80)
    logger.info("FHIR Upload Session Started")
    logger.info("=" * 80)

    return logger


def load_upload_plan(plan_file: Path) -> Dict:
    """
    Load and parse upload-plan.json.

    Args:
        plan_file: Path to upload-plan.json

    Returns:
        Parsed upload plan dictionary
    """
    if not plan_file.exists():
        print(f"ERROR: Upload plan not found: {plan_file}")
        print("Please run prepare_fhir_bundles.py first to generate the upload plan.")
        sys.exit(1)

    try:
        with open(plan_file, 'r', encoding='utf-8') as f:
            plan = json.load(f)

        # Validate required fields
        required_fields = ['dependency_levels', 'total_bundles', 'total_resources']
        for field in required_fields:
            if field not in plan:
                print(f"ERROR: Invalid upload plan - missing field: {field}")
                sys.exit(1)

        logger.info(f"Loaded upload plan from: {plan_file}")
        logger.info(f"  Analysis timestamp: {plan.get('analysis_timestamp')}")
        logger.info(f"  Total bundles: {plan.get('total_bundles')}")
        logger.info(f"  Total resources: {plan.get('total_resources')}")
        logger.info(f"  Dependency levels: {len(plan.get('dependency_levels', []))}")

        return plan

    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in upload plan: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Failed to load upload plan: {e}")
        sys.exit(1)


def display_plan_warnings(plan: Dict):
    """
    Display warnings from upload plan.

    Args:
        plan: Upload plan dictionary
    """
    circular_refs = plan.get('circular_references', [])
    circular_instances = plan.get('circular_reference_instances', [])
    orphaned_refs = plan.get('orphaned_references', [])

    has_warnings = circular_refs or orphaned_refs

    if not has_warnings:
        return

    print("\nWARNINGS:")

    if circular_instances:
        print(f"  - {len(circular_instances)} mutual reference pair(s) detected")
        print("    These resources reference each other bidirectionally:")
        for instance in circular_instances[:3]:
            print(f"      * {instance.get('resource_a')} <-> {instance.get('resource_b')}")
        if len(circular_instances) > 3:
            print(f"      ... and {len(circular_instances) - 3} more")

    if orphaned_refs:
        print(f"  - {len(orphaned_refs)} orphaned reference(s) detected")
        print("    Some resources reference non-existent resources")

    print("  - See upload-plan.json for full details")
    print()

    # Log warnings
    logger.warning(f"Circular reference pairs: {len(circular_instances)}")
    logger.warning(f"Orphaned references: {len(orphaned_refs)}")


def scan_level_directory(level_dir: Path) -> List[Path]:
    """
    Scan a level directory for bundle JSON files.

    Args:
        level_dir: Path to level directory (e.g., level-01/)

    Returns:
        Sorted list of bundle file paths
    """
    if not level_dir.exists():
        logger.warning(f"Level directory not found: {level_dir}")
        return []

    bundle_files = sorted(level_dir.glob("*.json"))
    logger.info(f"Found {len(bundle_files)} bundle files in {level_dir.name}")

    return bundle_files


def upload_bundle_file(bundle_file: Path, client: FHIRClientWrapper) -> Tuple[int, int, float]:
    """
    Upload a single bundle JSON file to FHIR server.

    Args:
        bundle_file: Path to bundle JSON file
        client: FHIR client

    Returns:
        Tuple of (success_count, failure_count, duration)
    """
    start_time = time.time()

    try:
        # Read bundle file
        with open(bundle_file, 'r', encoding='utf-8') as f:
            bundle = json.load(f)

        # Validate bundle
        if bundle.get('resourceType') != 'Bundle':
            logger.error(f"Invalid bundle in {bundle_file.name}: not a Bundle resource")
            return (0, 0, time.time() - start_time)

        if bundle.get('type') not in ['transaction', 'batch']:
            logger.warning(f"Bundle {bundle_file.name} has unexpected type: {bundle.get('type')} (expected 'transaction' or 'batch')")

        # Upload bundle
        logger.info(f"Uploading {bundle_file.name}...")
        success, response = client.post_bundle(bundle)

        duration = time.time() - start_time

        if not success:
            logger.error(f"Failed to upload {bundle_file.name}: {response}")
            return (0, len(bundle.get('entry', [])), duration)

        # Parse response
        success_count = 0
        failure_count = 0

        entries = response.get('entry', [])
        for idx, entry in enumerate(entries, 1):
            response_entry = entry.get('response', {})
            status = response_entry.get('status', '')

            if status.startswith('2'):  # 2xx success
                success_count += 1
                logger.debug(f"  [{idx}] SUCCESS - Status: {status}")
            else:
                failure_count += 1
                location = response_entry.get('location', '')
                outcome = response_entry.get('outcome', {})
                logger.error(f"  [{idx}] FAILED - Status: {status}, Location: {location}")
                if outcome:
                    logger.error(f"       Outcome: {json.dumps(outcome)}")

        logger.info(f"{bundle_file.name}: {success_count} succeeded, {failure_count} failed")

        return (success_count, failure_count, duration)

    except json.JSONDecodeError as e:
        duration = time.time() - start_time
        logger.error(f"Invalid JSON in {bundle_file.name}: {e}")
        return (0, 0, duration)
    except Exception as e:
        duration = time.time() - start_time
        logger.error(f"Error uploading {bundle_file.name}: {e}")
        return (0, 0, duration)


def upload_level(level_info: Dict, base_dir: Path, client: FHIRClientWrapper, total_levels: int) -> Dict:
    """
    Upload all bundles for a specific dependency level.

    Args:
        level_info: Level information from upload plan
        base_dir: Base directory containing level directories
        client: FHIR client
        total_levels: Total number of levels

    Returns:
        Statistics dictionary
    """
    level_num = level_info.get('level')
    level_name = level_info.get('name')
    expected_bundles = level_info.get('bundles', 0)
    resource_types = level_info.get('resource_types', [])

    # Find level directory
    level_dir = base_dir / f"level-{level_num:02d}"

    print(f"\n[Level {level_num}/{total_levels}] {level_name} ({expected_bundles} bundles)")
    logger.info(f"\n{'=' * 80}")
    logger.info(f"Level {level_num}: {level_name}")
    logger.info(f"Resource types: {', '.join(resource_types)}")
    logger.info(f"Expected bundles: {expected_bundles}")
    logger.info(f"{'=' * 80}")

    # Scan for bundle files
    bundle_files = scan_level_directory(level_dir)

    if not bundle_files:
        print(f"  WARNING: No bundle files found in {level_dir.name}")
        logger.warning(f"No bundle files found in {level_dir}")
        return {
            'level': level_num,
            'bundles': 0,
            'success': 0,
            'failed': 0,
            'duration': 0
        }

    if len(bundle_files) != expected_bundles:
        logger.warning(f"Found {len(bundle_files)} bundles but expected {expected_bundles}")

    # Upload each bundle
    total_success = 0
    total_failed = 0
    level_start = time.time()

    for bundle_file in bundle_files:
        success, failed, duration = upload_bundle_file(bundle_file, client)
        total_success += success
        total_failed += failed

        status = "OK" if failed == 0 else "FAILED"
        print(f"  {bundle_file.name} ... {status} ({success} created, {failed} failed) - {duration:.1f}s")

    level_duration = time.time() - level_start

    print(f"  Level {level_num} complete: {total_success:,} resources uploaded")
    logger.info(f"Level {level_num} summary: {total_success} succeeded, {total_failed} failed, {format_duration(level_duration)}")

    return {
        'level': level_num,
        'bundles': len(bundle_files),
        'success': total_success,
        'failed': total_failed,
        'duration': level_duration
    }


def display_summary(stats: List[Dict], total_duration: float):
    """
    Display upload summary.

    Args:
        stats: List of level statistics
        total_duration: Total upload duration
    """
    total_bundles = sum(s['bundles'] for s in stats)
    total_success = sum(s['success'] for s in stats)
    total_failed = sum(s['failed'] for s in stats)
    total_resources = total_success + total_failed

    print("\n" + "=" * 50)
    print("Summary")
    print("=" * 50)
    print(f"Total bundles: {total_bundles}")
    print(f"Total resources: {total_resources:,}")
    print(f"Successfully uploaded: {total_success:,}")
    print(f"Failed: {total_failed}")
    print(f"Duration: {format_duration(total_duration)}")
    print("=" * 50)

    # Log summary
    logger.info("\n" + "=" * 80)
    logger.info("Upload Summary")
    logger.info("=" * 80)
    logger.info(f"Total bundles: {total_bundles}")
    logger.info(f"Total resources: {total_resources:,}")
    logger.info(f"Successfully uploaded: {total_success:,}")
    logger.info(f"Failed: {total_failed}")
    logger.info(f"Duration: {format_duration(total_duration)}")

    for stat in stats:
        logger.info(f"  Level {stat['level']}: {stat['success']} succeeded, {stat['failed']} failed")

    if total_failed > 0:
        logger.warning(f"Upload completed with {total_failed} failures")
        print(f"\nFailed resources logged to: {logger.handlers[0].baseFilename}")
    else:
        logger.info("Upload completed successfully")

    logger.info("=" * 80)


def main():
    """Main entry point."""
    overall_start = time.time()

    # Parse arguments
    args = parse_arguments()

    # Setup logging
    setup_logging(args.log_file)

    # Determine paths
    input_dir = Path(args.input)
    if args.plan_file:
        plan_file = Path(args.plan_file)
    else:
        plan_file = input_dir / 'upload-plan.json'

    # Display header
    print("=" * 50)
    print("HAPI FHIR Batch Uploader")
    print("=" * 50)
    print(f"Mode: Plan-Based Upload")
    print(f"Source: {input_dir}")
    print(f"Plan: {plan_file}")
    print()

    # Log configuration
    logger.info(f"Configuration:")
    logger.info(f"  Input directory: {input_dir}")
    logger.info(f"  Upload plan: {plan_file}")
    logger.info(f"  Log file: {args.log_file}")

    # Load upload plan
    print("Loading upload plan...")
    plan = load_upload_plan(plan_file)

    # Display plan info
    print(f"  Analysis timestamp: {plan.get('analysis_timestamp')}")
    print(f"  Total bundles: {plan.get('total_bundles')} across {len(plan.get('dependency_levels'))} levels")
    print(f"  Total resources: {plan.get('total_resources'):,}")

    # Display warnings
    display_plan_warnings(plan)

    # Create FHIR client from config
    try:
        config = Config()
        client = FHIRClientWrapper(
            base_url=config.fhir_base_url,
            auth_enabled=config.fhir_auth_enabled,
            username=config.fhir_username,
            password=config.fhir_password
        )
    except Exception as e:
        print(f"ERROR: Failed to create FHIR client: {e}")
        logger.error(f"Failed to create FHIR client: {e}")
        sys.exit(1)

    # Test FHIR server
    print(f"Destination: {config.fhir_base_url}")
    print("Testing FHIR server... ", end='', flush=True)
    success, version = client.test_connection()

    if success:
        print(f"OK (HAPI FHIR {version})")
        logger.info(f"FHIR server connection successful: {config.fhir_base_url} (version: {version})")
    else:
        print("FAILED")
        logger.error("FHIR server connection failed")
        sys.exit(1)

    # Display upload order
    print("\nUpload order:")
    for level_info in plan.get('dependency_levels', []):
        level_num = level_info.get('level')
        resource_types = level_info.get('resource_types', [])
        bundles = level_info.get('bundles', 0)
        resources = level_info.get('total_resources', 0)
        types_str = ", ".join(resource_types)
        print(f"  Level {level_num}: {types_str} ({bundles} bundles, {resources:,} resources)")

    # Upload by level
    print("\nStarting upload...")
    level_stats = []
    total_levels = len(plan.get('dependency_levels', []))

    for level_info in plan.get('dependency_levels', []):
        stats = upload_level(level_info, input_dir, client, total_levels)
        level_stats.append(stats)

    # Display summary
    overall_duration = time.time() - overall_start
    display_summary(level_stats, overall_duration)

    # Exit with appropriate code
    total_failed = sum(s['failed'] for s in level_stats)
    sys.exit(1 if total_failed > 0 else 0)


if __name__ == "__main__":
    main()
