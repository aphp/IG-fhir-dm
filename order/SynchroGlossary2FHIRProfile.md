# FHIR Profile Generation and Maintenance from Business Glossary

## Objective
Generate and maintain complete, valid FHIR R4 Profiles in FSH (FHIR Shorthand) format by synchronizing them with the Business Glossary located at `input/pagecontent/use-core-variables-acquisition.md`.

## Context

### Input Files
- **Business Glossary**: `input/pagecontent/use-core-variables-acquisition.md`
  - Markdown table containing business variable definitions
  - Columns mainly: Concept | Description | Références
- **Existing FHIR Profiles**: `input/fsh/semantic-layer/profiles/`
  - FSH files representing standardized variables in FHIR format
- **ValueSets**: `input/fsh/semantic-layer/valuesets/`

### Expected Outputs
1. **Updated/New Profiles**: `input/fsh/semantic-layer/profiles/StructureDefinition-<ConceptId>.fsh`
   - Valid FSH syntax conforming to FHIR R4
   - One profile per glossary concept
2. **Updated/New ValueSets**: When multiple reference codes exist for a concept

## Detailed Instructions

### Step 1: Parse the Business Glossary
1. Read `input/pagecontent/use-core-variables-acquisition.md`
2. Extract the markdown table with columns: **Concept**, **Description**, **Références**
3. For each row, identify:
   - Concept name (use as basis for Profile title + Profile id follow the kebab-case + Profile name follow the camel-case)
   - Description (use as Profile description)
   - Reference code(s) (use for binding or cardinality constraints)

**Example Glossary Entry:**
| Concept | Description | Note | Aussi connu comme | Lien/Dépendance | Références |
|---------|-------------|------|-------------------|-----------------|------------|
| Urée | Taux d'urée dans le sang. L'urée est un catabolite composé formé dans le foie à partir de l'ammoniac produit par la désamination des acides aminés. C'est le principal produit final du catabolisme des protéines et il constitue environ la moitié des solides urinaires totaux. | Reflet de la fonction rénale | Dosage de l'urée dans le sang | | [22664-7](https://bioloinc.fr/bioloinc/KB/index#Concept:uri=http://www.aphp.fr/LOINC_CircuitBio_Demande/22664-7_Ur%25C3%25A9e){:target="_blank"} |
| Créatininémie | Taux de créatinine dans le sang. La créatinine est un produit de dégradation de la phosphocréatine et de la déshydratation de la créatine dans le muscle. | Taux fonction de la masse musculaire. Reflet de la fonction rénale (molécule éliminée en quasi totalité par le rein). | créatinine dans le sang, créatinine sérique | | [14682-9](https://loinc.org/14682-9/){:target="_blank"} ou [2160-0](https://loinc.org/2160-0/){:target="_blank"} |

### Step 2: Apply Mapping Rules

#### Profile Naming Convention
- **Profile file**: `StructureDefinition-dm-<resource-type-kebab-case>-<context-kebab-case>-<concept-name-kebab-case>.fsh`
- **Profile ID**: `dm-<resource-type-kebab-case>-<context-kebab-case>-<concept-name-kebab-case>`
- **Profile Name**: `DM<ResourceType><Context><ConceptName>` (context is optional)
- **Profile Title**: Use the exact **Concept** from glossary
- **Profile Description**: Use the exact **Description** from glossary

### Step 3: Generate FSH Profile Structure

**Template for each profile:**
```fsh
Profile: <ConceptName>
Parent: <DeterminedFromContext>
Id: dm-<resource-type-kebab-case>-<context-kebab-case>-<concept-name-kebab-case>
Title: "<Concept from Glossary>"
Description: "<Description from Glossary>"

// Cardinality and constraints based on Références
* <element-path> 1..1 MS
* <element-path> ^short = "<Concept>"
* <element-path> ^definition = "<Description>"
```

**Concrete Example:**
```fsh
Profile: DateNaissanceProfile
Parent: Patient
Id: profile-date-naissance
Title: "DateNaissance"
Description: "Date de naissance du patient"
* ^version = "1.0.0"
* ^status = #active

* birthDate 1..1 MS
* birthDate ^short = "Date de naissance"
* birthDate ^definition = "Date de naissance du patient"
```

### Step 4: Handle Multiple Reference Codes

**When Références contains multiple values** (e.g., "alive, deceased"):

1. Create a ValueSet:
```fsh
ValueSet: <ConceptName>ValueSet
Id: valueset-<concept-name>
Title: "<Concept> ValueSet"
Description: "Valeurs possibles pour <Concept>"
* ^status = #active
* include codes from system <appropriate-system>
  * #<code1> "<display1>"
  * #<code2> "<display2>"
```

2. Bind the ValueSet in the profile:
```fsh
* <element-path> from <ConceptName>ValueSet (required)
```

### Step 5: Validation Checklist

Before completing, verify:
- [ ] All glossary entries have corresponding profiles
- [ ] No FSH syntax errors (run `sushi` if available)
- [ ] Profile IDs are unique and follow naming convention
- [ ] All Références are correctly mapped to FHIR paths
- [ ] ValueSets created for multi-value Références
- [ ] CodeSystem updated with new concepts
- [ ] All profiles include:
  - [ ] Valid Parent resource
  - [ ] Proper cardinality (MS flag where appropriate)
  - [ ] Complete metadata (version, status, date)
- [ ] Traceability maintained (comments linking to glossary)

### Step 7: Maintenance Mode

When updating existing profiles:
1. Compare glossary with existing FSH files
2. Identify changes (new concepts, modified descriptions, updated references)
3. Update only changed elements
4. Preserve existing constraints not in glossary
5. Add change comments:
```fsh
// Updated: <date> - <reason>
```

## Important Constraints

1. **Immutability**: Never modify profile IDs or URLs of published profiles
2. **Versioning**: Increment version number for any changes
3. **Backward Compatibility**: Maintain existing constraints unless explicitly instructed
4. **Traceability**: Add comments linking each profile to glossary entry
5. **FHIR Conformance**: All outputs must validate against FHIR R4 specification

## Error Handling

If you encounter:
- **Ambiguous Références**: Ask for clarification or document assumption
- **Invalid FHIR paths**: Flag and suggest closest valid path
- **Conflicting constraints**: Prioritize glossary, document conflict
- **Missing parent resources**: Default to appropriate base resource (Patient, Observation, etc.)

## Output Format

Organize generated files as:
```
input/fsh/semantic-layer/profiles/
├── Profile-DateNaissance.fsh
├── Profile-StatutVital.fsh
└── ...

input/fsh/semantic-layer/valuesets/
├── ValueSet-StatutVital.fsh
└── ...
```

## References
- [FHIR R4 Specification](http://hl7.org/fhir/R4/)
- [StructureDefinition Resource](http://hl7.org/fhir/R4/structuredefinition.html)
- [FSH Specification](https://build.fhir.org/ig/HL7/fhir-shorthand/)
- [FSH Language Reference](https://build.fhir.org/ig/HL7/fhir-shorthand/reference.html)

## Example Complete Workflow

1. Read glossary → Extract: "StatutVital | Statut vital du patient | alive, deceased"
2. Generate Profile-StatutVital.fsh with Patient parent
3. Create ValueSet-StatutVital.fsh with alive/deceased codes
4. Add "statut-vital" code to CodeSystem-transformation.fsh
5. Validate all FSH files
6. Document mapping in profile comments