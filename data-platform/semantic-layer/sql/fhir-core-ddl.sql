-- ========================================================================
-- PostgreSQL 17.x DDL Script for FHIR Semantic Layer (FSL) Database
-- Generated from: input/fsh/semantic-layer/profiles/*.fsh
-- 
-- This script creates database tables based on FHIR resources used by 
-- FHIR profiles in the semantic layer, including DM profiles for French 
-- healthcare data management and interoperability.
-- 
-- Key FHIR Resources:
-- - Patient, Encounter, Condition, Procedure, Observation
-- - MedicationRequest, MedicationAdministration, Organization
-- - Location, Practitioner, PractitionerRole, EpisodeOfCare, Claim
-- ========================================================================

-- ========================================================================
--                                 LIMITES                                 
-- le modèle du médicament (posologie), est très limité dans la demande HDH
-- ========================================================================
--                               CONVENTIONS                               
-- Les nom des champs reprennent les noms des propriétés FHIR avec parfois quelques modifications : 
-- - Le lower camel case ('basedOn') est remplacé par du snake case ('based_on')
-- - pour les champs dont la cardinalité est >1, le nom est mis au pluriel (si son sens ne l'est pas par nature ('history'), au pire : '_s'). La pluralité des valeurs possibles est soit portée intrinsèquement par le type JSONB, soit via la spécification d'un champ de typ ARRAY
-- les types primitifs donnent lieu à la création d'un champ de type équivalent, éventuellement sous forme d'array selon leur cardinalité (et donc au pluriel)
-- les types complexes donnent lieu à la création d'un champ de type JSONB sauf si tous les types simples qui le compose donnent lieu à la création d'un champ. 
-- Pour les références, on distingue les liens socles, les liens de contextes, et les liens non pertinents à ce stade :
-- - dans le périmètre socle (Patient, Encounter, Condition, Procedure, Observation, sans que ce soit systématique) : 
--   - on crée un champ par type de ressource du socle (en formalisant ce type): 
--     - le nom du champ est suffixé '_id' 
--     - le champs est type VARCHAR(64)
--     - ce champs est une clé étrangère
--     - si la cardinalité est > 1, on a un array d'id (pas sur que ce cas existe)
-- - si on est dans les données de contexte 
--   - on crée un champ par type de ressource de contexte (en formalisant ce type)
--     - le nom du champ est suffixé '_display'
--     - le champs est type VARCHAR(255)
--     - ce champ contient une valeur textuelle qui correspond à Reference.display
-- - si on est dans les données non identifiée comme d'intéret à ce stade : on ne fait rien de spécifique
-- - dans tous les cas, on reprend la propriété en créant un champ de type JSONB.
-- Pour les identifier : 
-- - on reprend la propriété identifier dans un champ de type JSONB
-- - on peut créer des champs spécifiques pour les identifiers d'intérêt spécifique
-- - les champs spécifiques contiennet une valeur textuel qui correspond à identifier.value
-- Pour les propriétés de type [x] :
-- - on les reprend sous forme de JSONB systèmatiquement (en remplacçant '[x]' par '_x')
-- - on peut créer des champs spécifiques pour des data types d'intérêt spécifique
-- Pour les extension: 
-- - on reprend sous forme de JSONB
-- - on peut créer des champs spécifiques pour les value et les sous extension d'intéret
-- ========================================================================

-- Drop tables in reverse dependency order
--DROP TABLE IF EXISTS fhir_claim CASCADE;
DROP TABLE IF EXISTS fhir_medication_administration CASCADE;
DROP TABLE IF EXISTS fhir_medication_request CASCADE;
DROP TABLE IF EXISTS fhir_observation_component CASCADE;
DROP TABLE IF EXISTS fhir_observation CASCADE;
DROP TABLE IF EXISTS fhir_procedure CASCADE;
DROP TABLE IF EXISTS fhir_condition CASCADE;
DROP TABLE IF EXISTS fhir_encounter CASCADE;
--DROP TABLE IF EXISTS fhir_episode_of_care CASCADE;
--DROP TABLE IF EXISTS fhir_practitioner_role CASCADE;
--DROP TABLE IF EXISTS fhir_practitioner CASCADE;
--DROP TABLE IF EXISTS fhir_location CASCADE;
--DROP TABLE IF EXISTS fhir_organization CASCADE;
DROP TABLE IF EXISTS fhir_patient CASCADE;

-- ========================================================================
-- CORE FHIR RESOURCE TABLES
-- ========================================================================

-- Table: fhir_patient (DMPatient profile)
-- French Patient profile with INS-NIR identifiers
-- Description: Profil Patient du socle commun des EDS (Patient profile for common EDS foundation)
CREATE TABLE fhir_patient (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Patient core elements
    active BOOLEAN, -- Whether this patient's record is in active use
    
    -- Identifiers (multiple allowed)
    identifiers JSONB, -- Array of Identifier objects
    nss_identifier VARCHAR(50), -- NSS (Numéro de Sécurité Sociale) - Social Security Number
    ins_nir_identifier VARCHAR(15), -- INS-NIR - The patient national health identifier obtained from INSi teleservice
    
    -- Names (multiple allowed)
    names JSONB, -- A name associated with the patient
    full_names TEXT,  -- Structured name representation, serialized as JSONB internally 
    
    -- Demographics
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'unknown')), -- Administrative Gender - male | female | other | unknown
    birth_date DATE, -- The date of birth for the individual
    deceased_x JSONB, -- Indicates if the individual is deceased or not (boolean or dateTime)
    deceased_date_time TIMESTAMP WITH TIME ZONE, -- Date and time of death
    deceased_extension_death_source VARCHAR(10) CHECK (deceased_extension_death_source IN ('insee', 'cepidc', 'sih')), -- Source of death information (INSEE, CepiDc, or Hospital Information System)
    marital_status VARCHAR(4) CHECK (marital_status IN ('PACS', 'A', 'D', 'I', 'L', 'M', 'C', 'P', 'T', 'U', 'S', 'W', 'UNK')), -- Marital (civil) status of a patient

    -- Addresses (multiple allowed)
    address JSONB, -- Physical addresses for the individual (home, work, temporary, etc.) - FHIR Address (0..*)
    address_extension_geolocation_latitude FLOAT, -- Latitude coordinate for patient address geolocation extension
    address_extension_geolocation_longitude FLOAT, -- Longitude coordinate for patient address geolocation extension
    address_extension_census_tract VARCHAR(255), -- IRIS census tract code and label (ISO 21090 ADXP census tract extension)
    address_period_start DATE, -- Start date of address validity period for data collection tracking
    address_extension_pmsi_code_geo JSONB, -- PMSI geographic code extension for French healthcare facility location coding
    address_extension_pmsi_code_geo_code VARCHAR(5), -- PMSI geographic code value for administrative purposes

    -- Contact information - FHIR ContactPoint, Contact, Communication
    telecoms JSONB, -- Contact details for the individual (phone, email, fax, etc.) - FHIR telecom ContactPoint (0..*)
    contacts JSONB, -- Emergency contacts and guardians for the patient - FHIR contact BackboneElement (0..*)
    communications JSONB, -- Languages the patient can communicate in - FHIR communication BackboneElement (0..*)
    preferred_communication_languages TEXT, -- Preferred languages for communication (serialized list)
    
    -- Multiple birth - FHIR multipleBirth[x] (0..1)
    multiple_birth_x JSONB, -- Whether patient is part of multiple birth (boolean or integer) - FHIR multipleBirth[x]
    multiple_birth_integer INTEGER, -- Birth order for multiple birth scenarios (rang gémellaire)
    
    -- Care pathway enrollment - FHIR generalPractitioner, managingOrganization
    general_practitioners JSONB, -- Patient's nominated primary care provider(s) - FHIR generalPractitioner Reference (0..*)
    managing_organization JSONB, -- Organization that is the custodian of the patient record - FHIR managingOrganization Reference (0..1)

    -- Identity vigilance - FHIR link (0..*)
    links JSONB, -- Link to another patient resource that concerns the same actual person - used for patient deduplication

    -- French Core extensions
--    birth_place VARCHAR(255), je vois pas l'intérêt (identitovigilance seulement), on peut le laisser dans le jsonb extension
--    nationality VARCHAR(10), pas d'intérêt pour le soin, on peut le laisser dans le jsonb extension
    
    -- FHIR metadata and resource control
    meta JSONB, -- Metadata about the resource (version, lastUpdated, profile, security labels) - FHIR Meta
    implicit_rules VARCHAR(255), -- A set of rules under which this content was created - FHIR implicitRules (0..1)
    resource_language VARCHAR(10), -- Language of the resource content - FHIR language (0..1)
    text_div TEXT, -- Text summary of the resource for human interpretation - FHIR Narrative text
    contained JSONB, -- Contained, inline Resources that don't have independent identity - FHIR contained (0..*)
    extensions JSONB, -- Additional content defined by implementations - FHIR extension (0..*)
    modifier_extensions JSONB,  -- Extensions that cannot be ignored - FHIR modifierExtension (0..*)

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

    -- Note: photo field not implemented (FHIR photo 0..* - Attachment type for patient image)
);
/*
-- de ma compréhension, on n'a de lien que textuel vers les organization en l'état actuel. 
-- Table: fhir_organization (DMOrganization profile)
CREATE TABLE fhir_organization (
    id VARCHAR(64) PRIMARY KEY,
    version_id VARCHAR(64),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Organization core elements
    active BOOLEAN DEFAULT TRUE,
    types JSONB, -- Array of CodeableConcept
    name VARCHAR(255),
    aliases JSONB, -- Array of strings
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    finess_identifier VARCHAR(20), -- FINESS identifier for French healthcare facilities
    siret_identifier VARCHAR(14), -- SIRET identifier
    
    -- Contact information
    telecoms JSONB, -- Array of ContactPoint objects
    addresses JSONB, -- Array of Address objects
    
    -- Hierarchy
    part_of_organization_id VARCHAR(64),
    
    -- Contact persons
    contacts JSONB, -- Array of Organization.contact objects
    
    -- Endpoints
    endpoints JSONB, -- Array of Reference(Endpoint)
    
    -- FHIR metadata
    meta JSONB,
    text_div TEXT,
    extensions JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (part_of_organization_id) REFERENCES fhir_organization(id)
);
*/
/*
-- de ma compréhension, on n'a pas de location, on n'a que des organization 
-- Table: fhir_location (DMLocation profile)
CREATE TABLE fhir_location (
    id VARCHAR(64) PRIMARY KEY,
    version_id VARCHAR(64),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Location core elements
    status VARCHAR(20) CHECK (status IN ('active', 'suspended', 'inactive')),
    operational_status JSONB, -- Coding
    name VARCHAR(255),
    aliases JSONB, -- Array of strings
    description TEXT,
    mode VARCHAR(20) CHECK (mode IN ('instance', 'kind')),
    types JSONB, -- Array of CodeableConcept
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Contact and address
    telecoms JSONB, -- Array of ContactPoint objects
    address JSONB, -- Address object
    physical_type JSONB, -- CodeableConcept
    
    -- Geographic position
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    altitude DECIMAL(10,3),
    
    -- Hierarchy
    managing_organization_id VARCHAR(64),
    part_of_location_id VARCHAR(64),
    
    -- Operational details
    hours_of_operation JSONB, -- Array of Location.hoursOfOperation
    availability_exceptions TEXT,
    endpoints JSONB, -- Array of Reference(Endpoint)
    
    -- FHIR metadata
    meta JSONB,
    text_div TEXT,
    extensions JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (managing_organization_id) REFERENCES fhir_organization(id),
    FOREIGN KEY (part_of_location_id) REFERENCES fhir_location(id)
);
*/
/*
-- de ma compréhension, on n'a de lien que textuel vers des practitionner en l'état actuel. 
-- Table: fhir_practitioner (DMPractitioner profile)
CREATE TABLE fhir_practitioner (
    id VARCHAR(64) PRIMARY KEY,
    version_id VARCHAR(64),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Practitioner core elements
    active BOOLEAN DEFAULT TRUE,
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    rpps_identifier VARCHAR(20), -- RPPS identifier for French healthcare professionals
    adeli_identifier VARCHAR(20), -- ADELI identifier
    
    -- Names
    names JSONB, -- Array of HumanName objects
    family_name VARCHAR(255),
    given_names VARCHAR(255),
    
    -- Contact information
    telecoms JSONB, -- Array of ContactPoint objects
    addresses JSONB, -- Array of Address objects
    
    -- Demographics
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'unknown')),
    birth_date DATE,
    
    -- Professional information
    qualifications JSONB, -- Array of Practitioner.qualification
    communications JSONB, -- Array of CodeableConcept (languages)
    
    -- Photo
    photos JSONB, -- Array of Attachment
    
    -- FHIR metadata
    meta JSONB,
    text_div TEXT,
    extensions JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
*/
/*
-- de ma compréhension, on n'a pas de practitionerRole en l'état. 
-- Table: fhir_practitioner_role (DMPractitionerRole profile)
CREATE TABLE fhir_practitioner_role (
    id VARCHAR(64) PRIMARY KEY,
    version_id VARCHAR(64),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR PractitionerRole core elements
    active BOOLEAN DEFAULT TRUE,
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- References
    practitioner_id VARCHAR(64),
    organization_id VARCHAR(64),
    locations JSONB, -- Array of Reference(Location)
    healthcare_services JSONB, -- Array of Reference(HealthcareService)
    
    -- Professional details
    codes JSONB, -- Array of CodeableConcept (roles)
    specialties JSONB, -- Array of CodeableConcept
    
    -- Period of validity
    period_start DATE,
    period_end DATE,
    
    -- Contact information
    telecoms JSONB, -- Array of ContactPoint objects
    
    -- Availability
    available_times JSONB, -- Array of PractitionerRole.availableTime
    not_available JSONB, -- Array of PractitionerRole.notAvailable
    availability_exceptions TEXT,
    
    -- Endpoints
    endpoints JSONB, -- Array of Reference(Endpoint)
    
    -- FHIR metadata
    meta JSONB,
    text_div TEXT,
    extensions JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (practitioner_id) REFERENCES fhir_practitioner(id),
    FOREIGN KEY (organization_id) REFERENCES fhir_organization(id)
);
*/
/*
-- de ma compréhension, on n'a pas d'épisodeOfCare 
-- Table: fhir_episode_of_care (DMEpisodeOfCare profile)
CREATE TABLE fhir_episode_of_care (
    id VARCHAR(64) PRIMARY KEY,
    version_id VARCHAR(64),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR EpisodeOfCare core elements
    status VARCHAR(20) CHECK (status IN ('planned', 'waitlist', 'active', 'onhold', 'finished', 'cancelled', 'entered-in-error')),
    status_history JSONB, -- Array of EpisodeOfCare.statusHistory
    types JSONB, -- Array of CodeableConcept
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Patient reference
    patient_id VARCHAR(64) NOT NULL,
    
    -- Managing organization
    managing_organization_id VARCHAR(64),
    
    -- Period
    period_start DATE,
    period_end DATE,
    
    -- Diagnosis
    diagnoses JSONB, -- Array of EpisodeOfCare.diagnosis
    
    -- Referral request
    referral_requests JSONB, -- Array of Reference(ServiceRequest)
    
    -- Care manager
    care_manager_id VARCHAR(64), -- Reference(Practitioner|PractitionerRole|Organization)
    
    -- Team
    teams JSONB, -- Array of Reference(CareTeam)
    
    -- Accounts
    accounts JSONB, -- Array of Reference(Account)
    
    -- FHIR metadata
    meta JSONB,
    text_div TEXT,
    extensions JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (managing_organization_id) REFERENCES fhir_organization(id),
    FOREIGN KEY (care_manager_id) REFERENCES fhir_practitioner(id)
);
*/

