// ============================================================================
// Provenance instances documenting the creation and modification history of
// this IG's artifacts, per profile-lifecycle-process.md (mandatory step 3).
//
// Only cross-cutting entries live here: one Provenance instance covering
// several artifacts that were created, renamed, or updated together for the
// same reason. An entry targeting a single artifact is placed in that
// artifact's own .fsh file, right after its definition (resource-templates.md,
// Provenance).
//
// Ordering is newest first. CREATE entries below were backfilled from this
// repository's git history (the commit date each artifact's file first
// appears, following renames) as part of the 2026-08-05 compliance
// remediation. They are a best-effort reconstruction, not a live-captured
// record: occurredDateTime carries the historical date, recorded the date the
// entry was written.
// ============================================================================

// --- CREATE entries ---

Instance: 7c1e4b9a-3d52-4e8f-a6b1-0f9d2c84e317
InstanceOf: Provenance
Title: "Move the data-exporter-only ViewDefinitions into the IG"
Description: """Add the care_site, provider, specimen and drug_strength ViewDefinitions, moved from the retired data-exporter"""
Usage: #definition

* target[0].display = "ViewDefinition-care-site (input/resources/ViewDefinition_OMOP)"
* target[+].display = "ViewDefinition-provider (input/resources/ViewDefinition_OMOP)"
* target[+].display = "ViewDefinition-specimen (input/resources/ViewDefinition_OMOP)"
* target[+].display = "ViewDefinition-drug-strength (input/resources/ViewDefinition_OMOP)"
* occurredDateTime = "2026-10-15"
* reason.text = """The Python data-exporter (data-platform/share-layer/data-exporter, first committed 2025-09-14) held its own 12 OMOP ViewDefinitions under the former canonical base. This IG keeps only the FHIR artifacts in input/, so the data-exporter was retired. These four tables had no counterpart in input/resources/ViewDefinition_OMOP: their ViewDefinitions were moved here unchanged in their select/column content, with the IG's header conventions (no url, PascalCase name, French description). For the eight tables both sets covered (person, location, visit_occurrence, condition_occurrence, procedure_occurrence, measurement, drug_exposure, death), the IG's own ViewDefinitions remain authoritative; the data-exporter variants stay in git history only. Targets carry a display only: the IG does not yet resolve its ViewDefinitions as Binary resources."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-10-15T12:00:00.000+02:00"

// --- UPDATE entries ---

Instance: 0d3f6c2e-5b8a-4f1d-9c7e-2a4b6d8e1f30
InstanceOf: Provenance
Title: "Align Logical Model ids with the kebab-case template"
Description: """Give the OMOP CDM Logical Models and LogicalBundle a kebab-case id and matching file name"""
Usage: #definition

* target[0] = Reference(OMOPCareSite)
* target[+] = Reference(OMOPConcept)
* target[+] = Reference(OMOPConditionEra)
* target[+] = Reference(OMOPConditionOccurrence)
* target[+] = Reference(OMOPCost)
* target[+] = Reference(OMOPDeath)
* target[+] = Reference(OMOPDeviceExposure)
* target[+] = Reference(OMOPDoseEra)
* target[+] = Reference(OMOPDrugEra)
* target[+] = Reference(OMOPDrugExposure)
* target[+] = Reference(OMOPEpisode)
* target[+] = Reference(OMOPEpisodeEvent)
* target[+] = Reference(OMOPFactRelationship)
* target[+] = Reference(OMOPLocation)
* target[+] = Reference(OMOPMeasurement)
* target[+] = Reference(OMOPNote)
* target[+] = Reference(OMOPNoteNLP)
* target[+] = Reference(OMOPObservation)
* target[+] = Reference(OMOPObservationPeriod)
* target[+] = Reference(OMOPPayerPlanPeriod)
* target[+] = Reference(OMOPPerson)
* target[+] = Reference(OMOPProcedureOccurrence)
* target[+] = Reference(OMOPProvider)
* target[+] = Reference(OMOPSpecimen)
* target[+] = Reference(OMOPVisitDetail)
* target[+] = Reference(OMOPVisitOccurrence)
* target[+] = Reference(LogicalBundle)
* occurredDateTime = "2026-10-15"
* reason.text = """resource-templates.md (StructureDefinition: Logical Model) requires id = nom-du-modele-logique (kebab-case) and file name StructureDefinition-<id>.fsh; it has no PascalCase exception for Logical Models. These artifacts declared no Id, so SUSHI minted the PascalCase name (OMOPPerson). Added an explicit kebab-case Id (omop-person, ..., logical-bundle) and renamed each file accordingly. BREAKING: the canonical of each Logical Model changes (.../StructureDefinition/OMOPPerson -> .../StructureDefinition/omop-person); the StructureMaps' uses clauses were updated in the same change. FSH names are unchanged."""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-10-15T12:00:00.000+02:00"

