#!/usr/bin/env python3
"""
FHIR Bundle Preparation Tool
Transform NDJSON files into FHIR Bundle (type: batch) JSON files.
Analyzes resource references to determine optimal upload order.
"""

import json
import argparse
import time
import sys
from pathlib import Path
from typing import List, Dict, Set, Tuple, Optional, Any
from collections import defaultdict
from datetime import datetime
from dotenv import load_dotenv
import networkx as nx

# Add common directory to path
sys.path.insert(0, str(Path(__file__).parent))

from common.utils import get_resource_type_from_filename, format_duration

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
        description='Transform FHIR NDJSON files into batch Bundle JSON files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                                    # Use default settings
  %(prog)s --input ./downloaded --output ./bundles
  %(prog)s --batch-size 50
  %(prog)s --no-analyze                       # Skip reference analysis
        """
    )

    parser.add_argument(
        '--input', '-i',
        type=str,
        help='Source directory with NDJSON files (default: ./tmp/fhir-download)'
    )

    parser.add_argument(
        '--output', '-o',
        type=str,
        help='Output directory for Bundle JSON files (default: ./tmp/fhir-upload)'
    )

    parser.add_argument(
        '--batch-size', '-s',
        type=int,
        default=100,
        help='Resources per bundle (default: 100)'
    )

    parser.add_argument(
        '--no-analyze',
        action='store_true',
        help='Skip reference analysis, use default order'
    )

    parser.add_argument(
        '--preserve-ids',
        action='store_true',
        default=True,
        help='Keep original resource IDs (default: true)'
    )

    return parser.parse_args()


def load_config(args):
    """Load configuration from .env and override with args."""
    import os
    load_dotenv()

    # Load from .env with defaults
    env_input_dir = os.getenv('INPUT_DIR', './tmp/fhir-download')
    env_output_dir = os.getenv('OUTPUT_DIR', './tmp/fhir-upload')
    env_batch_size = int(os.getenv('BATCH_SIZE', '100'))
    env_analyze = os.getenv('ANALYZE_REFERENCES', 'true').lower() in ('true', '1', 'yes', 'on')
    env_preserve_ids = os.getenv('PRESERVE_IDS', 'true').lower() in ('true', '1', 'yes', 'on')

    config = {
        'input_dir': Path(args.input) if args.input else Path(env_input_dir),
        'output_dir': Path(args.output) if args.output else Path(env_output_dir),
        'batch_size': args.batch_size if args.batch_size != 100 else env_batch_size,  # Use env if not explicitly set
        'analyze_references': not args.no_analyze if args.no_analyze else env_analyze,
        'preserve_ids': args.preserve_ids if hasattr(args, 'preserve_ids') else env_preserve_ids
    }

    return config


def scan_ndjson_files(input_dir: Path) -> Dict[str, List[Dict]]:
    """
    Scan directory and load all resources grouped by type.

    Args:
        input_dir: Directory containing NDJSON files

    Returns:
        Dictionary mapping resource types to lists of resources
    """
    resources_by_type = defaultdict(list)

    if not input_dir.exists():
        print(f"❌ Input directory not found: {input_dir}")
        sys.exit(1)

    ndjson_files = list(input_dir.glob("*.ndjson"))

    if not ndjson_files:
        print(f"❌ No NDJSON files found in {input_dir}")
        sys.exit(1)

    print(f"Found {len(ndjson_files)} NDJSON files")

    total_resources = 0

    for ndjson_file in ndjson_files:
        # Get resource type from filename
        resource_type = get_resource_type_from_filename(ndjson_file.name)

        if not resource_type:
            print(f"WARNING: Skipping {ndjson_file.name}: Cannot determine resource type")
            continue

        # Read and parse NDJSON file
        with open(ndjson_file, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue

                try:
                    resource = json.loads(line)
                    resources_by_type[resource_type].append(resource)
                    total_resources += 1
                except json.JSONDecodeError as e:
                    print(f"WARNING: Error parsing {ndjson_file.name}:{line_num}: {e}")
                    continue

    print(f"Scanning resources: {total_resources:,} resources")

    return dict(resources_by_type)


def extract_references(resource: Dict, path: str = "") -> List[Tuple[str, str]]:
    """
    Recursively extract all references from a resource.

    Args:
        resource: FHIR resource dictionary
        path: Current JSON path (for debugging)

    Returns:
        List of tuples: [(reference_value, json_path), ...]
    """
    references = []

    if isinstance(resource, dict):
        for key, value in resource.items():
            current_path = f"{path}.{key}" if path else key

            # Check if this is a reference field
            if key == "reference" and isinstance(value, str):
                references.append((value, current_path))
            else:
                # Recurse into nested structures
                references.extend(extract_references(value, current_path))

    elif isinstance(resource, list):
        for idx, item in enumerate(resource):
            current_path = f"{path}[{idx}]"
            references.extend(extract_references(item, current_path))

    return references


def parse_reference(ref_string: str) -> Tuple[str, str]:
    """
    Parse FHIR reference string.

    Args:
        ref_string: Reference string (e.g., "Patient/123")

    Returns:
        Tuple of (resource_type, resource_id)

    Examples:
        "Patient/123" -> ("Patient", "123")
        "urn:uuid:..." -> ("", "urn:uuid:...")
    """
    if ref_string.startswith("urn:uuid:") or ref_string.startswith("urn:oid:"):
        return ("", ref_string)

    parts = ref_string.split('/')
    if len(parts) >= 2:
        return (parts[0], '/'.join(parts[1:]))

    return ("", ref_string)


def build_resource_inventory(resources_by_type: Dict[str, List[Dict]]) -> Dict[str, Set[str]]:
    """
    Build inventory of all resource IDs.

    Args:
        resources_by_type: Resources grouped by type

    Returns:
        Dictionary mapping resource types to sets of IDs
    """
    inventory = defaultdict(set)

    for resource_type, resources in resources_by_type.items():
        for resource in resources:
            if 'id' in resource:
                inventory[resource_type].add(resource['id'])

    return dict(inventory)


def build_dependency_graph(
    resources_by_type: Dict[str, List[Dict]],
    inventory: Dict[str, Set[str]]
) -> Tuple[nx.DiGraph, List[Dict]]:
    """
    Build dependency graph and detect orphaned references.

    Args:
        resources_by_type: Resources grouped by type
        inventory: Inventory of all resource IDs

    Returns:
        Tuple of (directed graph, list of orphaned reference details)
    """
    graph = nx.DiGraph()
    orphaned_refs = []

    # Add all resource types as nodes
    for resource_type in resources_by_type.keys():
        graph.add_node(resource_type)

    print("Analyzing references: ", end='', flush=True)
    total_refs = 0

    # Build edges based on references
    for resource_type, resources in resources_by_type.items():
        for resource in resources:
            # Extract all references from this resource
            refs = extract_references(resource)
            total_refs += len(refs)

            for ref_string, ref_path in refs:
                target_type, target_id = parse_reference(ref_string)

                if not target_type:
                    # Skip URN references
                    continue

                # Check if referenced resource exists
                if target_type in inventory and target_id not in inventory[target_type]:
                    orphaned_refs.append({
                        'resource': f"{resource_type}/{resource.get('id', 'unknown')}",
                        'missing_reference': ref_string,
                        'reference_path': ref_path
                    })

                # Add edge: resource_type -> target_type (depends on)
                if target_type in graph:
                    graph.add_edge(resource_type, target_type)

    print(f"{total_refs:,} references")

    return graph, orphaned_refs


def topological_sort_levels(graph: nx.DiGraph) -> List[List[str]]:
    """
    Sort resource types into dependency levels.
    Each level contains types that can be uploaded in parallel.

    Args:
        graph: Directed dependency graph

    Returns:
        List of levels, each containing list of resource types
    """
    # Reverse the graph because we want dependencies first
    # In our graph: A -> B means "A references B", so B should come first
    reversed_graph = graph.reverse()

    # Check if graph has cycles
    if not nx.is_directed_acyclic_graph(reversed_graph):
        # Graph has cycles - break them by removing feedback edges
        # Create a copy to modify
        acyclic_graph = reversed_graph.copy()

        # Find and remove cycle edges
        while True:
            try:
                # Try to find a cycle
                cycle = nx.find_cycle(acyclic_graph, orientation='original')
                # Remove the first edge in the cycle to break it
                if cycle:
                    u, v, _ = cycle[0]
                    acyclic_graph.remove_edge(u, v)
            except nx.NetworkXNoCycle:
                # No more cycles
                break

        # Use the acyclic version
        reversed_graph = acyclic_graph

    try:
        # Get topological generations (levels)
        levels = list(nx.topological_generations(reversed_graph))
        return levels
    except:
        # Still failed, use fallback
        return []


def detect_circular_dependencies(graph: nx.DiGraph) -> List[List[str]]:
    """
    Detect circular reference chains.

    Args:
        graph: Directed dependency graph

    Returns:
        List of cycles (each cycle is a list of resource types)
    """
    try:
        cycles = list(nx.simple_cycles(graph))
        return cycles
    except:
        return []


def find_circular_resource_instances(
    resources_by_type: Dict[str, List[Dict]],
    circular_types: List[List[str]]
) -> List[Dict]:
    """
    Find actual resource instances involved in circular dependencies.

    A circular reference occurs when Resource A references Resource B,
    and Resource B references Resource A (mutual references).

    Args:
        resources_by_type: Resources grouped by type
        circular_types: List of resource type cycles (e.g., [['Encounter'], ['Medication']])

    Returns:
        List of circular reference examples with resource IDs
    """
    circular_examples = []

    for cycle in circular_types:
        if len(cycle) != 1:
            # Multi-type cycles - skip for now, complex to trace
            continue

        resource_type = cycle[0]
        if resource_type not in resources_by_type:
            continue

        resources = resources_by_type[resource_type]

        # Build a map of resource ID -> list of referenced IDs of the same type
        ref_map = {}

        for resource in resources:
            resource_id = resource.get('id')
            if not resource_id:
                continue

            # Extract references to same resource type
            refs = extract_references(resource)
            same_type_refs = []

            for ref_string, ref_path in refs:
                target_type, target_id = parse_reference(ref_string)

                if target_type == resource_type and target_id != resource_id:
                    same_type_refs.append({
                        'id': target_id,
                        'path': ref_path
                    })

            if same_type_refs:
                ref_map[resource_id] = same_type_refs

        # Now find mutual references (A->B and B->A)
        found_mutual = set()

        for resource_id, referenced in ref_map.items():
            for ref_info in referenced:
                target_id = ref_info['id']

                # Check if target also references back to this resource
                if target_id in ref_map:
                    for back_ref in ref_map[target_id]:
                        if back_ref['id'] == resource_id:
                            # Found mutual reference!
                            pair_key = tuple(sorted([resource_id, target_id]))

                            if pair_key not in found_mutual:
                                found_mutual.add(pair_key)
                                circular_examples.append({
                                    'resource_type': resource_type,
                                    'resource_a': f"{resource_type}/{resource_id}",
                                    'resource_b': f"{resource_type}/{target_id}",
                                    'description': f"{resource_type}/{resource_id} references {resource_type}/{target_id}, and vice versa"
                                })

                                # Limit examples
                                if len(circular_examples) >= 10:
                                    return circular_examples

    return circular_examples


def create_batch_bundle(
    resources: List[Dict],
    preserve_ids: bool = True
) -> Dict:
    """
    Create FHIR Bundle of type 'batch'.

    Args:
        resources: List of FHIR resources
        preserve_ids: Whether to preserve original resource IDs

    Returns:
        FHIR Bundle resource
    """
    bundle = {
        "resourceType": "Bundle",
        "type": "batch",
        "entry": []
    }

    for resource in resources:
        resource_type = resource.get('resourceType')
        resource_id = resource.get('id')

        if not resource_type or not resource_id:
            continue

        entry = {
            "request": {
                "method": "PUT",
                "url": f"{resource_type}/{resource_id}"
            },
            "resource": resource
        }

        bundle["entry"].append(entry)

    return bundle


def write_bundle_files(
    resources_by_type: Dict[str, List[Dict]],
    dependency_levels: List[List[str]],
    output_dir: Path,
    batch_size: int,
    preserve_ids: bool
) -> int:
    """
    Write bundle JSON files organized by dependency level.

    Args:
        resources_by_type: Resources grouped by type
        dependency_levels: Sorted dependency levels
        output_dir: Output directory
        batch_size: Resources per bundle
        preserve_ids: Whether to preserve resource IDs

    Returns:
        Total number of bundles created
    """
    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    total_bundles = 0

    for level_idx, resource_types in enumerate(dependency_levels, 1):
        level_dir = output_dir / f"level-{level_idx:02d}"
        level_dir.mkdir(parents=True, exist_ok=True)

        level_type_names = [rt for rt in resource_types if rt in resources_by_type]

        if level_type_names:
            print(f"  Level {level_idx}")

        for resource_type in level_type_names:
            resources = resources_by_type.get(resource_type, [])

            if not resources:
                continue

            # Split resources into batches
            num_batches = (len(resources) + batch_size - 1) // batch_size

            for batch_idx in range(num_batches):
                start_idx = batch_idx * batch_size
                end_idx = min(start_idx + batch_size, len(resources))
                batch_resources = resources[start_idx:end_idx]

                # Create bundle
                bundle = create_batch_bundle(batch_resources, preserve_ids)

                # Generate filename
                resource_name = resource_type.lower()
                # Convert CamelCase to kebab-case for compound medication resources
                if resource_name.startswith('medication') and len(resource_name) > len('medication'):
                    # MedicationRequest -> medication-request
                    resource_name = resource_name.replace('medication', 'medication-')

                bundle_filename = f"{resource_name}-batch-{batch_idx + 1:03d}.json"
                bundle_path = level_dir / bundle_filename

                # Write bundle file
                with open(bundle_path, 'w', encoding='utf-8') as f:
                    json.dump(bundle, f, indent=2, ensure_ascii=False)

                total_bundles += 1

            print(f"    {resource_type}: {num_batches} bundle{'s' if num_batches > 1 else ''} created")

    return total_bundles


def generate_upload_plan(
    dependency_levels: List[List[str]],
    resources_by_type: Dict[str, List[Dict]],
    orphaned_refs: List[Dict],
    circular_refs: List[List[str]],
    circular_instances: Dict[str, List[Dict]],
    output_file: Path,
    analysis_enabled: bool,
    batch_size: int
):
    """
    Generate upload-plan.json with metadata.

    Args:
        dependency_levels: Sorted dependency levels
        resources_by_type: Resources grouped by type
        orphaned_refs: List of orphaned references
        circular_refs: List of circular dependencies
        output_file: Output file path
        analysis_enabled: Whether reference analysis was enabled
        batch_size: Batch size used
    """
    total_resources = sum(len(resources) for resources in resources_by_type.values())

    # Build level details
    level_details = []
    for level_idx, resource_types in enumerate(dependency_levels, 1):
        level_type_names = [rt for rt in resource_types if rt in resources_by_type]
        level_resources = sum(len(resources_by_type.get(rt, [])) for rt in level_type_names)
        level_bundles = sum(
            (len(resources_by_type.get(rt, [])) + batch_size - 1) // batch_size
            for rt in level_type_names
        )

        # Determine dependencies
        dependencies = set()
        for rt in level_type_names:
            for prev_level in dependency_levels[:level_idx - 1]:
                for prev_rt in prev_level:
                    if prev_rt in resources_by_type:
                        dependencies.add(prev_rt)

        level_name_map = {
            1: "Foundation Resources",
            2: "Patient Context",
            3: "Encounters",
            4: "Clinical Context",
            5: "Clinical Data"
        }

        level_details.append({
            'level': level_idx,
            'name': level_name_map.get(level_idx, f"Level {level_idx}"),
            'resource_types': level_type_names,
            'total_resources': level_resources,
            'bundles': level_bundles,
            'dependencies': sorted(list(dependencies))
        })

    total_bundles = sum(level['bundles'] for level in level_details)

    plan = {
        'analysis_timestamp': datetime.now().isoformat(),
        'total_resources': total_resources,
        'total_bundles': total_bundles,
        'batch_size': batch_size,
        'reference_analysis_enabled': analysis_enabled,
        'dependency_levels': level_details,
        'circular_references': circular_refs,
        'circular_reference_instances': circular_instances,
        'orphaned_references': orphaned_refs[:100]  # Limit to first 100
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(plan, f, indent=2, ensure_ascii=False)


def print_summary(
    resources_by_type: Dict,
    dependency_levels: List[List[str]],
    total_bundles: int,
    orphaned_refs: List[Dict],
    circular_refs: List[List[str]],
    output_dir: Path,
    duration: float
):
    """Print summary to console."""
    print("\n" + "=" * 50)
    print("Summary")
    print("=" * 50)

    total_resources = sum(len(resources) for resources in resources_by_type.values())

    print(f"Total resources processed: {total_resources:,}")
    print(f"Total bundles created: {total_bundles}")
    print(f"Output directory: {output_dir}")
    print(f"Upload plan saved: {output_dir / 'upload-plan.json'}")

    if orphaned_refs or circular_refs:
        print("\nWARNINGS:")
        if orphaned_refs:
            print(f"  - {len(orphaned_refs)} orphaned references found (resources reference non-existent resources)")
        if circular_refs:
            print(f"  - {len(circular_refs)} circular dependencies detected")
        print("  - See upload-plan.json for details")

    print("\nOK Bundles ready for upload")
    print(f"  Use these bundles with your FHIR upload tool in level order (1->2->3->4->5)")

    print(f"\nDuration: {format_duration(duration)}")
    print("=" * 50)


def main():
    """Main entry point."""
    start_time = time.time()

    # 1. Parse arguments and load config
    args = parse_arguments()
    config = load_config(args)

    print("=" * 50)
    print("FHIR Bundle Preparation Tool")
    print("=" * 50)
    print(f"Input: {config['input_dir']}")
    print(f"Output: {config['output_dir']}")
    print(f"Batch Size: {config['batch_size']}")
    print(f"Reference Analysis: {'ENABLED' if config['analyze_references'] else 'DISABLED'}")
    print()

    # 2. Phase 1: Discover resources
    print("[Phase 1] Discovering resources...")
    resources_by_type = scan_ndjson_files(config['input_dir'])

    print("\nResource inventory:")
    for resource_type, resources in sorted(resources_by_type.items()):
        print(f"  {resource_type}: {len(resources)} resources")
    print()

    # 3. Phase 2 & 3: Extract references and build graph (if enabled)
    dependency_levels = []
    orphaned_refs = []
    circular_refs = []
    circular_instances = []

    if config['analyze_references']:
        print("[Phase 2] Extracting references...")
        inventory = build_resource_inventory(resources_by_type)

        print("\n[Phase 3] Building dependency graph...")
        graph, orphaned_refs = build_dependency_graph(resources_by_type, inventory)
        print("OK Graph constructed")

        # Detect circular dependencies
        circular_refs = detect_circular_dependencies(graph)
        circular_instances = []

        if circular_refs:
            print(f"WARNING: Found {len(circular_refs)} circular dependency type(s)")
            print("  Analyzing mutual reference instances...")
            circular_instances = find_circular_resource_instances(resources_by_type, circular_refs)

            if circular_instances:
                print(f"  Found {len(circular_instances)} mutual reference pair(s):")
                for example in circular_instances[:3]:  # Show first 3
                    print(f"    * {example['resource_a']} <-> {example['resource_b']}")
            else:
                print("  No mutual references found (resources can reference same type, which is OK)")
        else:
            print("OK No circular dependencies detected")

        if orphaned_refs:
            print(f"WARNING: Found {len(orphaned_refs)} orphaned references (see upload-plan.json)")

        # 4. Phase 4: Compute upload order
        print("\n[Phase 4] Computing upload order...")
        dependency_levels = topological_sort_levels(graph)

        if not dependency_levels:
            print("WARNING: Using fallback order")
            # Use default order
            dependency_levels = [[rt] for rt in DEFAULT_RESOURCE_ORDER if rt in resources_by_type]
        else:
            print(f"Topological sort completed: {len(dependency_levels)} dependency levels")
    else:
        # Use default order
        print("[Phases 2-4] Skipped (using default order)")
        dependency_levels = [[rt] for rt in DEFAULT_RESOURCE_ORDER if rt in resources_by_type]

    # Display dependency levels
    print("\nDependency levels:")
    for level_idx, resource_types in enumerate(dependency_levels, 1):
        level_type_names = [rt for rt in resource_types if rt in resources_by_type]
        if level_type_names:
            level_resources = sum(len(resources_by_type.get(rt, [])) for rt in level_type_names)
            types_str = ", ".join(level_type_names)
            print(f"  Level {level_idx}: {types_str} ({level_resources} resources)")

    # 5. Phase 5: Create bundle files
    print("\n[Phase 5] Creating bundle files...")
    total_bundles = write_bundle_files(
        resources_by_type,
        dependency_levels,
        config['output_dir'],
        config['batch_size'],
        config['preserve_ids']
    )

    # 6. Generate upload plan
    plan_file = config['output_dir'] / 'upload-plan.json'
    generate_upload_plan(
        dependency_levels,
        resources_by_type,
        orphaned_refs,
        circular_refs,
        circular_instances,
        plan_file,
        config['analyze_references'],
        config['batch_size']
    )

    # 7. Print summary
    duration = time.time() - start_time
    print_summary(
        resources_by_type,
        dependency_levels,
        total_bundles,
        orphaned_refs,
        circular_refs,
        config['output_dir'],
        duration
    )


if __name__ == "__main__":
    main()
