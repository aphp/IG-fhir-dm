"""
FHIR client wrapper with common operations.
"""

import requests
from typing import Dict, Optional, Tuple
from requests.auth import HTTPBasicAuth

class FHIRClientWrapper:
    """Wrapper for FHIR server operations."""

    def __init__(self, base_url: str, auth_enabled: bool = False,
                 username: str = '', password: str = ''):
        """
        Initialize FHIR client.

        Args:
            base_url: FHIR server base URL
            auth_enabled: Enable authentication
            username: Username for basic auth
            password: Password for basic auth
        """
        self.base_url = base_url.rstrip('/')
        self.auth = None
        if auth_enabled and username and password:
            self.auth = HTTPBasicAuth(username, password)

    def test_connection(self) -> Tuple[bool, Optional[str]]:
        """
        Test connection to FHIR server.

        Returns:
            Tuple of (success, server_version)
        """
        try:
            response = requests.get(
                f"{self.base_url}/metadata",
                auth=self.auth,
                timeout=10
            )

            if response.status_code == 200:
                metadata = response.json()
                version = metadata.get('software', {}).get('version', 'unknown')
                return True, version
            else:
                print(f"❌ FHIR server returned status {response.status_code}")
                return False, None

        except requests.exceptions.ConnectionError:
            print(f"❌ Cannot connect to FHIR server at {self.base_url}")
            return False, None
        except Exception as e:
            print(f"❌ Error testing FHIR server: {e}")
            return False, None

    def post_bundle(self, bundle: Dict) -> Tuple[bool, Optional[Dict]]:
        """
        Post a batch bundle to FHIR server.

        Args:
            bundle: FHIR Bundle resource

        Returns:
            Tuple of (success, response_bundle)
        """
        try:
            response = requests.post(
                self.base_url,
                json=bundle,
                auth=self.auth,
                headers={'Content-Type': 'application/fhir+json'},
                timeout=300
            )

            if response.status_code in (200, 201):
                return True, response.json()
            else:
                print(f"❌ FHIR server returned status {response.status_code}")
                print(f"Response: {response.text[:500]}")
                return False, None

        except requests.exceptions.Timeout:
            print(f"❌ Request timeout")
            return False, None
        except Exception as e:
            print(f"❌ Error posting bundle: {e}")
            return False, None
