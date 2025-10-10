# HAPI FHIR Bundle Transaction Preparation Tool

## Objective
Create a Python script to transform FHIR NDJSON files into FHIR Bundle (type: transaction) JSON files, automatically analyzing resource references to determine optimal upload order while respecting referential integrity, and verifying consistency between source and destination resources.

## Production Experience Notes

**CRITICAL LEARNINGS FROM REAL EXECUTION** (with 928K resources, including 813K Observations):

1. **Progress Indicators are MANDATORY**: Without progress reporting every 10K resources, the script appears to hang during Phase 2 & 3 (which can take 5-10 minutes with large datasets)

2. **Mutual References Must Stay in Same Bundle**: The SCC (Strongly Connected Components) algorithm MUST be used to keep mutually referencing resources together. Never split these across bundles.

3. **Directory Creation**: Create level directories ONLY when they have resources to avoid FileNotFoundError

4. **Performance**: Expect ~2-3 minutes per phase for datasets with 800K+ resources. This is normal - not a bug!

5. **Batch Size**: Default 100 resources per bundle. With 813K Observations and 10 mutual reference groups, expect ~814 bundles for Observations alone.

6. **Verification is Critical**: The consistency check (Phase 6) is essential to ensure all resources from source NDJSON files appear in output bundles.

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
OUTPUT_DIR=./tmp/fhir-upload        # Destination for Bundle JSON files
BATCH_SIZE=100                      # Resources per bundle
ANALYZE_REFERENCES=true             # Enable smart reference analysis
PRESERVE_IDS=true                   # Keep original resource IDs
VERIFY_CONSISTENCY=true             # Verify source/destination ID consistency
GENERATE_DEBUG_REPORT=true          # Generate detailed debug report on failure
EXPORT_MISSING_IDS=true             # Export missing IDs to file
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

# Skip consistency verification
python prepare_fhir_bundles.py --no-verify

# Generate detailed debug report
python prepare_fhir_bundles.py --debug-report

# Export missing IDs to custom file
python prepare_fhir_bundles.py --export-missing-ids ./debug/missing.txt

# Help
python prepare_fhir_bundles.py --help
```

**Arguments**:
- `--input` / `-i`: Source directory with NDJSON files (overrides .env)
- `--output` / `-o`: Output directory for Bundle JSON files (overrides .env)
- `--batch-size` / `-s`: Resources per bundle (default: 100)
- `--no-analyze`: Skip reference analysis, use default order
- `--preserve-ids`: Keep original resource IDs (default: true)
- `--no-verify`: Skip consistency verification
- `--debug-report`: Generate detailed consistency debug report (missing-resources-report.json)
- `--export-missing-ids PATH`: Export list of missing resource IDs to specified file

## Reference Analysis Algorithm (CRITICAL)

The script **automatically analyzes** actual references between resources to determine optimal upload order:

### Phase 1: Resource Discovery
- Scan all NDJSON files
- Extract resource type and ID from each resource
- Track source file and line number for each resource
- Build resource inventory

### Phase 2: Reference Extraction
For each resource, extract all references:
- Direct references: `subject.reference`, `patient.reference`, `encounter.reference`, `recorder.reference`
- Array references: `participant[].actor.reference`, `performer[].actor.reference`, `performer[].reference`, `authorizingPrescription[].reference`
- **Temporal/derivation references**: `derivedFrom[].reference` (critical for Observation ordering)
- Reference patterns: `ResourceType/id` or relative references

**IMPORTANT - Temporal Dependencies (Same Resource Type)**:
- Some resources reference other resources of the **same type** to indicate temporal or derivation relationships
- Example: `Observation/B` may have `derivedFrom: [{reference: "Observation/A"}]`
- These create **intra-type dependencies** that must be respected during bundle creation
- **Solution**: Within each resource type, sort resources by their internal dependencies before batching

### Phase 3: Dependency Graph Construction

**Inter-Type Dependencies** (between different resource types):
- Build directed graph: Resource Type A → Resource Type B (A references B)
- Identify resource types without dependencies (roots)
- Detect circular references (warn user)
- Build reverse reference map (which resources reference this resource)

**Intra-Type Dependencies** (within same resource type):
- Build separate graph for each resource type tracking instance-level dependencies
- Example: For Observation type, track which specific Observations reference other Observations
- Use for sorting resources within each type before batching
- Handle via `derivedFrom`, `partOf`, `hasMember`, `replaces`, etc.

### Phase 4: Topological Sort
- Sort resource types by dependency order
- Resources with no dependencies come first
- Resources referencing others come after their dependencies
- Handle same-level resources (can be uploaded in parallel)

### Phase 5: Bundle Creation
- Create FHIR Bundles organized by dependency level
- **Sort resources within each type** by intra-type dependencies (topological sort at instance level)
- Split sorted resources into batches of specified size
- Track bundle file location for each resource
- Preserve original resource IDs
- Generate numbered bundle files

**Intra-Type Ordering Algorithm**:
1. For each resource type, extract instance-level references (same type only)
2. Build mini-graph of resource instances: `Observation/A → Observation/B`
3. **Detect mutual references** (strongly connected components): Resources that reference each other
4. **Group mutual references together** - they MUST stay in the same bundle
5. Perform topological sort on groups (not individual resources)
6. Create batches ensuring mutual reference groups are never split
7. Maintain order within and across batches

**CRITICAL - Batching Algorithm Implementation**:
```python
# Track which resources are already in batches
processed_ids = set()

