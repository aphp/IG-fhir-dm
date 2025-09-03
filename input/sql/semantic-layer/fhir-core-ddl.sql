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
-- manque une extension pour les codes géographique PMSI
-- manque une extension pour la source du décès
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
DROP TABLE IF EXISTS fhir_claim CASCADE;
DROP TABLE IF EXISTS fhir_medication_administration CASCADE;
DROP TABLE IF EXISTS fhir_medication_request CASCADE;
DROP TABLE IF EXISTS fhir_observation CASCADE;
DROP TABLE IF EXISTS fhir_procedure CASCADE;
DROP TABLE IF EXISTS fhir_condition CASCADE;
DROP TABLE IF EXISTS fhir_encounter CASCADE;
DROP TABLE IF EXISTS fhir_episode_of_care CASCADE;
DROP TABLE IF EXISTS fhir_practitioner_role CASCADE;
DROP TABLE IF EXISTS fhir_practitioner CASCADE;
DROP TABLE IF EXISTS fhir_location CASCADE;
DROP TABLE IF EXISTS fhir_organization CASCADE;
DROP TABLE IF EXISTS fhir_patient CASCADE;

-- ========================================================================
-- CORE FHIR RESOURCE TABLES
-- ========================================================================

-- Table: fhir_patient (DMPatient profile)
-- French Patient profile with INS-NIR identifiers
CREATE TABLE fhir_patient (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Patient core elements
    active BOOLEAN, -- je me dis qu'il vaut mieux éviter les valeurs par défaut sur des modifiers
    
    -- Identifiers (multiple allowed)
    identifiers JSONB, -- Array of Identifier objects
--    nss_identifier VARCHAR(50), -- NSS (Numéro de Sécurité Sociale) --cet identifier est problématique en terme d'expression de besoin
    ins_nir_identifier VARCHAR(15), -- INS-NIR official identifier
    
    -- Names (multiple allowed)
    names JSONB, -- Array of HumanName objects
    full_names VARCHAR(255)[][],  -- Le premier array correspond au nombre de HumanName, le second au nombre maximum de givenNames (-1). Dans chaque sous arret, le premier terme est le familyName et les termes d'après sont les givenName. 
    
    -- Demographics
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'unknown')),
    birth_date DATE,
    deceased_x JSONB,
    deceased_date_time TIMESTAMP WITH TIME ZONE,
    deceased_source VARCHAR(10) CHECK (deceased_source IN ('insee', 'cepidc', 'sih')), -- il faut une extension ad hoc
    marital_status VARCHAR(4) CHECK (marital_status IN ('PACS', 'A', 'D', 'I', 'L', 'M', 'C', 'P', 'T', 'U', 'S', 'W', 'UNK')),

    -- Addresses (multiple allowed)
    addresses JSONB, -- Array of Address objects
    address_extension_geolocation_latitude FLOAT,
    address_extension_geolocation_longitude FLOAT,
    address_extension_census_tract VARCHAR(255), -- concaténation du code et du libellé de l'iris dans l'extension (http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-censusTract)
    address_period_start DATE, --pour la date de recueil des informations d'addresse. C’est impropre, mais on peut espérer que le patient habite bien là ou il dit habiter au moment ou il dit qu’il y habite. 
    address_extension_code_geo_pmsi JSONB, -- il faut une extension ad hoc
    address_extension_code_geo_pmsi_code VARCHAR(5),
    address_extension_code_geo_pmsi_display VARCHAR(255),

    -- Contact information  -- j'aurais bien fait comme pour les name, mais il n'y a rien qui indique la prééminence de certain contactpoint...
    telecoms JSONB, -- Array of ContactPoint objects
    contacts JSONB,
    communications JSONB,
    preferred_communication_languages VARCHAR(255)[], -- array des language.text where language.preferred = true
    
    -- Multiple birth
    multiple_birth_x JSONB,
    multiple_birth_integer INTEGER,
    
    -- inscription dans le parcours de soins
    general_practitioners JSONB,
    managing_organization JSONB,

    -- identitovigilance
    links JSONB,

    -- French Core extensions
