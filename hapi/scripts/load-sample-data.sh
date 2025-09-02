#!/bin/bash

# Load Sample FHIR Data Script
# Loads sample Patient and Observation data for testing

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Load environment variables
if [ -f .env ]; then
    source .env
fi

FHIR_URL="http://localhost:${HAPI_PORT:-8080}/fhir"

# Check if server is running
if ! curl -f -s "$FHIR_URL/metadata" > /dev/null; then
    print_error "HAPI FHIR server is not responding at $FHIR_URL"
    print_error "Please start the server first with: ./scripts/start.sh"
    exit 1
fi

print_info "Loading sample FHIR data to $FHIR_URL"

# Create sample Patient
print_info "Creating sample Patient..."
patient_response=$(curl -s -X POST \
  -H "Content-Type: application/fhir+json" \
  -d '{
    "resourceType": "Patient",
    "identifier": [
      {
        "system": "http://hospital.example.org/patients",
        "value": "12345"
      }
    ],
    "active": true,
    "name": [
      {
        "use": "official",
        "family": "Doe",
        "given": ["John", "Edward"]
      }
    ],
    "gender": "male",
    "birthDate": "1980-03-15",
    "address": [
      {
        "use": "home",
        "type": "both",
        "text": "123 Main St, Anytown, USA 12345",
        "line": ["123 Main St"],
        "city": "Anytown",
        "state": "NY",
        "postalCode": "12345",
        "country": "USA"
      }
    ],
    "telecom": [
      {
        "system": "phone",
        "value": "+1-555-123-4567",
        "use": "home"
      },
      {
        "system": "email",
        "value": "john.doe@example.com",
        "use": "home"
      }
    ]
  }' \
  "$FHIR_URL/Patient")

patient_id=$(echo "$patient_response" | grep -o '"id":"[^"]*' | sed 's/"id":"//' | head -1)
if [ -n "$patient_id" ]; then
    print_info "Patient created with ID: $patient_id"
else
    print_error "Failed to create patient"
    exit 1
fi

# Create sample Practitioner
print_info "Creating sample Practitioner..."
practitioner_response=$(curl -s -X POST \
  -H "Content-Type: application/fhir+json" \
  -d '{
    "resourceType": "Practitioner",
    "identifier": [
      {
        "system": "http://hospital.example.org/practitioners",
        "value": "DR001"
      }
    ],
    "active": true,
    "name": [
      {
        "use": "official",
        "family": "Smith",
        "given": ["Jane"],
        "prefix": ["Dr."]
      }
    ],
    "gender": "female",
    "qualification": [
      {
        "identifier": [
          {
            "system": "http://example.org/medical-license",
            "value": "MD123456"
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "309343006",
              "display": "Physician"
            }
          ]
        }
      }
    ]
  }' \
  "$FHIR_URL/Practitioner")

practitioner_id=$(echo "$practitioner_response" | grep -o '"id":"[^"]*' | sed 's/"id":"//' | head -1)
if [ -n "$practitioner_id" ]; then
    print_info "Practitioner created with ID: $practitioner_id"
else
    print_error "Failed to create practitioner"
    exit 1
fi

