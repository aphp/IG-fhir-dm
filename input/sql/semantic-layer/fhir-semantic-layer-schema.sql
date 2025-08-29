-- =====================================================================
-- FHIR Semantic Layer Database Schema for PostgreSQL 17.x
-- 
-- This schema implements tables based on FHIR profiles found in the 
-- semantic-layer/profiles directory, optimized for French healthcare
-- data management with PMSI (Programme de médicalisation des systèmes 
-- d'information) support.
--
-- Design Approach:
-- - Grouped tables by resource type for maintainability
-- - Specialized tables for complex resources (Observations, Claims)
-- - FHIR reference support with foreign keys
-- - Coded values stored with system, code, and display
-- - Extensions support for French healthcare specifics
-- - Optimized for both transactional and analytical queries
-- =====================================================================

-- Enable UUID extension for FHIR resource IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schema for semantic layer
CREATE SCHEMA IF NOT EXISTS fhir_semantic;

-- Set search path
SET search_path TO fhir_semantic, public;

-- =====================================================================
-- SUPPORTING TABLES
-- =====================================================================

-- Table for coded values (CodeableConcept, Coding)
CREATE TABLE coded_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    system VARCHAR(512) NOT NULL,
    code VARCHAR(256) NOT NULL,
    display VARCHAR(512),
    version VARCHAR(64),
    user_selected BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(system, code, version)
);

-- Table for FHIR extensions
CREATE TABLE extensions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    resource_type VARCHAR(64) NOT NULL,
    resource_id UUID NOT NULL,
    url VARCHAR(512) NOT NULL,
    value_type VARCHAR(32) NOT NULL, -- string, integer, boolean, coding, etc.
    value_string TEXT,
    value_integer INTEGER,
    value_boolean BOOLEAN,
    value_decimal DECIMAL(20,8),
    value_datetime TIMESTAMP WITH TIME ZONE,
    value_coding_id UUID REFERENCES coded_values(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table for identifiers
CREATE TABLE identifiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    resource_type VARCHAR(64) NOT NULL,
    resource_id UUID NOT NULL,
    use VARCHAR(32), -- usual, official, temp, secondary
    type_coding_id UUID REFERENCES coded_values(id),
    system VARCHAR(512),
    value VARCHAR(256) NOT NULL,
    period_start TIMESTAMP WITH TIME ZONE,
    period_end TIMESTAMP WITH TIME ZONE,
    assigner_organization_id UUID,
    
    UNIQUE(resource_type, resource_id, system, value)
);

-- =====================================================================
-- CORE RESOURCE TABLES
-- =====================================================================

-- Patient table (DMPatient profile)
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    active BOOLEAN DEFAULT true,
    
    -- Names (simplified - could be normalized further)
    family_name VARCHAR(256),
    given_names TEXT[], -- Array for multiple given names
    
    -- Core demographics
    gender VARCHAR(32) NOT NULL, -- Required, from FrCore gender valueset
    birth_date DATE,
    deceased_boolean BOOLEAN DEFAULT false,
    deceased_datetime TIMESTAMP WITH TIME ZONE,
    multiple_birth_integer INTEGER,
    
    -- Address (simplified - using DMAddress profile)
    address_use VARCHAR(32),
    address_type VARCHAR(32),
    address_line TEXT[],
    address_city VARCHAR(128),
    address_district VARCHAR(128),
    address_state VARCHAR(128),
    address_postal_code VARCHAR(32),
    address_country VARCHAR(128),
    address_period_start TIMESTAMP WITH TIME ZONE,
    address_period_end TIMESTAMP WITH TIME ZONE,
    
    -- Contact information
    telecom JSONB, -- Store as JSON for flexibility
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Organization table (DMOrganization profile)
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    active BOOLEAN DEFAULT true,
    type_coding_id UUID REFERENCES coded_values(id),
    name VARCHAR(512) NOT NULL,
    alias TEXT[],
    
    -- Contact information
    telecom JSONB,
    address JSONB, -- Simplified address storage
    
    -- Hierarchical relationship
    part_of_organization_id UUID REFERENCES organizations(id),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Location table (DMLocation profile)
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    operational_status_coding_id UUID REFERENCES coded_values(id),
    name VARCHAR(512),
    alias TEXT[],
    description TEXT,
    mode VARCHAR(32), -- instance, kind
    type_coding_id UUID REFERENCES coded_values(id),
    
    -- Address
    address JSONB,
    
    -- Position (coordinates)
    position_longitude DECIMAL(10, 7),
    position_latitude DECIMAL(10, 7),
    position_altitude DECIMAL(10, 3),
    
    -- Relationships
    managing_organization_id UUID REFERENCES organizations(id),
    part_of_location_id UUID REFERENCES locations(id),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Practitioner table (DMPractitioner profile)
CREATE TABLE practitioners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    active BOOLEAN DEFAULT true,
    
    -- Names
    family_name VARCHAR(256),
    given_names TEXT[],
    prefix TEXT[],
    suffix TEXT[],
    
    -- Demographics
    gender VARCHAR(32),
    birth_date DATE,
    
    -- Contact
    telecom JSONB,
    address JSONB,
    
    -- Photo (stored as reference to binary data)
    photo_attachment JSONB,
    
    -- Qualifications stored as JSON for flexibility
    qualifications JSONB,
    
    -- Communication (languages)
    communication JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PractitionerRole table (DMPractitionerRole profile)
