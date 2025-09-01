"""
FHIR data transformation module.
"""

import json
from typing import Dict, List, Any, Optional
from datetime import datetime, date
from decimal import Decimal
from loguru import logger


class FHIRTransformer:
    """Transforms database records to FHIR-compliant resources."""
    
    # Mapping of database tables to FHIR resource types
    TABLE_TO_RESOURCE = {
        "fhir_patient": "Patient",
        "fhir_encounter": "Encounter",
        "fhir_condition": "Condition",
        "fhir_procedure": "Procedure",
        "fhir_observation": "Observation",
        "fhir_medication_request": "MedicationRequest",
        "fhir_medication_administration": "MedicationAdministration",
        "fhir_organization": "Organization",
        "fhir_location": "Location",
        "fhir_practitioner": "Practitioner",
        "fhir_practitioner_role": "PractitionerRole",
        "fhir_episode_of_care": "EpisodeOfCare",
        "fhir_claim": "Claim"
    }
    
    def transform_batch(
        self,
        records: List[Dict[str, Any]],
        table_name: str
    ) -> List[Dict[str, Any]]:
        """
        Transform a batch of database records to FHIR resources.
        
        Args:
            records: List of database records
            table_name: Name of the source table
            
        Returns:
            List of FHIR resources
        """
        resource_type = self.TABLE_TO_RESOURCE.get(table_name)
        if not resource_type:
            logger.warning(f"Unknown table: {table_name}")
            return records
        
        transformed = []
        for record in records:
            fhir_resource = self.transform_record(record, resource_type, table_name)
            transformed.append(fhir_resource)
        
        return transformed
    
    def transform_record(
        self,
        record: Dict[str, Any],
        resource_type: str,
        table_name: str
    ) -> Dict[str, Any]:
        """
        Transform a single database record to a FHIR resource.
        
        Args:
            record: Database record
            resource_type: FHIR resource type
            table_name: Source table name
            
        Returns:
            FHIR resource dictionary
        """
        # Get the appropriate transformation method
        transform_method = getattr(
            self,
            f"_transform_{table_name}",
            self._default_transform
        )
        
        # Apply transformation
        fhir_resource = transform_method(record, resource_type)
        
        # Ensure resource type is set
        fhir_resource["resourceType"] = resource_type
        
        # Clean up the resource
        fhir_resource = self._clean_resource(fhir_resource)
        
        return fhir_resource
    
    def _default_transform(
        self,
        record: Dict[str, Any],
        resource_type: str
    ) -> Dict[str, Any]:
        """
        Default transformation for any FHIR resource.
        
        Args:
            record: Database record
            resource_type: FHIR resource type
            
        Returns:
            FHIR resource dictionary
        """
        fhir_resource = {
            "resourceType": resource_type,
            "id": record.get("id")
        }
        
        # Add meta information
        if record.get("version_id") or record.get("last_updated"):
            fhir_resource["meta"] = {}
            if record.get("version_id"):
                fhir_resource["meta"]["versionId"] = record.get("version_id")
            if record.get("last_updated"):
                fhir_resource["meta"]["lastUpdated"] = self._format_datetime(record.get("last_updated"))
        
        # Process all fields
        exclude_fields = {
            "id", "version_id", "last_updated", "created_at", "updated_at"
        }
        
        for key, value in record.items():
            if key not in exclude_fields and value is not None:
                # Parse JSONB fields
                if isinstance(value, str) and (value.startswith('{') or value.startswith('[')):
                    try:
                        value = json.loads(value)
                    except json.JSONDecodeError:
                        pass
                
                # Convert field name to FHIR format
                fhir_key = self._to_fhir_field_name(key)
                fhir_resource[fhir_key] = value
        
        return fhir_resource
    
    def _transform_fhir_patient(
        self,
        record: Dict[str, Any],
        resource_type: str
    ) -> Dict[str, Any]:
        """Transform Patient resource."""
        fhir_resource = {
            "resourceType": "Patient",
            "id": record.get("id")
        }
        
        # Meta information
        if record.get("version_id") or record.get("last_updated"):
            fhir_resource["meta"] = {}
            if record.get("version_id"):
                fhir_resource["meta"]["versionId"] = record.get("version_id")
            if record.get("last_updated"):
                fhir_resource["meta"]["lastUpdated"] = self._format_datetime(record.get("last_updated"))
            if record.get("meta"):
                fhir_resource["meta"].update(self._parse_json(record.get("meta")))
        
        # Active status
        if record.get("active") is not None:
            fhir_resource["active"] = record.get("active")
        
        # Identifiers
        identifiers = []
        
        if record.get("identifier"):
            parsed_identifiers = self._parse_json(record.get("identifier"))
            if isinstance(parsed_identifiers, list):
                identifiers.extend(parsed_identifiers)
        
        if record.get("nss_identifier"):
            identifiers.append({
                "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                "value": record.get("nss_identifier"),
                "use": "official"
            })
        
        if record.get("ins_nir_identifier"):
            identifiers.append({
                "system": "urn:oid:1.2.250.1.213.1.4.8",
                "value": record.get("ins_nir_identifier"),
                "use": "official"
            })
        
        if identifiers:
            fhir_resource["identifier"] = identifiers
        
        # Names
        names = []
        
        if record.get("name"):
            parsed_names = self._parse_json(record.get("name"))
            if isinstance(parsed_names, list):
                names.extend(parsed_names)
        
        if record.get("family_name") or record.get("given_names"):
            name = {}
            if record.get("family_name"):
                name["family"] = record.get("family_name")
            if record.get("given_names"):
                name["given"] = record.get("given_names").split()
            name["use"] = "official"
            names.append(name)
        
        if names:
            fhir_resource["name"] = names
        
        # Demographics
        if record.get("gender"):
            fhir_resource["gender"] = record.get("gender")
        
        if record.get("birthdate"):
            fhir_resource["birthDate"] = self._format_date(record.get("birthdate"))
        
        # Deceased
        if record.get("deceased_boolean") is not None:
            if record.get("deceased_date_time"):
                fhir_resource["deceasedDateTime"] = self._format_datetime(record.get("deceased_date_time"))
            else:
                fhir_resource["deceasedBoolean"] = record.get("deceased_boolean")
        
        # Addresses
        if record.get("address"):
            addresses = self._parse_json(record.get("address"))
            if isinstance(addresses, list):
                fhir_resource["address"] = addresses
        
        # Telecoms
        if record.get("telecom"):
            telecoms = self._parse_json(record.get("telecom"))
            if isinstance(telecoms, list):
                fhir_resource["telecom"] = telecoms
        
        # Multiple birth
        if record.get("multiple_birth_boolean") is not None:
            if record.get("multiple_birth_integer"):
                fhir_resource["multipleBirthInteger"] = record.get("multiple_birth_integer")
            else:
                fhir_resource["multipleBirthBoolean"] = record.get("multiple_birth_boolean")
        
        # Extensions
        extensions = []
        
        if record.get("birth_place"):
            extensions.append({
                "url": "http://hl7.org/fhir/StructureDefinition/patient-birthPlace",
                "valueAddress": {"text": record.get("birth_place")}
            })
        
        if record.get("nationality"):
            extensions.append({
                "url": "http://hl7.org/fhir/StructureDefinition/patient-nationality",
                "valueCode": record.get("nationality")
            })
        
        if record.get("extensions"):
            parsed_extensions = self._parse_json(record.get("extensions"))
            if isinstance(parsed_extensions, list):
                extensions.extend(parsed_extensions)
        
        if extensions:
            fhir_resource["extension"] = extensions
        
        return fhir_resource
    
    def _transform_fhir_encounter(
        self,
        record: Dict[str, Any],
        resource_type: str
    ) -> Dict[str, Any]:
        """Transform Encounter resource."""
        fhir_resource = {
            "resourceType": "Encounter",
            "id": record.get("id")
        }
        
        # Meta information
        if record.get("version_id") or record.get("last_updated"):
            fhir_resource["meta"] = {}
            if record.get("version_id"):
                fhir_resource["meta"]["versionId"] = record.get("version_id")
            if record.get("last_updated"):
                fhir_resource["meta"]["lastUpdated"] = self._format_datetime(record.get("last_updated"))
        
        # Status
        if record.get("status"):
            fhir_resource["status"] = record.get("status")
        
        # Class
        if record.get("class"):
            class_data = self._parse_json(record.get("class"))
            if class_data:
                fhir_resource["class"] = class_data
        
        # Types
        if record.get("types"):
            types = self._parse_json(record.get("types"))
            if isinstance(types, list):
                fhir_resource["type"] = types
        
        # Subject (Patient reference)
        if record.get("patient_id"):
            fhir_resource["subject"] = {
                "reference": f"Patient/{record.get('patient_id')}"
            }
        
        # Period
        if record.get("period_start") or record.get("period_end"):
            period = {}
            if record.get("period_start"):
                period["start"] = self._format_datetime(record.get("period_start"))
            if record.get("period_end"):
                period["end"] = self._format_datetime(record.get("period_end"))
            fhir_resource["period"] = period
        
        # Service provider
        if record.get("service_provider_id"):
            fhir_resource["serviceProvider"] = {
                "reference": f"Organization/{record.get('service_provider_id')}"
            }
        
        # Participants
        if record.get("participants"):
            participants = self._parse_json(record.get("participants"))
            if isinstance(participants, list):
                fhir_resource["participant"] = participants
        
        # Diagnoses
        if record.get("diagnoses"):
            diagnoses = self._parse_json(record.get("diagnoses"))
            if isinstance(diagnoses, list):
                fhir_resource["diagnosis"] = diagnoses
        
        # Locations
        if record.get("locations"):
            locations = self._parse_json(record.get("locations"))
            if isinstance(locations, list):
                fhir_resource["location"] = locations
        
        return fhir_resource
    
    def _transform_fhir_condition(
        self,
        record: Dict[str, Any],
        resource_type: str
    ) -> Dict[str, Any]:
        """Transform Condition resource."""
        fhir_resource = {
            "resourceType": "Condition",
            "id": record.get("id")
        }
        
        # Meta information
        if record.get("version_id") or record.get("last_updated"):
            fhir_resource["meta"] = {}
            if record.get("version_id"):
                fhir_resource["meta"]["versionId"] = record.get("version_id")
            if record.get("last_updated"):
                fhir_resource["meta"]["lastUpdated"] = self._format_datetime(record.get("last_updated"))
        
        # Clinical status
        if record.get("clinical_status"):
            clinical_status = self._parse_json(record.get("clinical_status"))
            if clinical_status:
                fhir_resource["clinicalStatus"] = clinical_status
        
        # Verification status
        if record.get("verification_status"):
            verification_status = self._parse_json(record.get("verification_status"))
            if verification_status:
                fhir_resource["verificationStatus"] = verification_status
        
        # Categories
        if record.get("categories"):
            categories = self._parse_json(record.get("categories"))
            if isinstance(categories, list):
                fhir_resource["category"] = categories
        
        # Code (CIM-10)
        if record.get("code"):
            code = self._parse_json(record.get("code"))
            if code:
                fhir_resource["code"] = code
        
        # Subject (Patient reference)
        if record.get("subject_patient_id"):
            fhir_resource["subject"] = {
                "reference": f"Patient/{record.get('subject_patient_id')}"
            }
        
        # Encounter
        if record.get("encounter_id"):
            fhir_resource["encounter"] = {
                "reference": f"Encounter/{record.get('encounter_id')}"
            }
        
        # Onset
        if record.get("onset_date_time"):
            fhir_resource["onsetDateTime"] = self._format_datetime(record.get("onset_date_time"))
        elif record.get("onset_period"):
            fhir_resource["onsetPeriod"] = self._parse_json(record.get("onset_period"))
        elif record.get("onset_string"):
            fhir_resource["onsetString"] = record.get("onset_string")
        
        # Abatement
        if record.get("abatement_date_time"):
            fhir_resource["abatementDateTime"] = self._format_datetime(record.get("abatement_date_time"))
        elif record.get("abatement_boolean") is not None:
            fhir_resource["abatementBoolean"] = record.get("abatement_boolean")
        elif record.get("abatement_string"):
            fhir_resource["abatementString"] = record.get("abatement_string")
        
        # Recorded date
        if record.get("recorded_date"):
            fhir_resource["recordedDate"] = self._format_date(record.get("recorded_date"))
        
        return fhir_resource
    
    def _transform_fhir_observation(
        self,
        record: Dict[str, Any],
        resource_type: str
    ) -> Dict[str, Any]:
        """Transform Observation resource."""
        fhir_resource = {
            "resourceType": "Observation",
            "id": record.get("id")
        }
        
        # Meta information
        if record.get("version_id") or record.get("last_updated"):
            fhir_resource["meta"] = {}
            if record.get("version_id"):
                fhir_resource["meta"]["versionId"] = record.get("version_id")
            if record.get("last_updated"):
                fhir_resource["meta"]["lastUpdated"] = self._format_datetime(record.get("last_updated"))
        
        # Status
        if record.get("status"):
            fhir_resource["status"] = record.get("status")
        
        # Categories
        if record.get("categories"):
            categories = self._parse_json(record.get("categories"))
            if isinstance(categories, list):
                fhir_resource["category"] = categories
        
        # Code (LOINC)
        if record.get("code"):
            code = self._parse_json(record.get("code"))
            if code:
                fhir_resource["code"] = code
        
        # Subject (Patient reference)
        if record.get("subject_patient_id"):
            fhir_resource["subject"] = {
                "reference": f"Patient/{record.get('subject_patient_id')}"
            }
        
        # Encounter
        if record.get("encounter_id"):
            fhir_resource["encounter"] = {
                "reference": f"Encounter/{record.get('encounter_id')}"
            }
        
        # Effective
        if record.get("effective_date_time"):
            fhir_resource["effectiveDateTime"] = self._format_datetime(record.get("effective_date_time"))
        elif record.get("effective_period"):
            fhir_resource["effectivePeriod"] = self._parse_json(record.get("effective_period"))
        
        # Value
        if record.get("value_quantity"):
            fhir_resource["valueQuantity"] = self._parse_json(record.get("value_quantity"))
        elif record.get("value_codeable_concept"):
            fhir_resource["valueCodeableConcept"] = self._parse_json(record.get("value_codeable_concept"))
        elif record.get("value_string"):
            fhir_resource["valueString"] = record.get("value_string")
        elif record.get("value_boolean") is not None:
            fhir_resource["valueBoolean"] = record.get("value_boolean")
        elif record.get("value_integer") is not None:
            fhir_resource["valueInteger"] = record.get("value_integer")
        
        # Interpretation
        if record.get("interpretations"):
            interpretations = self._parse_json(record.get("interpretations"))
            if isinstance(interpretations, list):
                fhir_resource["interpretation"] = interpretations
        
        # Reference ranges
        if record.get("reference_ranges"):
            reference_ranges = self._parse_json(record.get("reference_ranges"))
            if isinstance(reference_ranges, list):
                fhir_resource["referenceRange"] = reference_ranges
        
        return fhir_resource
    
    def _to_fhir_field_name(self, snake_case: str) -> str:
        """Convert snake_case to camelCase for FHIR field names."""
        components = snake_case.split('_')
        return components[0] + ''.join(x.title() for x in components[1:])
    
    def _parse_json(self, value: Any) -> Any:
        """Parse JSON string if needed."""
        if value is None:
            return None
        
        if isinstance(value, str):
            if value.startswith('{') or value.startswith('['):
                try:
                    return json.loads(value)
                except json.JSONDecodeError:
                    return value
        
        return value
    
    def _format_datetime(self, dt: Any) -> str:
        """Format datetime for FHIR."""
        if dt is None:
            return None
        
        if isinstance(dt, str):
            return dt
        
        if isinstance(dt, datetime):
            return dt.isoformat()
        
        return str(dt)
    
    def _format_date(self, d: Any) -> str:
        """Format date for FHIR."""
        if d is None:
            return None
        
        if isinstance(d, str):
            return d
        
        if isinstance(d, date):
            return d.isoformat()
        
        return str(d)
    
    def _clean_resource(self, resource: Dict[str, Any]) -> Dict[str, Any]:
        """Remove null values and empty fields from FHIR resource."""
        cleaned = {}
        
        for key, value in resource.items():
            if value is not None:
                if isinstance(value, dict):
                    cleaned_dict = self._clean_resource(value)
                    if cleaned_dict:
                        cleaned[key] = cleaned_dict
                elif isinstance(value, list):
                    cleaned_list = [
                        self._clean_resource(item) if isinstance(item, dict) else item
                        for item in value
                        if item is not None
                    ]
                    if cleaned_list:
                        cleaned[key] = cleaned_list
                elif value != "" and value != []:
                    cleaned[key] = value
        
        return cleaned