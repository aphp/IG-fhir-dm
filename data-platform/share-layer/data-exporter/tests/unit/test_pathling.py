"""Simple test to verify Pathling setup."""

import os
import logging
from datetime import datetime, timezone
from pathling import PathlingContext

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    logger.info("Testing Pathling initialization...")
    
    # Create a temp directory in the current directory
    temp_dir = "./temp"
    os.makedirs(temp_dir, exist_ok=True)
    
    # Try setting TMPDIR environment variable
    os.environ["TMPDIR"] = temp_dir
    os.environ["TMP"] = temp_dir
    os.environ["TEMP"] = temp_dir
    
    # Initialize Pathling
    pc = PathlingContext.create()
    logger.info("✅ Pathling context created successfully!")

    view_path = "view-definition/omop/OMOP-Person-View.json"
    with open(view_path, "r", encoding="utf-8") as f:
                view_definition = f.read()
    
    # Test basic functionality
    logger.info("Testing FHIR server connectivity...")

    data = pc.read.bulk(
        fhir_endpoint_url="http://localhost:8080/fhir",
        output_dir="temp/bulk_export",
        types=["Patient"]
    )

    person = data.view(
        "Patient",
        json=view_definition
    )

    person.write.mode("overwrite").option("compression", "snappy").parquet("./output/parquet/Patient.0000.parquet")
    
    logger.info("✅ Test completed successfully!")
    
except Exception as e:
    logger.error(f"❌ Test failed: {e}")
    import traceback
    traceback.print_exc()