# Task: Create FHIR StructureMap in FML Format for Questionnaire to Profile Mapping

## Project Context

You are working on a FHIR Implementation Guide project. Your task is to create a StructureMap in FHIR Mapping Language (FML) that transforms data from a Questionnaire resource into conformant FHIR resources based on custom profiles.

**Key Files:**
- **Source Questionnaire:** `input/resources/usages/core/Questionnaire-UsageCore.json`
- **Target FHIR Profiles:** `input/fsh/semantic-layer/profiles/*.fsh`
- **Output StructureMap:** `input/fml/StructureMap-Q2FSL.fml`

## Step-by-Step Instructions

### Step 1: Analysis Phase
First, examine the source and target files:

1. **Read the source Questionnaire:**
   - Review `input/resources/usages/core/Questionnaire-UsageCore.json`
   - Identify all Questionnaire items (linkId, type, answer values)
   - Note any enableWhen conditions, value sets, or validation rules

2. **Read all target FHIR profiles:**
   - List all `.fsh` files in `input/fsh/semantic-layer/profiles/`
   - For each profile, identify:
     - Profile name and base resource type
     - Required elements and cardinality constraints
     - Extensions defined
     - Terminology bindings
     - Data types expected

3. **Document your findings:**
   - Create a mapping table showing which Questionnaire items map to which profile elements
   - Identify any gaps or ambiguities

### Step 2: Present Mapping Plan
Before writing code, present a structured mapping plan:
```
Mapping Plan:
├── Group 1: [Bundle wrapper - workaround for validator limitation]
│   ├── Source: QuestionnaireResponse (single source as required)
│   ├── Target: Bundle (transaction type)
│   └── Contains: References to other groups
│
├── Group 2: [Profile Name 1]
│   ├── Sources: [list of linkIds from Questionnaire]
│   ├── Target: [FHIR Resource conforming to Profile X]
│   └── Mappings: [item.a → element.x, item.b → element.y]
│
├── Group 3: [Profile Name 2]
│   └── ...
```

**Wait for user confirmation before proceeding.**

### Step 3: Implementation

Once the plan is approved, create the FML file with the following structure:

#### Required FML Structure:
```fml
/// url = 'https://interop.aphp.fr/ig/fhir/dm/StructureMap/Q2FSL'
/// name = 'Q2FSL'
/// title = 'Questionnaire to FHIR Semantic Layer'
/// status = 'draft'
/// description = 'Questionnaire to FHIR Semantic Layer resources using Bundle as container'

uses "http://hl7.org/fhir/StructureDefinition/QuestionnaireResponse" as source
uses "http://hl7.org/fhir/StructureDefinition/Bundle" as target
// Add other resource canonical URLs

// Group 1: Bundle wrapper (required by validator)
group QuestionnaireResponseToBundle(source src : QuestionnaireResponse, target bundle : Bundle) {
  src -> bundle.type = 'transaction' "setTransactionType";
  src -> bundle.entry as entry then {
    // Call other groups to create resources
  } "createEntries";
}

// Group 2+: One group per target profile
group CreateProfile1(source src : QuestionnaireResponse, target tgt : ResourceType) {
  // Map questionnaire items to profile elements
  src.item as item where (linkId = 'item-id') -> tgt.element = item.answer.value "mapItem";
}
```

#### Key Requirements:
- **Bundle Workaround:** First group must have single source → single target (Bundle), then create other resources within Bundle.entry
- **Source Access:** Use `src.item where (linkId = 'specific-id')` to access questionnaire items
- **Answer Extraction:** Extract values using `item.answer.value[x]` (e.g., valueString, valueInteger)
- **Profile Conformance:** Ensure all mandatory elements from profiles are populated
- **Data Type Handling:** Convert questionnaire answer types to FHIR element types correctly
- **Extensions:** Map questionnaire items to extensions where appropriate

### Step 4: Validation

After creating the FML file:
1. Verify the syntax is valid FML
2. Check that all valuable Questionnaire items are mapped
3. Confirm all profiles from `input/fsh/semantic-layer/profiles/` are covered
4. Ensure the Bundle wrapper correctly implements the validator workaround

## Success Criteria

- [ ] FML file created at `input/fml/StructureMap-Q2FSL.fml`
- [ ] File uses valid FHIR Mapping Language syntax
- [ ] First group implements Bundle wrapper (single source/target) to satisfy validator
- [ ] All meaningful Questionnaire items (from source) are mapped
- [ ] All FHIR profiles (from `profiles/*.fsh`) have corresponding mapping groups
- [ ] Mappings respect profile constraints (cardinality, data types, required elements)
- [ ] Code includes comments explaining complex transformations
- [ ] Bundle.entry references are correctly structured for transaction processing
