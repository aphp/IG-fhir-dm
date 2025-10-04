#!/usr/bin/env python3
"""
MIMIC-IV FHIR NDJSON Uploader to MinIO

This script decompresses NDJSON.gz files and uploads them to MinIO object storage.
"""

import os
import sys
import gzip
import argparse
import logging
from pathlib import Path
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Upload MIMIC-IV FHIR NDJSON files to MinIO',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s --input-dir ../data/fhir
  %(prog)s -i ../data/fhir -b my-bucket
        '''
    )

    parser.add_argument(
        '--input-dir', '-i',
        required=True,
        help='Directory containing NDJSON.gz files'
    )

    parser.add_argument(
        '--bucket', '-b',
        help='MinIO bucket name (overrides .env)'
    )

    parser.add_argument(
        '--log-file', '-l',
        default='upload.log',
        help='Log file path (default: upload.log)'
    )

    return parser.parse_args()


def setup_logging(log_file):
    """Setup logging to console and file."""
    # Create logger
    logger = logging.getLogger('ndjson_uploader')
    logger.setLevel(logging.INFO)

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_format = logging.Formatter('[%(asctime)s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)

    # File handler
    file_handler = logging.FileHandler(log_file, mode='w')
    file_handler.setLevel(logging.INFO)
    file_format = logging.Formatter('[%(asctime)s] %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    file_handler.setFormatter(file_format)
    logger.addHandler(file_handler)

    return logger


def load_config(bucket_override=None):
    """Load and validate environment variables."""
    # Load .env file from script directory
    script_dir = Path(__file__).parent
    env_path = script_dir / '.env'

    if not env_path.exists():
        print(f"Error: .env file not found at {env_path}")
        print("Please create a .env file from .env.example")
        sys.exit(1)

    load_dotenv(env_path)

    # Check required variables
    required_vars = ['MINIO_ENDPOINT', 'MINIO_ACCESS_KEY', 'MINIO_SECRET_KEY', 'MINIO_BUCKET_NAME']
    missing_vars = [var for var in required_vars if not os.getenv(var)]

    if missing_vars:
        print(f"Error: Missing required environment variables: {', '.join(missing_vars)}")
        sys.exit(1)

    # Build config
    config = {
        'endpoint': os.getenv('MINIO_ENDPOINT'),
        'access_key': os.getenv('MINIO_ACCESS_KEY'),
        'secret_key': os.getenv('MINIO_SECRET_KEY'),
        'bucket': bucket_override or os.getenv('MINIO_BUCKET_NAME'),
        'secure': os.getenv('MINIO_SECURE', 'false').lower() == 'true'
    }

    return config


def validate_input_directory(input_dir, logger):
    """Validate input directory exists and has NDJSON files."""
    input_path = Path(input_dir)

    # Check directory exists
    if not input_path.exists():
        logger.error(f"Input directory does not exist: {input_dir}")
        sys.exit(1)

    # Check it's a directory
    if not input_path.is_dir():
        logger.error(f"Input path is not a directory: {input_dir}")
        sys.exit(1)

    # Find .ndjson.gz files
    ndjson_files = list(input_path.glob('*.ndjson.gz'))

    if not ndjson_files:
        logger.error(f"No .ndjson.gz files found in directory: {input_dir}")
        sys.exit(1)

    return input_path, ndjson_files


def decompress_file(gz_file_path, output_path, logger):
    """Decompress a .ndjson.gz file to .ndjson."""
    try:
        with gzip.open(gz_file_path, 'rb') as f_in:
            with open(output_path, 'wb') as f_out:
                # Read and write in chunks to handle large files
                while True:
                    chunk = f_in.read(8192)
                    if not chunk:
                        break
                    f_out.write(chunk)
        return output_path
    except Exception as e:
        logger.error(f"Failed to decompress {gz_file_path.name}: {e}")
        raise


def create_minio_client(config, logger):
    """Create and test MinIO client."""
    try:
        client = Minio(
            config['endpoint'],
            access_key=config['access_key'],
            secret_key=config['secret_key'],
            secure=config['secure']
        )

        # Test connection by listing buckets
        client.list_buckets()
        logger.info("MinIO connection successful")

        return client

    except S3Error as e:
        logger.error(f"MinIO connection failed: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error connecting to MinIO: {e}")
        sys.exit(1)


def ensure_bucket(client, bucket_name, logger):
    """Create bucket if doesn't exist."""
    try:
        if not client.bucket_exists(bucket_name):
            client.make_bucket(bucket_name)
            logger.info(f"Created bucket '{bucket_name}'")
        else:
            logger.info(f"Bucket '{bucket_name}' ready")

    except S3Error as e:
        logger.error(f"Error ensuring bucket exists: {e}")
        sys.exit(1)


def upload_files(client, bucket_name, ndjson_files, logger):
    """Upload all NDJSON files from directory after decompressing."""
    total_files = len(ndjson_files)
    uploaded = 0
    skipped = 0
    failed = 0
    total_compressed_size = 0
    total_decompressed_size = 0

    logger.info(f"Found {total_files} files to upload")
    print()  # Empty line for better readability

    for idx, gz_file_path in enumerate(ndjson_files, 1):
        gz_file_name = gz_file_path.name
        # Remove .gz extension for the decompressed file
        ndjson_file_name = gz_file_name[:-3] if gz_file_name.endswith('.gz') else gz_file_name

        # Create temporary decompressed file path
        temp_ndjson_path = gz_file_path.parent / f".temp_{ndjson_file_name}"

        gz_file_size = gz_file_path.stat().st_size
        gz_file_size_mb = gz_file_size / (1024 * 1024)
        total_compressed_size += gz_file_size

        try:
            # Decompress file
            decompress_file(gz_file_path, temp_ndjson_path, logger)

            # Get decompressed file size
            decompressed_size = temp_ndjson_path.stat().st_size
            decompressed_size_mb = decompressed_size / (1024 * 1024)
            total_decompressed_size += decompressed_size

            # Check if file already exists with same size
            try:
                stat = client.stat_object(bucket_name, ndjson_file_name)
                if stat.size == decompressed_size:
                    print(f"Decompressing and uploading file {idx}/{total_files}: {gz_file_name} → {ndjson_file_name} ({decompressed_size_mb:.1f} MB) already exists, skipped")
                    logger.info(f"Skipped {ndjson_file_name} (already exists)")
                    skipped += 1
                    # Clean up temp file
                    temp_ndjson_path.unlink()
                    continue
            except S3Error:
                # File doesn't exist, proceed with upload
                pass

            # Upload decompressed file
            print(f"Decompressing and uploading file {idx}/{total_files}: {gz_file_name} → {ndjson_file_name} ({decompressed_size_mb:.1f} MB) ", end='', flush=True)

            client.fput_object(
                bucket_name,
                ndjson_file_name,
                str(temp_ndjson_path)
            )

            print("✓")
            logger.info(f"Uploaded {ndjson_file_name} ({decompressed_size_mb:.1f} MB)")
            uploaded += 1

            # Clean up temp file
            temp_ndjson_path.unlink()

        except Exception as e:
            print(f"✗ Failed")
            logger.error(f"Failed to process {gz_file_name}: {e}")
            failed += 1
            # Try to clean up temp file if it exists
            if temp_ndjson_path.exists():
                try:
                    temp_ndjson_path.unlink()
                except:
                    pass

    return {
        'total': total_files,
        'uploaded': uploaded,
        'skipped': skipped,
        'failed': failed,
        'total_compressed_size': total_compressed_size,
        'total_decompressed_size': total_decompressed_size
    }


def main():
    """Main entry point."""
    # Parse arguments
    args = parse_arguments()

    # Setup logging
    logger = setup_logging(args.log_file)

    logger.info("Starting upload...")

    # Load config
    config = load_config(args.bucket)

    # Print configuration (mask secret key)
    logger.info("Configuration:")
    logger.info(f"  - Endpoint: {config['endpoint']}")
    logger.info(f"  - Bucket: {config['bucket']}")
    logger.info(f"  - Input: {args.input_dir}")
    logger.info(f"  - Log file: {args.log_file}")
    print()  # Empty line for better readability

    # Validate input directory
    input_path, ndjson_files = validate_input_directory(args.input_dir, logger)

    # Create MinIO client
    client = create_minio_client(config, logger)

    # Ensure bucket exists
    ensure_bucket(client, config['bucket'], logger)

    # Upload files
    stats = upload_files(client, config['bucket'], ndjson_files, logger)

    # Print summary
    print()  # Empty line for better readability
    logger.info("Upload complete!")
    print("Summary:")
    print(f"  - Total files: {stats['total']}")
    print(f"  - Uploaded: {stats['uploaded']}")
    print(f"  - Skipped: {stats['skipped']}")
    print(f"  - Failed: {stats['failed']}")
    print(f"  - Total compressed size: {stats['total_compressed_size'] / (1024 * 1024):.1f} MB")
    print(f"  - Total decompressed size: {stats['total_decompressed_size'] / (1024 * 1024):.1f} MB")
    print(f"  - Log file: {args.log_file}")

    # Exit with appropriate code
    if stats['failed'] > 0:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