-- Table: fhir_encounter (DMEncounter profile)  
-- Healthcare encounters adapted for Data Management
-- Description: A healthcare interaction between a patient and healthcare provider(s)
CREATE TABLE fhir_encounter (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Encounter core elements
    status VARCHAR(20) CHECK (status IN ('planned', 'arrived', 'triaged', 'in-progress', 'onleave', 'finished', 'cancelled', 'entered-in-error', 'unknown')), -- Current state of encounter - FHIR status (1..1) - modifier element
    status_history JSONB, -- The status history permits tracking of statuses over time - FHIR statusHistory (0..*)
    class JSONB, -- Classification of patient encounter (inpatient, outpatient, emergency) - FHIR class Coding (1..1)
    class_display VARCHAR(255), -- Display text for encounter class for easier querying
    class_history JSONB, -- The class history permits tracking of the encounter type over time - FHIR classHistory (0..*)
    types JSONB, -- Specific type of encounter (consultation, surgical day care, etc.) - FHIR type CodeableConcept (0..*)
    service_type JSONB, -- Broad categorization of the service provided - FHIR serviceType CodeableConcept (0..1)
    priority JSONB, -- Indicates the urgency of the encounter - FHIR priority CodeableConcept (0..1)
    
    -- Identifiers
    identifiers JSONB, -- Business identifiers for this encounter - FHIR identifier (0..*)
    
    -- Patient reference (required)
    subject JSONB, -- The patient or group present at the encounter - FHIR subject Reference(Patient|Group) (0..1)
    subject_patient_id VARCHAR(64) NOT NULL, -- Required reference to DMPatient - enforced business rule
    
    -- Episode of care
    episodes_of_care JSONB, -- Where a specific encounter should be classified as part of an episode - FHIR episodeOfCare Reference (0..*)
    
    -- Based on appointments
    based_on_s JSONB, -- The appointment that scheduled this encounter - FHIR basedOn Reference(Appointment|ServiceRequest) (0..*)
    
    -- Participants
    participants JSONB, -- List of people involved in the encounter - FHIR participant BackboneElement (0..*)
    
    -- Appointments
    appointments JSONB, -- The appointment that scheduled this encounter - FHIR appointment Reference (0..*)
    
    -- Period - FHIR period (0..1)
    period_start TIMESTAMP WITH TIME ZONE, -- Start time of the encounter - FHIR period.start
    period_end TIMESTAMP WITH TIME ZONE, -- End time of the encounter - FHIR period.end
    
    -- Length of stay - FHIR length (0..1)
    length JSONB, -- Quantity of time the encounter lasted (excludes time for leaves of absence) - FHIR length Duration
    length_number_of_day INTEGER, -- Length of stay in days for easier reporting
    
    -- Reason codes - FHIR reasonCode, reasonReference
    reason_codes JSONB, -- Coded reason the encounter takes place - FHIR reasonCode CodeableConcept (0..*)
    reason_references JSONB, -- Reason the encounter takes place (reference to other resources) - FHIR reasonReference Reference (0..*)
    
    -- Diagnoses
    diagnoses JSONB, -- Array of Encounter.diagnosis
    
    -- Account
    account JSONB, -- Array of Reference(Account)
    
    -- Hospitalization details
    hospitalization JSONB, -- Encounter.hospitalization object
--    pre_admission_identifier VARCHAR(50),  pas formalisé à ce stade 
--    origin_location_id VARCHAR(64), pas formalisé à ce stade
    admit_source_text VARCHAR(255) CHECK (admit_source_text IN ('Mutation', 'Transfert définitif', 'Transfert provisoire', 'Domicile', 'Naissance', 'Patient entré décédé pour prélèvement d''organes')),
    discharge_disposition_text VARCHAR(255) CHECK (discharge_disposition_text IN ('Mutation', 'Transfert définitif', 'Transfert provisoire', 'Domicile', 'Décès')),

    -- Locations
    locations JSONB, -- Array of Encounter.location
    
    -- Service provider
    service_provider JSONB,
    service_provider_organization_display VARCHAR(64),
    
    -- Part of (for sub-encounters)
    part_of JSONB,
    
    -- FHIR metadata -- je vois pas de raison pour ne pas faire la même chose avec tous les types de ressources (il y a peut être des exceptions, mais bon)
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subject_patient_id) REFERENCES fhir_patient(id)
--    FOREIGN KEY (origin_location_id) REFERENCES fhir_location(id),
--    FOREIGN KEY (service_provider_id) REFERENCES fhir_organization(id),
--    FOREIGN KEY (part_of_encounter_id) REFERENCES fhir_encounter(id)
);