--    birth_place VARCHAR(255), je vois pas l'intérêt (identitovigilance seulement), on peut le laisser dans le jsonb extension
--    nationality VARCHAR(10), pas d'intérêt pour le soin, on peut le laisser dans le jsonb extension
    
    -- FHIR metadata
    meta JSONB,
    implicit_rules VARCHAR(255),
    resource_language VARCHAR(10), -- confusant avec le language de communication
    text_div TEXT,
    contained JSONB,
    extensions JSONB,
    modifier_extensions JSONB,  -- je suis plutôt pour que ces extensions soient dejsonifié, mais pour l'heure on n'en a pas.
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

    -- manque photo
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
CREATE TABLE fhir_encounter (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Encounter core elements
    status VARCHAR(20) CHECK (status IN ('planned', 'arrived', 'triaged', 'in-progress', 'onleave', 'finished', 'cancelled', 'entered-in-error', 'unknown')),
    status_history JSONB, -- Array of Encounter.statusHistory
    class JSONB, -- Coding (encounter class)
    class_display VARCHAR(255),
    class_history JSONB, -- Array of Encounter.classHistory
    types JSONB, -- CodeableConcept
    service_type JSONB, -- CodeableConcept
    priority JSONB, -- CodeableConcept
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Patient reference (required)
    subject JSONB,
    subject_patient_id VARCHAR(64) NOT NULL,
    
    -- Episode of care
    episodes_of_care JSONB, -- Array of Reference(EpisodeOfCare)
    
    -- Based on appointments
    based_on_s JSONB, -- Array of Reference(Appointment | ServiceRequest)
    
    -- Participants
    participants JSONB, -- Array of Encounter.participant
    
    -- Appointments
    appointments JSONB, -- Array of Reference(Appointment)
    
    -- Period
    period_start TIMESTAMP WITH TIME ZONE,
    period_end TIMESTAMP WITH TIME ZONE,
    
    -- Length of stay
    length JSONB, 
    length_number_of_day INTEGER,
    
    -- Reason codes
    reason_codes JSONB, -- Array of CodeableConcept
    reason_references JSONB, -- Array of Reference
    
    -- Diagnoses
    diagnoses JSONB, -- Array of Encounter.diagnosis
    
    -- Account
    account JSONB, -- Array of Reference(Account)
    
    -- Hospitalization details
    hospitalization JSONB, -- Encounter.hospitalization object
--    pre_admission_identifier VARCHAR(50),  pas formalisé à ce stade 
--    origin_location_id VARCHAR(64), pas formalisé à ce stade
    admit_source_text VARCHAR(255) CHECK (status IN ('Mutation', 'Transfert définitif', 'Transfert provisoire', 'Domicile', 'Naissance', ' Patient entré décédé pour prélèvement d''organes')),
    discharge_disposition_text VARCHAR(255) CHECK (status IN ('Mutation', 'Transfert définitif', 'Transfert provisoire', 'Domicile', 'Décès')),

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
CREATE TABLE fhir_condition (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Condition core elements
    clinical_status JSONB, -- CodeableConcept
    clinical_status_text VARCHAR(255), 
    verification_status JSONB, -- CodeableConcept
    verification_status_text VARCHAR(255),
    categories JSONB, -- Array of CodeableConcept
    categories_text VARCHAR(255)[], -- préciser qu'il s'agit de diag codés dans le cadre du PMSI
    severity JSONB, -- CodeableConcept
    code JSONB, -- CodeableConcept (CIM-10)
    code_text VARCHAR(255),
    body_sites JSONB, -- Array of CodeableConcept
    
    -- Identifiers
    identifiers JSONB, -- Array of Identifier objects
    
    -- Patient reference (required)
    subject JSONB NOT NULL,
    subject_patient_id VARCHAR(64) NOT NULL,
    
    -- Encounter reference
    encounter JSONB,
    encounter_id VARCHAR(64),
    
    -- Onset and abatement - on simplifie
    onset_x JSONB,
    abatement_x JSONB,
    
    -- Recording information
    recorded_date DATE,
    recorder JSONB,
    asserter JSONB,
    
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
    performed_date_time DATETIME, -- date de réalisation de l'acte, dispo dans le pmsi et plus intéressante que la date du recueil, seule demandée dans le socle.
    
    -- Recorder and asserter
    recorder JSONB,
    asserter JSONB,
    
    -- Performers
    performers JSONB, -- Array of Procedure.performer
    performer_actor_practitioner_text VARCHAR(255)[],
    
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
CREATE TABLE fhir_observation (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR Observation core elements
    status VARCHAR(20) CHECK (status IN ('registered', 'preliminary', 'final', 'amended', 'corrected', 'cancelled', 'entered-in-error', 'unknown')), -- prévoir un mapping de statut de validation vers ce status.
    categories JSONB, -- Array of CodeableConcept (laboratory, vital-signs, etc.)
    categories_text VARCHAR(255)[],
    code JSONB, -- CodeableConcept (LOINC codes)
    code_text VARCHAR(255),
    
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
    reference_ranges_value FLOAT[2][], --même unité que la value, le premier sub-array pour referenceRange.low.value, le second pour referenceRange.high.value
    
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
    
    FOREIGN KEY (subject_id) REFERENCES fhir_patient(id),
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
    reference_ranges_value FLOAT[2][], --même unité que la value, le premier sub-array pour referenceRange.low.value, le second pour referenceRange.high.value

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (observation_id) REFERENCES fhir_observation(id)
);


-- Table: fhir_medication_request (DMMedicationRequest profile)
-- Medication prescriptions
CREATE TABLE fhir_medication_request (
    id VARCHAR(64) PRIMARY KEY,
--    version_id VARCHAR(64), ça me semble pas nécessaire à sortir du meta
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- FHIR MedicationRequest core elements
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'on-hold', 'cancelled', 'completed', 'entered-in-error', 'stopped', 'draft', 'unknown')),
    status_reason JSONB, -- CodeableConcept
    intent VARCHAR(20) NOT NULL CHECK (intent IN ('proposal', 'plan', 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order', 'option')),
    categories JSONB, -- Array of CodeableConcept
    priority VARCHAR(20) CHECK (priority IN ('routine', 'urgent', 'asap', 'stat')),
    do_not_perform BOOLEAN,
    
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
    dosage_instruction_timing_bounds_period_start DATETIME, 
    dosage_instruction_timing_bounds_period_end DATETIME, 
    
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
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- je n'ai pas regardé en dessous
-- ========================================================================

-- Patient indexes
CREATE INDEX idx_patient_identifiers ON fhir_patient USING GIN (identifiers);
CREATE INDEX idx_patient_nss ON fhir_patient(nss_identifier) WHERE nss_identifier IS NOT NULL;
CREATE INDEX idx_patient_ins_nir ON fhir_patient(ins_nir_identifier) WHERE ins_nir_identifier IS NOT NULL;
CREATE INDEX idx_patient_family_name ON fhir_patient(family_name);
CREATE INDEX idx_patient_birth_date ON fhir_patient(birth_date);
CREATE INDEX idx_patient_gender ON fhir_patient(gender);
CREATE INDEX idx_patient_active ON fhir_patient(active);

-- Organization indexes
CREATE INDEX idx_organization_identifiers ON fhir_organization USING GIN (identifiers);
CREATE INDEX idx_organization_name ON fhir_organization(name);
CREATE INDEX idx_organization_active ON fhir_organization(active);
CREATE INDEX idx_organization_part_of ON fhir_organization(part_of_organization_id);

-- Location indexes
CREATE INDEX idx_location_managing_org ON fhir_location(managing_organization_id);
CREATE INDEX idx_location_part_of ON fhir_location(part_of_location_id);
CREATE INDEX idx_location_status ON fhir_location(status);
CREATE INDEX idx_location_coordinates ON fhir_location(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Practitioner indexes
CREATE INDEX idx_practitioner_identifiers ON fhir_practitioner USING GIN (identifiers);
CREATE INDEX idx_practitioner_family_name ON fhir_practitioner(family_name);
CREATE INDEX idx_practitioner_active ON fhir_practitioner(active);

-- PractitionerRole indexes
CREATE INDEX idx_practitioner_role_practitioner ON fhir_practitioner_role(practitioner_id);
CREATE INDEX idx_practitioner_role_organization ON fhir_practitioner_role(organization_id);
CREATE INDEX idx_practitioner_role_active ON fhir_practitioner_role(active);

-- EpisodeOfCare indexes
CREATE INDEX idx_episode_patient ON fhir_episode_of_care(patient_id);
CREATE INDEX idx_episode_managing_org ON fhir_episode_of_care(managing_organization_id);
CREATE INDEX idx_episode_status ON fhir_episode_of_care(status);
CREATE INDEX idx_episode_period ON fhir_episode_of_care(period_start, period_end);

-- Encounter indexes
CREATE INDEX idx_encounter_patient ON fhir_encounter(patient_id);
CREATE INDEX idx_encounter_episode ON fhir_encounter USING GIN (episode_of_care_ids);
CREATE INDEX idx_encounter_service_provider ON fhir_encounter(service_provider_id);
CREATE INDEX idx_encounter_part_of ON fhir_encounter(part_of_encounter_id);
CREATE INDEX idx_encounter_status ON fhir_encounter(status);
CREATE INDEX idx_encounter_period ON fhir_encounter(period_start, period_end);
CREATE INDEX idx_encounter_class ON fhir_encounter USING GIN (class);

-- Condition indexes
CREATE INDEX idx_condition_patient ON fhir_condition(subject_patient_id);
CREATE INDEX idx_condition_encounter ON fhir_condition(encounter_id);
CREATE INDEX idx_condition_code ON fhir_condition USING GIN (code);
CREATE INDEX idx_condition_clinical_status ON fhir_condition USING GIN (clinical_status);
CREATE INDEX idx_condition_recorded_date ON fhir_condition(recorded_date);

-- Procedure indexes
CREATE INDEX idx_procedure_patient ON fhir_procedure(subject_patient_id);
CREATE INDEX idx_procedure_encounter ON fhir_procedure(encounter_id);
CREATE INDEX idx_procedure_code ON fhir_procedure USING GIN (code);
CREATE INDEX idx_procedure_status ON fhir_procedure(status);
CREATE INDEX idx_procedure_performed ON fhir_procedure(performed_date_time);

-- Observation indexes
CREATE INDEX idx_observation_patient ON fhir_observation(subject_patient_id);
CREATE INDEX idx_observation_encounter ON fhir_observation(encounter_id);
CREATE INDEX idx_observation_code ON fhir_observation USING GIN (code);
CREATE INDEX idx_observation_categories ON fhir_observation USING GIN (categories);
CREATE INDEX idx_observation_status ON fhir_observation(status);
CREATE INDEX idx_observation_effective ON fhir_observation(effective_date_time);
CREATE INDEX idx_observation_profile ON fhir_observation(observation_profile);
CREATE INDEX idx_observation_lab_type ON fhir_observation(laboratory_type) WHERE laboratory_type IS NOT NULL;
CREATE INDEX idx_observation_vital_type ON fhir_observation(vital_sign_type) WHERE vital_sign_type IS NOT NULL;
CREATE INDEX idx_observation_lifestyle_type ON fhir_observation(lifestyle_type) WHERE lifestyle_type IS NOT NULL;

-- MedicationRequest indexes
CREATE INDEX idx_med_request_patient ON fhir_medication_request(subject_patient_id);
CREATE INDEX idx_med_request_encounter ON fhir_medication_request(encounter_id);
CREATE INDEX idx_med_request_requester ON fhir_medication_request(requester_id);
CREATE INDEX idx_med_request_status ON fhir_medication_request(status);
CREATE INDEX idx_med_request_intent ON fhir_medication_request(intent);
CREATE INDEX idx_med_request_authored ON fhir_medication_request(authored_on);
CREATE INDEX idx_med_request_medication_cc ON fhir_medication_request USING GIN (medication_codeable_concept);

-- MedicationAdministration indexes
CREATE INDEX idx_med_admin_patient ON fhir_medication_administration(subject_patient_id);
CREATE INDEX idx_med_admin_encounter ON fhir_medication_administration(context_encounter_id);
CREATE INDEX idx_med_admin_episode ON fhir_medication_administration(context_episode_id);
CREATE INDEX idx_med_admin_request ON fhir_medication_administration(request_id);
CREATE INDEX idx_med_admin_status ON fhir_medication_administration(status);
CREATE INDEX idx_med_admin_effective ON fhir_medication_administration(effective_date_time);

-- Claim indexes
CREATE INDEX idx_claim_patient ON fhir_claim(patient_id);
CREATE INDEX idx_claim_provider ON fhir_claim(provider_id);
CREATE INDEX idx_claim_insurer ON fhir_claim(insurer_id);
CREATE INDEX idx_claim_facility ON fhir_claim(facility_id);
CREATE INDEX idx_claim_status ON fhir_claim(status);
CREATE INDEX idx_claim_created ON fhir_claim(created);
CREATE INDEX idx_claim_profile ON fhir_claim(claim_profile);

-- ========================================================================
-- PL/PGSQL VALIDATION FUNCTIONS FOR PROFILE CONSTRAINTS
-- ========================================================================

-- Function: Validate DMPatient profile constraints
CREATE OR REPLACE FUNCTION validate_dm_patient() RETURNS TRIGGER AS $$
BEGIN
    -- Validate INS-NIR identifier format (13 digits)
    IF NEW.ins_nir_identifier IS NOT NULL AND NEW.ins_nir_identifier !~ '^[0-9]{13}$' THEN
        RAISE EXCEPTION 'INS-NIR identifier must be 13 digits: %', NEW.ins_nir_identifier;
    END IF;
    
    -- Validate gender values according to French Core requirements
    IF NEW.gender IS NOT NULL AND NEW.gender NOT IN ('male', 'female', 'unknown') THEN
        RAISE EXCEPTION 'Invalid gender value for DMPatient: %', NEW.gender;
    END IF;
    
    -- Validate birth date is not in the future
    IF NEW.birth_date IS NOT NULL AND NEW.birth_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Birth date cannot be in the future: %', NEW.birth_date;
    END IF;
    
    -- Validate deceased constraints
    IF NEW.deceased_boolean IS TRUE AND NEW.deceased_date_time IS NULL THEN
        RAISE WARNING 'Patient marked as deceased but no death date provided';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate DMEncounter profile constraints
CREATE OR REPLACE FUNCTION validate_dm_encounter() RETURNS TRIGGER AS $$
BEGIN
    -- Validate patient reference exists
    IF NEW.patient_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM fhir_patient WHERE id = NEW.patient_id) THEN
        RAISE EXCEPTION 'Referenced patient does not exist: %', NEW.patient_id;
    END IF;
    
    -- Validate period consistency
    IF NEW.period_start IS NOT NULL AND NEW.period_end IS NOT NULL AND NEW.period_start > NEW.period_end THEN
        RAISE EXCEPTION 'Encounter start time cannot be after end time';
    END IF;
    
    -- Validate status transitions
    IF TG_OP = 'UPDATE' AND OLD.status = 'finished' AND NEW.status != 'finished' THEN
        RAISE EXCEPTION 'Cannot change status of finished encounter';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate DMCondition profile constraints (CIM-10)
CREATE OR REPLACE FUNCTION validate_dm_condition() RETURNS TRIGGER AS $$
BEGIN
    -- Validate patient reference exists
    IF NEW.subject_patient_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM fhir_patient WHERE id = NEW.subject_patient_id) THEN
        RAISE EXCEPTION 'Referenced patient does not exist: %', NEW.subject_patient_id;
    END IF;
    
    -- Validate encounter reference if provided
    IF NEW.encounter_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM fhir_encounter WHERE id = NEW.encounter_id) THEN
        RAISE EXCEPTION 'Referenced encounter does not exist: %', NEW.encounter_id;
    END IF;
    
    -- Validate onset/abatement consistency
    IF NEW.onset_date_time IS NOT NULL AND NEW.abatement_date_time IS NOT NULL 
       AND NEW.onset_date_time > NEW.abatement_date_time THEN
        RAISE EXCEPTION 'Condition onset cannot be after abatement';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate DMObservationLaboratory profile constraints
CREATE OR REPLACE FUNCTION validate_dm_observation_laboratory() RETURNS TRIGGER AS $$
BEGIN
    -- Validate laboratory observations have required category
    IF NEW.observation_profile = 'laboratory' THEN
        IF NEW.categories IS NULL OR NOT (NEW.categories::text LIKE '%"laboratory"%') THEN
            RAISE EXCEPTION 'Laboratory observations must have laboratory category';
        END IF;
    END IF;
    
    -- Validate LOINC codes for laboratory observations
    IF NEW.observation_profile = 'laboratory' AND NEW.code IS NOT NULL THEN
        IF NOT (NEW.code::text LIKE '%"http://loinc.org"%') THEN
            RAISE EXCEPTION 'Laboratory observations should use LOINC codes';
        END IF;
    END IF;
    
    -- Validate value constraints
    IF NEW.observation_profile = 'laboratory' AND NEW.status = 'final' THEN
        IF NEW.value_quantity IS NULL AND NEW.value_codeable_concept IS NULL 
           AND NEW.value_string IS NULL AND NEW.data_absent_reason IS NULL THEN
            RAISE EXCEPTION 'Final laboratory observations must have a value or data absent reason';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate DMObservationVitalSigns profile constraints
CREATE OR REPLACE FUNCTION validate_dm_observation_vital_signs() RETURNS TRIGGER AS $$
BEGIN
    -- Validate vital signs have required category
    IF NEW.observation_profile = 'vital-signs' THEN
        IF NEW.categories IS NULL OR NOT (NEW.categories::text LIKE '%"vital-signs"%') THEN
            RAISE EXCEPTION 'Vital sign observations must have vital-signs category';
        END IF;
    END IF;
    
    -- Validate specific vital sign ranges
    IF NEW.vital_sign_type = 'body_weight' AND NEW.value_quantity IS NOT NULL THEN
        DECLARE
            weight_value DECIMAL;
        BEGIN
            weight_value := (NEW.value_quantity->>'value')::DECIMAL;
            IF weight_value <= 0 OR weight_value > 1000 THEN
                RAISE EXCEPTION 'Body weight must be between 0 and 1000 kg: %', weight_value;
            END IF;
        END;
    END IF;
    
    IF NEW.vital_sign_type = 'body_height' AND NEW.value_quantity IS NOT NULL THEN
        DECLARE
            height_value DECIMAL;
        BEGIN
            height_value := (NEW.value_quantity->>'value')::DECIMAL;
            IF height_value <= 0 OR height_value > 300 THEN
                RAISE EXCEPTION 'Body height must be between 0 and 300 cm: %', height_value;
            END IF;
        END;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate DMMedicationRequest profile constraints
CREATE OR REPLACE FUNCTION validate_dm_medication_request() RETURNS TRIGGER AS $$
BEGIN
    -- Validate patient reference exists
    IF NEW.subject_patient_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM fhir_patient WHERE id = NEW.subject_patient_id) THEN
        RAISE EXCEPTION 'Referenced patient does not exist: %', NEW.subject_patient_id;
    END IF;
    
    -- Validate medication is specified
    IF NEW.medication_codeable_concept IS NULL AND NEW.medication_reference_id IS NULL THEN
        RAISE EXCEPTION 'Medication must be specified either as CodeableConcept or Reference';
    END IF;
    
    -- Validate status and intent combination
    IF NEW.status = 'active' AND NEW.intent NOT IN ('order', 'original-order', 'plan') THEN
        RAISE EXCEPTION 'Active medication requests must have appropriate intent';
    END IF;
    
    -- Validate dosage instructions for active prescriptions
    IF NEW.status = 'active' AND (NEW.dosage_instructions IS NULL OR NEW.dosage_instructions = '[]'::jsonb) THEN
        RAISE WARNING 'Active medication request should have dosage instructions';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate DMProcedure profile constraints