CREATE TABLE practitioner_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    active BOOLEAN DEFAULT true,
    
    -- References
    practitioner_id UUID REFERENCES practitioners(id),
    organization_id UUID REFERENCES organizations(id),
    
    -- Role details
    code JSONB, -- Array of CodeableConcept
    specialty JSONB, -- Array of CodeableConcept
    
    -- Locations where role is performed
    locations UUID[], -- Array of location IDs
    
    -- Contact and availability
    telecom JSONB,
    available_time JSONB,
    not_available JSONB,
    availability_exceptions TEXT,
    
    -- Period when role is/was valid
    period_start TIMESTAMP WITH TIME ZONE,
    period_end TIMESTAMP WITH TIME ZONE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Episode of Care table (DMEpisodeOfCare profile)
CREATE TABLE episodes_of_care (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status VARCHAR(32) NOT NULL, -- planned, waitlist, active, onhold, finished, cancelled
    status_history JSONB,
    
    -- Classifications
    type JSONB, -- Array of CodeableConcept
    diagnosis JSONB, -- Array with condition reference and role
    
    -- References
    patient_id UUID NOT NULL REFERENCES patients(id),
    managing_organization_id UUID REFERENCES organizations(id),
    
    -- Care manager
    care_manager_practitioner_id UUID REFERENCES practitioners(id),
    care_manager_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    
    -- Team (simplified)
    team JSONB,
    
    -- Referral request
    referral_request JSONB,
    
    -- Period
    period_start TIMESTAMP WITH TIME ZONE,
    period_end TIMESTAMP WITH TIME ZONE,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Encounter table (DMEncounter profile)
CREATE TABLE encounters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status VARCHAR(32) NOT NULL, -- planned, arrived, triaged, in-progress, onleave, finished, cancelled
    status_history JSONB,
    
    -- Classification
    class_coding_id UUID REFERENCES coded_values(id), -- AMB, EMER, FLD, HH, IMP, SS, VR
    type JSONB, -- Array of CodeableConcept
    service_type_coding_id UUID REFERENCES coded_values(id),
    priority_coding_id UUID REFERENCES coded_values(id),
    
    -- References
    subject_patient_id UUID NOT NULL REFERENCES patients(id),
    episode_of_care_id UUID REFERENCES episodes_of_care(id),
    
    -- Participants
    participants JSONB, -- Array with type, period, individual references
    
    -- Appointment
    appointment JSONB, -- Array of references
    
    -- Period
    period_start TIMESTAMP WITH TIME ZONE,
    period_end TIMESTAMP WITH TIME ZONE,
    length_value DECIMAL(10, 3),
    length_unit VARCHAR(32),
    
    -- Reason
    reason_code JSONB, -- Array of CodeableConcept
    reason_reference JSONB, -- Array of references to Condition, Procedure, etc.
    
    -- Diagnosis
    diagnosis JSONB, -- Array with condition reference, use, rank
    
    -- Account
    account JSONB,
    
    -- Hospitalization
    hospitalization JSONB, -- Pre-admission identifier, origin, admit source, etc.
    
    -- Service provider
    service_provider_organization_id UUID REFERENCES organizations(id),
    
    -- Part of (for sub-encounters)
    part_of_encounter_id UUID REFERENCES encounters(id),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- CLINICAL DATA TABLES
-- =====================================================================

-- Condition table (DMCondition profile)
CREATE TABLE conditions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Business identifiers
    clinical_status_coding_id UUID REFERENCES coded_values(id), -- active, recurrence, relapse, inactive, remission, resolved
    verification_status_coding_id UUID REFERENCES coded_values(id), -- unconfirmed, provisional, differential, confirmed, refuted
    
    -- Category and code
    category JSONB, -- Array of CodeableConcept
    severity_coding_id UUID REFERENCES coded_values(id),
    code_coding_id UUID NOT NULL REFERENCES coded_values(id), -- CIM-10 coding
    body_site JSONB, -- Array of CodeableConcept
    
    -- References
    subject_patient_id UUID NOT NULL REFERENCES patients(id),
    encounter_id UUID REFERENCES encounters(id),
    
    -- Timing
    onset_datetime TIMESTAMP WITH TIME ZONE,
    onset_age_value DECIMAL(10, 3),
    onset_age_unit VARCHAR(32),
    onset_period_start TIMESTAMP WITH TIME ZONE,
    onset_period_end TIMESTAMP WITH TIME ZONE,
    onset_range_low_value DECIMAL(10, 3),
    onset_range_high_value DECIMAL(10, 3),
    onset_string VARCHAR(512),
    
    abatement_datetime TIMESTAMP WITH TIME ZONE,
    abatement_age_value DECIMAL(10, 3),
    abatement_age_unit VARCHAR(32),
    abatement_period_start TIMESTAMP WITH TIME ZONE,
    abatement_period_end TIMESTAMP WITH TIME ZONE,
    abatement_range_low_value DECIMAL(10, 3),
    abatement_range_high_value DECIMAL(10, 3),
    abatement_string VARCHAR(512),
    abatement_boolean BOOLEAN,
    
    -- Recorded date and recorder
    recorded_date DATE,
    recorder_practitioner_id UUID REFERENCES practitioners(id),
    recorder_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    recorder_patient_id UUID REFERENCES patients(id),
    
    -- Asserter
    asserter_practitioner_id UUID REFERENCES practitioners(id),
    asserter_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    asserter_patient_id UUID REFERENCES patients(id),
    
    -- Stage
    stage JSONB,
    
    -- Evidence
    evidence JSONB,
    
    -- Notes
    notes TEXT,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Procedure table (DMProcedure profile)
CREATE TABLE procedures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Status
    status VARCHAR(32) NOT NULL, -- preparation, in-progress, not-done, on-hold, stopped, completed, entered-in-error, unknown
    status_reason_coding_id UUID REFERENCES coded_values(id),
    
    -- Category and code
    category_coding_id UUID REFERENCES coded_values(id),
    code_coding_id UUID REFERENCES coded_values(id), -- CCAM coding
    
    -- References
    subject_patient_id UUID NOT NULL REFERENCES patients(id),
    encounter_id UUID REFERENCES encounters(id),
    
    -- Timing
    performed_datetime TIMESTAMP WITH TIME ZONE,
    performed_period_start TIMESTAMP WITH TIME ZONE,
    performed_period_end TIMESTAMP WITH TIME ZONE,
    performed_string VARCHAR(512),
    performed_age_value DECIMAL(10, 3),
    performed_age_unit VARCHAR(32),
    performed_range_low_value DECIMAL(10, 3),
    performed_range_high_value DECIMAL(10, 3),
    
    -- Recorder and asserter
    recorder_practitioner_id UUID REFERENCES practitioners(id),
    recorder_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    recorder_patient_id UUID REFERENCES patients(id),
    
    asserter_practitioner_id UUID REFERENCES practitioners(id),
    asserter_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    asserter_patient_id UUID REFERENCES patients(id),
    
    -- Performers
    performers JSONB, -- Array with function, actor, onBehalfOf
    
    -- Location
    location_id UUID REFERENCES locations(id),
    
    -- Reason
    reason_code JSONB, -- Array of CodeableConcept
    reason_reference JSONB, -- Array of references to Condition, Observation, Procedure
    
    -- Body site
    body_site JSONB, -- Array of CodeableConcept
    
    -- Outcome
    outcome_coding_id UUID REFERENCES coded_values(id),
    
    -- Report and complications
    report JSONB, -- References to DiagnosticReport, DocumentReference
    complications JSONB, -- Array of CodeableConcept
    complications_detail JSONB, -- References to Condition
    
    -- Follow up
    follow_up JSONB, -- Array of CodeableConcept
    
    -- Notes
    notes TEXT,
    
    -- Used reference (devices, medications)
    used_reference JSONB,
    used_code JSONB,
    
    -- Part of (for sub-procedures)
    part_of_procedure_id UUID REFERENCES procedures(id),
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- OBSERVATION TABLES
-- =====================================================================

-- Base observations table for common observation data
CREATE TABLE observations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Status
    status VARCHAR(32) NOT NULL, -- registered, preliminary, final, amended, corrected, cancelled, entered-in-error, unknown
    
    -- Category and code
    category JSONB, -- Array of CodeableConcept (vital-signs, survey, etc.)
    code_coding_id UUID NOT NULL REFERENCES coded_values(id),
    
    -- References
    subject_patient_id UUID NOT NULL REFERENCES patients(id),
    encounter_id UUID REFERENCES encounters(id),
    
    -- Focus (when subject is not patient)
    focus JSONB,
    
    -- Timing
    effective_datetime TIMESTAMP WITH TIME ZONE,
    effective_period_start TIMESTAMP WITH TIME ZONE,
    effective_period_end TIMESTAMP WITH TIME ZONE,
    effective_timing JSONB,
    effective_instant TIMESTAMP WITH TIME ZONE,
    
    -- Issued
    issued TIMESTAMP WITH TIME ZONE,
    
    -- Performer
    performers UUID[], -- Array of practitioner, practitionerRole, organization, patient IDs
    
    -- Values (generic - specialized tables will have specific fields)
    value_quantity_value DECIMAL(20, 8),
    value_quantity_comparator VARCHAR(8), -- <, <=, >=, >
    value_quantity_unit VARCHAR(64),
    value_quantity_system VARCHAR(512),
    value_quantity_code VARCHAR(64),
    
    value_codeable_concept_id UUID REFERENCES coded_values(id),
    value_string TEXT,
    value_boolean BOOLEAN,
    value_integer INTEGER,
    value_range_low_value DECIMAL(20, 8),
    value_range_high_value DECIMAL(20, 8),
    value_ratio_numerator_value DECIMAL(20, 8),
    value_ratio_denominator_value DECIMAL(20, 8),
    value_sampled_data JSONB,
    value_time TIME,
    value_datetime TIMESTAMP WITH TIME ZONE,
    value_period_start TIMESTAMP WITH TIME ZONE,
    value_period_end TIMESTAMP WITH TIME ZONE,
    
    -- Data absent reason
    data_absent_reason_coding_id UUID REFERENCES coded_values(id),
    
    -- Interpretation and notes
    interpretation JSONB, -- Array of CodeableConcept
    notes TEXT,
    
    -- Body site and method
    body_site_coding_id UUID REFERENCES coded_values(id),
    method_coding_id UUID REFERENCES coded_values(id),
    
    -- Specimen and device
    specimen_reference JSONB,
    device_reference JSONB,
    
    -- Reference range
    reference_ranges JSONB, -- Array with low, high, type, applies_to, age, text
    
    -- Related observations
    has_members UUID[], -- Array of observation IDs
    derived_from UUID[], -- Array of observation or other resource IDs
    
    -- Components (for complex observations like BP)
    components JSONB,
    
    -- Observation type for filtering
    observation_type VARCHAR(64) NOT NULL,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Specialized Blood Pressure observations (DMObservationBloodPressure)
CREATE TABLE observations_blood_pressure (
    observation_id UUID PRIMARY KEY REFERENCES observations(id) ON DELETE CASCADE,
    
    -- Systolic BP component
    systolic_value DECIMAL(5, 2) NOT NULL,
    systolic_unit VARCHAR(32) NOT NULL DEFAULT 'mm[Hg]',
    
    -- Diastolic BP component  
    diastolic_value DECIMAL(5, 2) NOT NULL,
    diastolic_unit VARCHAR(32) NOT NULL DEFAULT 'mm[Hg]',
    
    -- Body site and method (more specific for BP)
    body_site_coding_id UUID REFERENCES coded_values(id),
    method_coding_id UUID REFERENCES coded_values(id)
);

-- Body Height observations (DMObservationBodyHeight)
CREATE TABLE observations_body_height (
    observation_id UUID PRIMARY KEY REFERENCES observations(id) ON DELETE CASCADE,
    
    -- Height value
    height_value DECIMAL(5, 2) NOT NULL,
    height_unit VARCHAR(32) NOT NULL DEFAULT 'cm',
    
    -- Measurement method
    method_coding_id UUID REFERENCES coded_values(id)
);

-- Body Weight observations (DMObservationBodyWeight)
CREATE TABLE observations_body_weight (
    observation_id UUID PRIMARY KEY REFERENCES observations(id) ON DELETE CASCADE,
    
    -- Weight value
    weight_value DECIMAL(6, 3) NOT NULL,
    weight_unit VARCHAR(32) NOT NULL DEFAULT 'kg',
    
    -- Measurement method
    method_coding_id UUID REFERENCES coded_values(id)
);

-- Laboratory observations (Generic and specialized)
CREATE TABLE observations_laboratory (
    observation_id UUID PRIMARY KEY REFERENCES observations(id) ON DELETE CASCADE,
    
    -- Lab-specific fields
    lab_category VARCHAR(64), -- chemistry, hematology, microbiology, etc.
    specimen_type_coding_id UUID REFERENCES coded_values(id),
    
    -- Result value (can be numeric, coded, or text)
    result_value_numeric DECIMAL(20, 8),
    result_value_text TEXT,
    result_value_coding_id UUID REFERENCES coded_values(id),
    
    -- Units and reference range
    result_unit VARCHAR(64),
    reference_range_low DECIMAL(20, 8),
    reference_range_high DECIMAL(20, 8),
    reference_range_text TEXT,
    
    -- Abnormal flags
    abnormal_flag_coding_id UUID REFERENCES coded_values(id),
    
    -- Lab-specific observation type
    lab_observation_type VARCHAR(64) -- fonctionrenale, tca, uremie, generic
);

-- Lifestyle observations (Smoking, Alcohol, Exercise, Substance Use)
CREATE TABLE observations_lifestyle (
    observation_id UUID PRIMARY KEY REFERENCES observations(id) ON DELETE CASCADE,
    
    -- Lifestyle type
    lifestyle_type VARCHAR(32) NOT NULL, -- smoking, alcohol, exercise, substance
    
    -- Status/assessment
    status_coding_id UUID REFERENCES coded_values(id),
    
    -- Quantity/frequency (for smoking pack-years, exercise frequency, etc.)
    quantity_value DECIMAL(10, 3),
    quantity_unit VARCHAR(32),
    
    -- Additional details as JSON
    details JSONB
);

-- =====================================================================
-- MEDICATION TABLES
-- =====================================================================

-- Medication base table (Fr medications)
CREATE TABLE medications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Medication type
    medication_type VARCHAR(32) NOT NULL, -- ucd, nonproprietaryname, compound, ucdpart
    
    -- Code (UCD, DC, etc.)
    code_coding_id UUID REFERENCES coded_values(id),
    
    -- Status
    status VARCHAR(32) DEFAULT 'active', -- active, inactive, entered-in-error
    
    -- Manufacturer
    manufacturer_organization_id UUID REFERENCES organizations(id),
    
    -- Form
    form_coding_id UUID REFERENCES coded_values(id),
    
    -- Amount and ingredient
    amount JSONB,
    ingredient JSONB,
    
    -- Batch information
    batch JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Medication Administration table (DMMedicationAdministration)
CREATE TABLE medication_administrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Status
    status VARCHAR(32) NOT NULL, -- in-progress, not-done, on-hold, completed, entered-in-error, stopped, unknown
    status_reason JSONB, -- Array of CodeableConcept
    
    -- Category
    category_coding_id UUID REFERENCES coded_values(id),
    
    -- Medication reference
    medication_id UUID REFERENCES medications(id),
    medication_codeable_concept_id UUID REFERENCES coded_values(id),
    
    -- References
    subject_patient_id UUID NOT NULL REFERENCES patients(id),
    context_encounter_id UUID REFERENCES encounters(id),
    context_episode_id UUID REFERENCES episodes_of_care(id),
    
    -- Supporting information
    supporting_information JSONB,
    
    -- Timing
    effective_datetime TIMESTAMP WITH TIME ZONE,
    effective_period_start TIMESTAMP WITH TIME ZONE,
    effective_period_end TIMESTAMP WITH TIME ZONE,
    
    -- Performers
    performers JSONB, -- Array with function and actor
    
    -- Reason
    reason_code JSONB, -- Array of CodeableConcept
    reason_reference JSONB, -- Array of references
    
    -- Request (reference to MedicationRequest)
    request_medication_request_id UUID,
    
    -- Device
    device JSONB, -- Array of device references
    
    -- Notes
    notes TEXT,
    
    -- Dosage (required 1..1)
    dosage_text TEXT,
    dosage_site_coding_id UUID REFERENCES coded_values(id),
    dosage_route_coding_id UUID REFERENCES coded_values(id), -- Required, from FrRouteOfAdministration
    dosage_method_coding_id UUID REFERENCES coded_values(id),
    dosage_dose_value DECIMAL(10, 3), -- Required (FrSimpleQuantityUcum)
    dosage_dose_unit VARCHAR(32),
    dosage_dose_system VARCHAR(512),
    dosage_dose_code VARCHAR(64),
    dosage_rate_ratio_numerator_value DECIMAL(10, 3),
    dosage_rate_ratio_denominator_value DECIMAL(10, 3),
    dosage_rate_quantity_value DECIMAL(10, 3),
    dosage_rate_quantity_unit VARCHAR(32),
    
    -- Event history
    event_history JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Medication Request table (DMMedicationRequest)
CREATE TABLE medication_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Status
    status VARCHAR(32) NOT NULL, -- active, on-hold, cancelled, completed, entered-in-error, stopped, draft, unknown
    status_reason_coding_id UUID REFERENCES coded_values(id),
    
    -- Intent
    intent VARCHAR(32) NOT NULL, -- proposal, plan, order, original-order, reflex-order, filler-order, instance-order, option
    
    -- Category
    category JSONB, -- Array of CodeableConcept
    
    -- Priority
    priority VARCHAR(32), -- routine, urgent, asap, stat
    
    -- Do not perform
    do_not_perform BOOLEAN DEFAULT false,
    
    -- Reported
    reported_boolean BOOLEAN,
    reported_reference JSONB,
    
    -- Medication
    medication_id UUID REFERENCES medications(id),
    medication_codeable_concept_id UUID REFERENCES coded_values(id),
    
    -- References
    subject_patient_id UUID NOT NULL REFERENCES patients(id),
    encounter_id UUID REFERENCES encounters(id),
    
    -- Supporting information
    supporting_information JSONB,
    
    -- Authored on
    authored_on TIMESTAMP WITH TIME ZONE,
    
    -- Requester
    requester_practitioner_id UUID REFERENCES practitioners(id),
    requester_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    requester_organization_id UUID REFERENCES organizations(id),
    requester_patient_id UUID REFERENCES patients(id),
    
    -- Performer
    performer_type_coding_id UUID REFERENCES coded_values(id),
    performer JSONB, -- Reference to practitioner, practitionerRole, organization, patient, device, etc.
    
    -- Recorder
    recorder_practitioner_id UUID REFERENCES practitioners(id),
    recorder_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    
    -- Reason
    reason_code JSONB, -- Array of CodeableConcept
    reason_reference JSONB, -- Array of references
    
    -- Instantiates canonical/uri
    instantiates_canonical TEXT[],
    instantiates_uri TEXT[],
    
    -- Based on
    based_on JSONB, -- Array of references
    
    -- Group identifier
    group_identifier JSONB,
    
    -- Course of therapy type
    course_of_therapy_type_coding_id UUID REFERENCES coded_values(id),
    
    -- Insurance
    insurance JSONB, -- Array of coverage references
    
    -- Notes
    notes TEXT,
    
    -- Dosage instruction
    dosage_instruction JSONB, -- Array of dosage
    
    -- Dispense request
    dispense_request JSONB,
    
    -- Substitution
    substitution JSONB,
    
    -- Prior prescription
    prior_prescription_id UUID REFERENCES medication_requests(id),
    
    -- Detection issue
    detection_issue JSONB,
    
    -- Event history
    event_history JSONB,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- PMSI/CLAIM TABLES (French Healthcare Specific)
-- =====================================================================

-- Base Claims table for PMSI data
CREATE TABLE claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Claim type (abstract profile specialization)
    claim_type VARCHAR(32) NOT NULL, -- pmsi, pmsi_mco, rum
    
    -- Status
    status VARCHAR(32) NOT NULL DEFAULT 'active', -- active, cancelled, draft, entered-in-error
    
    -- Type (required, from FrClaimType)
    type_coding_id UUID NOT NULL REFERENCES coded_values(id),
    
    -- Use (fixed to 'claim')
    use VARCHAR(32) NOT NULL DEFAULT 'claim',
    
    -- Patient
    patient_id UUID NOT NULL REFERENCES patients(id),
    
    -- Billable period
    billable_period_start TIMESTAMP WITH TIME ZONE,
    billable_period_end TIMESTAMP WITH TIME ZONE,
    
    -- Created
    created TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Enterer
    enterer_practitioner_id UUID REFERENCES practitioners(id),
    enterer_practitioner_role_id UUID REFERENCES practitioner_roles(id),
    
    -- Insurer
    insurer_organization_id UUID REFERENCES organizations(id),
    
    -- Provider (issuing legal entity)
    provider_organization_id UUID REFERENCES organizations(id),
    
    -- Priority (fixed to 'normal')
    priority_coding_id UUID NOT NULL REFERENCES coded_values(id),
    
    -- Funds reserve
    funds_reserve_coding_id UUID REFERENCES coded_values(id),
    
    -- Related claims
    related_claims JSONB,
    
    -- Prescription
    prescription JSONB,
    
    -- Original prescription
    original_prescription JSONB,
    
    -- Payee
    payee JSONB,
    
    -- Referral
    referral JSONB,
    
    -- Facility
    facility_location_id UUID REFERENCES locations(id),
    
    -- Care team
    care_team JSONB, -- Array with sequence, provider, responsible, role, qualification
    
    -- Supporting info
    supporting_info JSONB,
    
    -- Diagnosis
    diagnosis JSONB, -- Array with sequence, diagnosis, type, on admission, package code
    
    -- Procedures
    procedures JSONB, -- Array with sequence, type, date, procedure, udi
    
    -- Insurance (required, sequence=1, focal=true)
    insurance JSONB NOT NULL, -- Coverage display = "Assurance Maladie"
    
    -- Accident
    accident JSONB,
    
    -- Items (PMSI-specific items)
    items JSONB,
    
    -- Total
    total_value DECIMAL(12, 2),
    total_currency VARCHAR(8) DEFAULT 'EUR',
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PMSI MCO specific claims data
CREATE TABLE claims_pmsi_mco (
    claim_id UUID PRIMARY KEY REFERENCES claims(id) ON DELETE CASCADE,
    
    -- MCO-specific fields
    ghm_code VARCHAR(16), -- Groupe Homogène de Malades
    
    -- Supplementary information categories specific to MCO
    supplementary_info_categories JSONB, -- Using FrClaimSupInfoCategoryPMSIMCO
    
    -- MCO item categories
    item_categories JSONB, -- Using FrMCOClaimItemCategory
    
    -- Mode de sortie (discharge mode)
    discharge_mode_coding_id UUID REFERENCES coded_values(id),
    
    -- Durée de séjour (length of stay)
    length_of_stay INTEGER,
    
    -- Additional MCO-specific data
    mco_specific_data JSONB
);

-- RUM (Résumé d'Unité Médicale) specific data
CREATE TABLE claims_rum (
    claim_id UUID PRIMARY KEY REFERENCES claims(id) ON DELETE CASCADE,
    
    -- RUM-specific identifiers
    rum_number VARCHAR(32),
    medical_unit_code VARCHAR(16),
    
    -- Dates specific to RUM
    medical_unit_entry_date DATE,
    medical_unit_exit_date DATE,
    
    -- RUM-specific diagnosis types
    diagnosis_types JSONB, -- Using PMSIMCODiagType
    
    -- Medical disciplines
    medical_disciplines JSONB, -- Using PMSIMCOMDE and PMSIMCOMDS
    
    -- Additional RUM data
    rum_specific_data JSONB
);

-- =====================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================================

-- Patient indexes
CREATE INDEX idx_patients_gender ON patients(gender);
CREATE INDEX idx_patients_birth_date ON patients(birth_date);
CREATE INDEX idx_patients_deceased ON patients(deceased_boolean);
CREATE INDEX idx_patients_postal_code ON patients(address_postal_code);
CREATE INDEX idx_patients_active ON patients(active);

-- Organization indexes
CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_organizations_active ON organizations(active);
CREATE INDEX idx_organizations_part_of ON organizations(part_of_organization_id);

-- Location indexes  
CREATE INDEX idx_locations_name ON locations(name);
CREATE INDEX idx_locations_status ON locations(status);
CREATE INDEX idx_locations_managing_org ON locations(managing_organization_id);

-- Practitioner indexes
CREATE INDEX idx_practitioners_family_name ON practitioners(family_name);
CREATE INDEX idx_practitioners_active ON practitioners(active);

-- Episode of Care indexes
CREATE INDEX idx_episodes_patient ON episodes_of_care(patient_id);
CREATE INDEX idx_episodes_status ON episodes_of_care(status);
CREATE INDEX idx_episodes_managing_org ON episodes_of_care(managing_organization_id);
CREATE INDEX idx_episodes_period ON episodes_of_care(period_start, period_end);

-- Encounter indexes
CREATE INDEX idx_encounters_patient ON encounters(subject_patient_id);
CREATE INDEX idx_encounters_status ON encounters(status);
CREATE INDEX idx_encounters_class ON encounters(class_coding_id);
CREATE INDEX idx_encounters_period ON encounters(period_start, period_end);
CREATE INDEX idx_encounters_episode ON encounters(episode_of_care_id);
CREATE INDEX idx_encounters_service_provider ON encounters(service_provider_organization_id);

-- Condition indexes
CREATE INDEX idx_conditions_patient ON conditions(subject_patient_id);
CREATE INDEX idx_conditions_encounter ON conditions(encounter_id);
CREATE INDEX idx_conditions_code ON conditions(code_coding_id);
CREATE INDEX idx_conditions_clinical_status ON conditions(clinical_status_coding_id);
CREATE INDEX idx_conditions_onset_date ON conditions(onset_datetime);

-- Procedure indexes
CREATE INDEX idx_procedures_patient ON procedures(subject_patient_id);
CREATE INDEX idx_procedures_encounter ON procedures(encounter_id);
CREATE INDEX idx_procedures_code ON procedures(code_coding_id);
CREATE INDEX idx_procedures_status ON procedures(status);
CREATE INDEX idx_procedures_performed ON procedures(performed_datetime);

-- Observation indexes
CREATE INDEX idx_observations_patient ON observations(subject_patient_id);
CREATE INDEX idx_observations_encounter ON observations(encounter_id);
CREATE INDEX idx_observations_code ON observations(code_coding_id);
CREATE INDEX idx_observations_status ON observations(status);
CREATE INDEX idx_observations_effective ON observations(effective_datetime);
CREATE INDEX idx_observations_type ON observations(observation_type);
CREATE INDEX idx_observations_category ON observations USING gin(category);

-- Medication Administration indexes
CREATE INDEX idx_med_admin_patient ON medication_administrations(subject_patient_id);
CREATE INDEX idx_med_admin_medication ON medication_administrations(medication_id);
CREATE INDEX idx_med_admin_effective ON medication_administrations(effective_datetime);
CREATE INDEX idx_med_admin_status ON medication_administrations(status);

-- Medication Request indexes
CREATE INDEX idx_med_request_patient ON medication_requests(subject_patient_id);
CREATE INDEX idx_med_request_medication ON medication_requests(medication_id);
CREATE INDEX idx_med_request_authored ON medication_requests(authored_on);
CREATE INDEX idx_med_request_status ON medication_requests(status);

-- Claims indexes
CREATE INDEX idx_claims_patient ON claims(patient_id);
CREATE INDEX idx_claims_type ON claims(claim_type);
CREATE INDEX idx_claims_created ON claims(created);
CREATE INDEX idx_claims_provider ON claims(provider_organization_id);
CREATE INDEX idx_claims_billable_period ON claims(billable_period_start, billable_period_end);

-- Supporting table indexes
CREATE INDEX idx_coded_values_system_code ON coded_values(system, code);
CREATE INDEX idx_identifiers_resource ON identifiers(resource_type, resource_id);
CREATE INDEX idx_identifiers_system_value ON identifiers(system, value);
CREATE INDEX idx_extensions_resource ON extensions(resource_type, resource_id);
CREATE INDEX idx_extensions_url ON extensions(url);

-- Composite indexes for common query patterns
CREATE INDEX idx_encounters_patient_period ON encounters(subject_patient_id, period_start, period_end);
CREATE INDEX idx_observations_patient_code_date ON observations(subject_patient_id, code_coding_id, effective_datetime);
CREATE INDEX idx_conditions_patient_code ON conditions(subject_patient_id, code_coding_id);
CREATE INDEX idx_procedures_patient_date ON procedures(subject_patient_id, performed_datetime);

-- =====================================================================
-- FOREIGN KEY CONSTRAINTS
-- =====================================================================

-- Episode of Care foreign keys
ALTER TABLE episodes_of_care 
ADD CONSTRAINT fk_episodes_patient 
FOREIGN KEY (patient_id) REFERENCES patients(id);

ALTER TABLE episodes_of_care 
ADD CONSTRAINT fk_episodes_managing_org 
FOREIGN KEY (managing_organization_id) REFERENCES organizations(id);

-- Encounter foreign keys
ALTER TABLE encounters 
ADD CONSTRAINT fk_encounters_patient 
FOREIGN KEY (subject_patient_id) REFERENCES patients(id);

ALTER TABLE encounters 
ADD CONSTRAINT fk_encounters_episode 
FOREIGN KEY (episode_of_care_id) REFERENCES episodes_of_care(id);

-- Condition foreign keys
ALTER TABLE conditions 
ADD CONSTRAINT fk_conditions_patient 
FOREIGN KEY (subject_patient_id) REFERENCES patients(id);

ALTER TABLE conditions 
ADD CONSTRAINT fk_conditions_encounter 
FOREIGN KEY (encounter_id) REFERENCES encounters(id);

-- Procedure foreign keys  
ALTER TABLE procedures 
ADD CONSTRAINT fk_procedures_patient 
FOREIGN KEY (subject_patient_id) REFERENCES patients(id);

ALTER TABLE procedures 
ADD CONSTRAINT fk_procedures_encounter 
FOREIGN KEY (encounter_id) REFERENCES encounters(id);

-- Observation foreign keys
ALTER TABLE observations 
ADD CONSTRAINT fk_observations_patient 
FOREIGN KEY (subject_patient_id) REFERENCES patients(id);

ALTER TABLE observations 
ADD CONSTRAINT fk_observations_encounter 
FOREIGN KEY (encounter_id) REFERENCES encounters(id);

-- Medication Administration foreign keys
ALTER TABLE medication_administrations 
ADD CONSTRAINT fk_med_admin_patient 
FOREIGN KEY (subject_patient_id) REFERENCES patients(id);

ALTER TABLE medication_administrations 
ADD CONSTRAINT fk_med_admin_context_encounter 
FOREIGN KEY (context_encounter_id) REFERENCES encounters(id);

-- Medication Request foreign keys
ALTER TABLE medication_requests 
ADD CONSTRAINT fk_med_request_patient 
FOREIGN KEY (subject_patient_id) REFERENCES patients(id);

ALTER TABLE medication_requests 
ADD CONSTRAINT fk_med_request_encounter 
FOREIGN KEY (encounter_id) REFERENCES encounters(id);

-- Claims foreign keys
ALTER TABLE claims 
ADD CONSTRAINT fk_claims_patient 
FOREIGN KEY (patient_id) REFERENCES patients(id);

-- =====================================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================================

-- View for patient demographics with identifiers
CREATE VIEW v_patient_demographics AS
SELECT 
    p.id,
    p.family_name,
    p.given_names,
    p.gender,
    p.birth_date,
    p.deceased_boolean,
    p.address_city,
    p.address_postal_code,
    i.value as nir,
    ins_i.value as ins_nir
FROM patients p
LEFT JOIN identifiers i ON p.id = i.resource_id 
    AND i.resource_type = 'Patient' 
    AND i.system = 'urn:oid:1.2.250.1.213.1.4.2'
LEFT JOIN identifiers ins_i ON p.id = ins_i.resource_id 
    AND ins_i.resource_type = 'Patient' 
    AND ins_i.system = 'urn:oid:1.2.250.1.213.1.4.8';

-- View for active encounters with patient info
CREATE VIEW v_active_encounters AS
SELECT 
    e.id,
    e.status,
    e.period_start,
    e.period_end,
    p.family_name,
    p.given_names,
    o.name as service_provider_name
FROM encounters e
JOIN patients p ON e.subject_patient_id = p.id
LEFT JOIN organizations o ON e.service_provider_organization_id = o.id
WHERE e.status IN ('planned', 'arrived', 'triaged', 'in-progress');

-- View for recent observations with patient info
CREATE VIEW v_recent_observations AS
SELECT 
    o.id,
    o.observation_type,
    cv.display as observation_name,
    o.effective_datetime,
    o.value_quantity_value,
    o.value_quantity_unit,
    p.family_name,
    p.given_names
FROM observations o
JOIN patients p ON o.subject_patient_id = p.id
JOIN coded_values cv ON o.code_coding_id = cv.id
WHERE o.effective_datetime >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.effective_datetime DESC;

-- =====================================================================
-- AUDIT TRIGGERS
-- =====================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to main tables
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_practitioners_updated_at BEFORE UPDATE ON practitioners FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_practitioner_roles_updated_at BEFORE UPDATE ON practitioner_roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_episodes_updated_at BEFORE UPDATE ON episodes_of_care FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_encounters_updated_at BEFORE UPDATE ON encounters FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_conditions_updated_at BEFORE UPDATE ON conditions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_procedures_updated_at BEFORE UPDATE ON procedures FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_observations_updated_at BEFORE UPDATE ON observations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_medications_updated_at BEFORE UPDATE ON medications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_med_admin_updated_at BEFORE UPDATE ON medication_administrations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_med_requests_updated_at BEFORE UPDATE ON medication_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_claims_updated_at BEFORE UPDATE ON claims FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- SAMPLE DATA INSERTION FUNCTIONS
-- =====================================================================

-- Function to insert coded values safely
CREATE OR REPLACE FUNCTION insert_coded_value(
    p_system VARCHAR(512),
    p_code VARCHAR(256),
    p_display VARCHAR(512) DEFAULT NULL,
    p_version VARCHAR(64) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO coded_values (system, code, display, version)
    VALUES (p_system, p_code, p_display, p_version)
    ON CONFLICT (system, code, version) DO NOTHING
    RETURNING id INTO v_id;
    
    -- If no insertion happened, get existing ID
    IF v_id IS NULL THEN
        SELECT id INTO v_id 
        FROM coded_values 
        WHERE system = p_system AND code = p_code 
        AND (version = p_version OR (version IS NULL AND p_version IS NULL));
    END IF;
    
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- PERFORMANCE MONITORING
-- =====================================================================

-- Create a view to monitor table sizes and growth
CREATE VIEW v_table_stats AS
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation,
    most_common_vals,
    most_common_freqs
FROM pg_stats 
WHERE schemaname = 'fhir_semantic'
ORDER BY schemaname, tablename, attname;

-- =====================================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================================

-- Table comments
COMMENT ON TABLE patients IS 'Patient demographic and administrative data based on DMPatient profile';
COMMENT ON TABLE organizations IS 'Healthcare organizations and institutions based on DMOrganization profile';
COMMENT ON TABLE locations IS 'Physical locations where healthcare services are provided';
COMMENT ON TABLE practitioners IS 'Healthcare practitioners and professionals';
COMMENT ON TABLE practitioner_roles IS 'Roles played by practitioners in healthcare contexts';
COMMENT ON TABLE episodes_of_care IS 'Episodes of care representing ongoing healthcare contexts';
COMMENT ON TABLE encounters IS 'Healthcare encounters/visits based on DMEncounter profile';
COMMENT ON TABLE conditions IS 'Patient conditions and diagnoses using CIM-10 coding';
COMMENT ON TABLE procedures IS 'Medical procedures using CCAM coding system';
COMMENT ON TABLE observations IS 'Base table for all healthcare observations and measurements';
COMMENT ON TABLE observations_blood_pressure IS 'Blood pressure measurements with systolic/diastolic values';
COMMENT ON TABLE observations_body_height IS 'Height measurements';
COMMENT ON TABLE observations_body_weight IS 'Weight measurements';
COMMENT ON TABLE observations_laboratory IS 'Laboratory test results and measurements';
COMMENT ON TABLE observations_lifestyle IS 'Lifestyle-related observations (smoking, alcohol, exercise)';
COMMENT ON TABLE medications IS 'Medication definitions including French UCD codes';
COMMENT ON TABLE medication_administrations IS 'Records of medication administrations to patients';
COMMENT ON TABLE medication_requests IS 'Medication prescriptions and requests';
COMMENT ON TABLE claims IS 'Base table for PMSI healthcare claims and billing data';
COMMENT ON TABLE claims_pmsi_mco IS 'MCO-specific PMSI claims data with GHM codes';
COMMENT ON TABLE claims_rum IS 'RUM (Résumé d''Unité Médicale) specific claim data';
COMMENT ON TABLE coded_values IS 'Centralized storage for all coded values used across FHIR resources';
COMMENT ON TABLE identifiers IS 'Patient and resource identifiers including INS-NIR';
COMMENT ON TABLE extensions IS 'FHIR extensions for French healthcare-specific data';

-- Column comments for key tables
COMMENT ON COLUMN patients.gender IS 'Patient gender using French Core gender value set';
COMMENT ON COLUMN patients.address_postal_code IS 'French postal code for geographic analysis';
COMMENT ON COLUMN encounters.class_coding_id IS 'Encounter class (ambulatory, emergency, inpatient, etc.)';
COMMENT ON COLUMN conditions.code_coding_id IS 'Condition code using CIM-10 classification';
COMMENT ON COLUMN procedures.code_coding_id IS 'Procedure code using CCAM classification';
COMMENT ON COLUMN observations.observation_type IS 'Discriminator for observation subtypes';
COMMENT ON COLUMN claims.claim_type IS 'Type of PMSI claim (pmsi, pmsi_mco, rum)';

-- Schema documentation
COMMENT ON SCHEMA fhir_semantic IS 'FHIR Semantic Layer schema implementing French healthcare profiles with PMSI support';

-- =====================================================================
-- GRANT STATEMENTS (Adjust based on your security requirements)
-- =====================================================================

-- Grant usage on schema
-- GRANT USAGE ON SCHEMA fhir_semantic TO fhir_read_role, fhir_write_role;

-- Grant select permissions for read role
-- GRANT SELECT ON ALL TABLES IN SCHEMA fhir_semantic TO fhir_read_role;

-- Grant insert, update, delete for write role  
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fhir_semantic TO fhir_write_role;

-- Grant sequence usage
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA fhir_semantic TO fhir_write_role;

-- =====================================================================
-- END OF SCHEMA DEFINITION
-- =====================================================================

RESET search_path;

-- Script completion message
DO $$
BEGIN
    RAISE NOTICE 'FHIR Semantic Layer schema creation completed successfully!';
    RAISE NOTICE 'Schema: fhir_semantic';
    RAISE NOTICE 'Total tables created: ~25';
    RAISE NOTICE 'Indexes created for performance optimization';
    RAISE NOTICE 'Foreign key constraints established for data integrity';
    RAISE NOTICE 'Views created for common query patterns';
    RAISE NOTICE 'Audit triggers enabled for change tracking';
END $$;