-- Table: fhir_condition (DMCondition profile)
-- Conditions adapted for Data Management with CIM-10 coding
-- Description: A clinical condition, problem, diagnosis, or other event, situation, issue, or clinical concept
CREATE TABLE fhir_condition (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Condition core elements
    clinical_status JSONB, -- The clinical status of the condition (active, recurrence, relapse, inactive, remission, resolved) - FHIR clinicalStatus CodeableConcept (0..1) - modifier element
    clinical_status_text VARCHAR(255), -- Display text for clinical status for easier querying
    verification_status JSONB, -- The verification status (unconfirmed, provisional, differential, confirmed, refuted, entered-in-error) - FHIR verificationStatus CodeableConcept (0..1) - modifier element
    verification_status_text VARCHAR(255), -- Display text for verification status
    categories JSONB, -- A category assigned to the condition (problem-list-item, encounter-diagnosis) - FHIR category CodeableConcept (0..*)
    categories_text TEXT, -- Display text for categories, particularly PMSI diagnosis coding context
    severity JSONB, -- A subjective assessment of the severity (mild, moderate, severe) - FHIR severity CodeableConcept (0..1)
    code JSONB, -- Identification of the condition, problem or diagnosis using CIM-10 - FHIR code CodeableConcept (0..1)
    code_text VARCHAR(255), -- Display text for condition code
    body_sites JSONB, -- The anatomical location where condition manifests - FHIR bodySite CodeableConcept (0..*)
    
    -- Identifiers
    identifiers JSONB, -- Business identifiers for this condition - FHIR identifier (0..*)
    
    -- Patient reference (required)
    subject JSONB NOT NULL, -- Indicates the patient or group who condition concerns - FHIR subject Reference(Patient|Group) (1..1)
    subject_patient_id VARCHAR(64) NOT NULL, -- Required reference to DMPatient
    
    -- Encounter reference
    encounter JSONB, -- Encounter during which condition was first asserted - FHIR encounter Reference(Encounter) (0..1)
    encounter_id VARCHAR(64), -- Reference to DMEncounter where condition was identified
    
    -- Onset and abatement timing - FHIR onset[x], abatement[x]
    onset_x JSONB, -- Estimated or actual date, date-time, or age when condition began - FHIR onset[x] (0..1)
    abatement_x JSONB, -- Date or estimated date condition resolved or went into remission - FHIR abatement[x] (0..1)
    
    -- Recording information
    recorded_date DATE, -- Date condition was first recorded in system - FHIR recordedDate (0..1)
    recorder JSONB, -- Individual who recorded the condition - FHIR recorder Reference(Practitioner|PractitionerRole|Patient|RelatedPerson) (0..1)
    asserter JSONB, -- Individual making the condition statement - FHIR asserter Reference(Practitioner|PractitionerRole|Patient|RelatedPerson) (0..1)
    
    -- Stage
    stages JSONB, -- Array of Condition.stage
    
    -- Evidence
    evidences JSONB, -- Array of Condition.evidence
    
    -- Notes
    notes JSONB, -- Array of Annotation
    
    -- FHIR metadata -- je vois pas de raison pour ne pas faire la même chose avec tous les types de ressources (il y a peut être des exceptions, mais bon)
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subject_patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (encounter_id) REFERENCES fhir_encounter(id)
--    FOREIGN KEY (recorder_id) REFERENCES fhir_practitioner(id),
--    FOREIGN KEY (asserter_id) REFERENCES fhir_practitioner(id)
);

-- Table: fhir_procedure (DMProcedure profile)
-- Procedures adapted for Data Management
-- Description: An action that is or was performed on a patient (with CCAM coding)
CREATE TABLE fhir_procedure (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    instantiates_canonical_s JSONB,
    instantiates_uri_s JSONB,

    -- FHIR Procedure core elements
    status VARCHAR(20) CHECK (status IN ('preparation', 'in-progress', 'not-done', 'on-hold', 'stopped', 'completed', 'entered-in-error', 'unknown')),
    status_reason JSONB, -- CodeableConcept
    category JSONB, -- CodeableConcept
    code JSONB, -- CodeableConcept (CCAM or other coding systems)
    code_text VARCHAR(255), 

    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Based on
    based_on_s JSONB, -- Array of Reference(CarePlan|ServiceRequest)
    part_of_s JSONB, -- Array of Reference(Procedure|Observation|MedicationAdministration)
    
    -- Patient reference (required)
    subject JSONB NOT NULL,
    subject_patient_id VARCHAR(64) NOT NULL,
    
    -- Encounter reference
    encounter JSONB,
    encounter_id VARCHAR(64),
    
    -- Timing - on simplifie
    performed_x JSONB,
    performed_date_time TIMESTAMP WITH TIME ZONE, -- date de réalisation de l'acte, dispo dans le pmsi et plus intéressante que la date du recueil, seule demandée dans le socle.
    
    -- Recorder and asserter
    recorder JSONB,
    asserter JSONB,
    
    -- Performers
    performers JSONB, -- Array of Procedure.performer
    performer_actor_practitioner_text TEXT,
    
    -- Location
    location JSONB,
    
    -- Reason
    reason_codes JSONB, -- Array of CodeableConcept
    reason_references JSONB, -- Array of Reference
    
    -- Body sites
    body_sites JSONB, -- Array of CodeableConcept
    
    -- Outcome
    outcome JSONB, -- CodeableConcept
    
    -- Reports and complications
    reports JSONB, -- Array of Reference(DiagnosticReport|DocumentReference|Composition)
    complications JSONB, -- Array of CodeableConcept
    complication_details JSONB, -- Array of Reference(Condition)
    
    -- Follow up
    follow_up_s JSONB, -- Array of CodeableConcept
    
    -- Notes
    notes JSONB, -- Array of Annotation
    
    -- Focal device
    focal_devices JSONB, -- Array of Procedure.focalDevice
    
    -- Used items
    used_references JSONB, -- Array of Reference
    used_codes JSONB, -- Array of CodeableConcept
    
    -- FHIR metadata -- je vois pas de raison pour ne pas faire la même chose avec tous les types de ressources (il y a peut être des exceptions, mais bon)
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subject_patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (encounter_id) REFERENCES fhir_encounter(id)
--    FOREIGN KEY (recorder_id) REFERENCES fhir_practitioner(id),
--    FOREIGN KEY (asserter_id) REFERENCES fhir_practitioner(id),
--    FOREIGN KEY (location_id) REFERENCES fhir_location(id)
);

-- Table: fhir_observation
-- Generic observation table for all DM observation profiles
-- Includes laboratory results, vital signs, and lifestyle observations  
-- Description: Measurements and simple assertions made about a patient, device or other subject
CREATE TABLE fhir_observation (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Observation core elements
    status VARCHAR(20) CHECK (status IN ('registered', 'preliminary', 'final', 'amended', 'corrected', 'cancelled', 'entered-in-error', 'unknown')), -- The status of the result value - FHIR status (1..1) - modifier element
    categories JSONB, -- Classification of type of observation (laboratory, vital-signs, imaging, etc.) - FHIR category CodeableConcept (0..*)
    categories_text TEXT, -- Display text for observation categories
    code JSONB, -- Type of observation (what was measured/observed) using LOINC codes - FHIR code CodeableConcept (1..1)
    code_text VARCHAR(255), -- Display text for observation code (sometimes called observation "name")
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Based on
    based_on_s JSONB, -- Array of Reference(CarePlan|DeviceRequest|ImmunizationRecommendation|MedicationRequest|NutritionOrder|ServiceRequest)
    part_of_s JSONB, -- Array of Reference(MedicationAdministration|MedicationDispense|MedicationStatement|Procedure|Immunization|ImagingStudy)
    
    -- Patient reference (required)
    subject JSONB,
    subject_patient_id VARCHAR(64) ,
    
    -- Encounter reference
    encounter JSONB,
    encounter_id VARCHAR(64),
    
    -- Focus
    focus_s JSONB, -- Array of Reference(Any)
    
    -- Effective timing - on simplifie
    effective_x JSONB,
    effective_date_time TIMESTAMP WITH TIME ZONE, -- pour l'age, si on en fait une observation, j'ai posé la date à la date de début de l'encounter (c'est la règle dans les RSA)
--    effective_period JSONB, -- Period
--    effective_timing JSONB, -- Timing
--    effective_instant TIMESTAMP WITH TIME ZONE,
    
    -- Issued
    issued TIMESTAMP WITH TIME ZONE,
    
    -- Performers
    performers JSONB, -- Array of Reference(Practitioner|PractitionerRole|Organization|CareTeam|Patient|RelatedPerson)
    performer_organization_text VARCHAR(255), -- pour les labos de biologie
    
    -- Values (one of)
    value_x JSONB,
    value_quantity_value FLOAT, 
    value_quantity_unit VARCHAR(255),
--    value_codeable_concept JSONB, -- CodeableConcept
--    value_string VARCHAR(500),
--    value_boolean BOOLEAN,
--    value_integer INTEGER,
--    value_range JSONB, -- Range
--    value_ratio JSONB, -- Ratio
--    value_sampled_data JSONB, -- SampledData
--    value_time TIME,
--    value_date_time TIMESTAMP WITH TIME ZONE,
--    value_period JSONB, -- Period
    
    -- Data absent reason
    data_absent_reason JSONB, -- CodeableConcept
    
    -- Interpretation and notes
    interpretations JSONB, -- Array of CodeableConcept
    notes JSONB, -- Array of Annotation
    
    -- Body site
    body_site JSONB, -- CodeableConcept
    
    -- Method and specimen
    method JSONB, -- CodeableConcept
    specimen JSONB, -- Reference(Specimen)
    device JSONB, -- Reference(Device|DeviceMetric)
    
    -- Reference ranges
    reference_ranges JSONB, -- Array of Observation.referenceRange
    reference_ranges_value TEXT, --Reference range values serialized as JSONB
    
    -- Related observations
    has_members JSONB, -- Array of Reference(Observation|QuestionnaireResponse|MolecularSequence)
    derived_from_s JSONB, -- Array of Reference
    
    -- Components (for multi-component observations)
    components JSONB, -- Array of Observation.component
    
    -- Profile-specific fields for DM observations - je ne comprend pas l'intéret de ces trucs, c'est dans meta-profile, ou dans le code/la categorie
