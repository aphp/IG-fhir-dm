# HAPI FHIR Bundle Batch Preparation Tool

## Objective
Create a Python script to transform FHIR NDJSON files into FHIR Bundle (type: batch) JSON files, automatically analyzing resource references to determine optimal upload order while respecting referential integrity.

## Project Structure

```
data-platform/
└── share-layer/
      └── minio_to_fhir/
          ├── .env.example                # Configuration template
          ├── .env                        # Local config (gitignored)
          ├── .gitignore                  # Git ignore rules
          ├── requirements.txt            # Python dependencies
          ├── README.md                   # Project documentation
          ├── common/                     # Shared utilities
          │   ├── __init__.py
          │   ├── config.py               # Configuration loader
          │   ├── minio_client.py         # MinIO client wrapper
          │   ├── fhir_client.py          # FHIR client wrapper
          │   └── utils.py                # Common utilities
          ├── list_minio_resources.py     # Feature 1: List
          ├── download_minio_resources.py # Feature 2: Download
          └── prepare_fhir_bundles.py     # This script
```

## Configuration (.env)
```bash
# Bundle Preparation Configuration
INPUT_DIR=./tmp/fhir-download       # Source NDJSON files (from download step)
OUTPUT_DIR=./tmp/fhir-updalod        # Destination for Bundle JSON files
BATCH_SIZE=100                      # Resources per bundle
ANALYZE_REFERENCES=true             # Enable smart reference analysis
PRESERVE_IDS=true                   # Keep original resource IDs
```

## Command-Line Interface
```bash
# Basic usage - prepare bundles from default directories
python prepare_fhir_bundles.py

# With custom directories
python prepare_fhir_bundles.py --input ./downloaded --output ./bundles

# With custom batch size
python prepare_fhir_bundles.py --batch-size 50

# Skip reference analysis (use default order)
python prepare_fhir_bundles.py --no-analyze

# Help
python prepare_fhir_bundles.py --help
```

**Arguments**:
- `--input` / `-i`: Source directory with NDJSON files (overrides .env)
- `--output` / `-o`: Output directory for Bundle JSON files (overrides .env)
- `--batch-size` / `-s`: Resources per bundle (default: 100)
- `--no-analyze`: Skip reference analysis, use default order
- `--preserve-ids`: Keep original resource IDs (default: true)

## Reference Analysis Algorithm (CRITICAL)

The script **automatically analyzes** actual references between resources to determine optimal upload order:

### Phase 1: Resource Discovery
- Scan all NDJSON files
- Extract resource type and ID from each resource
- Build resource inventory

### Phase 2: Reference Extraction
For each resource, extract all references:
- Direct references: `subject.reference`, `patient.reference`, `encounter.reference`, `recorder.reference`
- Array references: `participant[].actor.reference`, `performer[].actor.reference`, `performer[].reference`, `authorizingPrescription[].reference`
- Reference patterns: `ResourceType/id` or relative references

### Phase 3: Dependency Graph Construction
- Build directed graph: Resource A → Resource B (A references B)
- Identify resource types without dependencies (roots)
- Detect circular references (warn user)

### Phase 4: Topological Sort
- Sort resource types by dependency order
- Resources with no dependencies come first
- Resources referencing others come after their dependencies
- Handle same-level resources (can be uploaded in parallel)

### Fallback Order (if analysis disabled)
```python
DEFAULT_RESOURCE_ORDER = [
    'Organization',
    'Location',
    'Practitioner',
    'PractitionerRole',
    'Patient',
    'Encounter',
    'Condition',
    'Specimen',
    'Medication',
    'Observation',
    'Procedure',
    'MedicationRequest',
    'MedicationDispense',
    'MedicationStatement',
    'MedicationAdministration'
]
```

## Output Structure

For each dependency level, create numbered bundle files:

```
output-dir/
├── upload-plan.json              # Dependency analysis results
├── level-01/
│   ├── organization-batch-001.json          
│   └── medication-batch-001.json
├── level-02/
│   ├── location-batch-001.json
│   ├── patient-batch-001.json
│   └── patient-batch-002.json
├── level-03/
│   ├── encounter-batch-001.json
│   └── specimen-batch-001.json
├── level-04/
│   ├── condition-batch-001.json
│   ├── medication-request-batch-001.json
│   ├── procedure-batch-001.json
└── level-05/
    ├── observation-batch-001.json
    ├── observation-batch-002.json
    ├── medication-dispense-batch-001.json
    └── medication-administration-batch-001.json
```