Instance: e50462fe-d15d-46be-8e5d-dc7be070e02d
InstanceOf: Provenance
Title: "Add -Cs/-Vs suffixes and kebab-case ids"
Description: """Add -Cs/-Vs suffixes and kebab-case ids to hand-authored CodeSystems/ValueSets"""
Usage: #definition

* target[0] = Reference(DpiGenderCs)
* target[+] = Reference(DpiEncounterTypeCs)
* target[+] = Reference(DpiModeInCs)
* target[+] = Reference(DpiModeOutCs)
* target[+] = Reference(DpiGenderVs)
* target[+] = Reference(DpiEncounterTypeVs)
* target[+] = Reference(DpiModeInVs)
* target[+] = Reference(DpiModeOutVs)
* target[+] = Reference(DMOmopCDMv20240229Cs)
* target[+] = Reference(OMOPGenderVs)
* occurredDateTime = "2026-08-05"
* reason.text = """These 10 artifacts declared no explicit Id, so SUSHI minted a PascalCase id equal to the FSH name instead of kebab-case, and none carried the -Cs/-Vs type suffix that resource-templates.md now applies by default. This had already produced a live collision: ValueSet DpiModeIn and CodeSystem DpiModeIn shared the same name and id (same for DpiModeOut). Added an explicit Id: and the type suffix to each, per resource-templates.md's CodeSystem/ValueSet entries; the FormBuilder id==name exception does not apply since these are hand-authored FSH, not FormBuilder output."""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

Instance: 3a612051-7ac7-4cfe-8ade-20c56f2460d5
InstanceOf: Provenance
Title: "Update ConceptMap references after CS/VS renames"
Description: """Update ConceptMap Canonical() references after CS/VS renames"""
Usage: #definition

* target[0] = Reference(dpi-gender-2-hl7-gender)
* target[+] = Reference(dpi-encounter-type-2-semantic-layer-encounter-class)
* target[+] = Reference(hl7-gender-to-ohdsi-gender)
* occurredDateTime = "2026-08-05"
* reason.text = """Consequential update: each of these ConceptMaps' sourceCanonical/targetCanonical or group source/target referenced a CodeSystem/ValueSet renamed in the same remediation pass (DpiGenderVS -> DpiGenderVs, DpiGender -> DpiGenderCs, DpiEncounterTypeVS -> DpiEncounterTypeVs, DpiEncounterType -> DpiEncounterTypeCs, OMOPGender -> OMOPGenderVs, DMOmopCDMv20240229 -> DMOmopCDMv20240229Cs). Updated the Canonical() references to keep these ConceptMaps resolvable; no change to the mapping content itself (source/target codes, equivalence)."""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

// --- CREATE entries: backfilled from git history ---

Instance: a8ce01cd-854b-42f7-926f-6479dfa26b03
InstanceOf: Provenance
Title: "Create Dpi entry/discharge mode terminology and encounter-type ConceptMap"
Description: """Create the DPI entry/discharge mode CodeSystems and ValueSets, and the DPI encounter-type ConceptMap"""
Usage: #definition

* target[0] = Reference(DpiModeInCs)
* target[+] = Reference(DpiModeOutCs)
* target[+] = Reference(DpiModeInVs)
* target[+] = Reference(DpiModeOutVs)
* target[+] = Reference(dpi-encounter-type-2-semantic-layer-encounter-class)
* occurredDateTime = "2025-06-19"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): the DPI (local hospital EHR) entry-mode and discharge-mode CodeSystems and ValueSets, and the ConceptMap standardizing DPI encounter types to the Semantic Layer encounter class, were first committed 2025-06-19 per git history (commits 3352886, ebf31cd), to support the EHR-to-FHIR transforms."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

