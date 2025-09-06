#!/usr/bin/env python3
"""Alternative FHIR bulk loader using Bundle POST operations.

This approach uses standard FHIR Bundle transactions instead of the $import operation,
which is more widely supported by HAPI FHIR servers.
"""

import asyncio
import gzip
import json
import logging
from pathlib import Path
from typing import Dict, List
import uuid

import aiohttp
from aiohttp import ClientSession, ClientTimeout

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class BundleFhirLoader:
    """FHIR loader using Bundle transactions."""
    
    def __init__(self, base_url: str = "http://localhost:8080/fhir"):
        self.base_url = base_url.rstrip('/')
        self.session: ClientSession = None
    
    async def __aenter__(self):
        """Async context manager entry."""
        timeout = ClientTimeout(total=30)
        self.session = ClientSession(timeout=timeout)
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        if self.session:
            await self.session.close()
    
    async def test_connection(self) -> bool:
        """Test connection to HAPI FHIR server."""
        try:
            metadata_url = f"{self.base_url}/metadata"
            async with self.session.get(metadata_url) as response:
                if response.status == 200:
                    data = await response.json()
                    logger.info(f"Connected to HAPI FHIR server: {data.get('software', {}).get('name', 'Unknown')}")
                    return True
                else:
                    logger.error(f"Failed to connect to HAPI FHIR server: {response.status}")
                    return False
        except Exception as e:
            logger.error(f"Connection test failed: {e}")
            return False
    
    async def create_bundle(self, resources: List[Dict]) -> Dict:
        """Create a FHIR Bundle from a list of resources."""
        bundle = {
            "resourceType": "Bundle",
            "id": str(uuid.uuid4()),
            "type": "transaction",
            "entry": []
        }
        
        for resource in resources:
            resource_id = resource.get('id', str(uuid.uuid4()))
            resource_type = resource.get('resourceType', 'Unknown')
            
            # Ensure resource has an ID
            if 'id' not in resource:
                resource['id'] = resource_id
            
            entry = {
                "resource": resource,
                "request": {
                    "method": "PUT",
                    "url": f"{resource_type}/{resource_id}"
                }
            }
            bundle["entry"].append(entry)
        
        return bundle
    
    async def post_bundle(self, bundle: Dict) -> bool:
        """Post a Bundle to the FHIR server."""
        headers = {
            "Content-Type": "application/fhir+json",
            "Accept": "application/fhir+json"
        }
        
        try:
            async with self.session.post(f"{self.base_url}/", json=bundle, headers=headers) as response:
                if response.status in [200, 201]:
                    result = await response.json()
                    # Count successful entries
                    successful = sum(1 for entry in result.get('entry', []) 
                                   if entry.get('response', {}).get('status', '').startswith(('200', '201')))
                    total = len(result.get('entry', []))
                    logger.info(f"Bundle processed: {successful}/{total} resources successful")
                    return successful > 0
                else:
                    error_text = await response.text()
                    logger.error(f"Bundle POST failed: {response.status} - {error_text}")
                    return False
        except Exception as e:
            logger.error(f"Error posting bundle: {e}")
            return False
    
    async def load_ndjson_file(self, file_path: Path, batch_size: int = 100) -> bool:
        """Load an NDJSON.gz file using Bundle transactions."""
        logger.info(f"Loading {file_path.name}...")
        
        resources = []
        total_processed = 0
        successful_batches = 0
        
        try:
            with gzip.open(file_path, 'rt', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    if line.strip():
                        try:
                            resource = json.loads(line.strip())
                            resources.append(resource)
                            
                            # Process batch when full
                            if len(resources) >= batch_size:
                                bundle = await self.create_bundle(resources)
                                success = await self.post_bundle(bundle)
                                if success:
                                    successful_batches += 1
                                total_processed += len(resources)
                                logger.info(f"Processed batch: {total_processed} resources total")
                                resources = []  # Reset for next batch
                                
                        except json.JSONDecodeError as e:
                            logger.warning(f"Invalid JSON at line {line_num} in {file_path}: {e}")
                
                # Process remaining resources
                if resources:
                    bundle = await self.create_bundle(resources)
                    success = await self.post_bundle(bundle)
                    if success:
                        successful_batches += 1
                    total_processed += len(resources)
                    logger.info(f"Processed final batch: {total_processed} resources total")
        
        except Exception as e:
            logger.error(f"Failed to load file {file_path}: {e}")
            return False
        
        logger.info(f"Completed {file_path.name}: {total_processed} resources in {successful_batches} successful batches")
        return successful_batches > 0

async def test_bundle_upload():
    """Test loading FHIR resources using Bundle transactions."""
    
    # Test files (smallest ones first)
    test_files = [
        "../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir/MimicOrganization.ndjson.gz",
        "../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir/MimicPatient.ndjson.gz",
        "../mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir/MimicLocation.ndjson.gz"
    ]
    
    async with BundleFhirLoader() as loader:
        # Test connection
        print("Testing connection to HAPI FHIR server...")
        if not await loader.test_connection():
            print("Failed to connect to HAPI FHIR server")
            return False
        
        print("Connection successful")
        
        # Process each test file
        all_successful = True
        for file_path_str in test_files:
            file_path = Path(file_path_str)
            if file_path.exists():
                success = await loader.load_ndjson_file(file_path, batch_size=50)
                if not success:
                    all_successful = False
                    logger.error(f"Failed to load {file_path.name}")
                else:
                    logger.info(f"Successfully loaded {file_path.name}")
            else:
                logger.warning(f"File not found: {file_path}")
        
        return all_successful

if __name__ == "__main__":
    print("Starting Bundle-based FHIR loader test...")
    success = asyncio.run(test_bundle_upload())
    if success:
        print("Bundle upload test completed successfully!")
    else:
        print("Bundle upload test failed!")
    exit(0 if success else 1)