CREATE OR REPLACE FUNCTION validate_dm_procedure() RETURNS TRIGGER AS $$
BEGIN
    -- Validate patient reference exists
    IF NEW.subject_patient_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM fhir_patient WHERE id = NEW.subject_patient_id) THEN
        RAISE EXCEPTION 'Referenced patient does not exist: %', NEW.subject_patient_id;
    END IF;
    
    -- Validate encounter reference if provided
    IF NEW.encounter_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM fhir_encounter WHERE id = NEW.encounter_id) THEN
        RAISE EXCEPTION 'Referenced encounter does not exist: %', NEW.encounter_id;
    END IF;
    
    -- Validate performed timing
    IF NEW.performed_date_time IS NOT NULL AND NEW.performed_date_time > CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Procedure performed time cannot be in the future';
    END IF;
    
    -- Validate status consistency
    IF NEW.status = 'completed' AND NEW.performed_date_time IS NULL AND NEW.performed_period IS NULL THEN
        RAISE EXCEPTION 'Completed procedures must have performed timing';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate reference integrity across FHIR resources
CREATE OR REPLACE FUNCTION validate_fhir_references() RETURNS TRIGGER AS $$
DECLARE
    ref_table TEXT;
    ref_id TEXT;
    ref_exists BOOLEAN;
