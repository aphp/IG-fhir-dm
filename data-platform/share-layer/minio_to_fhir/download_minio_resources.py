#!/usr/bin/env python3
"""
MinIO Resource Downloader
Download all FHIR NDJSON files from MinIO bucket to local directory.
"""

import argparse
import sys
import time
from pathlib import Path
from minio.error import S3Error

# Add common directory to path
sys.path.insert(0, str(Path(__file__).parent))

from common.config import Config
from common.minio_client import MinIOClientWrapper
from common.utils import format_size, format_duration


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Download all FHIR NDJSON files from MinIO bucket to local directory',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                                  # Download to default directory
  %(prog)s --bucket my-bucket               # Download from specific bucket
  %(prog)s --output /data/downloads         # Download to custom directory
  %(prog)s -b my-bucket -o /tmp/data        # Combine options
        """
    )

    parser.add_argument(
        '--bucket', '-b',
        type=str,
        help='Override bucket name from .env file'
    )

    parser.add_argument(
        '--output', '-o',
        type=str,
        help='Override download directory from .env file'
    )

    return parser.parse_args()


def load_config(bucket_override=None, output_override=None):
    """
    Load environment variables from .env file.

    Args:
        bucket_override: Optional bucket name to override .env value
        output_override: Optional download directory to override .env value

    Returns:
        Config object with loaded configuration
    """
    try:
        config = Config()

        # Override bucket if specified
        if bucket_override:
            config.minio_bucket_name = bucket_override

        # Override download directory if specified
        if output_override:
            config.download_dir = Path(output_override)

        return config

    except ValueError as e:
        print(f"❌ Configuration error: {e}")
        print("\nPlease ensure your .env file is configured correctly.")
        print("See .env.example for reference.")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error loading configuration: {e}")
        sys.exit(1)


def create_minio_client(config):
    """
    Create MinIO client from configuration.

    Args:
        config: Config object

    Returns:
        MinIOClientWrapper instance
    """
    try:
        client = MinIOClientWrapper(
            endpoint=config.minio_endpoint,
            access_key=config.minio_access_key,
            secret_key=config.minio_secret_key,
            secure=config.minio_secure
        )
        return client

    except Exception as e:
        print(f"❌ Error creating MinIO client: {e}")
        sys.exit(1)


def prepare_download_directory(download_dir):
    """
    Create download directory if it doesn't exist.

    Args:
        download_dir: Path to download directory

    Returns:
        True if successful, False otherwise
    """
    try:
        download_dir.mkdir(parents=True, exist_ok=True)
        return True
    except PermissionError:
        print(f"❌ Permission denied: Cannot create directory {download_dir}")
        return False
    except Exception as e:
        print(f"❌ Error creating directory {download_dir}: {e}")
        return False


def download_file(client, bucket_name, file_info, download_dir):
    """
    Download a single file from MinIO.

    Args:
        client: MinIOClientWrapper instance
        bucket_name: Name of the bucket
        file_info: Dict with file metadata (name, size, last_modified)
        download_dir: Path to download directory

    Returns:
        Dict with download stats (success, size, duration, error)
    """
    object_name = file_info['name']
    local_path = download_dir / object_name

    start_time = time.time()

    try:
        # Download the file
        success = client.download_file(bucket_name, object_name, local_path)
        duration = time.time() - start_time

        if success:
            return {
                'success': True,
                'size': file_info['size'],
                'duration': duration,
                'error': None
            }
        else:
            return {
                'success': False,
                'size': 0,
                'duration': duration,
                'error': 'Download failed'
            }

    except Exception as e:
        duration = time.time() - start_time
        return {
            'success': False,
            'size': 0,
            'duration': duration,
            'error': str(e)
        }


def download_all_files(client, bucket_name, download_dir):
    """
    Download all NDJSON files from bucket.

    Args:
        client: MinIOClientWrapper instance
        bucket_name: Name of the bucket
        download_dir: Path to download directory

    Returns:
        Dict with summary statistics
    """
    # Test connection first
    if not client.test_connection(bucket_name):
        sys.exit(1)

    # Get list of files with details
    print(f"\nFetching file list from {bucket_name}...")
    files = client.list_ndjson_files_with_details(bucket_name)

    if not files:
        print("❌ No NDJSON files found in bucket")
        return {
            'total': 0,
            'downloaded': 0,
            'failed': 0,
            'total_size': 0,
            'duration': 0
        }

    print(f"Found {len(files)} files to download...\n")

    # Download each file
    downloaded = 0
    failed = 0
    total_size = 0
    failed_files = []

    overall_start = time.time()

    for idx, file_info in enumerate(files, 1):
        filename = file_info['name']
        print(f"[{idx}/{len(files)}] Downloading {filename}...", end=' ', flush=True)

        result = download_file(client, bucket_name, file_info, download_dir)

        if result['success']:
            downloaded += 1
            total_size += result['size']
            size_str = format_size(result['size'])
            duration_str = format_duration(result['duration'])
            print(f"✓ ({size_str} in {duration_str})")
        else:
            failed += 1
            failed_files.append((filename, result['error']))
            print(f"✗ ({result['error']})")

    overall_duration = time.time() - overall_start

    # Print failed files if any
    if failed_files:
        print("\n⚠️  Failed downloads:")
        for filename, error in failed_files:
            print(f"  - {filename}: {error}")

    return {
        'total': len(files),
        'downloaded': downloaded,
        'failed': failed,
        'total_size': total_size,
        'duration': overall_duration
    }


def display_summary(stats, download_dir):
    """
    Display download summary.

    Args:
        stats: Dict with summary statistics
        download_dir: Path to download directory
    """
    print("\n" + "=" * 50)
    print("Summary")
    print("=" * 50)
    print(f"Total files: {stats['total']}")
    print(f"Downloaded: {stats['downloaded']}")
    print(f"Failed: {stats['failed']}")
    print(f"Total size: {format_size(stats['total_size'])}")
    print(f"Duration: {format_duration(stats['duration'])}")
    print(f"Location: {download_dir}")
    print("=" * 50)


def main():
    """Main entry point."""
    # Parse arguments
    args = parse_arguments()

    # Load configuration
    config = load_config(
        bucket_override=args.bucket,
        output_override=args.output
    )

    # Display header
    print("=" * 50)
    print("MinIO Resource Downloader")
    print("=" * 50)
    print(f"Source: {config.minio_bucket_name}@{config.minio_endpoint}")
    print(f"Destination: {config.download_dir}")

    # Prepare download directory
    if not prepare_download_directory(config.download_dir):
        sys.exit(1)

    # Create MinIO client
    client = create_minio_client(config)

    # Download all files
    stats = download_all_files(
        client,
        config.minio_bucket_name,
        config.download_dir
    )

    # Display summary
    display_summary(stats, config.download_dir)

    # Exit with error code if any downloads failed
    if stats['failed'] > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