**upload-plan.json** structure:
```json
{
  "analysis_timestamp": "2025-10-09T14:30:00Z",
  "total_resources": 2845,
  "total_bundles": 32,
  "reference_analysis_enabled": true,
  "dependency_levels": [
    {
      "level": 1,
      "resource_types": ["Organization", "Location"],
      "total_resources": 47,
      "bundles": 1
    },
    {
      "level": 2,
      "resource_types": ["Patient"],
      "total_resources": 250,
      "bundles": 3,
      "dependencies": ["Organization", "Location"]
    },
    {
      "level": 3,
      "resource_types": ["Encounter"],
      "total_resources": 420,
      "bundles": 5,
      "dependencies": ["Patient", "Location", "Organization"]
    }
  ],
  "circular_references": [],
  "orphaned_references": [
    {
      "resource": "Observation/obs-123",
      "missing_reference": "Encounter/enc-999",
      "reference_path": "encounter.reference"
    }
  ]
}
```

## Bundle Structure (Output JSON)

Each bundle file contains:
```json
{
  "resourceType": "Bundle",
  "type": "batch",
  "entry": [
    {
      "request": {
        "method": "PUT",
        "url": "Patient/patient-001"
      },
      "resource": {
        "resourceType": "Patient",
        "id": "patient-001",
        "identifier": [...],
        "name": [...]
      }
    },
    {
      "request": {
        "method": "PUT",
        "url": "Patient/patient-002"
      },
      "resource": {
        "resourceType": "Patient",
        "id": "patient-002",
        ...
      }
    }
  ]
}
```

## Console Output Format

```
=== FHIR Bundle Preparation Tool ===
Input: /tmp/fhir-download
Output: /tmp/fhir-bundles
Batch Size: 100
Reference Analysis: ENABLED

[Phase 1] Discovering resources...
Found 8 NDJSON files
Scanning resources: ████████████████████ 2,845/2,845 resources

Resource inventory:
  Organization: 12 resources
  Location: 35 resources
  Patient: 250 resources
  Encounter: 420 resources
  Observation: 1,456 resources
  Condition: 312 resources
  Procedure: 245 resources
  MedicationRequest: 115 resources

[Phase 2] Extracting references...
Analyzing references: ████████████████████ 2,845/2,845 resources
Found 8,234 references across 2,845 resources

[Phase 3] Building dependency graph...
✓ Graph constructed
✓ No circular dependencies detected
⚠ Found 3 orphaned references (see upload-plan.json)

[Phase 4] Computing upload order...
Topological sort completed: 5 dependency levels

Dependency levels:
  Level 1: Organization, Location (47 resources)
  Level 2: Patient (250 resources)
  Level 3: Encounter (420 resources)
  Level 4: Condition, Specimen (357 resources)
  Level 5: Observation, Procedure, MedicationRequest (1,771 resources)

[Phase 5] Creating bundle files...
  Level 1 - Foundation Resources
    Organization: 1 bundle created
    Location: 1 bundle created
  Level 2 - Patient Context
    Patient: 3 bundles created
  Level 3 - Encounters
    Encounter: 5 bundles created
  Level 4 - Clinical Context
    Condition: 4 bundles created
    Specimen: 1 bundle created
  Level 5 - Clinical Data
    Observation: 15 bundles created
    Procedure: 3 bundles created
    MedicationRequest: 2 bundles created

=== Summary ===
Total resources processed: 2,845
Total bundles created: 32
Output directory: ./tmp/fhir-upload
Upload plan saved: ./tmp/fhir-upload/upload-plan.json

⚠ Warnings:
  - 3 orphaned references found (resources reference non-existent resources)
  - See upload-plan.json for details

✓ Bundles ready for upload
  Use these bundles with your FHIR upload tool in level order (1→2→3→4→5)

Duration: 12.4s
```

## Dependencies (requirements.txt)
```txt
python-dotenv>=1.0.0
networkx>=3.0            # For graph analysis and topological sort
```

## Core Functionality

### 1. Resource Discovery
```python
def scan_ndjson_files(directory: Path) -> Dict[str, List[Dict]]:
    """
    Scan directory for NDJSON files and load all resources.
    Returns: {resource_type: [resources]}
    """
    pass
```

### 2. Reference Extraction
```python
def extract_references(resource: Dict) -> List[str]:
    """
    Extract all FHIR references from a resource.
    Returns list of references like ["Patient/123", "Encounter/456"]
    """
    # Recursively search for any field named "reference"
    # Handle both direct references and contained resources
    pass
```

### 3. Dependency Analysis
```python
def build_dependency_graph(resources: Dict[str, List[Dict]]) -> nx.DiGraph:
    """
    Build directed graph of resource type dependencies.
    Nodes: resource types
    Edges: A -> B means "A references B"
    """
    pass

def detect_circular_dependencies(graph: nx.DiGraph) -> List[List[str]]:
    """Detect circular reference chains."""
    pass

def topological_sort_resource_types(graph: nx.DiGraph) -> List[List[str]]:
    """
    Return resource types grouped by dependency level.
    Each level can be uploaded in parallel.
    """
    pass
```

### 4. Bundle Creation
```python
def create_batch_bundle(resources: List[Dict], preserve_ids: bool = True) -> Dict:
    """
    Create FHIR Bundle (type: batch) from resources.
    """
    pass

def write_bundle_files(
    resources_by_type: Dict[str, List[Dict]],
    dependency_levels: List[List[str]],
    output_dir: Path,
    batch_size: int
):
    """
    Write bundle JSON files organized by dependency level.
    """
    pass
```

