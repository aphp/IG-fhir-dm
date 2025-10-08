#!/usr/bin/env python3
"""
MinIO Resource Lister
List all FHIR NDJSON files in MinIO bucket.
"""

import argparse
import sys
from pathlib import Path
from minio.error import S3Error

# Add common directory to path
sys.path.insert(0, str(Path(__file__).parent))

from common.config import Config
from common.minio_client import MinIOClientWrapper
from common.utils import format_size


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='List all FHIR NDJSON files in MinIO bucket',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # List files in default bucket
  %(prog)s --bucket my-bucket        # List files in specific bucket
  %(prog)s --verbose                 # Show file size and modified date
        """
    )

    parser.add_argument(
        '--bucket', '-b',
        type=str,
        help='Override bucket name from .env file'
    )

    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show file size and last modified date'
    )

    return parser.parse_args()


def load_config(bucket_override=None):
    """
    Load environment variables from .env file.

    Args:
        bucket_override: Optional bucket name to override .env value

    Returns:
        Config object with loaded configuration
    """
    try:
        config = Config()

        # Override bucket if specified
        if bucket_override:
            config.minio_bucket_name = bucket_override

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


def list_ndjson_files(client, bucket_name, verbose=False):
    """
    List all NDJSON files in the bucket.

    Args:
        client: MinIOClientWrapper instance
        bucket_name: Name of the bucket
        verbose: If True, include file size and last modified date

    Returns:
        List of files (simple list or list of dicts if verbose)
    """
    try:
        # Test connection first
        if not client.test_connection(bucket_name):
            sys.exit(1)

        # Get file list
        if verbose:
            files = client.list_ndjson_files_with_details(bucket_name)
        else:
            files = client.list_ndjson_files(bucket_name)

        return files

    except S3Error as e:
        print(f"❌ MinIO error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)


def display_results(bucket_name, endpoint, files, verbose=False):
    """
    Display the results in a formatted way.

    Args:
        bucket_name: Name of the bucket
        endpoint: MinIO endpoint
        files: List of files (simple list or list of dicts)
        verbose: If True, show detailed information
    """
    print("=" * 50)
    print("MinIO Resource Lister")
    print("=" * 50)
    print(f"Bucket: {bucket_name}")
    print(f"Endpoint: {endpoint}")
    print()

    if not files:
        print("📋 NDJSON Files: (empty)")
        print()
        print("Total files: 0")
        print("=" * 50)
        return

    print("📋 NDJSON Files:")

    if verbose:
        # Display with details
        for file in files:
            size_str = format_size(file['size'])
            date_str = file['last_modified'].strftime('%Y-%m-%d %H:%M:%S')
            print(f"  - {file['name']} ({size_str}, {date_str})")
    else:
        # Display simple list
        for filename in files:
            print(f"  - {filename}")

    print()
    print(f"Total files: {len(files)}")
    print("=" * 50)


def main():
    """Main entry point."""
    # Parse arguments
    args = parse_arguments()

    # Load configuration
    config = load_config(bucket_override=args.bucket)

    # Create MinIO client
    client = create_minio_client(config)

    # List files
    files = list_ndjson_files(
        client,
        config.minio_bucket_name,
        verbose=args.verbose
    )

    # Display results
    display_results(
        config.minio_bucket_name,
        config.minio_endpoint,
        files,
        verbose=args.verbose
    )


if __name__ == "__main__":
    main()