# Create sample Observation (Blood Pressure)
print_info "Creating sample Blood Pressure Observation..."
curl -s -X POST \
  -H "Content-Type: application/fhir+json" \
  -d "{
    \"resourceType\": \"Observation\",
    \"status\": \"final\",
    \"category\": [
      {
        \"coding\": [
          {
            \"system\": \"http://terminology.hl7.org/CodeSystem/observation-category\",
            \"code\": \"vital-signs\",
            \"display\": \"Vital Signs\"
          }
        ]
      }
    ],
    \"code\": {
      \"coding\": [
        {
          \"system\": \"http://loinc.org\",
          \"code\": \"85354-9\",
          \"display\": \"Blood pressure panel with all children optional\"
        }
      ]
    },
    \"subject\": {
      \"reference\": \"Patient/$patient_id\"
    },
    \"performer\": [
      {
        \"reference\": \"Practitioner/$practitioner_id\"
      }
    ],
    \"effectiveDateTime\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"component\": [
      {
        \"code\": {
          \"coding\": [
            {
              \"system\": \"http://loinc.org\",
              \"code\": \"8480-6\",
              \"display\": \"Systolic blood pressure\"
            }
          ]
        },
        \"valueQuantity\": {
          \"value\": 120,
          \"unit\": \"mmHg\",
          \"system\": \"http://unitsofmeasure.org\",
          \"code\": \"mm[Hg]\"
        }
      },
      {
        \"code\": {
          \"coding\": [
            {
              \"system\": \"http://loinc.org\",
              \"code\": \"8462-4\",
              \"display\": \"Diastolic blood pressure\"
            }
          ]
        },
        \"valueQuantity\": {
          \"value\": 80,
          \"unit\": \"mmHg\",
          \"system\": \"http://unitsofmeasure.org\",
          \"code\": \"mm[Hg]\"
        }
      }
    ]
  }" \
  "$FHIR_URL/Observation" > /dev/null

print_info "Blood Pressure Observation created"

# Create sample Observation (Weight)
print_info "Creating sample Weight Observation..."
curl -s -X POST \
  -H "Content-Type: application/fhir+json" \
  -d "{
    \"resourceType\": \"Observation\",
    \"status\": \"final\",
    \"category\": [
      {
        \"coding\": [
          {
            \"system\": \"http://terminology.hl7.org/CodeSystem/observation-category\",
            \"code\": \"vital-signs\",
            \"display\": \"Vital Signs\"
          }
        ]
      }
    ],
    \"code\": {
      \"coding\": [
        {
          \"system\": \"http://loinc.org\",
          \"code\": \"29463-7\",
          \"display\": \"Body weight\"
        }
      ]
    },
    \"subject\": {
      \"reference\": \"Patient/$patient_id\"
    },
    \"performer\": [
      {
        \"reference\": \"Practitioner/$practitioner_id\"
      }
    ],
    \"effectiveDateTime\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"valueQuantity\": {
      \"value\": 70.5,
      \"unit\": \"kg\",
      \"system\": \"http://unitsofmeasure.org\",
      \"code\": \"kg\"
    }
  }" \
  "$FHIR_URL/Observation" > /dev/null

print_info "Weight Observation created"

# Create sample Encounter
print_info "Creating sample Encounter..."
curl -s -X POST \
  -H "Content-Type: application/fhir+json" \
  -d "{
    \"resourceType\": \"Encounter\",
    \"status\": \"finished\",
    \"class\": {
      \"system\": \"http://terminology.hl7.org/CodeSystem/v3-ActCode\",
      \"code\": \"AMB\",
      \"display\": \"ambulatory\"
    },
    \"type\": [
      {
        \"coding\": [
          {
            \"system\": \"http://snomed.info/sct\",
            \"code\": \"185349003\",
            \"display\": \"Encounter for check up (procedure)\"
          }
        ]
      }
    ],
    \"subject\": {
      \"reference\": \"Patient/$patient_id\"
    },
    \"participant\": [
      {
        \"individual\": {
          \"reference\": \"Practitioner/$practitioner_id\"
        }
      }
    ],
    \"period\": {
      \"start\": \"$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)\",
      \"end\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
    }
  }" \
  "$FHIR_URL/Encounter" > /dev/null

print_info "Encounter created"

echo ""
print_info "Sample data loading completed!"
echo ""
echo "Resources created:"
echo "  - 1 Patient (ID: $patient_id)"
echo "  - 1 Practitioner (ID: $practitioner_id)"  
echo "  - 2 Observations (Blood Pressure, Weight)"
echo "  - 1 Encounter"
echo ""
echo "Test queries:"
echo "  - All Patients: curl '$FHIR_URL/Patient'"
echo "  - Patient by ID: curl '$FHIR_URL/Patient/$patient_id'"
echo "  - Patient Observations: curl '$FHIR_URL/Observation?subject=Patient/$patient_id'"
echo "  - Web UI: http://localhost:${HAPI_PORT:-8080}"