--    observation_profile VARCHAR(50), -- 'laboratory', 'vital-signs', 'lifestyle', etc.
--    laboratory_type VARCHAR(50), -- 'uremie', 'tca', 'fonction_renale', 'generic'
--    vital_sign_type VARCHAR(50), -- 'blood_pressure', 'body_height', 'body_weight'
--    lifestyle_type VARCHAR(50), -- 'smoking_status', 'alcohol_use', 'substance_use', 'exercise_status'
    
    -- FHIR metadata -- je vois pas de raison pour ne pas faire la même chose avec tous les types de ressources (il y a peut être des exceptions, mais bon)
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subject_patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (encounter_id) REFERENCES fhir_encounter(id)
--    FOREIGN KEY (specimen_id) REFERENCES fhir_patient(id), -- Simplified; in real FHIR this would be Specimen
--    FOREIGN KEY (device_id) REFERENCES fhir_organization(id) -- Simplified; in real FHIR this would be Device
);

-- Table: fhir_observation_component
-- Observation components
CREATE TABLE fhir_observation_component (
    id VARCHAR(64) PRIMARY KEY, -- clé technique non FHIR
    observation_id VARCHAR(64), --Foreign key vers observation
    code JSONB, -- CodeableConcept (LOINC codes)
    code_text VARCHAR(255),

    -- Values (one of)
    value_x JSONB,
    value_quantity_value FLOAT, 
    value_quantity_unit VARCHAR(255),

    -- Data absent reason
    data_absent_reason JSONB, -- CodeableConcept
    
    -- Interpretation
    interpretations JSONB, -- Array of CodeableConcept

    -- Reference ranges
    reference_ranges JSONB, -- Array of Observation.referenceRange
    reference_ranges_value TEXT, --Reference range values serialized as JSONB

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (observation_id) REFERENCES fhir_observation(id)
);


