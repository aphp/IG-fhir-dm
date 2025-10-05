# MinIO to FHIR Pipeline Orchestrator - Feature 5

## Objective
Create a master orchestrator script that executes the complete data pipeline: list → download → upload → cleanup in a single command.

## Context


### Project Structure

minio_to_fhir project following directory structure:

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
          └── minio_to_fhir.py          # Feature 5: Orchestrator (this feature)
```

### Workflow
```
┌─────────────────────────────────────────────────────────────┐
│                    MinIO to FHIR Pipeline                   │
└─────────────────────────────────────────────────────────────┘

Step 1: LIST RESOURCES         [Feature 1]
   ├─ Connect to MinIO
   ├─ List all NDJSON files
   ├─ Group by resource type
   └─ Display summary
          ↓
Step 2: DOWNLOAD RESOURCES     [Feature 2]
   ├─ Download from MinIO
   ├─ Save to DOWNLOAD_DIR
   └─ Verify downloads
          ↓
Step 3: UPLOAD TO FHIR         [Feature 3]
   ├─ Test FHIR server
   ├─ Sort by dependency order
   ├─ Upload batches
   └─ Track results
          ↓
Step 4: CLEANUP (optional)     [Feature 4]
   ├─ Remove downloaded files
   └─ Remove empty directories

Result: FHIR resources loaded ✓
```

## Requirements

### 1. Command-Line Interface

```bash
# Full pipeline with defaults
python minio_to_fhir.py

# Custom bucket and directories
python minio_to_fhir.py --bucket fhir-prod --download-dir /data/temp

# Skip cleanup
python minio_to_fhir.py --no-cleanup

# Filter specific resources
python minio_to_fhir.py --filter "Patient,Observation"

# Dry run (no upload or cleanup)
python minio_to_fhir.py --dry-run

# Continue on errors
python minio_to_fhir.py --continue-on-error

# Verbose logging
python minio_to_fhir.py --verbose

# Custom batch size
python minio_to_fhir.py --batch-size 50

# Start from specific step
python minio_to_fhir.py --start-from upload

# Execute only specific steps
python minio_to_fhir.py --steps list,download

# Help
python minio_to_fhir.py --help
```

**Arguments**:
- `--bucket` / `-b`: MinIO bucket name (override .env)
- `--download-dir` / `-d`: Download directory (override .env)
- `--filter` / `-f`: Filter resource types (comma-separated)
- `--batch-size` / `-s`: Batch size for uploads (override .env)
- `--no-cleanup`: Skip cleanup step
- `--continue-on-error`: Continue if step fails
- `--dry-run`: Preview without executing upload/cleanup
- `--verbose` / `-v`: Verbose output
- `--start-from`: Start from step: list, download, upload, cleanup
- `--steps`: Execute only specific steps (comma-separated)
- `--log-file` / `-l`: Log file path (default: pipeline.log)

### 2. Core Functionality

**Must do**:
1. Load configuration from .env
2. Validate all prerequisites (MinIO, FHIR server)
3. Execute pipeline steps in order
4. Track overall progress and statistics
5. Handle errors at step level
6. Generate comprehensive report
7. Support partial execution (start from step, execute specific steps)
8. Support dry-run mode
9. Log all operations

**Step Integration**:
Each step should be implemented as a function that:
- Takes configuration as input
- Returns status (success/failure) and results
- Can be skipped based on arguments
- Logs its progress

### 3. Code Structure

```python
#!/usr/bin/env python3
"""
MinIO to FHIR Pipeline Orchestrator

Complete pipeline to transfer FHIR resources from MinIO to HAPI FHIR server:
1. List resources in MinIO
2. Download resources from MinIO
3. Upload resources to HAPI FHIR (batch transactions)
4. Cleanup temporary files

Usage:
    python minio_to_fhir.py [options]
"""

import sys
import argparse
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Import common utilities
from common.config import Config
from common.minio_client import MinIOClientWrapper
from common.fhir_client import FHIRClientWrapper
from common.utils import format_size, format_duration, setup_logging