BEGIN
    -- Generic reference validation for common patterns
    -- This function can be extended for specific reference validation needs
    
    -- Validate organization references
    IF NEW.managing_organization_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM fhir_organization WHERE id = NEW.managing_organization_id) THEN
            RAISE EXCEPTION 'Referenced organization does not exist: %', NEW.managing_organization_id;
        END IF;
    END IF;
    
    -- Validate location references
    IF NEW.part_of_location_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM fhir_location WHERE id = NEW.part_of_location_id) THEN
            RAISE EXCEPTION 'Referenced location does not exist: %', NEW.part_of_location_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================================================
-- TRIGGER DEFINITIONS
-- ========================================================================

-- Patient validation triggers
CREATE TRIGGER validate_patient_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_patient
    FOR EACH ROW EXECUTE FUNCTION validate_dm_patient();

-- Encounter validation triggers
CREATE TRIGGER validate_encounter_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_encounter
    FOR EACH ROW EXECUTE FUNCTION validate_dm_encounter();

-- Condition validation triggers
CREATE TRIGGER validate_condition_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_condition
    FOR EACH ROW EXECUTE FUNCTION validate_dm_condition();

-- Observation validation triggers
CREATE TRIGGER validate_observation_laboratory_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_observation
    FOR EACH ROW WHEN (NEW.observation_profile = 'laboratory')
    EXECUTE FUNCTION validate_dm_observation_laboratory();

