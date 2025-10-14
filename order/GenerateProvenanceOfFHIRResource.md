# Prompt: Generate Provenance Resources for FHIR Historization

## Objective
Automatically create Provenance instances to trace the modification history of FHIR resources (Profiles, CodeSystems, ValueSets, Extensions, etc.) in the FHIR Implementation Guide project.

## Project Context
This FHIR Implementation Guide uses Provenance resources to track the evolution of each FHIR artifact. Each modification (creation, update, deletion) must be documented via a Provenance instance with a unique UUID.

## Reference Structure
Based on project analysis, Provenance instances follow this pattern:

```fsh
Instance: [UUID-v4-unique]
InstanceOf: Provenance
Title: "[commit message or short description]"
Description: """[detailed description of the modification]"""
Usage: #definition

* target[0] = Reference([ResourceName])
* occurredDateTime = "[YYYY-MM-DD]"
* reason.text = """[reason for modification]"""
* activity = $v3-DataOperation#[CREATE|UPDATE|DELETE]
* agent
  * type = $provenance-participant-type#author
  * who.display = "[Author Name]"
* recorded = "[YYYY-MM-DDThh:mm:ss+timezone]"
```

## Detailed Instructions

### 1. Prerequisites
- Verify that the required aliases exist in `input/fsh/aliases.fsh`:
  ```fsh
  Alias: $v3-DataOperation = http://terminology.hl7.org/CodeSystem/v3-DataOperation
  Alias: $provenance-participant-type = http://terminology.hl7.org/CodeSystem/provenance-participant-type
  ```
- Ensure the Python `uuid` module is available to generate unique v4 UUIDs

### 2. Target Resource Identification
For each FSH file in `input/fsh/semantic-layer/`:
- Identify the resource type: CodeSystem, ValueSet, Profile (StructureDefinition), Extension, etc.
- Extract the name/ID of the main resource
- Check for existing Provenance instances for this resource

### 3. Unique UUID Generation
**CRITICAL**: Each Provenance instance MUST have a unique v4 UUID
- Use Python `uuid.uuid4()` to generate UUIDs
- Verify uniqueness before insertion with:
  ```bash
  grep -r "^Instance:" input/fsh --include="*.fsh" | grep "[UUID]"
  ```
- NEVER reuse an existing UUID

### 4. Activity Determination
Choose the appropriate activity based on context:
- `$v3-DataOperation#CREATE`: Initial creation of the resource
- `$v3-DataOperation#UPDATE`: Modification of an existing resource
- `$v3-DataOperation#DELETE`: Deletion or obsolescence (rare)

### 5. Metadata Specification
For each Provenance field:

**target**:
- `* target[0] = Reference([ResourceId])` where ResourceId is the ID of the tracked resource

**occurredDateTime**:
- Modification date in short ISO 8601 format: `YYYY-MM-DD`
- Use git commit date if available, otherwise current date

**reason.text**:
- Concise description of the modification reason
- Reuse git commit message if relevant
- Examples: "first import", "refactor(docs): reorganize structure", "fix: correct code values"

**activity**:
- CREATE for new resources
- UPDATE for modifications

**agent.who.display**:
- Name of the modification author
- Use git committer name if available
- Format: "First Last" or "@username"

**recorded**:
- Complete timestamp in ISO 8601 format: `YYYY-MM-DDThh:mm:ss±hh:mm`
- Include timezone
- Example: "2025-10-14T11:36:20+02:00"

### 6. Positioning in FSH File
Add the Provenance instance **at the end of the concerned FSH file**:
- After the main resource definition
- After existing Provenance instances
- Leave a blank line before and after

### 7. Multiple History Management
If a resource has multiple modifications:
- Create ONE Provenance instance PER modification
- Order chronologically (oldest first)
- Example:
  ```fsh
  // First version
  Instance: [uuid-1]
  * activity = $v3-DataOperation#CREATE
  * occurredDateTime = "2025-02-02"

  // Second version
  Instance: [uuid-2]
  * activity = $v3-DataOperation#UPDATE
  * occurredDateTime = "2025-10-14"
  ```

### 8. Automatic Validation
After generation, verify:
1. **UUID Uniqueness**:
   ```bash
   grep -r "^Instance:" input/fsh --include="*.fsh" | \
   sed 's/^.*Instance:[[:space:]]*//' | sort | uniq -d
   ```
   Expected result: no lines (no duplicates)

2. **Reference Consistency**:
   - Each `target[0]` must reference an existing resource in the same file

3. **Date Formats**:
   - occurredDateTime: `YYYY-MM-DD`
   - recorded: `YYYY-MM-DDThh:mm:ss±hh:mm`

4. **SUSHI Build**:
   ```bash
   ./gradlew sushiBuild
   ```
   No Provenance-related errors should appear

### 9. Specific Use Cases