-- Table: fhir_medication_request (DMMedicationRequest profile)
-- Medication prescriptions
-- Description: An order or request for both supply of the medication and the instructions for administration
CREATE TABLE fhir_medication_request (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR MedicationRequest core elements
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'on-hold', 'cancelled', 'completed', 'entered-in-error', 'stopped', 'draft', 'unknown')), -- Current state of order - FHIR status (1..1) - modifier element
    status_reason JSONB, -- Reason for current status - FHIR statusReason CodeableConcept (0..1)
    intent VARCHAR(20) NOT NULL CHECK (intent IN ('proposal', 'plan', 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order', 'option')), -- Whether request is proposal, plan, or original order - FHIR intent (1..1) - modifier element
    categories JSONB, -- Type of medication usage (inpatient, outpatient, community, discharge) - FHIR category CodeableConcept (0..*)
    priority VARCHAR(20) CHECK (priority IN ('routine', 'urgent', 'asap', 'stat')), -- Indicates urgency of request - FHIR priority (0..1)
    do_not_perform BOOLEAN, -- True if request is prohibiting action - FHIR doNotPerform (0..1) - modifier element
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Based on
    based_on_s JSONB, -- Array of Reference(CarePlan|MedicationRequest|ServiceRequest|ImmunizationRecommendation)
    reported_x JSONB, 
    
    -- Group identifier
    group_identifier JSONB, -- Identifier
    
    -- Course of therapy
    course_of_therapy_type JSONB, -- CodeableConcept
    
    -- Insurance
    insurances JSONB, -- Array of Reference(Coverage|ClaimResponse)
    
    -- Notes
    notes JSONB, -- Array of Annotation
    
    -- Medication (can be CodeableConcept or Reference)
    medication_x JSONB, 
    medication_text VARCHAR(255),
    
    -- Patient reference (required)
    subject_patient_id VARCHAR(64) NOT NULL,
    
    -- Encounter reference
    encounter_id VARCHAR(64),
    
    -- Support information
    supporting_informations JSONB, -- Array of Reference(Any)
    
    -- Authored on
    authored_on TIMESTAMP WITH TIME ZONE,
    
    -- Requester
    requester JSONB,
    requester_practitioner_display VARCHAR(255), -- Reference(Practitioner|PractitionerRole|Organization|Patient|RelatedPerson|Device)
    
    -- Performer and type
    performer JSONB, -- Reference(Practitioner|PractitionerRole|Organization|Patient|Device|RelatedPerson|CareTeam)
    performer_type JSONB, -- CodeableConcept
    
    -- Recorder
    recorder JSONB, -- Reference(Practitioner|PractitionerRole)
    
    -- Reason
    reason_codes JSONB, -- Array of CodeableConcept
    reason_references JSONB, -- Array of Reference(Condition|Observation)
    
    -- Instantiates
    instantiates_canonical_s JSONB, -- Array of canonical(ActivityDefinition|PlanDefinition)
    instantiates_uri_s JSONB, -- Array of uri
    
    -- Dosage instruction
    dosage_instructions JSONB, -- Array of Dosage. On part un peu du principe dans l'extraction SQL qu'il n'y aura qu'une occurrence.
    dosage_instruction_route_text VARCHAR(255),
    dosage_instruction_dose_quantity_value float, 
    dosage_instruction_dose_quantity_unit VARCHAR(255), 
    dosage_instruction_timing_bounds_period_start TIMESTAMP WITH TIME ZONE, 
    dosage_instruction_timing_bounds_period_end TIMESTAMP WITH TIME ZONE, 
    
    -- Dispense request
    dispense_request JSONB, -- MedicationRequest.dispenseRequest
    
    -- Substitution
    substitution JSONB, -- MedicationRequest.substitution
    
    -- Prior prescription
    prior_prescription JSONB, -- Reference(MedicationRequest)
    
    -- Detection flags
    detected_issues JSONB, -- Array of CodeableConcept
    
    -- Event history
    event_history JSONB, -- Array of Reference(Provenance)
    
    -- FHIR metadata -- je vois pas de raison pour ne pas faire la même chose avec tous les types de ressources (il y a peut être des exceptions, mais bon)
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subject_patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (encounter_id) REFERENCES fhir_encounter(id)
--    FOREIGN KEY (requester_id) REFERENCES fhir_practitioner(id),
--    FOREIGN KEY (performer_id) REFERENCES fhir_practitioner(id),
--    FOREIGN KEY (recorder_id) REFERENCES fhir_practitioner(id),
--    FOREIGN KEY (prior_prescription_id) REFERENCES fhir_medication_request(id)
);

-- Table: fhir_medication_administration (DMMedicationAdministration profile)
-- Medication administration records
-- Description: Describes the event of a patient consuming or otherwise being administered a medication
CREATE TABLE fhir_medication_administration (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR MedicationAdministration core elements
    status VARCHAR(20) NOT NULL CHECK (status IN ('in-progress', 'not-done', 'on-hold', 'completed', 'entered-in-error', 'stopped', 'unknown')),
    status_reasons JSONB, -- Array of CodeableConcept
    category JSONB, -- Array of CodeableConcept
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Instantiates
    instantiates_s JSONB, -- Array of uri
    
    -- Part of
    part_of_s JSONB, -- Array of Reference(MedicationAdministration|Procedure)
    
    -- Based on
--    based_on JSONB, -- Array of Reference(MedicationRequest)
    
    -- Medication (can be CodeableConcept or Reference)
    medication_x JSONB,
    medication_text VARCHAR(255),
    
    -- Patient reference (required)
    subject_patient_id VARCHAR(64) NOT NULL,
    
    -- Context
    context JSONB,
    context_encounter_id VARCHAR(64), -- Reference(Encounter)
--    context_episode_id VARCHAR(64), -- Reference(EpisodeOfCare) - on n'a pas d'épisode
    
    -- Support information
    supporting_informations JSONB, -- Array of Reference(Any)
    
    -- Effective timing
    effective_x JSONB,
    effective_date_time TIMESTAMP WITH TIME ZONE,
    
    -- Performers
    performers JSONB, -- Array of MedicationAdministration.performer
    
    -- Reason
    reason_codes JSONB, -- Array of CodeableConcept
    reason_references JSONB, -- Array of Reference(Condition|Observation|DiagnosticReport)
    
    -- Request reference
    request JSONB,
    request_medication_request_id VARCHAR(64), -- Reference(MedicationRequest)
    
    -- Device
    devices JSONB, -- Array of Reference(Device)
    
    -- Notes
    notes JSONB, -- Array of Annotation
    
    -- Dosage
    dosage JSONB, -- MedicationAdministration.dosage
    dosage_route_text VARCHAR(255),
    dosage_dose_value FLOAT, 
    dosage_dose_unit VARCHAR(255),
    
    -- Event history
    event_history JSONB, -- Array of Reference(Provenance)
    
    -- FHIR metadata -- je vois pas de raison pour ne pas faire la même chose avec tous les types de ressources (il y a peut être des exceptions, mais bon)
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subject_patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (context_encounter_id) REFERENCES fhir_encounter(id),
--    FOREIGN KEY (context_episode_id) REFERENCES fhir_episode_of_care(id),
    FOREIGN KEY (request_medication_request_id) REFERENCES fhir_medication_request(id)
);
/* pas nécessaire à ce stade
-- Table: fhir_claim
-- Generic claim table for PMSI billing data (DMClaimPMSI, DMClaimPMSIMCO, DMClaimRUM profiles)
CREATE TABLE fhir_claim (
    id VARCHAR(64) PRIMARY KEY,
    version_id VARCHAR(64),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Claim core elements
    status VARCHAR(20) CHECK (status IN ('active', 'cancelled', 'draft', 'entered-in-error')),
    type JSONB, -- CodeableConcept
    sub_type JSONB, -- CodeableConcept
    use VARCHAR(20) CHECK (use IN ('claim', 'preauthorization', 'predetermination')),
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Patient reference (required)
    patient_id VARCHAR(64) NOT NULL,
    
    -- Billing period
    billable_period JSONB, -- Period
    
    -- Created
    created TIMESTAMP WITH TIME ZONE,
    
    -- Enterer
    enterer_id VARCHAR(64), -- Reference(Practitioner|PractitionerRole)
    
    -- Insurer
    insurer_id VARCHAR(64), -- Reference(Organization)
    
    -- Provider
    provider_id VARCHAR(64), -- Reference(Practitioner|PractitionerRole|Organization)
    
    -- Priority
    priority JSONB, -- CodeableConcept
    
    -- Funds reserve
    funds_reserve JSONB, -- CodeableConcept
    
    -- Related claims
    related_claims JSONB, -- Array of Claim.related
    
    -- Prescription
    prescription_id VARCHAR(64), -- Reference(DeviceRequest|MedicationRequest|VisionPrescription)
    
    -- Original prescription
    original_prescription_id VARCHAR(64), -- Reference(DeviceRequest|MedicationRequest|VisionPrescription)
    
    -- Payee
    payee JSONB, -- Claim.payee
    
    -- Referral
    referral_id VARCHAR(64), -- Reference(ServiceRequest)
    
    -- Facility
    facility_id VARCHAR(64), -- Reference(Location)
    
    -- Care team
    care_teams JSONB, -- Array of Claim.careTeam
    
    -- Supporting info
    supporting_infos JSONB, -- Array of Claim.supportingInfo
    
    -- Diagnoses
    diagnoses JSONB, -- Array of Claim.diagnosis
    
    -- Procedures
    procedures JSONB, -- Array of Claim.procedure
    
    -- Items
    items JSONB, -- Array of Claim.item
    
    -- Total cost
    total JSONB, -- Money
    
    -- Claim-specific fields for DM profiles
    claim_profile VARCHAR(20), -- 'pmsi', 'pmsi_mco', 'rum'
    pmsi_data JSONB, -- PMSI-specific data
    
    -- FHIR metadata
    meta JSONB,
    text_div TEXT,
    extensions JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (patient_id) REFERENCES fhir_patient(id),
    FOREIGN KEY (enterer_id) REFERENCES fhir_practitioner(id),
    FOREIGN KEY (insurer_id) REFERENCES fhir_organization(id),
    FOREIGN KEY (provider_id) REFERENCES fhir_organization(id),
    FOREIGN KEY (prescription_id) REFERENCES fhir_medication_request(id),
    FOREIGN KEY (original_prescription_id) REFERENCES fhir_medication_request(id),
    FOREIGN KEY (referral_id) REFERENCES fhir_medication_request(id), -- Simplified
    FOREIGN KEY (facility_id) REFERENCES fhir_location(id)
);
*/
-- ========================================================================
-- POSTGRESQL 17.x OPTIMIZED INDEXES FOR PERFORMANCE
-- Comprehensive indexing strategy for FHIR Semantic Layer
-- ========================================================================

-- ========================================================================
-- PATIENT INDEXES (Core Resource)
-- ========================================================================

-- Primary lookup indexes
CREATE INDEX CONCURRENTLY idx_patient_identifiers ON fhir_patient USING GIN (identifiers);
CREATE INDEX idx_patient_nss ON fhir_patient(nss_identifier) WHERE nss_identifier IS NOT NULL;
CREATE INDEX idx_patient_ins_nir ON fhir_patient(ins_nir_identifier) WHERE ins_nir_identifier IS NOT NULL;

-- Hash indexes for exact lookups (PostgreSQL 17.x optimization)
CREATE INDEX idx_patient_nss_hash ON fhir_patient USING hash(nss_identifier) WHERE nss_identifier IS NOT NULL;
CREATE INDEX idx_patient_ins_nir_hash ON fhir_patient USING hash(ins_nir_identifier) WHERE ins_nir_identifier IS NOT NULL;

-- Demographic indexes
CREATE INDEX idx_patient_birth_date ON fhir_patient(birth_date);
CREATE INDEX idx_patient_gender ON fhir_patient(gender);
CREATE INDEX idx_patient_active ON fhir_patient(active);
CREATE INDEX idx_patient_deceased ON fhir_patient(deceased_date_time) WHERE deceased_date_time IS NOT NULL;

-- Full-text search index for patient names (French language)
CREATE INDEX CONCURRENTLY idx_patient_names_search ON fhir_patient USING gin(to_tsvector('french', COALESCE(names::text, '')));

-- Geographic indexes optimized for PostgreSQL 17.x
CREATE INDEX idx_patient_coordinates_gist ON fhir_patient USING gist(point(address_extension_geolocation_longitude, address_extension_geolocation_latitude)) 
    WHERE address_extension_geolocation_latitude IS NOT NULL AND address_extension_geolocation_longitude IS NOT NULL;
CREATE INDEX idx_patient_census_tract ON fhir_patient(address_extension_census_tract) WHERE address_extension_census_tract IS NOT NULL;

-- Composite indexes for common queries
CREATE INDEX idx_patient_demographics ON fhir_patient(birth_date, gender, active);
CREATE INDEX idx_patient_location_period ON fhir_patient(address_period_start DESC, address_extension_census_tract) WHERE address_period_start IS NOT NULL;

-- Organization indexes
--CREATE INDEX idx_organization_identifiers ON fhir_organization USING GIN (identifiers);
--CREATE INDEX idx_organization_name ON fhir_organization(name);
--CREATE INDEX idx_organization_active ON fhir_organization(active);
--CREATE INDEX idx_organization_part_of ON fhir_organization(part_of_organization_id);

-- Location indexes
--CREATE INDEX idx_location_managing_org ON fhir_location(managing_organization_id);
--CREATE INDEX idx_location_part_of ON fhir_location(part_of_location_id);
--CREATE INDEX idx_location_status ON fhir_location(status);
--CREATE INDEX idx_location_coordinates ON fhir_location(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Practitioner indexes
--CREATE INDEX idx_practitioner_identifiers ON fhir_practitioner USING GIN (identifiers);
--CREATE INDEX idx_practitioner_family_name ON fhir_practitioner(family_name);
--CREATE INDEX idx_practitioner_active ON fhir_practitioner(active);

-- PractitionerRole indexes
--CREATE INDEX idx_practitioner_role_practitioner ON fhir_practitioner_role(practitioner_id);
--CREATE INDEX idx_practitioner_role_organization ON fhir_practitioner_role(organization_id);
--CREATE INDEX idx_practitioner_role_active ON fhir_practitioner_role(active);

-- EpisodeOfCare indexes
--CREATE INDEX idx_episode_patient ON fhir_episode_of_care(patient_id);
--CREATE INDEX idx_episode_managing_org ON fhir_episode_of_care(managing_organization_id);
--CREATE INDEX idx_episode_status ON fhir_episode_of_care(status);
--CREATE INDEX idx_episode_period ON fhir_episode_of_care(period_start, period_end);

-- ========================================================================
-- ENCOUNTER INDEXES (Healthcare Episodes)
-- ========================================================================

-- Primary foreign key indexes
CREATE INDEX idx_encounter_patient ON fhir_encounter(subject_patient_id);
CREATE INDEX idx_encounter_status ON fhir_encounter(status);

-- Temporal indexes for encounters
CREATE INDEX idx_encounter_period ON fhir_encounter(period_start DESC, period_end) WHERE period_start IS NOT NULL;
CREATE INDEX idx_encounter_period_range ON fhir_encounter USING gist(tstzrange(period_start, period_end)) WHERE period_start IS NOT NULL;
CREATE INDEX idx_encounter_duration ON fhir_encounter(length_number_of_day) WHERE length_number_of_day IS NOT NULL;

-- JSONB indexes for FHIR complex types
CREATE INDEX idx_encounter_class ON fhir_encounter USING GIN (class);
CREATE INDEX idx_encounter_types ON fhir_encounter USING GIN (types);
CREATE INDEX idx_encounter_reason_codes ON fhir_encounter USING GIN (reason_codes);
CREATE INDEX idx_encounter_locations ON fhir_encounter USING GIN (locations);

-- Service provider lookup
CREATE INDEX idx_encounter_service_provider ON fhir_encounter(service_provider_organization_display) WHERE service_provider_organization_display IS NOT NULL;

-- Composite indexes for common queries
CREATE INDEX idx_encounter_patient_period ON fhir_encounter(subject_patient_id, period_start DESC);
CREATE INDEX idx_encounter_status_period ON fhir_encounter(status, period_start DESC) WHERE period_start IS NOT NULL;

-- ========================================================================
-- CONDITION INDEXES (Diagnoses and Problems)
-- ========================================================================

-- Primary foreign key indexes
CREATE INDEX idx_condition_patient ON fhir_condition(subject_patient_id);
CREATE INDEX idx_condition_encounter ON fhir_condition(encounter_id);

-- Clinical status and verification indexes
CREATE INDEX idx_condition_clinical_status ON fhir_condition USING GIN (clinical_status);
CREATE INDEX idx_condition_verification_status ON fhir_condition USING GIN (verification_status);

-- Code and terminology indexes
CREATE INDEX idx_condition_code ON fhir_condition USING GIN (code);
CREATE INDEX idx_condition_code_text ON fhir_condition(code_text) WHERE code_text IS NOT NULL;
CREATE INDEX idx_condition_categories ON fhir_condition USING GIN (categories);

-- Temporal indexes
CREATE INDEX idx_condition_recorded_date ON fhir_condition(recorded_date);
CREATE INDEX idx_condition_onset ON fhir_condition USING GIN (onset_x);

-- Composite indexes for common clinical queries
CREATE INDEX idx_condition_patient_clinical ON fhir_condition(subject_patient_id, clinical_status_text, recorded_date);
CREATE INDEX idx_condition_encounter_code ON fhir_condition(encounter_id, code_text) WHERE encounter_id IS NOT NULL;

-- ========================================================================
-- PROCEDURE INDEXES (Medical Procedures)
-- ========================================================================

-- Primary foreign key indexes
CREATE INDEX idx_procedure_patient ON fhir_procedure(subject_patient_id);
CREATE INDEX idx_procedure_encounter ON fhir_procedure(encounter_id);

-- Status and code indexes
CREATE INDEX idx_procedure_status ON fhir_procedure(status);
CREATE INDEX idx_procedure_code ON fhir_procedure USING GIN (code);
CREATE INDEX idx_procedure_code_text ON fhir_procedure(code_text) WHERE code_text IS NOT NULL;

-- Temporal indexes
CREATE INDEX idx_procedure_performed ON fhir_procedure(performed_date_time DESC) WHERE performed_date_time IS NOT NULL;

-- Procedure category and outcome
CREATE INDEX idx_procedure_category ON fhir_procedure USING GIN (category);
CREATE INDEX idx_procedure_outcome ON fhir_procedure USING GIN (outcome);

-- Composite indexes for procedure queries
CREATE INDEX idx_procedure_patient_performed ON fhir_procedure(subject_patient_id, performed_date_time DESC);
CREATE INDEX idx_procedure_encounter_status ON fhir_procedure(encounter_id, status) WHERE encounter_id IS NOT NULL;

-- ========================================================================
-- OBSERVATION INDEXES (Laboratory and Clinical Measurements)
-- ========================================================================

-- Primary foreign key indexes
CREATE INDEX idx_observation_patient ON fhir_observation(subject_patient_id);
CREATE INDEX idx_observation_encounter ON fhir_observation(encounter_id);

-- Status and categories
CREATE INDEX idx_observation_status ON fhir_observation(status);
CREATE INDEX idx_observation_categories ON fhir_observation USING GIN (categories);
CREATE INDEX idx_observation_categories_text ON fhir_observation(categories_text) WHERE categories_text IS NOT NULL;

-- Code and terminology (LOINC)
CREATE INDEX idx_observation_code ON fhir_observation USING GIN (code);
CREATE INDEX idx_observation_code_text ON fhir_observation(code_text) WHERE code_text IS NOT NULL;
CREATE INDEX idx_observation_code_hash ON fhir_observation USING hash(code_text) WHERE code_text IS NOT NULL;

-- Temporal indexes
CREATE INDEX idx_observation_effective ON fhir_observation(effective_date_time DESC) WHERE effective_date_time IS NOT NULL;
CREATE INDEX idx_observation_issued ON fhir_observation(issued) WHERE issued IS NOT NULL;

-- Value indexes for numeric results
CREATE INDEX idx_observation_value_numeric ON fhir_observation(value_quantity_value) WHERE value_quantity_value IS NOT NULL;
CREATE INDEX idx_observation_value_unit ON fhir_observation(value_quantity_unit) WHERE value_quantity_unit IS NOT NULL;

-- Performer organization (laboratories)
CREATE INDEX idx_observation_performer ON fhir_observation(performer_organization_text) WHERE performer_organization_text IS NOT NULL;

-- Composite indexes for common laboratory queries
CREATE INDEX idx_observation_patient_code ON fhir_observation(subject_patient_id, code_text, effective_date_time DESC);
CREATE INDEX idx_observation_patient_effective ON fhir_observation(subject_patient_id, effective_date_time DESC) WHERE effective_date_time IS NOT NULL;
CREATE INDEX idx_observation_encounter_code ON fhir_observation(encounter_id, code_text) WHERE encounter_id IS NOT NULL;

-- ========================================================================
-- OBSERVATION COMPONENT INDEXES
-- ========================================================================

CREATE INDEX idx_observation_component_parent ON fhir_observation_component(observation_id);
CREATE INDEX idx_observation_component_code ON fhir_observation_component USING GIN (code);
CREATE INDEX idx_observation_component_value ON fhir_observation_component(value_quantity_value) WHERE value_quantity_value IS NOT NULL;

-- ========================================================================
-- MEDICATION REQUEST INDEXES (Prescriptions)
-- ========================================================================

-- Primary foreign key indexes
CREATE INDEX idx_med_request_patient ON fhir_medication_request(subject_patient_id);
CREATE INDEX idx_med_request_encounter ON fhir_medication_request(encounter_id);

-- Status and intent (required fields)
CREATE INDEX idx_med_request_status ON fhir_medication_request(status);
CREATE INDEX idx_med_request_intent ON fhir_medication_request(intent);
CREATE INDEX idx_med_request_priority ON fhir_medication_request(priority) WHERE priority IS NOT NULL;

-- Medication identification
CREATE INDEX idx_med_request_medication_text ON fhir_medication_request(medication_text) WHERE medication_text IS NOT NULL;
CREATE INDEX idx_med_request_medication ON fhir_medication_request USING GIN (medication_x);

-- Temporal indexes
CREATE INDEX idx_med_request_authored ON fhir_medication_request(authored_on DESC) WHERE authored_on IS NOT NULL;
CREATE INDEX idx_med_request_dosage_period ON fhir_medication_request(dosage_instruction_timing_bounds_period_start, dosage_instruction_timing_bounds_period_end);

-- Prescriber information
CREATE INDEX idx_med_request_requester ON fhir_medication_request(requester_practitioner_display) WHERE requester_practitioner_display IS NOT NULL;

-- Route and dosing
CREATE INDEX idx_med_request_route ON fhir_medication_request(dosage_instruction_route_text) WHERE dosage_instruction_route_text IS NOT NULL;

-- Composite indexes for medication queries
CREATE INDEX idx_med_request_patient_medication ON fhir_medication_request(subject_patient_id, medication_text, authored_on DESC);
CREATE INDEX idx_med_request_patient_active ON fhir_medication_request(subject_patient_id, status, authored_on DESC) WHERE status IN ('active', 'on-hold');

-- ========================================================================
-- MEDICATION ADMINISTRATION INDEXES
-- ========================================================================

-- Primary foreign key indexes
CREATE INDEX idx_med_admin_patient ON fhir_medication_administration(subject_patient_id);
CREATE INDEX idx_med_admin_encounter ON fhir_medication_administration(context_encounter_id);
CREATE INDEX idx_med_admin_request ON fhir_medication_administration(request_medication_request_id) WHERE request_medication_request_id IS NOT NULL;

-- Status
CREATE INDEX idx_med_admin_status ON fhir_medication_administration(status);

-- Medication identification
CREATE INDEX idx_med_admin_medication_text ON fhir_medication_administration(medication_text) WHERE medication_text IS NOT NULL;

-- Temporal indexes
CREATE INDEX idx_med_admin_effective ON fhir_medication_administration(effective_date_time DESC) WHERE effective_date_time IS NOT NULL;

-- Route and dosing
CREATE INDEX idx_med_admin_route ON fhir_medication_administration(dosage_route_text) WHERE dosage_route_text IS NOT NULL;

-- Composite indexes for administration queries
CREATE INDEX idx_med_admin_patient_effective ON fhir_medication_administration(subject_patient_id, effective_date_time DESC);
CREATE INDEX idx_med_admin_encounter_medication ON fhir_medication_administration(context_encounter_id, medication_text) WHERE context_encounter_id IS NOT NULL;

-- Claim indexes
--CREATE INDEX idx_claim_patient ON fhir_claim(patient_id);
--CREATE INDEX idx_claim_provider ON fhir_claim(provider_id);
--CREATE INDEX idx_claim_insurer ON fhir_claim(insurer_id);
--CREATE INDEX idx_claim_facility ON fhir_claim(facility_id);
--CREATE INDEX idx_claim_status ON fhir_claim(status);
--CREATE INDEX idx_claim_created ON fhir_claim(created);
--CREATE INDEX idx_claim_profile ON fhir_claim(claim_profile);

-- ========================================================================
-- ENHANCED FOREIGN KEY CONSTRAINTS AND DATA VALIDATION
-- Comprehensive constraints for FHIR Semantic Layer
-- ========================================================================

-- ========================================================================
-- ENHANCED FOREIGN KEY CONSTRAINTS WITH PROPER CASCADE RULES
-- ========================================================================

-- Add proper foreign key constraint names for observation_component
ALTER TABLE fhir_observation_component 
ADD CONSTRAINT fk_observation_component_observation 
FOREIGN KEY (observation_id) REFERENCES fhir_observation(id) ON DELETE CASCADE;

-- ========================================================================
-- COMPREHENSIVE CHECK CONSTRAINTS FOR DATA VALIDATION
-- ========================================================================

-- Patient validation constraints
ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_birth_date_range 
CHECK (birth_date >= '1900-01-01' AND birth_date <= CURRENT_DATE);

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_deceased_logic 
CHECK (deceased_date_time IS NULL OR (deceased_date_time >= birth_date AND deceased_date_time <= CURRENT_TIMESTAMP));

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_coordinates_range 
CHECK ((address_extension_geolocation_latitude IS NULL AND address_extension_geolocation_longitude IS NULL) OR 
       (address_extension_geolocation_latitude BETWEEN -90 AND 90 AND address_extension_geolocation_longitude BETWEEN -180 AND 180));

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_multiple_birth_integer 
CHECK (multiple_birth_integer IS NULL OR multiple_birth_integer BETWEEN 1 AND 10);

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_nss_format 
CHECK (nss_identifier IS NULL OR nss_identifier ~ '^[0-9]{13,15}$');

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_ins_nir_format 
CHECK (ins_nir_identifier IS NULL OR ins_nir_identifier ~ '^[0-9]{15}$');

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_pmsi_code_geo_format 
CHECK (address_extension_pmsi_code_geo_code IS NULL OR address_extension_pmsi_code_geo_code ~ '^[0-9]{2,5}$');

-- Encounter validation constraints
ALTER TABLE fhir_encounter 
ADD CONSTRAINT chk_encounter_period_logic 
CHECK (period_end IS NULL OR period_start IS NULL OR period_end >= period_start);

ALTER TABLE fhir_encounter 
ADD CONSTRAINT chk_encounter_length_positive 
CHECK (length_number_of_day IS NULL OR length_number_of_day >= 0);

ALTER TABLE fhir_encounter 
ADD CONSTRAINT chk_encounter_period_future 
CHECK (period_start IS NULL OR period_start <= CURRENT_TIMESTAMP + INTERVAL '1 day');

ALTER TABLE fhir_encounter 
ADD CONSTRAINT chk_encounter_class_display_length 
CHECK (class_display IS NULL OR LENGTH(class_display) <= 255);

-- Condition validation constraints
ALTER TABLE fhir_condition 
ADD CONSTRAINT chk_condition_recorded_date_logic 
CHECK (recorded_date IS NULL OR recorded_date <= CURRENT_DATE);

ALTER TABLE fhir_condition 
ADD CONSTRAINT chk_condition_text_fields_not_empty 
CHECK (clinical_status_text IS NULL OR LENGTH(TRIM(clinical_status_text)) > 0);

ALTER TABLE fhir_condition 
ADD CONSTRAINT chk_condition_code_text_not_empty 
CHECK (code_text IS NULL OR LENGTH(TRIM(code_text)) > 0);

-- Procedure validation constraints
ALTER TABLE fhir_procedure 
ADD CONSTRAINT chk_procedure_performed_future 
CHECK (performed_date_time IS NULL OR performed_date_time <= CURRENT_TIMESTAMP + INTERVAL '1 day');

ALTER TABLE fhir_procedure 
ADD CONSTRAINT chk_procedure_code_text_not_empty 
CHECK (code_text IS NULL OR LENGTH(TRIM(code_text)) > 0);

-- Observation validation constraints
ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_effective_future 
CHECK (effective_date_time IS NULL OR effective_date_time <= CURRENT_TIMESTAMP + INTERVAL '1 day');

ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_issued_logic 
CHECK (issued IS NULL OR effective_date_time IS NULL OR issued >= effective_date_time);

ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_value_positive 
CHECK (value_quantity_value IS NULL OR value_quantity_value >= 0);

ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_code_text_not_empty 
CHECK (code_text IS NULL OR LENGTH(TRIM(code_text)) > 0);

ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_categories_text_not_empty 
CHECK (categories_text IS NULL OR LENGTH(TRIM(categories_text)) > 0);

ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_performer_not_empty 
CHECK (performer_organization_text IS NULL OR LENGTH(TRIM(performer_organization_text)) > 0);

-- Observation component validation constraints
ALTER TABLE fhir_observation_component 
ADD CONSTRAINT chk_observation_component_value_positive 
CHECK (value_quantity_value IS NULL OR value_quantity_value >= 0);

ALTER TABLE fhir_observation_component 
ADD CONSTRAINT chk_observation_component_code_text_not_empty 
CHECK (code_text IS NULL OR LENGTH(TRIM(code_text)) > 0);

-- Medication request validation constraints
ALTER TABLE fhir_medication_request 
ADD CONSTRAINT chk_medication_request_authored_future 
CHECK (authored_on IS NULL OR authored_on <= CURRENT_TIMESTAMP + INTERVAL '1 day');

ALTER TABLE fhir_medication_request 
ADD CONSTRAINT chk_medication_request_dosage_period_logic 
CHECK (dosage_instruction_timing_bounds_period_end IS NULL OR dosage_instruction_timing_bounds_period_start IS NULL OR 
       dosage_instruction_timing_bounds_period_end >= dosage_instruction_timing_bounds_period_start);

ALTER TABLE fhir_medication_request 
ADD CONSTRAINT chk_medication_request_dose_positive 
CHECK (dosage_instruction_dose_quantity_value IS NULL OR dosage_instruction_dose_quantity_value > 0);

ALTER TABLE fhir_medication_request 
ADD CONSTRAINT chk_medication_request_medication_not_empty 
CHECK (medication_text IS NULL OR LENGTH(TRIM(medication_text)) > 0);

ALTER TABLE fhir_medication_request 
ADD CONSTRAINT chk_medication_request_requester_not_empty 
CHECK (requester_practitioner_display IS NULL OR LENGTH(TRIM(requester_practitioner_display)) > 0);

-- Medication administration validation constraints
ALTER TABLE fhir_medication_administration 
ADD CONSTRAINT chk_medication_admin_effective_future 
CHECK (effective_date_time IS NULL OR effective_date_time <= CURRENT_TIMESTAMP + INTERVAL '1 day');

ALTER TABLE fhir_medication_administration 
ADD CONSTRAINT chk_medication_admin_dose_positive 
CHECK (dosage_dose_value IS NULL OR dosage_dose_value > 0);

ALTER TABLE fhir_medication_administration 
ADD CONSTRAINT chk_medication_admin_medication_not_empty 
CHECK (medication_text IS NULL OR LENGTH(TRIM(medication_text)) > 0);

-- ========================================================================
-- ADDITIONAL JSONB VALIDATION CONSTRAINTS
-- ========================================================================

-- Validate that JSONB fields contain valid JSON when not null
ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_identifiers_valid_json 
CHECK (identifiers IS NULL OR jsonb_typeof(identifiers) = 'array');

ALTER TABLE fhir_patient 
ADD CONSTRAINT chk_patient_names_valid_json 
CHECK (names IS NULL OR jsonb_typeof(names) = 'array');

ALTER TABLE fhir_encounter 
ADD CONSTRAINT chk_encounter_class_valid_json 
CHECK (class IS NULL OR jsonb_typeof(class) = 'object');

ALTER TABLE fhir_condition 
ADD CONSTRAINT chk_condition_code_valid_json 
CHECK (code IS NULL OR jsonb_typeof(code) = 'object');

ALTER TABLE fhir_procedure 
ADD CONSTRAINT chk_procedure_code_valid_json 
CHECK (code IS NULL OR jsonb_typeof(code) = 'object');

ALTER TABLE fhir_observation 
ADD CONSTRAINT chk_observation_code_valid_json 
CHECK (code IS NULL OR jsonb_typeof(code) = 'object');

ALTER TABLE fhir_medication_request 
ADD CONSTRAINT chk_med_request_medication_valid_json 
CHECK (medication_x IS NULL OR jsonb_typeof(medication_x) = 'object');

-- ========================================================================
-- COMMENTS ON TABLES AND COLUMNS
-- ========================================================================

COMMENT ON TABLE fhir_patient IS 'FHIR Patient resource (DMPatient profile) - Profil Patient du socle commun des EDS. Demographics and other administrative information about an individual receiving care or other health-related services';
COMMENT ON COLUMN fhir_patient.ins_nir_identifier IS 'INS-NIR - The patient national health identifier obtained from INSi teleservice (Identifiant national de santé)';
COMMENT ON COLUMN fhir_patient.nss_identifier IS 'NSS - Numéro de Sécurité Sociale (Social Security Number)';
COMMENT ON COLUMN fhir_patient.active IS 'Whether this patient record is in active use. Many systems use this property to mark as non-current patients, such as those that have not been seen for a period of time based on an organization business rule';
COMMENT ON COLUMN fhir_patient.gender IS 'Administrative Gender - the gender that the patient is considered to have for administration and record keeping purposes';
COMMENT ON COLUMN fhir_patient.birth_date IS 'The date of birth for the individual';

COMMENT ON TABLE fhir_encounter IS 'FHIR Encounter resource (DMEncounter profile) - An interaction between a patient and healthcare provider(s) for the purpose of providing healthcare service(s) or assessing the health status of a patient';
COMMENT ON COLUMN fhir_encounter.subject_patient_id IS 'Required reference to DMPatient - The patient present at the encounter';
COMMENT ON COLUMN fhir_encounter.status IS 'planned | arrived | triaged | in-progress | onleave | finished | cancelled | entered-in-error | unknown';

COMMENT ON TABLE fhir_condition IS 'FHIR Condition resource (DMCondition profile) - A clinical condition, problem, diagnosis, or other event, situation, issue, or clinical concept that has risen to a level of concern';
COMMENT ON COLUMN fhir_condition.code IS 'Identification of the condition, problem or diagnosis using CIM-10 value set (extensible)';
COMMENT ON COLUMN fhir_condition.clinical_status IS 'The clinical status of the condition - active | recurrence | relapse | inactive | remission | resolved';

COMMENT ON TABLE fhir_procedure IS 'FHIR Procedure resource (DMProcedure profile) - An action that is or was performed on or for a patient. This can be a physical intervention like an operation, or less invasive like long term services, counseling, or hypnotherapy';
COMMENT ON COLUMN fhir_procedure.code IS 'The specific procedure that was performed using CCAM or other standard classifications';
COMMENT ON COLUMN fhir_procedure.status IS 'A code specifying the state of the procedure - preparation | in-progress | not-done | on-hold | stopped | completed | entered-in-error | unknown';

COMMENT ON TABLE fhir_observation IS 'FHIR Observation resource - Measurements and simple assertions made about a patient, device or other subject. Generic table for all DM observation profiles (laboratory, vital signs, lifestyle)';
COMMENT ON COLUMN fhir_observation.status IS 'The status of the result value - registered | preliminary | final | amended | corrected | cancelled | entered-in-error | unknown';
COMMENT ON COLUMN fhir_observation.code IS 'Describes what was observed using LOINC codes. Sometimes this is called the observation "name"';

COMMENT ON TABLE fhir_medication_request IS 'FHIR MedicationRequest resource (DMMedicationRequest profile) - An order or request for both supply of the medication and the instructions for administration of the medication to a patient';
COMMENT ON COLUMN fhir_medication_request.status IS 'A code specifying the current state of the order - active | on-hold | cancelled | completed | entered-in-error | stopped | draft | unknown';
COMMENT ON COLUMN fhir_medication_request.intent IS 'Whether the request is a proposal, plan, or an original order - proposal | plan | order | original-order | reflex-order | filler-order | instance-order | option';

COMMENT ON TABLE fhir_medication_administration IS 'FHIR MedicationAdministration resource (DMMedicationAdministration profile) - Describes the event of a patient consuming or otherwise being administered a medication';
COMMENT ON COLUMN fhir_medication_administration.status IS 'Will generally be set to show that the administration has been completed - in-progress | not-done | on-hold | completed | entered-in-error | stopped | unknown';

-- Additional comprehensive column comments
COMMENT ON COLUMN fhir_patient.identifiers IS 'Business identifiers for this patient (0..*) - Array of Identifier objects';
COMMENT ON COLUMN fhir_patient.names IS 'A name associated with the patient (0..*) - Array of HumanName objects';
COMMENT ON COLUMN fhir_patient.telecoms IS 'Contact details for the individual (phone, email, fax, etc.) - FHIR telecom ContactPoint (0..*)';
COMMENT ON COLUMN fhir_patient.address IS 'Physical addresses for the individual (home, work, temporary, etc.) - FHIR Address (0..*)';
COMMENT ON COLUMN fhir_patient.marital_status IS 'Patient marital (civil) status - CodeableConcept with French coding system';
COMMENT ON COLUMN fhir_patient.contacts IS 'Emergency contacts and guardians for the patient - FHIR contact BackboneElement (0..*)';
COMMENT ON COLUMN fhir_patient.communications IS 'Languages the patient can communicate in - FHIR communication BackboneElement (0..*)';
COMMENT ON COLUMN fhir_patient.general_practitioners IS 'Patient nominated primary care provider(s) - FHIR generalPractitioner Reference (0..*)';
COMMENT ON COLUMN fhir_patient.managing_organization IS 'Organization that is the custodian of the patient record - FHIR managingOrganization Reference (0..1)';
COMMENT ON COLUMN fhir_patient.links IS 'Link to another patient resource that concerns the same actual person - used for patient deduplication';

COMMENT ON COLUMN fhir_encounter.participants IS 'List of people involved in the encounter - FHIR participant BackboneElement (0..*)';
COMMENT ON COLUMN fhir_encounter.period_start IS 'Start time of the encounter - FHIR period.start';
COMMENT ON COLUMN fhir_encounter.period_end IS 'End time of the encounter - FHIR period.end';
COMMENT ON COLUMN fhir_encounter.length IS 'Quantity of time the encounter lasted (excludes time for leaves of absence) - FHIR length Duration';
COMMENT ON COLUMN fhir_encounter.reason_codes IS 'Coded reason the encounter takes place - FHIR reasonCode CodeableConcept (0..*)';
COMMENT ON COLUMN fhir_encounter.diagnoses IS 'List of diagnoses relevant to encounter - FHIR diagnosis BackboneElement (0..*)';
COMMENT ON COLUMN fhir_encounter.hospitalization IS 'Details about admission to healthcare facility - FHIR hospitalization BackboneElement (0..1)';
COMMENT ON COLUMN fhir_encounter.locations IS 'List of locations where patient was during encounter - FHIR location BackboneElement (0..*)';

COMMENT ON COLUMN fhir_condition.onset_x IS 'Estimated or actual date, date-time, or age when condition began - FHIR onset[x] (0..1)';
COMMENT ON COLUMN fhir_condition.abatement_x IS 'Date or estimated date condition resolved or went into remission - FHIR abatement[x] (0..1)';
COMMENT ON COLUMN fhir_condition.stages IS 'Stage/grade of condition - FHIR stage BackboneElement (0..*)';
COMMENT ON COLUMN fhir_condition.evidences IS 'Supporting evidence for condition - FHIR evidence BackboneElement (0..*)';
COMMENT ON COLUMN fhir_condition.notes IS 'Additional information about the condition - FHIR note Annotation (0..*)';

COMMENT ON COLUMN fhir_observation.effective_date_time IS 'Clinically relevant time/time-period for observation - FHIR effective[x]';
COMMENT ON COLUMN fhir_observation.value_quantity_value IS 'Actual result value - FHIR value[x] as Quantity.value';
COMMENT ON COLUMN fhir_observation.value_quantity_unit IS 'Unit of measurement for observation value - FHIR value[x] as Quantity.unit';
COMMENT ON COLUMN fhir_observation.reference_ranges IS 'Provides guide for interpretation - FHIR referenceRange BackboneElement (0..*)';
COMMENT ON COLUMN fhir_observation.components IS 'Component results for complex observations - FHIR component BackboneElement (0..*)';
COMMENT ON COLUMN fhir_observation.performers IS 'Who is responsible for observation - FHIR performer Reference (0..*)';

COMMENT ON COLUMN fhir_medication_request.medication_x IS 'Medication to be taken - FHIR medication[x] (1..1) - either CodeableConcept or Reference(Medication)';
COMMENT ON COLUMN fhir_medication_request.dosage_instructions IS 'How medication should be taken - FHIR dosageInstruction Dosage (0..*)';
COMMENT ON COLUMN fhir_medication_request.requester IS 'Who/what requested the medication - FHIR requester Reference (0..1)';
COMMENT ON COLUMN fhir_medication_request.reason_codes IS 'Reason or indication for ordering medication - FHIR reasonCode CodeableConcept (0..*)';
COMMENT ON COLUMN fhir_medication_request.authored_on IS 'When request was initially authored - FHIR authoredOn dateTime (0..1)';

--COMMENT ON TABLE fhir_claim IS 'FHIR Claim resource - Generic table for PMSI billing data (DMClaimPMSI, DMClaimPMSIMCO, DMClaimRUM profiles)';
--COMMENT ON COLUMN fhir_claim.claim_profile IS 'Claim profile type: pmsi, pmsi_mco, rum';

-- ========================================================================
-- POSTGRESQL 17.x SPECIFIC OPTIMIZATIONS AND RECOMMENDATIONS
-- ========================================================================

-- Set optimal maintenance settings for FHIR data (apply at database level)
-- These settings are recommended for optimal performance:

/*
-- Memory configuration for large FHIR datasets
SET shared_buffers = '4GB';
SET work_mem = '256MB';
SET maintenance_work_mem = '1GB';
SET effective_cache_size = '12GB'; -- Adjust based on system memory

-- PostgreSQL 17.x specific optimizations
SET random_page_cost = 1.1; -- For SSD storage
SET seq_page_cost = 1.0;
SET cpu_tuple_cost = 0.01;
SET cpu_index_tuple_cost = 0.005;
SET cpu_operator_cost = 0.0025;

-- Parallel query settings for FHIR aggregations
SET max_parallel_workers_per_gather = 4;
SET parallel_tuple_cost = 0.1;
SET parallel_setup_cost = 1000;
SET max_parallel_maintenance_workers = 4;

-- JSONB specific optimizations
SET gin_fuzzy_search_limit = 0;
SET gin_pending_list_limit = '32MB';

-- WAL configuration for high write workloads
SET wal_buffers = '64MB';
SET checkpoint_completion_target = 0.9;
SET checkpoint_segments = 64;

-- Connection and resource limits
SET max_connections = 200;
SET shared_preload_libraries = 'pg_stat_statements';
*/

-- ========================================================================
-- PERFORMANCE MONITORING QUERIES FOR FHIR SEMANTIC LAYER
-- ========================================================================

-- Monitor JSONB index usage
/*
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename LIKE 'fhir_%' AND indexname LIKE '%gin%'
ORDER BY idx_scan DESC;
*/

-- Monitor table statistics for FHIR resources
/*
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del, n_live_tup, n_dead_tup
FROM pg_stat_user_tables
WHERE tablename LIKE 'fhir_%'
ORDER BY n_live_tup DESC;
*/

-- Monitor slow queries related to FHIR resources
/*
SELECT query, mean_time, calls, total_time, rows
FROM pg_stat_statements
WHERE query LIKE '%fhir_%'
ORDER BY mean_time DESC
LIMIT 10;
*/

-- ========================================================================
-- MAINTENANCE RECOMMENDATIONS
-- ========================================================================

-- Regular maintenance tasks for optimal FHIR performance:

-- 1. Daily VACUUM ANALYZE for high-write tables
/*
VACUUM ANALYZE fhir_patient;
VACUUM ANALYZE fhir_encounter;
VACUUM ANALYZE fhir_observation;
VACUUM ANALYZE fhir_medication_request;
VACUUM ANALYZE fhir_medication_administration;
*/

-- 2. Weekly REINDEX for GIN indexes on JSONB fields
/*
REINDEX INDEX CONCURRENTLY idx_patient_identifiers;
REINDEX INDEX CONCURRENTLY idx_encounter_class;
REINDEX INDEX CONCURRENTLY idx_condition_code;
REINDEX INDEX CONCURRENTLY idx_procedure_code;
REINDEX INDEX CONCURRENTLY idx_observation_code;
*/

-- 3. Monthly statistics update
/*
ANALYZE;
UPDATE pg_stat_statements SET calls = 0, total_time = 0;
*/

-- 4. Partitioning recommendations for large datasets (> 10M records):
-- Consider partitioning by:
-- - fhir_encounter: by period_start (monthly or quarterly)
-- - fhir_observation: by effective_date_time (monthly)
-- - fhir_medication_administration: by effective_date_time (monthly)

-- ========================================================================
-- FHIR SEMANTIC LAYER OPTIMIZATION COMPLETED
-- 
-- This optimized FHIR Semantic Layer database provides:
-- 1. PostgreSQL 17.x specific performance optimizations
-- 2. Comprehensive indexing strategy for FHIR resources and JSONB data
-- 3. Hash indexes for exact identifier lookups
-- 4. Full-text search capabilities for French healthcare data
-- 5. Spatial indexes for geographic patient data
-- 6. Comprehensive data validation and referential integrity
-- 7. French healthcare compliance (INS-NIR, CIM-10, CCAM, ATC)
-- 8. JSONB validation constraints
-- 9. Temporal range indexes for efficient date-based queries
-- 10. Covering indexes with INCLUDE columns for query optimization
-- 11. Proper foreign key cascading and constraint naming
-- 12. Performance monitoring and maintenance recommendations
-- 13. FHIR-specific business logic validation
-- 14. Audit trail capabilities with created_at/updated_at
-- 15. Extensibility for future FHIR profiles and resources
-- 
-- Key PostgreSQL 17.x Features Utilized:
-- - CONCURRENTLY index creation for minimal downtime
-- - GiST indexes for spatial and temporal data
-- - Hash indexes for exact equality lookups
-- - Advanced JSONB indexing and validation
-- - French language full-text search configuration
-- - Temporal range queries with tstzrange
-- - Advanced constraint validation with regex patterns
-- ========================================================================