# Import feature modules (these will be implemented as importable functions)
# If features 1-4 are scripts, we can import their main functions or
# refactor them to expose core functions
# For this orchestrator, assume features expose these functions:
# from list_minio_resources import list_resources
# from download_minio_resources import download_resources  
# from upload_to_fhir import upload_resources
# from cleanup_ndjson_files import cleanup_files

class PipelineOrchestrator:
    """Orchestrates the complete MinIO to FHIR pipeline."""
    
    STEPS = ['list', 'download', 'upload', 'cleanup']
    
    def __init__(self, config: Config, args: argparse.Namespace):
        """
        Initialize pipeline orchestrator.
        
        Args:
            config: Configuration object
            args: Parsed command-line arguments
        """
        self.config = config
        self.args = args
        self.results = {
            'list': None,
            'download': None,
            'upload': None,
            'cleanup': None
        }
        self.start_time = None
        self.end_time = None
    
    def validate_prerequisites(self) -> bool:
        """
        Validate that MinIO and FHIR servers are accessible.
        
        Returns:
            True if all prerequisites are met
        """
        print("\n" + "=" * 70)
        print("VALIDATING PREREQUISITES")
        print("=" * 70)
        
        # Test MinIO connection
        print("\n[1/2] Testing MinIO connection...")
        minio_client = MinIOClientWrapper(
            self.config.minio_endpoint,
            self.config.minio_access_key,
            self.config.minio_secret_key,
            self.config.minio_secure
        )
        
        bucket_name = self.args.bucket or self.config.minio_bucket_name
        if not minio_client.test_connection(bucket_name):
            print("❌ MinIO validation failed")
            return False
        print(f"✓ MinIO connection successful (bucket: {bucket_name})")
        
        # Test FHIR server connection (skip if not uploading)
        if 'upload' in self.get_steps_to_execute():
            print("\n[2/2] Testing FHIR server connection...")
            fhir_client = FHIRClientWrapper(
                self.config.fhir_base_url,
                self.config.fhir_auth_enabled,
                self.config.fhir_username,
                self.config.fhir_password
            )
            
            success, version = fhir_client.test_connection()
            if not success:
                print("❌ FHIR server validation failed")
                return False
            print(f"✓ FHIR server accessible (version: {version})")
        else:
            print("\n[2/2] Skipping FHIR server validation (upload not requested)")
        
        print("\n✓ All prerequisites validated")
        return True
    
    def get_steps_to_execute(self) -> List[str]:
        """
        Determine which steps to execute based on arguments.
        
        Returns:
            List of step names to execute
        """
        # If specific steps requested
        if self.args.steps:
            requested_steps = [s.strip() for s in self.args.steps.split(',')]
            return [s for s in requested_steps if s in self.STEPS]
        
        # If start-from specified
        if self.args.start_from:
            start_idx = self.STEPS.index(self.args.start_from)
            steps = self.STEPS[start_idx:]
        else:
            steps = self.STEPS.copy()
        
        # Remove cleanup if --no-cleanup
        if self.args.no_cleanup and 'cleanup' in steps:
            steps.remove('cleanup')
        
        return steps
    
    def step_1_list_resources(self) -> Tuple[bool, Dict]:
        """
        Step 1: List all NDJSON files in MinIO.
        
        Returns:
            Tuple of (success, results_dict)
        """
        print("\n" + "=" * 70)
        print("STEP 1: LIST RESOURCES IN MINIO")
        print("=" * 70)
        
        try:
            # Implementation of list_resources logic
            # This should call Feature 1 functionality
            # For now, placeholder:
            
            minio_client = MinIOClientWrapper(
                self.config.minio_endpoint,
                self.config.minio_access_key,
                self.config.minio_secret_key,
                self.config.minio_secure
            )
            
            bucket_name = self.args.bucket or self.config.minio_bucket_name
            files = minio_client.list_ndjson_files(bucket_name)
            
            # Group by resource type
            from common.utils import get_resource_type_from_filename
            files_by_type = {}
            for file in files:
                resource_type = get_resource_type_from_filename(file)
                if resource_type:
                    if resource_type not in files_by_type:
                        files_by_type[resource_type] = []
                    files_by_type[resource_type].append(file)
            
            # Display results
            print(f"\n✓ Found {len(files)} NDJSON files")
            print(f"✓ Resource types: {len(files_by_type)}")
            
            for resource_type, resource_files in sorted(files_by_type.items()):
                print(f"  - {resource_type}: {len(resource_files)} file(s)")
            
            results = {
                'total_files': len(files),
                'files_by_type': files_by_type,
                'success': True
            }
            
            return True, results
            
        except Exception as e:
            print(f"❌ Error in list step: {e}")
            return False, {'success': False, 'error': str(e)}
    
    def step_2_download_resources(self) -> Tuple[bool, Dict]:
        """
        Step 2: Download NDJSON files from MinIO.
        
        Returns:
            Tuple of (success, results_dict)
        """
        print("\n" + "=" * 70)
        print("STEP 2: DOWNLOAD RESOURCES FROM MINIO")
        print("=" * 70)
        
        if self.args.dry_run:
            print("\n⊘ Dry run mode - skipping actual download")
            return True, {'success': True, 'dry_run': True}
        
        try:
            # Implementation of download_resources logic
            # This should call Feature 2 functionality
            # Placeholder implementation
            
            minio_client = MinIOClientWrapper(
                self.config.minio_endpoint,
                self.config.minio_access_key,
                self.config.minio_secret_key,
                self.config.minio_secure
            )
            
            # Get files from Step 1 results
            if not self.results['list']:
                print("⚠️  No list results available, listing files now...")
                success, list_results = self.step_1_list_resources()
                if not success:
                    return False, {'success': False, 'error': 'Failed to list files'}
                self.results['list'] = list_results
            
            files_by_type = self.results['list']['files_by_type']
            bucket_name = self.args.bucket or self.config.minio_bucket_name
            download_dir = Path(self.args.download_dir or self.config.download_dir)
            
            # Create download directory
            download_dir.mkdir(parents=True, exist_ok=True)
            
            downloaded = 0
            failed = 0
            total_size = 0
            
            # Download all files
            all_files = []
            for files in files_by_type.values():
                all_files.extend(files)
            
            print(f"\nDownloading {len(all_files)} files to {download_dir}")
            
            for i, file in enumerate(all_files, 1):
                local_path = download_dir / file
                print(f"[{i}/{len(all_files)}] {file}...", end=' ')
                
                if minio_client.download_file(bucket_name, file, local_path):
                    size = local_path.stat().st_size
                    total_size += size
                    downloaded += 1
                    print(f"✓ ({format_size(size)})")
                else:
                    failed += 1
                    print("✗")
            
            results = {
                'total_files': len(all_files),
                'downloaded': downloaded,
                'failed': failed,
                'total_size': total_size,
                'download_dir': str(download_dir),
                'success': failed == 0
            }
            
            print(f"\n✓ Downloaded {downloaded}/{len(all_files)} files ({format_size(total_size)})")
            if failed > 0:
                print(f"⚠️  {failed} file(s) failed to download")
            
            return failed == 0, results
            
        except Exception as e:
            print(f"❌ Error in download step: {e}")
            return False, {'success': False, 'error': str(e)}
    
    def step_3_upload_to_fhir(self) -> Tuple[bool, Dict]:
        """
        Step 3: Upload resources to HAPI FHIR server.
        
        Returns:
            Tuple of (success, results_dict)
        """
        print("\n" + "=" * 70)
        print("STEP 3: UPLOAD RESOURCES TO HAPI FHIR")
        print("=" * 70)
        
        if self.args.dry_run:
            print("\n⊘ Dry run mode - skipping actual upload")
            return True, {'success': True, 'dry_run': True}
        
        try:
            # Implementation of upload_resources logic
            # This should call Feature 3 functionality
            # This is a complex step that needs full implementation
            # For now, placeholder that indicates Feature 3 should be called
            
            print("\n⚠️  Upload step needs Feature 3 implementation")
            print("This step should:")
            print("  1. Read NDJSON files from download directory")
            print("  2. Sort by resource dependency order")
            print("  3. Create batch bundles")
            print("  4. POST to FHIR server")
            print("  5. Track success/failure")
            
            # Placeholder results
            results = {
                'total_resources': 0,
                'uploaded': 0,
                'failed': 0,
                'success': True,
                'placeholder': True
            }
            
            return True, results
            
        except Exception as e:
            print(f"❌ Error in upload step: {e}")
            return False, {'success': False, 'error': str(e)}
    
    def step_4_cleanup_files(self) -> Tuple[bool, Dict]:
        """
        Step 4: Cleanup downloaded files.
        
        Returns:
            Tuple of (success, results_dict)
        """
        print("\n" + "=" * 70)
        print("STEP 4: CLEANUP TEMPORARY FILES")
        print("=" * 70)
        
        if self.args.dry_run:
            print("\n⊘ Dry run mode - skipping actual cleanup")
            return True, {'success': True, 'dry_run': True}
        
        try:
            # Implementation of cleanup_files logic
            # This should call Feature 4 functionality
            
            download_dir = Path(self.args.download_dir or self.config.download_dir)
            
            if not download_dir.exists():
                print(f"⚠️  Directory does not exist: {download_dir}")
                return True, {'success': True, 'nothing_to_clean': True}
            
            # Count files before cleanup
            ndjson_files = list(download_dir.glob('**/*.ndjson'))
            
            if not ndjson_files:
                print(f"⚠️  No NDJSON files found in {download_dir}")
                return True, {'success': True, 'nothing_to_clean': True}
            
            print(f"\nRemoving {len(ndjson_files)} NDJSON files from {download_dir}")
            
            deleted = 0
            for file in ndjson_files:
                try:
                    file.unlink()
                    deleted += 1
                except Exception as e:
                    print(f"⚠️  Failed to delete {file.name}: {e}")
            
            # Remove empty directories if configured
            if not self.config.keep_empty_dirs:
                # Remove empty subdirectories
                for subdir in sorted(download_dir.glob('**/'), reverse=True):
                    if subdir != download_dir and not any(subdir.iterdir()):
                        subdir.rmdir()
            
            results = {
                'files_deleted': deleted,
                'success': True
            }
            
            print(f"✓ Cleaned up {deleted} file(s)")
            
            return True, results
            
        except Exception as e:
            print(f"❌ Error in cleanup step: {e}")
            return False, {'success': False, 'error': str(e)}
    
    def run(self) -> bool:
        """
        Execute the complete pipeline.
        
        Returns:
            True if pipeline completed successfully
        """
        self.start_time = time.time()
        
        # Display header
        print("\n" + "=" * 70)
        print("MINIO TO FHIR PIPELINE")
        print("=" * 70)
        print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Display configuration
        self.config.display_config(mask_credentials=True)
        
        # Get steps to execute
        steps = self.get_steps_to_execute()
        print(f"\nSteps to execute: {', '.join(steps)}")
        
        if self.args.dry_run:
            print("\n⚠️  DRY RUN MODE - No modifications will be made")
        
        # Validate prerequisites
        if not self.validate_prerequisites():
            print("\n❌ Pipeline aborted - prerequisites not met")
            return False
        
        # Execute steps
        step_functions = {
            'list': self.step_1_list_resources,
            'download': self.step_2_download_resources,
            'upload': self.step_3_upload_to_fhir,
            'cleanup': self.step_4_cleanup_files
        }
        
        overall_success = True
        
        for step_name in steps:
            step_func = step_functions[step_name]
            
            try:
                success, results = step_func()
                self.results[step_name] = results
                
                if not success:
                    overall_success = False
                    if not self.args.continue_on_error:
                        print(f"\n❌ Pipeline stopped at step '{step_name}'")
                        break
                    else:
                        print(f"\n⚠️  Step '{step_name}' failed, continuing...")
                
            except Exception as e:
                print(f"\n❌ Unexpected error in step '{step_name}': {e}")
                overall_success = False
                if not self.args.continue_on_error:
                    break
        
        # Display final report
        self.end_time = time.time()
        self.display_final_report(overall_success)
        
        return overall_success
    
    def display_final_report(self, success: bool):
        """Display final pipeline report."""
        duration = self.end_time - self.start_time
        
        print("\n" + "=" * 70)
        print("PIPELINE SUMMARY")
        print("=" * 70)
        
        print(f"\nStatus: {'✓ SUCCESS' if success else '✗ FAILED'}")
        print(f"Duration: {format_duration(duration)}")
        print(f"Completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Step-by-step results
        print("\nStep Results:")
        for step_name, results in self.results.items():
            if results is None:
                continue
            
            status = "✓" if results.get('success', False) else "✗"
            print(f"  {status} {step_name.title()}")
            
            # Display relevant metrics
            if step_name == 'list' and results.get('total_files'):
                print(f"      Files found: {results['total_files']}")
            
            elif step_name == 'download' and not results.get('dry_run'):
                print(f"      Downloaded: {results.get('downloaded', 0)}")
                if results.get('failed', 0) > 0:
                    print(f"      Failed: {results.get('failed', 0)}")
            
            elif step_name == 'upload' and not results.get('dry_run'):
                print(f"      Uploaded: {results.get('uploaded', 0)}")
                if results.get('failed', 0) > 0:
                    print(f"      Failed: {results.get('failed', 0)}")
            
            elif step_name == 'cleanup' and not results.get('dry_run'):
                print(f"      Files deleted: {results.get('files_deleted', 0)}")
        
        print("\n" + "=" * 70)

def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='MinIO to FHIR complete data pipeline',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Full pipeline
  %(prog)s
  
  # Custom bucket and directory
  %(prog)s -b fhir-prod -d /data/temp
  
  # Filter specific resources
  %(prog)s -f "Patient,Observation"
  
  # Dry run
  %(prog)s --dry-run
  
  # Skip cleanup
  %(prog)s --no-cleanup
  
  # Start from upload step
  %(prog)s --start-from upload
  
  # Execute only specific steps
  %(prog)s --steps list,download
        '''
    )
    
    parser.add_argument(
        '--bucket', '-b',
        help='MinIO bucket name (override .env)'
    )
    
    parser.add_argument(
        '--download-dir', '-d',
        help='Download directory (override .env)'
    )
    
    parser.add_argument(
        '--filter', '-f',
        help='Filter resource types (comma-separated)'
    )
    
    parser.add_argument(
        '--batch-size', '-s',
        type=int,
        help='Batch size for uploads (override .env)'
    )
    
    parser.add_argument(
        '--no-cleanup',
        action='store_true',
        help='Skip cleanup step'
    )
    
    parser.add_argument(
        '--continue-on-error',
        action='store_true',
        help='Continue if a step fails'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview without executing upload/cleanup'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )
    
    parser.add_argument(
        '--start-from',
        choices=['list', 'download', 'upload', 'cleanup'],
        help='Start from specific step'
    )
    
    parser.add_argument(
        '--steps',
        help='Execute only specific steps (comma-separated)'
    )
    
    parser.add_argument(
        '--log-file', '-l',
        default='pipeline.log',
        help='Log file path (default: pipeline.log)'
    )
    
    return parser.parse_args()

def main():
    """Main entry point."""
    # Parse arguments
    args = parse_arguments()
    
    # Setup logging
    setup_logging(args.log_file, args.verbose)
    
    try:
        # Load configuration
        config = Config()
        
        # Override config with command-line arguments
        if args.bucket:
            config.minio_bucket_name = args.bucket
        if args.download_dir:
            config.download_dir = Path(args.download_dir)
        if args.batch_size:
            config.batch_size = args.batch_size
        
        # Create and run orchestrator
        orchestrator = PipelineOrchestrator(config, args)
        success = orchestrator.run()
        
        # Exit with appropriate code
        sys.exit(0 if success else 1)
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Pipeline interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Integration Requirements

**CRITICAL**: For the orchestrator to work properly, Features 1-4 must expose their core functionality as importable functions:

### Feature 1 (list_minio_resources.py)
```python
def list_resources(config, bucket_name=None):
    """List all NDJSON files in MinIO bucket."""
    # Return dict with files_by_type
    pass
```

### Feature 2 (download_minio_resources.py)
```python
def download_resources(config, files_by_type, download_dir):
    """Download NDJSON files from MinIO."""
    # Return dict with download stats
    pass
```

### Feature 3 (upload_to_fhir.py)
```python
def upload_resources(config, source_dir, batch_size, continue_on_error):
    """Upload resources to FHIR server."""
    # Return dict with upload stats
    pass
```

### Feature 4 (cleanup_ndjson_files.py)
```python
def cleanup_files(config, directory, keep_structure):
    """Cleanup NDJSON files."""
    # Return dict with cleanup stats
    pass
```

## Output Example

```bash
$ python minio_to_fhir.py

======================================================================
MINIO TO FHIR PIPELINE
======================================================================
Started: 2025-10-04 15:30:00

==================================================
Configuration
==================================================

[MinIO]
  Endpoint: localhost:9000
  Bucket: fhir-data
  Access Key: ********
  Secret Key: ********
  Secure: False

[FHIR Server]
  Base URL: http://localhost:8080/fhir
  Authentication: Disabled

[Directories]
  Download: /tmp/fhir-download
  Upload: /tmp/fhir-upload

[Pipeline]
  Batch Size: 100
  Continue on Error: True
  Auto Cleanup: True
==================================================

Steps to execute: list, download, upload, cleanup

======================================================================
VALIDATING PREREQUISITES
======================================================================

[1/2] Testing MinIO connection...
✓ MinIO connection successful (bucket: fhir-data)

[2/2] Testing FHIR server connection...
✓ FHIR server accessible (version: 6.8.0)

✓ All prerequisites validated

======================================================================
STEP 1: LIST RESOURCES IN MINIO
======================================================================

✓ Found 11 NDJSON files
✓ Resource types: 8
  - Condition: 1 file(s)
  - Encounter: 1 file(s)
  - Location: 1 file(s)
  - Medication: 1 file(s)
  - Observation: 3 file(s)
  - Organization: 1 file(s)
  - Patient: 2 file(s)
  - Procedure: 1 file(s)

======================================================================
STEP 2: DOWNLOAD RESOURCES FROM MINIO
======================================================================

Downloading 11 files to /tmp/fhir-download
[1/11] Organization.ndjson... ✓ (45.2 KB)
[2/11] Location.ndjson... ✓ (23.1 KB)
[3/11] Medication.ndjson... ✓ (156.3 KB)
[4/11] Patient.ndjson... ✓ (1.2 MB)
[5/11] Patient_part2.ndjson... ✓ (245.7 KB)
[6/11] Encounter.ndjson... ✓ (2.3 MB)
[7/11] Observation_labs.ndjson... ✓ (3.4 MB)
[8/11] Observation_vitals.ndjson... ✓ (2.1 MB)
[9/11] Observation_other.ndjson... ✓ (1.5 MB)
[10/11] Procedure.ndjson... ✓ (890.2 KB)
[11/11] Condition.ndjson... ✓ (567.8 KB)

✓ Downloaded 11/11 files (12.4 MB)

======================================================================
STEP 3: UPLOAD RESOURCES TO HAPI FHIR
======================================================================

⚠️  Upload step needs Feature 3 implementation
This step should:
  1. Read NDJSON files from download directory
  2. Sort by resource dependency order
  3. Create batch bundles
  4. POST to FHIR server
  5. Track success/failure

======================================================================
STEP 4: CLEANUP TEMPORARY FILES
======================================================================

Removing 11 NDJSON files from /tmp/fhir-download
✓ Cleaned up 11 file(s)

======================================================================
PIPELINE SUMMARY
======================================================================

Status: ✓ SUCCESS
Duration: 2m 35s
Completed: 2025-10-04 15:32:35

Step Results:
  ✓ List
      Files found: 11
  ✓ Download
      Downloaded: 11
  ✓ Upload
      Uploaded: 0
  ✓ Cleanup
      Files deleted: 11

======================================================================
```

## Success Criteria

✅ Orchestrates all 4 features in correct order  
✅ Validates prerequisites before execution  
✅ Supports partial execution (specific steps)  
✅ Supports dry-run mode  
✅ Handles errors gracefully  
✅ Provides comprehensive reporting  
✅ Supports all configuration options  
✅ Logs all operations  
✅ Can continue on errors  
✅ Clean command-line interface  

## Deliverables

1. `minio_to_fhir.py` - Complete orchestrator
2. Integration with Features 1-4 (ensure they expose callable functions)
3. Comprehensive help text and examples

## Notes

- The orchestrator should work even if some features are not fully implemented (graceful degradation)
- Each step should be independently testable
- The pipeline should be resumable from any step
- All operations should be logged for debugging
- The dry-run mode should preview all operations without making changes
```