#### Case 1: New Resource Created
```fsh
CodeSystem: NewCodeSystem
// ... definition ...

Instance: [new-uuid]
InstanceOf: Provenance
Title: "Initial creation"
Description: """Initial creation of NewCodeSystem"""
Usage: #definition

* target[0] = Reference(NewCodeSystem)
* occurredDateTime = "2025-10-15"
* reason.text = """Initial creation"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Your Name"
* recorded = "2025-10-15T14:30:00+01:00"
```

#### Case 2: Updating an Existing Resource
Add a new instance without modifying the old ones:
```fsh
Instance: [new-uuid]
InstanceOf: Provenance
Title: "Add missing codes"
Description: """Added 15 new codes to the CodeSystem"""
Usage: #definition

* target[0] = Reference(ExistingCodeSystem)
* occurredDateTime = "2025-10-15"
* reason.text = """Enhancement: add missing codes from updated specification"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Your Name"
* recorded = "2025-10-15T14:30:00+01:00"
```

#### Case 3: Git-Based Historization
Use git history to generate Provenance:
```python
import subprocess
import uuid
from datetime import datetime

def get_git_history(file_path):
    cmd = f'git log --follow --format="%H|%an|%ai|%s" -- {file_path}'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip().split('\n')

def generate_provenance(commit_info, resource_name):
    commit_hash, author, date, message = commit_info.split('|')
    occurred_date = date.split()[0]  # YYYY-MM-DD
    recorded_datetime = date.replace(' ', 'T')  # ISO 8601

    return f"""
Instance: {uuid.uuid4()}
InstanceOf: Provenance
Title: "{message}"
Description: \"\"\"{message}\"\"\"
Usage: #definition

* target[0] = Reference({resource_name})
* occurredDateTime = "{occurred_date}"
* reason.text = \"\"\"{message}\"\"\"
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "{author}"
* recorded = "{recorded_datetime}"
"""
```

### 10. Recommended Workflow

**Step A: Analysis**
1. List all FSH files without Provenance
2. Identify the main resources in each file
3. Retrieve git history if available

**Step B: Generation**
1. For each resource without Provenance, generate a CREATE instance
2. For resources with git modifications, generate UPDATE instances
3. Ensure UUID uniqueness

**Step C: Validation**
1. Verify unique UUIDs
2. Validate FSH format with SUSHI
3. Build the complete IG

**Step D: Documentation**
1. List modified files
2. Count the number of Provenance created
3. Generate a traceability report

### 11. Recommended Automation Script

```python
#!/usr/bin/env python3
"""
Automatically generates Provenance instances for all FHIR resources
"""
import os
import re
import uuid
import subprocess
from datetime import datetime
from pathlib import Path
from collections import defaultdict

def extract_resource_name(fsh_content):
    """Extracts the main resource name from the FSH file"""
    patterns = [
        r'^Profile:\s+(\S+)',
        r'^CodeSystem:\s+(\S+)',
        r'^ValueSet:\s+(\S+)',
        r'^Extension:\s+(\S+)',
    ]
    for pattern in patterns:
        match = re.search(pattern, fsh_content, re.MULTILINE)
        if match:
            return match.group(1)
    return None

def has_provenance(fsh_content):
    """Checks if the file already contains Provenance instances"""
    return bool(re.search(r'InstanceOf:\s+Provenance', fsh_content))

def get_all_instance_ids(fsh_dir):
    """Retrieves all already used UUIDs"""
    instance_ids = set()
    for fsh_file in Path(fsh_dir).rglob('*.fsh'):
        with open(fsh_file, 'r', encoding='utf-8') as f:
            content = f.read()
            for match in re.finditer(r'^Instance:\s+(\S+)', content, re.MULTILINE):
                instance_ids.add(match.group(1))
    return instance_ids

def generate_unique_uuid(existing_ids):
    """Generates a unique v4 UUID"""
    while True:
        new_uuid = str(uuid.uuid4())
        if new_uuid not in existing_ids:
            existing_ids.add(new_uuid)
            return new_uuid

def get_git_info(file_path):
    """Retrieves info from the first commit (creation) from git"""
    try:
        # First commit (creation)
        cmd = f'git log --follow --reverse --format="%an|%ai|%s" -- "{file_path}" | head -1'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=os.path.dirname(file_path))
        if result.stdout.strip():
            author, date, message = result.stdout.strip().split('|', 2)
            occurred_date = date.split()[0]
            recorded_datetime = date.replace(' ', 'T')
            return {
                'author': author,
                'occurred': occurred_date,
                'recorded': recorded_datetime,
                'message': message
            }
    except:
        pass

    # Fallback if git fails
    now = datetime.now()
    return {
        'author': 'Unknown',
        'occurred': now.strftime('%Y-%m-%d'),
        'recorded': now.isoformat(),
        'message': 'Initial import'
    }

def generate_provenance_instance(resource_name, git_info, existing_ids):
    """Generates a Provenance instance"""
    unique_id = generate_unique_uuid(existing_ids)

    return f"""
Instance: {unique_id}
InstanceOf: Provenance
Title: "{git_info['message']}"
Description: \"\"\"{git_info['message']}\"\"\"
Usage: #definition

* target[0] = Reference({resource_name})
* occurredDateTime = "{git_info['occurred']}"
* reason.text = \"\"\"{git_info['message']}\"\"\"
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "{git_info['author']}"
* recorded = "{git_info['recorded']}"
"""

def process_fsh_directory(fsh_dir, dry_run=True):
    """Processes all FSH files in the directory"""
    existing_ids = get_all_instance_ids(fsh_dir)
    files_processed = 0
    files_updated = 0

    for fsh_file in Path(fsh_dir).rglob('*.fsh'):
        with open(fsh_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Skip if already has Provenance
        if has_provenance(content):
            continue

        # Extract resource name
        resource_name = extract_resource_name(content)
        if not resource_name:
            continue

        files_processed += 1

        # Retrieve git info
        git_info = get_git_info(str(fsh_file))

        # Generate Provenance
        provenance = generate_provenance_instance(resource_name, git_info, existing_ids)

        # Add to file
        new_content = content.rstrip() + '\n' + provenance

        if dry_run:
            print(f"[DRY-RUN] Would add Provenance to: {fsh_file}")
            print(f"  Resource: {resource_name}")
            print(f"  Author: {git_info['author']}")
        else:
            with open(fsh_file, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"✓ Added Provenance to: {fsh_file}")
            files_updated += 1

    print(f"\nSummary:")
    print(f"  Files processed: {files_processed}")
    print(f"  Files updated: {files_updated}")
    print(f"  Total unique IDs: {len(existing_ids)}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Generate Provenance instances for FHIR resources')
    parser.add_argument('--fsh-dir', default='input/fsh/semantic-layer', help='FSH directory to process')
    parser.add_argument('--execute', action='store_true', help='Execute changes (default is dry-run)')
    args = parser.parse_args()

    process_fsh_directory(args.fsh_dir, dry_run=not args.execute)
```

