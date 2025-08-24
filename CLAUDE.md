# Project: FHIR Implementation Guide for Data Management with FHIR

## Project Description
This guide demonstrates how to use the FHIR standard for health data management. Starting from a description of the core variables for the EDSH, we propose a data model enabling the storage of these variables according to an original (proprietary) modeling approach. We then align this proprietary data model with the FHIR profiles adapted to this context, and finally, we propose an alignment of the FHIR profiles with the OMOP data model.

## Technologies Used
- Markdown, HTML, Mermaid, PlantUML
- JSON
- FHIRPath, FHIR Mapping Language (FML), FHIR Shorthand (FSH)
- SQL/PostgreSQL
- DBT

## Project Structure
The directory containing the guide inputs is located in `input`.  
It includes the following subfolders:

- **`data`**: configuration elements for building the guide.  
- **`fml`**: mapping files written in FML.  
- **`fsh`**: FHIR artifacts written in FSH, i.e., the guide content intended for implementers.  
- **`images`**: images visible in the output.  
- **`images-source`**: PlantUML files, transformed during the guide build process into SVG files for inclusion in HTML files.  
- **`includes`**: additional include files.  
- **`pagecontent`**: markdown files describing the guide content, intended for all roles involved in a digital transformation project based on interoperability.  
- **`resources`**: FHIR artifacts in JSON format (avoiding transformation through SUSHI).  
- **`sql`**: SQL scripts for building the different data models for PostgreSQL.  
- **`test-map`**: material for testing the mappings defined in FML, also very useful for demo purposes.  

## Important Commands
- Linux/macOS: `./gradlew buildIG`
- Windows: `.\gradlew.bat buildIG`

## Preferred APIs and Libraries
- no library
- no API

## Specific Rules

### 1. Scoping and Governance
- Clearly define the functional scope (use cases)
- Identify actors and data flows
- Involve stakeholders (vendors, institutions, domain experts)
- Document design decisions and their rationale

### 2. Reuse and Alignment
- Check for existing IGs or international profiles (US Core, IPS, IHE…)
- Check for existing IGs or national profiles (Fr Core, ANS…)
- Align profiles with base HL7 artifacts
- Reuse standard terminologies (SNOMED CT, LOINC, ICD, ATC…)
- Limit creation of extensions and document them clearly

### 3. Technical Quality of Profiles
- Avoid unnecessary over-constraining
- Specify cardinalities, Must Support flags, coded values
- Ensure consistency with FHIR base model invariants
- Provide **valid and representative** examples for each profile
- Use validation tools (FHIR Validator, SUSHI/IG Publisher…)

### 4. Documentation Clarity
- Organize the guide around business scenarios
- Include sequence diagrams, JSON/XML examples, real-life exchange cases
- Explain the choice of FHIR resources used (and why others are not)
- Document governance and versioning policies

### 5. Interoperability and Mapping
- Define mappings to other data models (CDA, OMOP, openEHR…)
- Mention compatibility with IHE profiles (PAM, PIXm, PDQm, MHD…)
- Document compliance with local/EU regulations (GDPR, eHDSI…)

### 6. Maintenance and Evolution
- Version the guide with a clear changelog
- Define an evolution policy (breaking changes, extensions)
- Host the guide on a sustainable platform (HL7, GitHub Pages)
- Plan automated conformance testing (Touchstone, Inferno, Postman…)

### 7. User Experience
- Provide clear and intuitive navigation (menu, search)
- Offer progressive reading: business scenario → technical constraints → profiles → examples
- Add "Implementation Notes" to help developers understand quickly
