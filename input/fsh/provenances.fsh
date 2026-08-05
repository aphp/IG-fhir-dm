// ============================================================================
// Provenance instances documenting the creation and modification history of
// this IG's artifacts, per profile-lifecycle-process.md (mandatory step 3).
//
// These are cross-cutting entries: one Provenance instance may cover several
// artifacts that were created, renamed, or updated together for the same
// reason, rather than duplicating a near-identical entry per artifact. This
// mirrors fig-core's own provenances.fsh convention referenced in
// resource-templates.md.
//
// Ordering is newest first. CREATE entries below were backfilled from this
// repository's git history (the commit date each artifact's file first
// appears) as part of the 2026-08-05 compliance remediation — they are a
// best-effort reconstruction, not a live-captured record, since no
// Provenance existed in this repo prior to that date.
// ============================================================================

// --- UPDATE entries: 2026-08-05 compliance remediation ---

Instance: e1e95871-918e-484e-a463-4134fd5af134
InstanceOf: Provenance
Title: "Fix EHR canonical URL drift and Id"
Description: """Fix EHR canonical URL drift and Id"""
Usage: #definition

* target[0] = Reference(EHR)
* occurredDateTime = "2026-08-05"
* reason.text = """sushi-config.yaml's canonical moved from https://interop.aphp.fr/ig/fhir/dm to https://aphp.github.io/IG-fhir-dm in commit 714e95e (2026-02-05), but StructureMap-EHR2FSL.fml's `uses` clause and its embedded extension URLs were never updated to match, so the StructureMap could no longer resolve this IG's own Logical Model. Also changed Id: ehr -> EHR to match the Logical Model exception in resource-templates.md (id is PascalCase matching name, not kebab-case), consistent with the existing filename StructureDefinition-EHR.fsh. Both fixes landed together since they touch the same StructureMap `uses` line."""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

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

Instance: be35214d-25ff-4e90-8898-9ef1e067549a
InstanceOf: Provenance
Title: "Fix LogicalBundle Title"
Description: """Fix LogicalBundle Title to a human-readable form"""
Usage: #definition

* target[0] = Reference(LogicalBundle)
* occurredDateTime = "2026-08-05"
* reason.text = """Title was "LogicalBundle" (the raw FSH name), not a human-readable title. resource-templates.md's Logical Model entry defines title as name with spaces; changed to "Logical Bundle"."""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2026-08-05T12:00:00.000+02:00"

// --- CREATE entries: backfilled from git history ---

Instance: a8ce01cd-854b-42f7-926f-6479dfa26b03
InstanceOf: Provenance
Title: "Create Dpi CodeSystems and ValueSets"
Description: """Create the DPI (local EHR) CodeSystems and ValueSets"""
Usage: #definition

* target[0] = Reference(DpiGenderCs)
* target[+] = Reference(DpiEncounterTypeCs)
* target[+] = Reference(DpiModeInCs)
* target[+] = Reference(DpiModeOutCs)
* target[+] = Reference(DpiGenderVs)
* target[+] = Reference(DpiEncounterTypeVs)
* target[+] = Reference(DpiModeInVs)
* target[+] = Reference(DpiModeOutVs)
* occurredDateTime = "2025-09-06"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): these CodeSystems and ValueSets encode DPI (local hospital EHR) coded values -- administrative gender, encounter type, entry mode, discharge mode -- first committed 2025-09-06 per git history, to support the EHR-to-FHIR Semantic Layer transform."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-09-06T10:00:00.000+02:00"

Instance: ff2c79ce-8a97-4f4e-b830-710a12780fb0
InstanceOf: Provenance
Title: "Create EHR Logical Model"
Description: """Create the EHR Logical Model"""
Usage: #definition

* target[0] = Reference(EHR)
* occurredDateTime = "2025-08-31"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): the EHR Logical Model, generated from input/sql/applications/ehr/questionnaire-core-ddl.sql, first committed 2025-08-31 per git history. Represents the comprehensive EDSH core-variable EHR data structure that StructureMap-EHR2FSL.fml transforms into the FHIR Semantic Layer."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-08-31T10:00:00.000+02:00"

Instance: 5cbc87af-bfad-4af2-a852-e29501525a16
InstanceOf: Provenance
Title: "Create Dpi-to-standard ConceptMaps"
Description: """Create the DPI-to-standard-terminology ConceptMaps"""
Usage: #definition

* target[0] = Reference(dpi-gender-2-hl7-gender)
* target[+] = Reference(dpi-encounter-type-2-semantic-layer-encounter-class)
* occurredDateTime = "2025-07-23"
* reason.text = """Backfilled retrospectively (2026-08-05 compliance remediation): these ConceptMaps standardize DPI (local) coded values -- administrative gender, encounter type -- to HL7/FHIR terminology, first committed 2025-07-23 per git history, to support the Core usage's Physical-to-FHIR transform."""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-07-23T10:00:00.000+02:00"

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
* recorded = "2025-06-10T10:00:00.000+02:00"

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
* recorded = "2025-03-24T10:00:00.000+02:00"
