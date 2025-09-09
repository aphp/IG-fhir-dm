"""Pathling configuration and setup utilities for Windows compatibility."""

import os
import sys
import tempfile
import logging
from pathlib import Path
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

class PathlingConfig:
    """Configuration manager for Pathling on Windows."""
    
    def __init__(self):
        self.temp_dir: Optional[str] = None
        self.original_env: Dict[str, str] = {}
        
    def setup_environment(self) -> str:
        """Setup environment for Pathling/Spark on Windows."""
        # Create a clean temp directory
        self.temp_dir = tempfile.mkdtemp(prefix="pathling_fhir_")
        
        # Store original environment
        env_vars = [
            "TMPDIR", "TMP", "TEMP", 
            "SPARK_LOCAL_DIRS", "SPARK_WORKER_DIR",
            "SPARK_UI_ENABLED", "PYSPARK_PYTHON"
        ]
        
        for var in env_vars:
            if var in os.environ:
                self.original_env[var] = os.environ[var]
        
        # Set new environment variables
        env_config = {
            "TMPDIR": self.temp_dir,
            "TMP": self.temp_dir,
            "TEMP": self.temp_dir,
            "SPARK_LOCAL_DIRS": self.temp_dir,
            "SPARK_WORKER_DIR": self.temp_dir,
            "SPARK_UI_ENABLED": "false",
            "PYSPARK_PYTHON": sys.executable,
        }
        
        for key, value in env_config.items():
            os.environ[key] = value
            
        logger.info(f"Environment configured with temp dir: {self.temp_dir}")
        return self.temp_dir
    
    def get_spark_config(self) -> Dict[str, Any]:
        """Get Spark configuration for minimal resource usage."""
        return {
            "spark.ui.enabled": "false",
            "spark.sql.adaptive.enabled": "false",
            "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
            "spark.driver.memory": "2g",
            "spark.executor.memory": "1g",
            "spark.sql.adaptive.coalescePartitions.enabled": "false",
            "spark.local.dir": self.temp_dir or tempfile.gettempdir(),
        }
    
    def create_pathling_context(self, timeout: int = 300):
        """Create Pathling context with proper configuration."""
        try:
            from pathling import PathlingContext
            
            # Setup environment first
            if not self.temp_dir:
                self.setup_environment()
            
            logger.info("Initializing Pathling context...")
            
            # Create with minimal configuration - don't try to modify configs after creation
            pc = PathlingContext.create()
            
            logger.info("Pathling context created successfully")
            return pc
            
        except ImportError as e:
            logger.error(f"Pathling not available: {e}")
            raise ImportError("Install pathling with: pip install pathling>=8.0.1")
            
        except Exception as e:
            logger.error(f"Failed to create Pathling context: {e}")
            raise
    
    def cleanup(self):
        """Cleanup environment and temp files."""
        # Restore original environment
        for var, value in self.original_env.items():
            os.environ[var] = value
        
        # Remove temp directory
        if self.temp_dir and Path(self.temp_dir).exists():
            try:
                import shutil
                shutil.rmtree(self.temp_dir)
                logger.info(f"Cleaned up temp directory: {self.temp_dir}")
            except Exception as e:
                logger.warning(f"Could not clean temp directory: {e}")
                
        self.temp_dir = None
        self.original_env.clear()


def create_sample_fhir_data(output_file: Path) -> int:
    """Create sample FHIR patient data for testing."""
    import json
    
    patients = [
        {
            "resourceType": "Patient",
            "id": "patient-001",
            "gender": "male",
            "birthDate": "1980-01-15",
            "address": [
                {
                    "id": "addr-001",
                    "use": "home",
                    "city": "Paris",
                    "state": "Ile-de-France",
                    "country": "France"
                }
            ],
            "managingOrganization": {
                "reference": "Organization/aphp-hopital-001"
            }
        },
        {
            "resourceType": "Patient",
            "id": "patient-002",
            "gender": "female", 
            "birthDate": "1990-06-20",
            "address": [
                {
                    "id": "addr-002",
                    "use": "home",
                    "city": "Lyon",
                    "state": "Rhone-Alpes",
                    "country": "France"
                }
            ],
            "generalPractitioner": [
                {
                    "reference": "Practitioner/gp-001"
                }
            ]
        },
        {
            "resourceType": "Patient",
            "id": "patient-003",
            "gender": "other",
            "birthDate": "1985-12-05",
            "address": [
                {
                    "id": "addr-003", 
                    "use": "work",
                    "city": "Marseille",
                    "state": "PACA",
                    "country": "France"
                }
            ],
            "managingOrganization": {
                "reference": "Organization/aphp-hopital-002"
            },
            "generalPractitioner": [
                {
                    "reference": "Practitioner/gp-002"
                }
            ]
        }
    ]
    
    # Write as NDJSON (each resource on its own line)
    with open(output_file, "w", encoding="utf-8") as f:
        for patient in patients:
            json.dump(patient, f, separators=(',', ':'))
            f.write("\n")
    
    logger.info(f"Created {len(patients)} sample patients at {output_file}")
    return len(patients)


def validate_view_definition(view_def: Dict[str, Any]) -> bool:
    """Validate ViewDefinition structure."""
    required_fields = ["resource", "select"]
    
    for field in required_fields:
        if field not in view_def:
            logger.error(f"Missing required field in ViewDefinition: {field}")
            return False
    
    if view_def["resource"] != "Patient":
        logger.error(f"Expected resource 'Patient', got '{view_def['resource']}'")
        return False
    
    if not view_def["select"] or not view_def["select"][0].get("column"):
        logger.error("ViewDefinition missing columns")
        return False
    
    columns = view_def["select"][0]["column"]
    logger.info(f"ViewDefinition has {len(columns)} columns")
    
    return True


def load_view_definition_safe() -> Optional[Dict[str, Any]]:
    """Safely load the OMOP Person ViewDefinition."""
    import json
    
    # Try multiple possible locations
    possible_paths = [
        Path("../view-definition/omop/OMOP-Person-View.json"),
        Path("omop/OMOP-Person-View.json"),
        Path("../../view-definition/omop/OMOP-Person-View.json"),
        Path("OMOP-Person-View.json")
    ]
    
    for view_def_path in possible_paths:
        if view_def_path.exists():
            try:
                with open(view_def_path, "r", encoding="utf-8") as f:
                    view_def = json.load(f)
                
                if validate_view_definition(view_def):
                    logger.info(f"Successfully loaded ViewDefinition from {view_def_path}")
                    return view_def
                else:
                    logger.warning(f"Invalid ViewDefinition at {view_def_path}")
                    
            except Exception as e:
                logger.warning(f"Failed to load ViewDefinition from {view_def_path}: {e}")
    
    logger.error("Could not find or load ViewDefinition")
    return None