# Iterate through sorted resources
for each resource in sorted_resources:
    if resource.id already in processed_ids:
        skip  # Already added as part of a mutual group

    if resource is in a mutual_group:
        # Collect ALL group members from sorted_resources
        group_resources = [r for r in sorted_resources if r.id in group]

        # Check if group fits in current batch
        if current_batch has space:
            current_batch.extend(group_resources)
        else:
            finalize current_batch
            start new batch with group_resources

        # Mark all group members as processed
        processed_ids.add(all group member IDs)
    else:
        # Regular resource
        add to current_batch
        processed_ids.add(resource.id)
```

**Verification Step**: After batching, verify `sum(len(batch)) == len(resources)`

**CRITICAL - Mutual Reference Handling**:
- **Mutual references** = Resources that reference each other (A→B and B→A)
- **Example**: Observation A has `hasMember: [B]` and Observation B has `derivedFrom: [A]`
- **Solution**: Keep all mutually referencing resources in the SAME bundle
- **Implementation**: Use Strongly Connected Components (SCC) algorithm
- **Batching**: When creating batches, never split an SCC across bundle boundaries

### Phase 6: Consistency Verification
- Compare source inventory vs destination bundles
- Detect missing resources
- Detect extra resources (duplicates)
- Detect type mismatches
- Generate detailed debug report on failure

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
├── missing-resources-report.json # Detailed debug report (if consistency fails)
├── missing-ids.txt               # Simple list of missing IDs (if consistency fails)
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

## File Formats

### 1. upload-plan.json
```json
{
  "analysis_timestamp": "2025-10-09T14:30:00Z",
  "total_resources": 2845,
  "total_bundles": 32,
  "reference_analysis_enabled": true,
  "consistency_check": {
    "enabled": true,
    "status": "passed",
    "total_source_resources": 2845,
    "total_destination_resources": 2845,
    "matched_resources": 2845,
    "missing_in_destination": [],
    "extra_in_destination": [],
    "type_mismatches": []
  },
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

### 2. missing-resources-report.json (generated on consistency failure)
```json
{
  "report_timestamp": "2025-10-09T14:30:00Z",
  "consistency_status": "failed",
  "summary": {
    "total_source_resources": 2845,
    "total_destination_resources": 2842,
    "matched_resources": 2842,
    "missing_count": 3,
    "extra_count": 1,
    "type_mismatch_count": 1
  },
  "missing_resources": [
    {
      "resource_type": "Patient",
      "resource_id": "patient-999",
      "full_reference": "Patient/patient-999",
      "source_file": "patient.ndjson",
      "source_line_number": 999,
      "expected_bundle": "level-02/patient-batch-010.json",
      "resource_snapshot": {
        "resourceType": "Patient",
        "id": "patient-999",
        "identifier": [{"system": "http://hospital.com/patients", "value": "P999"}],
        "name": [{"family": "Doe", "given": ["John"]}]
      },
      "referenced_by": [
        "Encounter/enc-1234",
        "Observation/obs-5678",
        "Condition/cond-9012"
      ]
    }
  ],
  "extra_resources": [
    {
      "resource_type": "Patient",
      "resource_id": "patient-duplicate-001",
      "full_reference": "Patient/patient-duplicate-001",
      "bundle_file": "level-02/patient-batch-001.json",
      "bundle_entry_index": 15,
      "possible_cause": "Duplicate resource in source or processing error"
    }
  ],
  "type_mismatches": [
    {
      "resource_id": "resource-123",
      "source_type": "Patient",
      "destination_type": "Person",
      "full_source_reference": "Patient/resource-123",
      "full_destination_reference": "Person/resource-123",
      "source_file": "patient.ndjson",
      "source_line_number": 123,
      "bundle_file": "level-02/person-batch-001.json",
      "bundle_entry_index": 5,
      "possible_cause": "Resource type changed during processing"
    }
  ],
  "analysis": {
    "most_affected_resource_types": [
      {
        "resource_type": "Observation",
        "missing_count": 2,
        "total_source_count": 1456,
        "missing_percentage": 0.14
      }
    ],
    "potential_causes": [
      "Resources may have been filtered during processing",
      "Possible duplicate handling issue",
      "Bundle creation may have skipped invalid resources",
      "Check for resources with missing required fields"
    ]
  }
}
```

### 3. missing-ids.txt (generated on consistency failure)
```txt
# Missing Resource IDs Report
# Generated: 2025-10-09T14:30:00Z
# Total Missing: 3

Patient/patient-999
Observation/obs-456
Observation/obs-789
```

### 4. Bundle Structure (Output JSON)

Each bundle file contains:
```json
{
  "resourceType": "Bundle",
  "type": "transaction",
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

### Success Case (Consistency Passed):

```
=== FHIR Bundle Preparation Tool ===
Input: /tmp/fhir-download
Output: /tmp/fhir-bundles
Batch Size: 100
Reference Analysis: ENABLED
Consistency Verification: ENABLED

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

[Phase 6] Verifying consistency...
Comparing source and destination resources: ████████████████████ 2,845/2,845 verified
✓ Consistency check PASSED
  Source resources: 2,845
  Destination resources: 2,845
  Matched: 2,845 (100%)
  Missing: 0
  Extra: 0
  Type mismatches: 0

=== Summary ===
Total resources processed: 2,845/2,845
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

### Failure Case (Consistency Failed):

```
[Phase 6] Verifying consistency...
Comparing source and destination resources: ████████████████████ 2,845/2,845 verified
✗ Consistency check FAILED
  Source resources: 2,845
  Destination resources: 2,842
  Matched: 2,842 (99.89%)
  Missing in destination: 3
  Extra in destination: 1
  Type mismatches: 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MISSING RESOURCES (not found in bundles)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Patient/patient-999
   Source: patient.ndjson (line 999)
   Expected: level-02/patient-batch-010.json
   Referenced by: 3 resources (Encounter/enc-1234, Observation/obs-5678, Condition/cond-9012)

2. Observation/obs-456
   Source: observation.ndjson (line 456)
   Expected: level-05/observation-batch-005.json
   Referenced by: 0 resources

3. Observation/obs-789
   Source: observation.ndjson (line 789)
   Expected: level-05/observation-batch-008.json
   Referenced by: 1 resource (DiagnosticReport/dr-111)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXTRA RESOURCES (found in bundles but not in source)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Patient/patient-duplicate-001
   Bundle: level-02/patient-batch-001.json (entry #15)
   Possible cause: Duplicate resource in source or processing error

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TYPE MISMATCHES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. resource-123
   Source: Patient/resource-123 (patient.ndjson, line 123)
   Destination: Person/resource-123 (level-02/person-batch-001.json, entry #5)
   Issue: Resource type changed from Patient to Person

=== Summary ===
Total resources processed: 2,845/2,845
Total bundles created: 32
Output directory: ./tmp/fhir-upload
Upload plan saved: ./tmp/fhir-upload/upload-plan.json

❌ CRITICAL ERRORS:
  - Consistency check failed: 3 resources missing, 1 extra, 1 type mismatch
  - DO NOT upload these bundles until consistency issues are resolved
  - Detailed debug report: ./tmp/fhir-upload/missing-resources-report.json
  - Missing IDs list: ./tmp/fhir-upload/missing-ids.txt

⚠ Warnings:
  - 3 orphaned references found (resources reference non-existent resources)
  - See upload-plan.json for details

Recommended Actions:
  1. Review missing-resources-report.json for detailed analysis
  2. Check source NDJSON files for data integrity
  3. Verify processing logic didn't filter out resources
  4. Re-run with --debug flag for verbose logging

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
def scan_ndjson_files(directory: Path) -> Tuple[Dict[str, List[Dict]], Dict[Tuple[str, str], Dict], Dict[Tuple[str, str], Path]]:
    """
    Scan directory for NDJSON files and load all resources.
    Returns: 
        - resources_by_type: {resource_type: [resources]}
        - source_resources_map: {(resource_type, resource_id): full_resource_with_metadata}
        - ndjson_files: {(resource_type, resource_id): source_file_path}
    
    Each resource should be augmented with:
        - _line_number: line number in source file
        - _source_file: source file name
    """
    pass
```

### 2. Reference Extraction
```python
def extract_references(resource: Dict, path: str = "") -> List[Tuple[str, str]]:
    """
    Recursively extract all FHIR references from a resource.
    Returns list of tuples: [(reference_value, json_path), ...]
    
    Example: [("Patient/123", "subject.reference"), ("Encounter/456", "encounter.reference")]
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
```

### 3. Dependency Analysis
```python
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
    Build directed graph of resource type dependencies.
    Nodes: resource types
    Edges: A -> B means "A references B"

    Returns: (graph, orphaned_references)
    """
    pass

def build_intra_type_dependency_graph(
    resources: List[Dict],
    resource_type: str
) -> nx.DiGraph:
    """
    Build directed graph of instance-level dependencies within a single resource type.

    Args:
        resources: List of resources of the same type
        resource_type: The resource type (e.g., "Observation")

    Returns:
        DiGraph where nodes are resource IDs and edges represent dependencies
        (A -> B means "A depends on B", so B must come before A)

    Example:
        For Observation/B with derivedFrom: [{reference: "Observation/A"}]
        Creates edge: B -> A (B depends on A, so A must load first)
    """
    pass

def find_mutual_reference_groups(
    resources: List[Dict],
    resource_type: str
) -> List[Set[str]]:
    """
    Find groups of resources with mutual references (strongly connected components).

    Args:
        resources: List of resources to analyze
        resource_type: The resource type

    Returns:
        List of sets, where each set contains resource IDs that mutually reference each other

    Algorithm:
        1. Build intra-type dependency graph
        2. Use NetworkX strongly_connected_components() to find SCCs
        3. Return groups with size > 1 (mutual references)
    """
    pass

def topological_sort_resources(
    resources: List[Dict],
    resource_type: str,
    mutual_groups: List[Set[str]] = None
) -> List[Dict]:
    """
    Sort resources of the same type by their intra-type dependencies.
    Keeps mutual reference groups together.

    Args:
        resources: List of resources to sort
        resource_type: The resource type
        mutual_groups: Optional list of mutual reference groups (SCCs)

    Returns:
        Sorted list of resources (dependencies first, mutual groups kept together)

    Algorithm:
        1. Build intra-type dependency graph
        2. Find strongly connected components (mutual reference groups)
        3. Collapse each SCC into a single "super node"
        4. Perform topological sort on collapsed graph
        5. Expand super nodes back to original resources
        6. Return sorted resources with mutual groups intact
    """
    pass

def build_reverse_reference_map(resources_by_type: Dict[str, List[Dict]]) -> Dict[str, List[str]]:
    """
    Build a map of which resources are referenced by which other resources.
    
    Returns:
        {referenced_resource: [list of resources that reference it]}
        Example: {"Patient/123": ["Encounter/456", "Observation/789"]}
    """
    pass

def detect_circular_dependencies(graph: nx.DiGraph) -> List[List[str]]:
    """Detect circular reference chains between resource types."""
    pass

def topological_sort_levels(graph: nx.DiGraph) -> List[List[str]]:
    """
    Sort resource types into dependency levels.
    Each level contains types that can be uploaded in parallel.
    Returns: [[level1_types], [level2_types], ...]
    """
    pass
```

### 4. Bundle Creation
```python
def create_transaction_bundle(resources: List[Dict], preserve_ids: bool = True) -> Dict:
    """
    Create FHIR Bundle (type: transaction) from resources.
    Each resource becomes an entry with PUT request.
    """
    pass

def write_bundle_files(
    resources_by_type: Dict[str, List[Dict]],
    dependency_levels: List[List[str]],
    output_dir: Path,
    batch_size: int,
    preserve_ids: bool
) -> Tuple[int, Dict[str, List[Dict]]]:
    """
    Write bundle JSON files organized by dependency level.

    CRITICAL: Handle mutual reference groups correctly:
    - Detect mutual reference groups for each resource type
    - Never split a mutual reference group across bundles
    - If a group is larger than batch_size, create a dedicated bundle for it

    Returns:
        - total_bundles: number of bundle files created
        - bundle_resources: {resource_type: [resources]} extracted from created bundles
          (each resource augmented with _bundle_file and _entry_index)

    Algorithm:
        1. Sort resources by intra-type dependencies
        2. Identify mutual reference groups
        3. Create batches ensuring groups stay together:
           - If group fits in current batch, add it
           - If group doesn't fit, start new batch
           - If group > batch_size, create dedicated bundle for it
    """
    pass

def calculate_expected_bundle(resource_type: str, resource_id: str, level: int, batch_size: int) -> str:
    """
    Calculate expected bundle file name for a resource.
    Example: "level-02/patient-batch-005.json"
    """
    pass
```

### 5. Consistency Verification
```python
def verify_consistency(
    source_inventory: Dict[str, Set[str]],
    resources_by_type: Dict[str, List[Dict]],
    bundle_resources: Dict[str, List[Dict]],
    ndjson_files: Dict[Tuple[str, str], Path],
    source_resources_map: Dict[Tuple[str, str], Dict]
) -> Dict:
    """
    Verify consistency between source NDJSON resources and destination bundle resources.
    
    Returns:
        Dictionary with detailed consistency check results:
        {
            'status': 'passed' | 'failed',
            'total_source': int,
            'total_destination': int,
            'matched': int,
            'missing_in_destination': [...],
            'extra_in_destination': [...],
            'type_mismatches': [...]
        }
    """
    pass

def print_consistency_results(results: Dict, verbose: bool = True):
    """
    Print detailed consistency check results to console with formatted output.
    """
    pass
```

### 6. Debug Reports
```python
def generate_debug_report(
    consistency_results: Dict,
    output_file: Path
):
    """
    Generate detailed JSON debug report for consistency issues.
    Includes analysis of most affected resource types and potential causes.
    """
    pass

def export_missing_ids(missing_resources: List[Dict], output_file: Path):
    """
    Export missing resource IDs to a simple text file.
    Format: one reference per line (ResourceType/id)
    """
    pass
```

### 7. Upload Plan Generation
```python
def generate_upload_plan(
    dependency_levels: List[List[str]],
    resources_by_type: Dict[str, List[Dict]],
    orphaned_refs: List[Dict],
    circular_refs: List[List[str]],
    output_file: Path,
    analysis_enabled: bool,
    consistency_results: Dict = None
):
    """
    Generate upload-plan.json with dependency analysis results and consistency check.
    """
    pass
```

### 8. Summary and Reporting
```python
def print_summary(
    resources_by_type: Dict,
    dependency_levels: List[List[str]],
    total_bundles: int,
    orphaned_refs: List[Dict],
    output_dir: Path,
    duration: float,
    consistency_results: Dict = None
):
    """
    Print comprehensive summary to console including consistency status.
    """
    pass
```

## Code Structure

```python
#!/usr/bin/env python3
"""
FHIR Bundle Preparation Tool
Transform NDJSON files into FHIR Bundle (type: transaction) JSON files.
Analyzes resource references to determine optimal upload order.
Verifies consistency between source and destination resources.
"""

import json
import argparse
import time
from pathlib import Path
from typing import List, Dict, Set, Tuple
from collections import defaultdict
from datetime import datetime
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
    parser = argparse.ArgumentParser(
        description='Prepare FHIR Bundle files from NDJSON resources'
    )
    parser.add_argument('--input', '-i', type=Path, help='Input directory with NDJSON files')
    parser.add_argument('--output', '-o', type=Path, help='Output directory for Bundle files')
    parser.add_argument('--batch-size', '-s', type=int, default=100, help='Resources per bundle')
    parser.add_argument('--no-analyze', action='store_true', help='Skip reference analysis')
    parser.add_argument('--preserve-ids', action='store_true', default=True, help='Keep original IDs')
    parser.add_argument('--no-verify', action='store_true', help='Skip consistency verification')
    parser.add_argument('--debug-report', action='store_true', help='Generate detailed debug report')
    parser.add_argument('--export-missing-ids', type=Path, help='Export missing IDs to file')
    return parser.parse_args()

def load_config(args):
    """Load configuration from .env and override with args."""
    load_dotenv()
    # Implementation: merge .env with args
    pass

def scan_ndjson_files(input_dir: Path) -> Tuple[Dict[str, List[Dict]], Dict[Tuple[str, str], Dict], Dict[Tuple[str, str], Path]]:
    """Scan directory and load all resources grouped by type with metadata."""
    pass

def extract_references(resource: Dict, path: str = "") -> List[Tuple[str, str]]:
    """Recursively extract all references from a resource."""
    pass

def parse_reference(ref_string: str) -> Tuple[str, str]:
    """Parse FHIR reference string into (resource_type, resource_id)."""
    pass

def build_resource_inventory(resources_by_type: Dict) -> Dict[str, Set[str]]:
    """Build inventory of all resource IDs."""
    pass

def build_reverse_reference_map(resources_by_type: Dict[str, List[Dict]]) -> Dict[str, List[str]]:
    """Build reverse reference map for consistency checking."""
    pass

def build_dependency_graph(
    resources_by_type: Dict[str, List[Dict]],
    inventory: Dict[str, Set[str]]
) -> Tuple[nx.DiGraph, List[Dict]]:
    """Build dependency graph and detect orphaned references."""
    pass

def topological_sort_levels(graph: nx.DiGraph) -> List[List[str]]:
    """Sort resource types into dependency levels."""
    pass

def create_transaction_bundle(resources: List[Dict], preserve_ids: bool = True) -> Dict:
    """Create FHIR Bundle of type 'transaction'."""
    pass

def calculate_expected_bundle(resource_type: str, resource_id: str, level: int, batch_size: int) -> str:
    """Calculate expected bundle file name."""
    pass

def write_bundle_files(
    resources_by_type: Dict[str, List[Dict]],
    dependency_levels: List[List[str]],
    output_dir: Path,
    batch_size: int,
    preserve_ids: bool
) -> Tuple[int, Dict[str, List[Dict]]]:
    """Write bundle JSON files organized by dependency level."""
    pass

def verify_consistency(
    source_inventory: Dict[str, Set[str]],
    resources_by_type: Dict[str, List[Dict]],
    bundle_resources: Dict[str, List[Dict]],
    ndjson_files: Dict[Tuple[str, str], Path],
    source_resources_map: Dict[Tuple[str, str], Dict]
) -> Dict:
    """Verify consistency between source and destination resources."""
    pass

def print_consistency_results(results: Dict, verbose: bool = True):
    """Print detailed consistency check results to console."""
    pass

def generate_debug_report(consistency_results: Dict, output_file: Path):
    """Generate detailed JSON debug report for consistency issues."""
    pass

def export_missing_ids(missing_resources: List[Dict], output_file: Path):
    """Export missing resource IDs to simple text file."""
    pass

def generate_upload_plan(
    dependency_levels: List[List[str]],
    resources_by_type: Dict[str, List[Dict]],
    orphaned_refs: List[Dict],
    circular_refs: List[List[str]],
    output_file: Path,
    analysis_enabled: bool,
    consistency_results: Dict = None
):
    """Generate upload-plan.json with metadata."""
    pass

def print_summary(
    resources_by_type: Dict,
    dependency_levels: List[List[str]],
    total_bundles: int,
    orphaned_refs: List[Dict],
    output_dir: Path,
    duration: float,
    consistency_results: Dict = None
):
    """Print comprehensive summary to console."""
    pass

def main():
    """Main entry point."""
    start_time = time.time()
    
    # 1. Parse arguments and load config
    args = parse_arguments()
    config = load_config(args)
    
    print("=== FHIR Bundle Preparation Tool ===")
    print(f"Input: {config['input_dir']}")
    print(f"Output: {config['output_dir']}")
    print(f"Batch Size: {config['batch_size']}")
    print(f"Reference Analysis: {'ENABLED' if config['analyze_references'] else 'DISABLED'}")
    print(f"Consistency Verification: {'ENABLED' if config['verify_consistency'] else 'DISABLED'}")
    print()
    
    # 2. Phase 1: Discover resources
    print("[Phase 1] Discovering resources...")
    resources_by_type, source_resources_map, ndjson_files = scan_ndjson_files(config['input_dir'])
    source_inventory = build_resource_inventory(resources_by_type)
    
    # 3. Phase 2: Extract references (if enabled)
    reference_map = None
    if config['analyze_references']:
        print("\n[Phase 2] Extracting references...")
        reference_map = build_reverse_reference_map(resources_by_type)
    
    # 4. Phase 3: Build dependency graph
    orphaned_refs = []
    circular_refs = []
    if config['analyze_references']:
        print("\n[Phase 3] Building dependency graph...")
        graph, orphaned_refs = build_dependency_graph(resources_by_type, source_inventory)
        circular_refs = detect_circular_dependencies(graph)
    
    # 5. Phase 4: Compute upload order (topological sort)
    if config['analyze_references']:
        print("\n[Phase 4] Computing upload order...")
        dependency_levels = topological_sort_levels(graph)
    else:
        # Use default order
        dependency_levels = [[rt] for rt in DEFAULT_RESOURCE_ORDER if rt in resources_by_type]
    
    # 6. Phase 5: Create bundle files
    print("\n[Phase 5] Creating bundle files...")
    total_bundles, bundle_resources = write_bundle_files(
        resources_by_type,
        dependency_levels,
        config['output_dir'],
        config['batch_size'],
        config['preserve_ids']
    )
    
    # 7. Phase 6: Verify consistency (if enabled)
    consistency_results = None
    if config['verify_consistency']:
        consistency_results = verify_consistency(
            source_inventory,
            resources_by_type,
            bundle_resources,
            ndjson_files,
            source_resources_map
        )
        print_consistency_results(consistency_results, verbose=True)
        
        # Generate debug reports if consistency failed
        if consistency_results['status'] == 'failed':
            if config.get('generate_debug_report', True) or args.debug_report:
                debug_report_path = config['output_dir'] / 'missing-resources-report.json'
                generate_debug_report(consistency_results, debug_report_path)
            
            if config.get('export_missing_ids', True) or args.export_missing_ids:
                missing_ids_path = args.export_missing_ids or (config['output_dir'] / 'missing-ids.txt')
                export_missing_ids(
                    consistency_results['missing_in_destination'],
                    missing_ids_path
                )
    
    # 8. Generate upload-plan.json
    generate_upload_plan(
        dependency_levels,
        resources_by_type,
        orphaned_refs,
        circular_refs,
        config['output_dir'] / 'upload-plan.json',
        config['analyze_references'],
        consistency_results
    )
    
    # 9. Print summary
    duration = time.time() - start_time
    print_summary(
        resources_by_type,
        dependency_levels,
        total_bundles,
        orphaned_refs,
        config['output_dir'],
        duration,
        consistency_results
    )

if __name__ == "__main__":
    main()
```

## Important Notes

- **Circular reference definition**: A circular reference occurs when two or more resource *types* reference each other (e.g., Resource A references Resource B, and Resource B references Resource A), NOT when resources reference others of the same type.
  
- **Metadata tracking**: Every resource should track its source location (_source_file, _line_number) and destination location (_bundle_file, _entry_index) for detailed error reporting.

- **Progress indicators**: Use progress bars (████████████) to show scanning, analysis, and verification progress.

- **Error handling**: Always check for and handle:
  - Missing resource IDs
  - Invalid references
  - Malformed NDJSON
  - File I/O errors
  - Graph cycles

## Performance Considerations & Troubleshooting

### Expected Performance (tested with 928,935 resources)

| Phase | Duration | Notes |
|-------|----------|-------|
| Phase 1: Discovery | < 30s | Reading NDJSON files |
| Phase 2: Reverse Reference Map | ~2-3 min | Processing 928K resources |
| Phase 3: Dependency Graph | ~2-3 min | Extracting 2M references |
| Phase 4: Topological Sort | < 10s | Graph algorithm |
| Phase 5: Bundle Creation | ~5-10 min | **Longest phase**: 813K Observations with intra-type sorting |
| Phase 6: Consistency Verification | ~1-2 min | Comparing source vs destination |

**Total**: ~15-20 minutes for 928K resources

### Common Issues & Solutions

**Issue**: "Script appears frozen at 99%"
- **Cause**: Processing large resource types (e.g., 813K Observations) with intra-type dependencies
- **Solution**: Wait - progress indicators show it's working. Phase 5 takes longest.

**Issue**: "FileNotFoundError: level-XX directory"
- **Cause**: Directory creation logic tried to create file before directory
- **Solution**: Ensure `level_dir.mkdir()` is called BEFORE processing resources in that level

**Issue**: "WARNING: Only X/Y resources batched"
- **Cause**: Batching algorithm bug - resources skipped or duplicated
- **Solution**: Check `processed_ids` tracking logic in mutual reference handling

**Issue**: "Consistency check FAILED"
- **Cause**: Resources missing from bundles during creation
- **Solution**: Check bundle creation logic, verify all resources processed

### Debug Mode

To see detailed execution:
```bash
# Add verbose logging (future enhancement)
python prepare_fhir_bundles.py --verbose

# Test with small dataset first
head -1000 observation.ndjson > test-observation.ndjson
python prepare_fhir_bundles.py --input ./test-data
```

## Success Criteria

✅ Reads NDJSON files and groups by resource type
✅ Extracts all references from resources recursively
✅ Builds accurate dependency graph
✅ Detects circular dependencies between resource types
✅ Identifies orphaned references
✅ Performs topological sort for optimal order
✅ Creates valid FHIR transaction bundles
✅ Organizes bundles by dependency level
✅ Generates comprehensive upload-plan.json
✅ Handles edge cases (missing refs, circular deps)
✅ Displays clear progress and warnings
✅ Outputs production-ready bundle files
✅ Preserves original resource IDs
✅ Verifies consistency between source and destination resources
✅ Detects missing, extra, and mismatched resources
✅ Provides detailed consistency error reports with resource snapshots
✅ Exports simple list of missing IDs for debugging
✅ Tracks which resources reference missing resources
✅ Prevents upload when consistency check fails
✅ Generates actionable debug information
✅ Shows progress indicators every 10K resources
✅ Completes successfully with 900K+ resources
✅ Handles 10+ mutual reference groups correctly
✅ Creates level directories only when needed