Instance: 86947806-47fb-4165-b655-f5045c5e0cd6
InstanceOf: Provenance
Title: "Create OMOP gender terminology and mapping"
Description: """Create the OMOP CDM gender CodeSystem, ValueSet, and HL7-to-OHDSI ConceptMap"""
Usage: #definition

* target[0] = Reference(DMOmopCDMv20240229Cs)
* target[+] = Reference(OMOPGenderVs)
* target[+] = Reference(hl7-gender-to-ohdsi-gender)
* occurredDateTime = "2025-06-10"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): the OMOP CDM v5.4.2024-03-01 CodeSystem, its gender ValueSet, and the ConceptMap aligning HL7 administrative-gender to OHDSI gender concept ids were first committed together 2025-06-10 per git history, to support FHIR-to-OMOP mapping (CoreFHIR2OMOPPerson.fml)."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

Instance: f8af86f9-718d-464e-99a5-0fe00b785d2a
InstanceOf: Provenance
Title: "Create OMOP CDM v5.4 Logical Models"
Description: """Create the OMOP CDM v5.4 Logical Models and LogicalBundle"""
Usage: #definition

* target[0] = Reference(OMOPCareSite)
* target[+] = Reference(OMOPConcept)
* target[+] = Reference(OMOPConditionEra)
* target[+] = Reference(OMOPConditionOccurrence)
* target[+] = Reference(OMOPCost)
* target[+] = Reference(OMOPDeath)
* target[+] = Reference(OMOPDeviceExposure)
* target[+] = Reference(OMOPDoseEra)
* target[+] = Reference(OMOPDrugEra)
* target[+] = Reference(OMOPDrugExposure)
* target[+] = Reference(OMOPEpisode)
* target[+] = Reference(OMOPEpisodeEvent)
* target[+] = Reference(OMOPFactRelationship)
* target[+] = Reference(OMOPLocation)
* target[+] = Reference(OMOPMeasurement)
* target[+] = Reference(OMOPNote)
* target[+] = Reference(OMOPNoteNLP)
* target[+] = Reference(OMOPObservation)
* target[+] = Reference(OMOPObservationPeriod)
* target[+] = Reference(OMOPPayerPlanPeriod)
* target[+] = Reference(OMOPPerson)
* target[+] = Reference(OMOPProcedureOccurrence)
* target[+] = Reference(OMOPProvider)
* target[+] = Reference(OMOPSpecimen)
* target[+] = Reference(OMOPVisitDetail)
* target[+] = Reference(OMOPVisitOccurrence)
* target[+] = Reference(LogicalBundle)
* occurredDateTime = "2025-03-24"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): the 26 OMOP CDM v5.4 table Logical Models, plus LogicalBundle (a Bundle-like container for grouping them), were all first committed together 2025-03-24 per git history. Together they represent the target physical model for the Core usage's FHIR-to-OMOP transform (CoreFHIR2OMOP.fml and siblings)."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

Instance: 5cbc87af-bfad-4af2-a852-e29501525a16
InstanceOf: Provenance
Title: "Create Dpi gender/encounter-type terminology and gender ConceptMap"
Description: """Create the DPI gender and encounter-type CodeSystems and ValueSets, and the DPI gender ConceptMap"""
Usage: #definition

* target[0] = Reference(DpiGenderCs)
* target[+] = Reference(DpiEncounterTypeCs)
* target[+] = Reference(DpiGenderVs)
* target[+] = Reference(DpiEncounterTypeVs)
* target[+] = Reference(dpi-gender-2-hl7-gender)
* occurredDateTime = "2025-02-02"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): the DPI (local hospital EHR) administrative-gender and encounter-type CodeSystems and ValueSets, and the ConceptMap standardizing DPI gender to HL7 administrative-gender, were first committed together 2025-02-02 per git history (commit fe1b1a1, followed across later renames), to support the EHR-to-FHIR transforms."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"