### 12. Script Usage

```bash
# Simulation (dry-run)
python order/generate_provenance.py --fsh-dir input/fsh/semantic-layer

# Actual execution
python order/generate_provenance.py --fsh-dir input/fsh/semantic-layer --execute

# Validation after execution
grep -r "^Instance:" input/fsh --include="*.fsh" | sed 's/^.*Instance:[[:space:]]*//' | sort | uniq -d

# Build to verify
./gradlew sushiBuild
```

### 13. Best Practices

✅ **DO**:
- Always generate unique v4 UUIDs
- Verify uniqueness before and after generation
- Use git information when available
- Clearly document each modification in reason.text
- Test with sushiBuild after each addition
- Order Provenance chronologically in each file

❌ **DON'T**:
- Reuse existing UUIDs
- Modify historical Provenance
- Omit timezone in recorded
- Use inconsistent date formats
- Forget to reference the correct resource in target[0]
- Create Provenance for examples (unless necessary)

### 14. Common Problem Resolution

**Error: "Duplicate instance ID"**
- Cause: Reused UUID
- Solution: Regenerate with `uuid.uuid4()` and verify uniqueness

**Error: "Invalid reference target"**
- Cause: target[0] references a non-existent resource
- Solution: Verify the exact resource name in the same file

**Error: "Invalid datetime format"**
- Cause: Incorrect date format
- Solution: Use `YYYY-MM-DD` for occurredDateTime and complete ISO 8601 for recorded

**Warning: "Unknown alias"**
- Cause: Missing alias in aliases.fsh
- Solution: Add required aliases in input/fsh/aliases.fsh

## Expected Deliverables

1. **Updated FSH files** with Provenance instances
2. **Generation report** listing:
   - Number of files processed
   - Number of Provenance created
   - List of generated UUIDs
3. **Successful validation**: `./gradlew sushiBuild` without errors
4. **Documentation** of modifications in the git commit

## Complete Output Example

For a `CodeSystem-Example.fsh` file:

```fsh
CodeSystem: Example
Title: "Example CodeSystem"
Description: "An example code system"

* ^status = #active
* ^content = #complete

* #code1 "Code One"
* #code2 "Code Two"

Instance: 3f8e9a2b-1c4d-5e6f-7a8b-9c0d1e2f3a4b
InstanceOf: Provenance
Title: "Initial creation of Example CodeSystem"
Description: """Initial creation of Example CodeSystem for demonstration purposes"""
Usage: #definition

* target[0] = Reference(Example)
* occurredDateTime = "2025-10-15"
* reason.text = """Initial creation of Example CodeSystem"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-15T14:30:00+01:00"
```

## Final Checklist

- [ ] All required aliases are present in aliases.fsh
- [ ] Each UUID is unique (automatic verification)
- [ ] Each Provenance references the correct resource
- [ ] Date formats are consistent
- [ ] SUSHI build succeeds without errors
- [ ] Provenance are ordered chronologically
- [ ] Git commit documents the additions
- [ ] A generation report is available

---

**Note**: This prompt is designed to be used by Claude Code or a developer to automate the generation of Provenance resources while ensuring quality and consistency of traceability in the FHIR IG project.