CREATE TRIGGER validate_observation_vital_signs_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_observation
    FOR EACH ROW WHEN (NEW.observation_profile = 'vital-signs')
    EXECUTE FUNCTION validate_dm_observation_vital_signs();

-- MedicationRequest validation triggers
CREATE TRIGGER validate_medication_request_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_medication_request
    FOR EACH ROW EXECUTE FUNCTION validate_dm_medication_request();

-- Procedure validation triggers
CREATE TRIGGER validate_procedure_before_insert_update
    BEFORE INSERT OR UPDATE ON fhir_procedure
    FOR EACH ROW EXECUTE FUNCTION validate_dm_procedure();

-- Reference validation triggers for tables with references
CREATE TRIGGER validate_organization_references
    BEFORE INSERT OR UPDATE ON fhir_organization
    FOR EACH ROW EXECUTE FUNCTION validate_fhir_references();

CREATE TRIGGER validate_location_references
    BEFORE INSERT OR UPDATE ON fhir_location
    FOR EACH ROW EXECUTE FUNCTION validate_fhir_references();

-- ========================================================================
-- UTILITY FUNCTIONS
-- ========================================================================

-- Function: Extract identifier value by system
CREATE OR REPLACE FUNCTION get_identifier_value(identifiers JSONB, system_url TEXT)
RETURNS TEXT AS $$
DECLARE
    identifier JSONB;
