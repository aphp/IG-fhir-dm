#!/usr/bin/env python3
"""
FHIR Bundle Preparation Tool
Transform NDJSON files into FHIR Bundle (type: transaction) JSON files.
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

    parser.add_argument(
        '--no-verify',
        action='store_true',
        help='Skip consistency verification'
    )

    parser.add_argument(
        '--debug-report',
        action='store_true',
        help='Generate detailed debug report (missing-resources-report.json)'
    )

    parser.add_argument(
        '--export-missing-ids',
        type=str,
        metavar='PATH',
        help='Export list of missing resource IDs to specified file'
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
    env_verify = os.getenv('VERIFY_CONSISTENCY', 'true').lower() in ('true', '1', 'yes', 'on')
    env_debug_report = os.getenv('GENERATE_DEBUG_REPORT', 'true').lower() in ('true', '1', 'yes', 'on')
    env_export_missing = os.getenv('EXPORT_MISSING_IDS', 'true').lower() in ('true', '1', 'yes', 'on')

    config = {
        'input_dir': Path(args.input) if args.input else Path(env_input_dir),
        'output_dir': Path(args.output) if args.output else Path(env_output_dir),
        'batch_size': args.batch_size if args.batch_size != 100 else env_batch_size,  # Use env if not explicitly set
        'analyze_references': not args.no_analyze if args.no_analyze else env_analyze,
        'preserve_ids': args.preserve_ids if hasattr(args, 'preserve_ids') else env_preserve_ids,
        'verify_consistency': not args.no_verify if args.no_verify else env_verify,
        'generate_debug_report': args.debug_report or env_debug_report,
        'export_missing_ids': args.export_missing_ids or env_export_missing
    }

    return config


def scan_ndjson_files(input_dir: Path) -> Tuple[Dict[str, List[Dict]], Dict[Tuple[str, str], Dict], Dict[Tuple[str, str], Path]]:
    """
    Scan directory and load all resources grouped by type with metadata.

    Args:
        input_dir: Directory containing NDJSON files

    Returns:
        Tuple of:
        - resources_by_type: {resource_type: [resources]}
        - source_resources_map: {(resource_type, resource_id): full_resource_with_metadata}
        - ndjson_files: {(resource_type, resource_id): source_file_path}
    """
    resources_by_type = defaultdict(list)
    source_resources_map = {}
    ndjson_file_map = {}

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

                    # Add source metadata to resource
                    resource['_source_file'] = ndjson_file.name
                    resource['_line_number'] = line_num

                    resources_by_type[resource_type].append(resource)

                    # Track in source resources map
                    if 'id' in resource:
                        resource_id = resource['id']
                        key = (resource_type, resource_id)
                        source_resources_map[key] = resource.copy()
                        ndjson_file_map[key] = ndjson_file

                    total_resources += 1
                except json.JSONDecodeError as e:
                    print(f"WARNING: Error parsing {ndjson_file.name}:{line_num}: {e}")
                    continue

    print(f"Scanning resources: {total_resources:,} resources")

    return dict(resources_by_type), source_resources_map, ndjson_file_map


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


def build_reverse_reference_map(resources_by_type: Dict[str, List[Dict]]) -> Dict[str, List[str]]:
    """
    Build a map of which resources are referenced by which other resources.

    Args:
        resources_by_type: Resources grouped by type

    Returns:
        Dictionary mapping referenced resources to lists of resources that reference them
        Example: {"Patient/123": ["Encounter/456", "Observation/789"]}
    """
    reverse_map = defaultdict(list)

    total_resources = sum(len(resources) for resources in resources_by_type.values())
    print(f"Building reverse reference map for {total_resources:,} resources...")
    processed = 0

    for resource_type, resources in resources_by_type.items():
        for resource in resources:
            resource_id = resource.get('id')
            if not resource_id:
                continue

            resource_ref = f"{resource_type}/{resource_id}"

            # Extract all references from this resource
            refs = extract_references(resource)

            for ref_string, ref_path in refs:
                target_type, target_id = parse_reference(ref_string)

                if not target_type or not target_id:
                    continue

                target_ref = f"{target_type}/{target_id}"

                # Add this resource to the reverse map for the target
                reverse_map[target_ref].append(resource_ref)

            # Progress indicator
            processed += 1
            if processed % 10000 == 0:
                pct = (processed / total_resources) * 100
                print(f"  Progress: {processed:,}/{total_resources:,} ({pct:.1f}%)", flush=True)

    print(f"Reverse map built with {len(reverse_map):,} referenced resources")
    return dict(reverse_map)


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
    graph = nx.DiGraph()

    # Build resource ID inventory for this type
    resource_ids = {r.get('id') for r in resources if r.get('id')}

    # Add all resource IDs as nodes
    for resource_id in resource_ids:
        graph.add_node(resource_id)

    # Build edges based on same-type references
    for resource in resources:
        resource_id = resource.get('id')
        if not resource_id:
            continue

        # Extract all references from this resource
        refs = extract_references(resource)

        for ref_string, ref_path in refs:
            target_type, target_id = parse_reference(ref_string)

            # Only consider references to the same resource type
            if target_type == resource_type and target_id in resource_ids:
                # Create edge: resource_id -> target_id
                # This means resource_id depends on target_id
                # So target_id must be loaded before resource_id
                graph.add_edge(resource_id, target_id)

    return graph


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
    if not resources:
        return []

    # Build dependency graph
    graph = build_intra_type_dependency_graph(resources, resource_type)

    # If no dependencies, no mutual references
    if graph.number_of_edges() == 0:
        return []

    # Find strongly connected components
    sccs = list(nx.strongly_connected_components(graph))

    # Return only SCCs with more than one node (mutual references)
    mutual_groups = [scc for scc in sccs if len(scc) > 1]

    return mutual_groups


def topological_sort_resources(
    resources: List[Dict],
    resource_type: str
) -> Tuple[List[Dict], List[Set[str]]]:
    """
    Sort resources of the same type by their intra-type dependencies.
    Keeps mutual reference groups together using SCC algorithm.

    Args:
        resources: List of resources to sort
        resource_type: The resource type

    Returns:
        Tuple of:
        - Sorted list of resources (dependencies first, mutual groups kept together)
        - List of mutual reference groups (SCCs with size > 1)

    Algorithm:
        1. Build intra-type dependency graph
        2. Find strongly connected components (mutual reference groups)
        3. Build condensation graph (collapse SCCs into super nodes)
        4. Perform topological sort on condensation
        5. Expand super nodes back to original resources
        6. Return sorted resources with mutual groups intact
    """
    if not resources:
        return resources, []

    # Build dependency graph
    graph = build_intra_type_dependency_graph(resources, resource_type)

    # If no dependencies, return original order
    if graph.number_of_edges() == 0:
        return resources, []

    # Find strongly connected components (includes single nodes and mutual groups)
    sccs = list(nx.strongly_connected_components(graph))

    # Identify mutual groups (SCCs with > 1 node)
    mutual_groups = [scc for scc in sccs if len(scc) > 1]

    # Create condensation graph (SCCs collapsed into super nodes)
    # This is a DAG even if original graph has cycles
    condensation = nx.condensation(graph, scc=sccs)

    # Reverse because we want dependencies first
    reversed_condensation = condensation.reverse()

    # Topological sort on the condensation
    try:
        sorted_scc_indices = list(nx.topological_sort(reversed_condensation))
    except:
        # Fallback to original order
        return resources, mutual_groups

    # Create mapping from resource ID to resource
    resource_map = {r.get('id'): r for r in resources if r.get('id')}

    # Build sorted resource list by expanding SCCs in sorted order
    sorted_resources = []
    added_ids = set()

    for scc_idx in sorted_scc_indices:
        scc = sccs[scc_idx]
        # Add all resources in this SCC
        for resource_id in scc:
            if resource_id in resource_map and resource_id not in added_ids:
                sorted_resources.append(resource_map[resource_id])
                added_ids.add(resource_id)

    # Add any resources not in graph (no ID or isolated)
    for resource in resources:
        resource_id = resource.get('id')
        if not resource_id or resource_id not in added_ids:
            sorted_resources.append(resource)

    return sorted_resources, mutual_groups


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

    total_resources = sum(len(resources) for resources in resources_by_type.values())
    print(f"Analyzing references in {total_resources:,} resources...")

    total_refs = 0
    processed = 0

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

            # Progress indicator every 10000 resources
            processed += 1
            if processed % 10000 == 0:
                pct = (processed / total_resources) * 100
                print(f"  Progress: {processed:,}/{total_resources:,} ({pct:.1f}%)", flush=True)

    print(f"Found {total_refs:,} references total")

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


def create_transaction_bundle(
    resources: List[Dict],
    preserve_ids: bool = True
) -> Dict:
    """
    Create FHIR Bundle of type 'transaction'.

    Args:
        resources: List of FHIR resources
        preserve_ids: Whether to preserve original resource IDs

    Returns:
        FHIR Bundle resource
    """
    bundle = {
        "resourceType": "Bundle",
        "type": "transaction",
        "entry": []
    }

    for resource in resources:
        resource_type = resource.get('resourceType')
        resource_id = resource.get('id')

        if not resource_type or not resource_id:
            continue

        # Create clean copy without metadata fields
        clean_resource = {k: v for k, v in resource.items() if not k.startswith('_')}

        entry = {
            "request": {
                "method": "PUT",
                "url": f"{resource_type}/{resource_id}"
            },
            "resource": clean_resource
        }

        bundle["entry"].append(entry)

    return bundle


def write_bundle_files(
    resources_by_type: Dict[str, List[Dict]],
    dependency_levels: List[List[str]],
    output_dir: Path,
    batch_size: int,
    preserve_ids: bool
) -> Tuple[int, Dict[str, List[Dict]]]:
    """
    Write bundle JSON files organized by dependency level.

    Args:
        resources_by_type: Resources grouped by type
        dependency_levels: Sorted dependency levels
        output_dir: Output directory
        batch_size: Resources per bundle
        preserve_ids: Whether to preserve resource IDs

    Returns:
        Tuple of:
        - total_bundles: number of bundle files created
        - bundle_resources: {resource_type: [resources]} extracted from created bundles
          (each resource augmented with _bundle_file and _entry_index)
    """
    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    total_bundles = 0
    bundle_resources = defaultdict(list)

    for level_idx, resource_types in enumerate(dependency_levels, 1):
        level_type_names = [rt for rt in resource_types if rt in resources_by_type]

        if not level_type_names:
            continue

        level_dir = output_dir / f"level-{level_idx:02d}"
        level_dir.mkdir(parents=True, exist_ok=True)

        print(f"  Level {level_idx}")

        for resource_type in level_type_names:
            resources = resources_by_type.get(resource_type, [])

            if not resources:
                continue

            # Sort resources by intra-type dependencies and get mutual groups
            sorted_resources, mutual_groups = topological_sort_resources(resources, resource_type)

            # Build ID-to-group mapping for quick lookup
            id_to_group_idx = {}
            for group_idx, group in enumerate(mutual_groups):
                for resource_id in group:
                    id_to_group_idx[resource_id] = group_idx

            # Track which resources have been added to batches
            processed_ids = set()

            # Create batches ensuring mutual reference groups stay together
            batches = []
            current_batch = []

            i = 0
            while i < len(sorted_resources):
                resource = sorted_resources[i]
                resource_id = resource.get('id')

                # Skip if already processed (part of a group we already added)
                if resource_id and resource_id in processed_ids:
                    i += 1
                    continue

                # Check if this resource is part of a mutual group
                if resource_id and resource_id in id_to_group_idx:
                    group_idx = id_to_group_idx[resource_id]
                    group = mutual_groups[group_idx]

                    # Collect all resources in this group
                    group_resources = []
                    for r in sorted_resources:
                        if r.get('id') in group:
                            group_resources.append(r)

                    group_size = len(group_resources)

                    # If group doesn't fit in current batch, start new batch
                    if len(current_batch) > 0 and len(current_batch) + group_size > batch_size:
                        batches.append(current_batch)
                        current_batch = []

                    # Add all group members
                    current_batch.extend(group_resources)

                    # Mark all as processed
                    for gr in group_resources:
                        if gr.get('id'):
                            processed_ids.add(gr.get('id'))

                    # If batch is now full or oversized, finalize it
                    if len(current_batch) >= batch_size:
                        batches.append(current_batch)
                        current_batch = []
                else:
                    # Regular resource (not in mutual group)
                    if len(current_batch) >= batch_size:
                        batches.append(current_batch)
                        current_batch = []

                    current_batch.append(resource)
                    if resource_id:
                        processed_ids.add(resource_id)

                i += 1

            # Add final batch if not empty
            if current_batch:
                batches.append(current_batch)

            # Create bundle files
            num_batches = len(batches)

            for batch_idx, batch_resources in enumerate(batches):
                # Create bundle
                bundle = create_transaction_bundle(batch_resources, preserve_ids)

                # Generate filename
                resource_name = resource_type.lower()
                # Convert CamelCase to kebab-case for compound medication resources
                if resource_name.startswith('medication') and len(resource_name) > len('medication'):
                    # MedicationRequest -> medication-request
                    resource_name = resource_name.replace('medication', 'medication-')

                bundle_filename = f"{resource_name}-batch-{batch_idx + 1:03d}.json"
                bundle_path = level_dir / bundle_filename
                relative_bundle_path = f"level-{level_idx:02d}/{bundle_filename}"

                # Write bundle file
                with open(bundle_path, 'w', encoding='utf-8') as f:
                    json.dump(bundle, f, indent=2, ensure_ascii=False)

                # Track resources in this bundle
                for entry_idx, entry in enumerate(bundle.get('entry', [])):
                    resource = entry.get('resource', {})
                    if resource:
                        # Add bundle metadata
                        resource_copy = resource.copy()
                        resource_copy['_bundle_file'] = relative_bundle_path
                        resource_copy['_entry_index'] = entry_idx
                        bundle_resources[resource_type].append(resource_copy)

                total_bundles += 1

            # Report status
            mutual_count = len(mutual_groups)
            mutual_resources_count = sum(len(g) for g in mutual_groups)

            # Verify all resources were batched
            batched_count = sum(len(batch) for batch in batches)
            if batched_count != len(resources):
                print(f"    WARNING: {resource_type} - Only {batched_count}/{len(resources)} resources batched!")
                print(f"      Sorted: {len(sorted_resources)}, Processed: {len(processed_ids)}, Mutual: {mutual_resources_count}")

            if mutual_count > 0:
                print(f"    {resource_type}: {num_batches} bundle{'s' if num_batches > 1 else ''} created ({batched_count} resources)")
                print(f"      -> {mutual_count} mutual reference group{'s' if mutual_count > 1 else ''} ({mutual_resources_count} resources)")
            else:
                intra_deps = build_intra_type_dependency_graph(resources, resource_type)
                intra_deps_note = f" (intra-type deps: {intra_deps.number_of_edges()})" if intra_deps.number_of_edges() > 0 else ""
                print(f"    {resource_type}: {num_batches} bundle{'s' if num_batches > 1 else ''} created ({batched_count} resources){intra_deps_note}")

    return total_bundles, dict(bundle_resources)


def verify_consistency(
    source_inventory: Dict[str, Set[str]],
    resources_by_type: Dict[str, List[Dict]],
    bundle_resources: Dict[str, List[Dict]],
    ndjson_files: Dict[Tuple[str, str], Path],
    source_resources_map: Dict[Tuple[str, str], Dict],
    reverse_reference_map: Dict[str, List[str]]
) -> Dict:
    """
    Verify consistency between source NDJSON resources and destination bundle resources.

    Args:
        source_inventory: Inventory of source resource IDs by type
        resources_by_type: Source resources grouped by type
        bundle_resources: Resources extracted from bundles
        ndjson_files: Map of resource keys to source file paths
        source_resources_map: Full source resources with metadata
        reverse_reference_map: Map of which resources reference which

    Returns:
        Dictionary with detailed consistency check results
    """
    # Build destination inventory
    destination_inventory = defaultdict(set)
    for resource_type, resources in bundle_resources.items():
        for resource in resources:
            if 'id' in resource:
                destination_inventory[resource_type].add(resource['id'])

    # Count totals
    total_source = sum(len(ids) for ids in source_inventory.values())
    total_destination = sum(len(ids) for ids in destination_inventory.values())

    # Find missing resources (in source but not in destination)
    missing_resources = []
    for resource_type, source_ids in source_inventory.items():
        destination_ids = destination_inventory.get(resource_type, set())
        missing_ids = source_ids - destination_ids

        for resource_id in missing_ids:
            key = (resource_type, resource_id)
            source_resource = source_resources_map.get(key, {})

            # Calculate expected bundle (this is approximate)
            source_file = source_resource.get('_source_file', 'unknown')
            line_number = source_resource.get('_line_number', 0)

            # Get referenced by list
            resource_ref = f"{resource_type}/{resource_id}"
            referenced_by = reverse_reference_map.get(resource_ref, [])

            # Create resource snapshot (remove metadata fields)
            resource_snapshot = {k: v for k, v in source_resource.items()
                               if not k.startswith('_')}

            missing_resources.append({
                'resource_type': resource_type,
                'resource_id': resource_id,
                'full_reference': resource_ref,
                'source_file': source_file,
                'source_line_number': line_number,
                'resource_snapshot': resource_snapshot,
                'referenced_by': referenced_by
            })

    # Find extra resources (in destination but not in source)
    extra_resources = []
    for resource_type, destination_ids in destination_inventory.items():
        source_ids = source_inventory.get(resource_type, set())
        extra_ids = destination_ids - source_ids

        for resource_id in extra_ids:
            # Find this resource in bundle_resources
            for resource in bundle_resources.get(resource_type, []):
                if resource.get('id') == resource_id:
                    extra_resources.append({
                        'resource_type': resource_type,
                        'resource_id': resource_id,
                        'full_reference': f"{resource_type}/{resource_id}",
                        'bundle_file': resource.get('_bundle_file', 'unknown'),
                        'bundle_entry_index': resource.get('_entry_index', -1),
                        'possible_cause': 'Duplicate resource in source or processing error'
                    })
                    break

    # Find type mismatches (same ID but different types)
    type_mismatches = []
    # This would require tracking IDs across types, which is uncommon
    # Skipping for now as it's a rare edge case

    # Determine status
    matched = total_source - len(missing_resources)
    status = 'passed' if len(missing_resources) == 0 and len(extra_resources) == 0 else 'failed'

    return {
        'status': status,
        'total_source': total_source,
        'total_destination': total_destination,
        'matched': matched,
        'missing_in_destination': missing_resources,
        'extra_in_destination': extra_resources,
        'type_mismatches': type_mismatches
    }


def print_consistency_results(results: Dict, verbose: bool = True):
    """
    Print detailed consistency check results to console with formatted output.

    Args:
        results: Consistency check results dictionary
        verbose: Whether to print detailed information
    """
    print(f"\n[Phase 6] Verifying consistency...")
    print(f"Comparing source and destination resources...")

    status = results['status']
    total_source = results['total_source']
    total_destination = results['total_destination']
    matched = results['matched']
    missing = results['missing_in_destination']
    extra = results['extra_in_destination']
    type_mismatches = results['type_mismatches']

    if status == 'passed':
        print(f"OK Consistency check PASSED")
        print(f"  Source resources: {total_source:,}")
        print(f"  Destination resources: {total_destination:,}")
        print(f"  Matched: {matched:,} (100%)")
        print(f"  Missing: 0")
        print(f"  Extra: 0")
        print(f"  Type mismatches: 0")
    else:
        print(f"ERROR Consistency check FAILED")
        print(f"  Source resources: {total_source:,}")
        print(f"  Destination resources: {total_destination:,}")
        matched_pct = (matched / total_source * 100) if total_source > 0 else 0
        print(f"  Matched: {matched:,} ({matched_pct:.2f}%)")
        print(f"  Missing in destination: {len(missing)}")
        print(f"  Extra in destination: {len(extra)}")
        print(f"  Type mismatches: {len(type_mismatches)}")

        if verbose and missing:
            print("\n" + "=" * 70)
            print("MISSING RESOURCES (not found in bundles)")
            print("=" * 70)

            for idx, res in enumerate(missing[:10], 1):  # Show first 10
                print(f"\n{idx}. {res['full_reference']}")
                print(f"   Source: {res['source_file']} (line {res['source_line_number']})")
                if res['referenced_by']:
                    ref_count = len(res['referenced_by'])
                    refs_display = ', '.join(res['referenced_by'][:3])
                    if ref_count > 3:
                        refs_display += f', ... ({ref_count - 3} more)'
                    print(f"   Referenced by: {ref_count} resources ({refs_display})")
                else:
                    print(f"   Referenced by: 0 resources")

            if len(missing) > 10:
                print(f"\n... and {len(missing) - 10} more (see debug report)")

        if verbose and extra:
            print("\n" + "=" * 70)
            print("EXTRA RESOURCES (found in bundles but not in source)")
            print("=" * 70)

            for idx, res in enumerate(extra[:10], 1):  # Show first 10
                print(f"\n{idx}. {res['full_reference']}")
                print(f"   Bundle: {res['bundle_file']} (entry #{res['bundle_entry_index']})")
                print(f"   Possible cause: {res['possible_cause']}")

            if len(extra) > 10:
                print(f"\n... and {len(extra) - 10} more (see debug report)")


def generate_debug_report(
    consistency_results: Dict,
    output_file: Path
):
    """
    Generate detailed JSON debug report for consistency issues.

    Args:
        consistency_results: Consistency check results
        output_file: Path to output JSON file
    """
    missing = consistency_results['missing_in_destination']
    extra = consistency_results['extra_in_destination']
    type_mismatches = consistency_results['type_mismatches']

    # Analyze most affected resource types
    type_counts = defaultdict(lambda: {'missing': 0, 'total': 0})
    for res in missing:
        resource_type = res['resource_type']
        type_counts[resource_type]['missing'] += 1

    most_affected = []
    for resource_type, counts in sorted(type_counts.items(),
                                       key=lambda x: x[1]['missing'],
                                       reverse=True):
        most_affected.append({
            'resource_type': resource_type,
            'missing_count': counts['missing'],
            'missing_percentage': (counts['missing'] / counts['total'] * 100) if counts['total'] > 0 else 0
        })

    report = {
        'report_timestamp': datetime.now().isoformat(),
        'consistency_status': consistency_results['status'],
        'summary': {
            'total_source_resources': consistency_results['total_source'],
            'total_destination_resources': consistency_results['total_destination'],
            'matched_resources': consistency_results['matched'],
            'missing_count': len(missing),
            'extra_count': len(extra),
            'type_mismatch_count': len(type_mismatches)
        },
        'missing_resources': missing,
        'extra_resources': extra,
        'type_mismatches': type_mismatches,
        'analysis': {
            'most_affected_resource_types': most_affected[:5],
            'potential_causes': [
                'Resources may have been filtered during processing',
                'Possible duplicate handling issue',
                'Bundle creation may have skipped invalid resources',
                'Check for resources with missing required fields'
            ]
        }
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)


def export_missing_ids(missing_resources: List[Dict], output_file: Path):
    """
    Export missing resource IDs to a simple text file.

    Args:
        missing_resources: List of missing resource dictionaries
        output_file: Path to output text file
    """
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"# Missing Resource IDs Report\n")
        f.write(f"# Generated: {datetime.now().isoformat()}\n")
        f.write(f"# Total Missing: {len(missing_resources)}\n\n")

        for res in missing_resources:
            f.write(f"{res['full_reference']}\n")


def generate_upload_plan(
    dependency_levels: List[List[str]],
    resources_by_type: Dict[str, List[Dict]],
    orphaned_refs: List[Dict],
    circular_refs: List[List[str]],
    circular_instances: Dict[str, List[Dict]],
    output_file: Path,
    analysis_enabled: bool,
    batch_size: int,
    consistency_results: Optional[Dict] = None
):
    """
    Generate upload-plan.json with metadata.

    Args:
        dependency_levels: Sorted dependency levels
        resources_by_type: Resources grouped by type
        orphaned_refs: List of orphaned references
        circular_refs: List of circular dependencies
        circular_instances: Actual circular reference examples
        output_file: Output file path
        analysis_enabled: Whether reference analysis was enabled
        batch_size: Batch size used
        consistency_results: Optional consistency check results
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

    # Add consistency check results if available
    if consistency_results:
        plan['consistency_check'] = {
            'enabled': True,
            'status': consistency_results['status'],
            'total_source_resources': consistency_results['total_source'],
            'total_destination_resources': consistency_results['total_destination'],
            'matched_resources': consistency_results['matched'],
            'missing_in_destination': len(consistency_results['missing_in_destination']),
            'extra_in_destination': len(consistency_results['extra_in_destination']),
            'type_mismatches': len(consistency_results['type_mismatches'])
        }
    else:
        plan['consistency_check'] = {
            'enabled': False
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
    duration: float,
    consistency_results: Optional[Dict] = None
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

    # Check for critical errors (consistency failure)
    has_critical_errors = False
    if consistency_results and consistency_results['status'] == 'failed':
        has_critical_errors = True
        missing_count = len(consistency_results['missing_in_destination'])
        extra_count = len(consistency_results['extra_in_destination'])
        mismatch_count = len(consistency_results['type_mismatches'])

        print("\n" + "=" * 50)
        print("CRITICAL ERRORS")
        print("=" * 50)
        print(f"  - Consistency check failed: {missing_count} resources missing, {extra_count} extra, {mismatch_count} type mismatch(es)")
        print(f"  - DO NOT upload these bundles until consistency issues are resolved")
        print(f"  - Detailed debug report: {output_dir / 'missing-resources-report.json'}")
        print(f"  - Missing IDs list: {output_dir / 'missing-ids.txt'}")

        print("\nRecommended Actions:")
        print("  1. Review missing-resources-report.json for detailed analysis")
        print("  2. Check source NDJSON files for data integrity")
        print("  3. Verify processing logic didn't filter out resources")
        print("  4. Re-run with --debug flag for verbose logging")

    # Show warnings
    if orphaned_refs or circular_refs:
        print("\nWARNINGS:")
        if orphaned_refs:
            print(f"  - {len(orphaned_refs)} orphaned references found (resources reference non-existent resources)")
        if circular_refs:
            print(f"  - {len(circular_refs)} circular dependencies detected")
        print("  - See upload-plan.json for details")

    # Final status
    if has_critical_errors:
        print("\nERROR Bundles have consistency issues")
        print("  DO NOT upload until issues are resolved")
    else:
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
    print(f"Consistency Verification: {'ENABLED' if config['verify_consistency'] else 'DISABLED'}")
    print()

    # 2. Phase 1: Discover resources
    print("[Phase 1] Discovering resources...")
    resources_by_type, source_resources_map, ndjson_files = scan_ndjson_files(config['input_dir'])
    source_inventory = build_resource_inventory(resources_by_type)

    print("\nResource inventory:")
    for resource_type, resources in sorted(resources_by_type.items()):
        print(f"  {resource_type}: {len(resources)} resources")
    print()

    # 3. Phase 2 & 3: Extract references and build graph (if enabled)
    dependency_levels = []
    orphaned_refs = []
    circular_refs = []
    circular_instances = []
    reverse_reference_map = {}

    if config['analyze_references']:
        print("\n[Phase 2] Extracting references...")
        reverse_reference_map = build_reverse_reference_map(resources_by_type)

        print("\n[Phase 3] Building dependency graph...")
        graph, orphaned_refs = build_dependency_graph(resources_by_type, source_inventory)
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
                # Show first 10 pairs
                for example in circular_instances[:10]:
                    print(f"    * {example['resource_a']} <-> {example['resource_b']}")
                if len(circular_instances) > 10:
                    print(f"    ... and {len(circular_instances) - 10} more (see upload-plan.json)")
                print(f"  NOTE: Mutual reference groups will be kept in the same bundle")
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
    total_bundles, bundle_resources = write_bundle_files(
        resources_by_type,
        dependency_levels,
        config['output_dir'],
        config['batch_size'],
        config['preserve_ids']
    )

    # 6. Phase 6: Verify consistency (if enabled)
    consistency_results = None
    if config['verify_consistency']:
        consistency_results = verify_consistency(
            source_inventory,
            resources_by_type,
            bundle_resources,
            ndjson_files,
            source_resources_map,
            reverse_reference_map
        )
        print_consistency_results(consistency_results, verbose=True)

        # Generate debug reports if consistency failed
        if consistency_results['status'] == 'failed':
            if config.get('generate_debug_report', True):
                debug_report_path = config['output_dir'] / 'missing-resources-report.json'
                generate_debug_report(consistency_results, debug_report_path)
                print(f"\nDebug report generated: {debug_report_path}")

            if config.get('export_missing_ids', True):
                missing_ids_path = Path(config['export_missing_ids']) if isinstance(config['export_missing_ids'], str) else (config['output_dir'] / 'missing-ids.txt')
                export_missing_ids(
                    consistency_results['missing_in_destination'],
                    missing_ids_path
                )
                print(f"Missing IDs exported: {missing_ids_path}")

    # 7. Generate upload plan
    plan_file = config['output_dir'] / 'upload-plan.json'
    generate_upload_plan(
        dependency_levels,
        resources_by_type,
        orphaned_refs,
        circular_refs,
        circular_instances,
        plan_file,
        config['analyze_references'],
        config['batch_size'],
        consistency_results
    )

    # 8. Print summary
    duration = time.time() - start_time
    print_summary(
        resources_by_type,
        dependency_levels,
        total_bundles,
        orphaned_refs,
        circular_refs,
        config['output_dir'],
        duration,
        consistency_results
    )

    # 9. Exit with error code if consistency failed
    if consistency_results and consistency_results['status'] == 'failed':
        sys.exit(1)


if __name__ == "__main__":
    main()