### 5. Upload Plan Generation
```python
def generate_upload_plan(
    dependency_levels: List[List[str]],
    resources_by_type: Dict[str, List[Dict]],
    orphaned_refs: List[Dict],
    output_dir: Path
):
    """
    Generate upload-plan.json with dependency analysis results.
    """
    pass
```

## Code Structure

```python
#!/usr/bin/env python3
"""
FHIR Bundle Preparation Tool
Transform NDJSON files into FHIR Bundle (type: batch) JSON files.
Analyzes resource references to determine optimal upload order.
"""

import json
import argparse
import time
from pathlib import Path
from typing import List, Dict, Set, Tuple
from collections import defaultdict
from dotenv import load_dotenv
import networkx as nx

# Default resource order (used when analysis is disabled)
DEFAULT_RESOURCE_ORDER = [
    'Organization', 'Location', 'Practitioner', 'PractitionerRole',
    'Patient', 'Encounter', 'Condition', 'Specimen', 'Medication',
    'Observation', 'Procedure', 'MedicationRequest', 'MedicationDispense',
    'MedicationStatement', 'MedicationAdministration'
]

def parse_arguments():
    """Parse command-line arguments."""
    pass

def load_config(args):
    """Load configuration from .env and override with args."""
    pass

def scan_ndjson_files(input_dir: Path) -> Dict[str, List[Dict]]:
    """Scan directory and load all resources grouped by type."""
    pass

def extract_references(resource: Dict, path: str = "") -> List[Tuple[str, str]]:
    """
    Recursively extract all references from a resource.
    Returns: [(reference_value, json_path), ...]
    """
    pass

def parse_reference(ref_string: str) -> Tuple[str, str]:
    """
    Parse FHIR reference string.
    Returns: (resource_type, resource_id)
    Examples:
      "Patient/123" -> ("Patient", "123")
      "urn:uuid:..." -> ("", "urn:uuid:...")
    """
    pass

def build_resource_inventory(resources_by_type: Dict) -> Dict[str, Set[str]]:
    """
    Build inventory of all resource IDs.
    Returns: {resource_type: {id1, id2, ...}}
    """
    pass

def build_dependency_graph(
    resources_by_type: Dict[str, List[Dict]],
    inventory: Dict[str, Set[str]]
) -> Tuple[nx.DiGraph, List[Dict]]:
    """
    Build dependency graph and detect orphaned references.
    Returns: (graph, orphaned_references)
    """
    pass

def topological_sort_levels(graph: nx.DiGraph) -> List[List[str]]:
    """
    Sort resource types into dependency levels.
    Each level contains types that can be uploaded in parallel.
    """
    pass

def create_batch_bundle(
    resources: List[Dict],
    preserve_ids: bool = True
) -> Dict:
    """Create FHIR Bundle of type 'batch'."""
    pass

def write_bundle_files(
    resources_by_type: Dict[str, List[Dict]],
    dependency_levels: List[List[str]],
    output_dir: Path,
    batch_size: int,
    preserve_ids: bool
) -> int:
    """Write bundle JSON files organized by dependency level."""
    pass

def generate_upload_plan(
    dependency_levels: List[List[str]],
    resources_by_type: Dict[str, List[Dict]],
    orphaned_refs: List[Dict],
    circular_refs: List[List[str]],
    output_file: Path,
    analysis_enabled: bool
):
    """Generate upload-plan.json with metadata."""
    pass

def print_summary(
    resources_by_type: Dict,
    dependency_levels: List[List[str]],
    total_bundles: int,
    orphaned_refs: List[Dict],
    output_dir: Path,
    duration: float
):
    """Print summary to console."""
    pass

def main():
    """Main entry point."""
    # 1. Parse arguments and load config
    # 2. Phase 1: Discover resources
    # 3. Phase 2: Extract references
    # 4. Phase 3: Build dependency graph
    # 5. Phase 4: Compute upload order (topological sort)
    # 6. Phase 5: Create bundle files
    # 7. Generate upload-plan.json
    # 8. Print summary
    pass

if __name__ == "__main__":
    main()
```

## Important notes
- **A circular reference** is when two or more resources reference each other (e.g., Resource A references Resource B, and Resource B references Resource A), not when resources reference others of the same type.

## Success Criteria
✅ Reads NDJSON files and groups by resource type  
✅ Extracts all references from resources recursively  
✅ Builds accurate dependency graph  
✅ Detects circular dependencies  
✅ Identifies orphaned references  
✅ Performs topological sort for optimal order  
✅ Creates valid FHIR batch bundles  
✅ Organizes bundles by dependency level  
✅ Generates comprehensive upload-plan.json  
✅ Handles edge cases (missing refs, circular deps)  
✅ Displays clear progress and warnings  
✅ Outputs production-ready bundle files  
✅ Preserves original resource IDs