BEGIN
    FOR identifier IN SELECT jsonb_array_elements(identifiers)
    LOOP
        IF identifier->>'system' = system_url THEN
            RETURN identifier->>'value';
        END IF;
    END LOOP;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function: Extract coding from CodeableConcept
CREATE OR REPLACE FUNCTION get_coding_code(codeable_concept JSONB, system_url TEXT)
RETURNS TEXT AS $$
DECLARE
    coding JSONB;
BEGIN
    FOR coding IN SELECT jsonb_array_elements(codeable_concept->'coding')
    LOOP
        IF coding->>'system' = system_url THEN
            RETURN coding->>'code';
        END IF;
    END LOOP;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function: Validate FHIR ID format
CREATE OR REPLACE FUNCTION is_valid_fhir_id(id_value TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- FHIR ID regex: [A-Za-z0-9\-\.]{1,64}
    RETURN id_value ~ '^[A-Za-z0-9\-\.]{1,64}$';
END;
$$ LANGUAGE plpgsql;

-- Function: Generate FHIR-compliant UUID
CREATE OR REPLACE FUNCTION generate_fhir_id()
RETURNS TEXT AS $$
BEGIN
    RETURN REPLACE(gen_random_uuid()::TEXT, '-', '');
END;
$$ LANGUAGE plpgsql;

-- ========================================================================
-- COMMENTS ON TABLES AND COLUMNS
-- ========================================================================

COMMENT ON TABLE fhir_patient IS 'FHIR Patient resource (DMPatient profile) - French patient demographics with INS-NIR identifiers';
COMMENT ON COLUMN fhir_patient.ins_nir_identifier IS 'INS-NIR official French national health identifier (13 digits)';
COMMENT ON COLUMN fhir_patient.nss_identifier IS 'Numéro de Sécurité Sociale (Social Security Number)';

COMMENT ON TABLE fhir_encounter IS 'FHIR Encounter resource (DMEncounter profile) - Healthcare encounters adapted for Data Management';
COMMENT ON COLUMN fhir_encounter.patient_id IS 'Required reference to DMPatient';

COMMENT ON TABLE fhir_condition IS 'FHIR Condition resource (DMCondition profile) - Conditions with CIM-10 coding';
COMMENT ON COLUMN fhir_condition.code IS 'Condition code using CIM-10 value set (extensible)';

COMMENT ON TABLE fhir_observation IS 'FHIR Observation resource - Generic table for all DM observation profiles (laboratory, vital signs, lifestyle)';
COMMENT ON COLUMN fhir_observation.observation_profile IS 'Profile type: laboratory, vital-signs, lifestyle';
COMMENT ON COLUMN fhir_observation.laboratory_type IS 'Laboratory subtype: uremie, tca, fonction_renale, generic';

COMMENT ON TABLE fhir_medication_request IS 'FHIR MedicationRequest resource (DMMedicationRequest profile) - Medication prescriptions';
COMMENT ON COLUMN fhir_medication_request.medication_codeable_concept IS 'Medication coded with ATC or other standard codes';

COMMENT ON TABLE fhir_claim IS 'FHIR Claim resource - Generic table for PMSI billing data (DMClaimPMSI, DMClaimPMSIMCO, DMClaimRUM profiles)';
COMMENT ON COLUMN fhir_claim.claim_profile IS 'Claim profile type: pmsi, pmsi_mco, rum';

-- ========================================================================
-- SCHEMA CREATION COMPLETED
-- 
-- This FHIR Semantic Layer database provides:
-- 1. Complete FHIR resource tables based on DM profiles
-- 2. French healthcare compliance (INS-NIR, CIM-10, CCAM, ATC)
-- 3. Profile-specific validation through PL/pgSQL functions
-- 4. Proper foreign key relationships and referential integrity
-- 5. Comprehensive indexing for performance
-- 6. JSONB support for complex FHIR data types
-- 7. Extensibility for future FHIR profiles and resources
-- 8. Audit trail capabilities
-- ========================================================================