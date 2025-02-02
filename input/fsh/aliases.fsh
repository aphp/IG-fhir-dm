// External Code Systems with a canonical recognized by terminology.hl7.org
Alias:   $loinc = http://loinc.org
Alias:   $sct = http://snomed.info/sct
//Alias:   SCT = http://snomed.info/sct|http://snomed.info/sct/731000124108   // latest US edition (see exp-params.json)
//Alias:   SCT = http://snomed.info/sct|http://snomed.info/sct/900000000000207008   // Latest international edition
Alias:   SCT_TBD = http://hl7.org/fhir/us/mcode/CodeSystem/snomed-requested-cs
Alias:   $unitsofmeasure = http://unitsofmeasure.org
Alias:   ICD10CM = http://hl7.org/fhir/sid/icd-10-cm
Alias:   ICD10PCS = http://www.cms.gov/Medicare/Coding/ICD10
Alias:   RXN = http://www.nlm.nih.gov/research/umls/rxnorm
Alias:   CPT = http://www.ama-assn.org/go/cpt
Alias:   HGNC = http://www.genenames.org
Alias:   HGVS = http://varnomen.hgvs.org

// Code systems lacking a recognized canonical at terminology.hl7.org
Alias:   GTR = http://www.ncbi.nlm.nih.gov/gtr
Alias:   CLINVAR = http://www.ncbi.nlm.nih.gov/clinvar
Alias:   SO = http://www.sequenceontology.org/
Alias:   AJCC = http://cancerstaging.org
Alias:   ENTREZ = https://www.ncbi.nlm.nih.gov/gene

// Code systems URLs from HL7 Terminology Authority that conflict with terminology.hl7.org
Alias:   NCI = http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl

// From terminology.hl7.org
Alias:   OmbRaceCat             = urn:oid:2.16.840.1.113883.6.238
Alias:   ICDO3                  = http://terminology.hl7.org/CodeSystem/icd-o
Alias:   UMLS                   = http://terminology.hl7.org/CodeSystem/umls
Alias:   IDTYPE                 = http://terminology.hl7.org/CodeSystem/v2-0203
Alias:   SPTY                   = http://terminology.hl7.org/CodeSystem/v2-0487
Alias:   ObsInt                 = http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation
Alias:   DiagnosticService      = http://terminology.hl7.org/CodeSystem/v2-0074
Alias:   TimingAbbreviation     = http://terminology.hl7.org/CodeSystem/v3-GTSAbbreviation
Alias:   MedReqStatus           = http://hl7.org/fhir/CodeSystem/medicationrequest-status
Alias:   MedReqIntent           = http://hl7.org/fhir/CodeSystem/medicationrequest-intent
Alias:   MedReqCat              = http://terminology.hl7.org/CodeSystem/medicationrequest-category
Alias:   RefMeaning             = http://terminology.hl7.org/CodeSystem/referencerange-meaning
Alias:   AbsentReason           = http://terminology.hl7.org/CodeSystem/data-absent-reason
Alias:   EndpointConnType       = http://terminology.hl7.org/CodeSystem/endpoint-connection-type
Alias:   EndpointPLType         = http://terminology.hl7.org/CodeSystem/endpoint-payload-type
Alias:   $observation-category                = http://terminology.hl7.org/CodeSystem/observation-category
Alias:   $v3-ActCode                          = http://terminology.hl7.org/CodeSystem/v3-ActCode
Alias:   $observation-status                  = http://hl7.org/fhir/observation-status
Alias:   $condition-clinical                  = http://terminology.hl7.org/CodeSystem/condition-clinical
Alias:   $condition-category                  = http://terminology.hl7.org/CodeSystem/condition-category
Alias:   $episode-of-care-status              = http://hl7.org/fhir/episode-of-care-status
Alias:   $provenance-participant-type         = http://terminology.hl7.org/CodeSystem/provenance-participant-type
Alias:   $event-status                        = http://hl7.org/fhir/event-status
Alias:   $identifier-use                      = http://hl7.org/fhir/identifier-use
Alias:   $usage-context-type-vs               = http://hl7.org/fhir/ValueSet/usage-context-type
Alias:   $v3-ParticipationType                = http://terminology.hl7.org/CodeSystem/v3-ParticipationType

// From DICOM
Alias:   DCM = http://dicom.nema.org/resources/ontology/DCM

// From HL7 CRMI
Alias: $crmi-publishablecodesystem              = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablecodesystem
Alias: $crmi-shareablecodesystem                = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablecodesystem

Alias: $crmi-shareablevalueset                  = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablevalueset
Alias: $crmi-computablevalueset                 = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-computablevalueset
Alias: $crmi-publishablevalueset                = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablevalueset
Alias: $crmi-expandedvalueset                   = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-expandedvalueset

Alias: $crmi-shareableconceptmap                = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareableconceptmap
Alias: $crmi-publishableconceptmap              = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishableconceptmap

// From HL7 SDC
Alias: $sdc-questionnaire-assemble-expectation  = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assemble-expectation
Alias: $sdc-questionnaire-assemble-context      = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-assembleContext
Alias: $sdc-sub-questionnaire                   = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-subQuestionnaire
Alias: $sdc-questionnaire-calculated-expression = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression
Alias: $sdc-valueset                            = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-valueset
Alias: $sdc-questionnaire-observationExtract    = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observationExtract
Alias: $sdc-questionnaire-observationExtractCat = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observation-extract-category
Alias: $launchContext-cs                        = http://hl7.org/fhir/uv/sdc/CodeSystem/launchContext
Alias: $launchContext-vs                        = http://hl7.org/fhir/uv/sdc/ValueSet/launchContext
Alias: $sdc-questionnaire-launchContext         = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-launchContext
Alias: $maxDecimalPlace                         = http://hl7.org/fhir/StructureDefinition/maxDecimalPlaces
Alias: $maxValue                                = http://hl7.org/fhir/StructureDefinition/maxValue
Alias: $minValue                                = http://hl7.org/fhir/StructureDefinition/minValue
Alias: $answerExpression                        = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-answerExpression
Alias: $calculatedExpression                    = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression

// From CRMI
Alias:   $crmi-shareable-codesystem   = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-shareablecodesystem
Alias:   $crmi-publishable-codesystem = http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishablecodesystem

// From FR Core
Alias: $fr-identifier-type = https://hl7.fr/ig/fhir/core/CodeSystem/fr-identifier-type
Alias: $fr-core-practitioner-identifier-type = https://hl7.fr/ig/fhir/core/ValueSet/fr-core-practitioner-identifier-type
