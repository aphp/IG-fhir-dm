#!/usr/bin/env python3
"""
Installation and setup verification script.

This script tests that all dependencies are installed correctly
and the basic functionality works as expected.
"""

import sys
from pathlib import Path
from typing import Dict, Any
import importlib

def test_imports() -> Dict[str, Any]:
    """Test that all required packages can be imported."""
    required_packages = [
        "duckdb",
        "pandas", 
        "pyarrow",
        "loguru",
        "pydantic",
        "typer",
        "rich"
    ]
    
    results = {"passed": True, "details": {}}
    
    for package in required_packages:
        try:
            importlib.import_module(package)
            results["details"][package] = "[OK]"
        except ImportError as e:
            results["passed"] = False
            results["details"][package] = f"[FAIL]: {e}"
    
    return results

def test_local_modules() -> Dict[str, Any]:
    """Test that local modules can be imported."""
    local_modules = ["config", "db_utils", "loader"]
    
    results = {"passed": True, "details": {}}
    
    for module in local_modules:
        try:
            importlib.import_module(module)
            results["details"][module] = "[OK]"
        except ImportError as e:
            results["passed"] = False
            results["details"][module] = f"[FAIL]: {e}"
    
    return results

def test_file_structure() -> Dict[str, Any]:
    """Test that required files and directories exist."""
    current_dir = Path(__file__).parent
    
    required_files = [
        "requirements.txt",
        "config.py",
        "db_utils.py", 
        "loader.py",
        "parquet_to_duckdb.py",
        "test_queries.py",
        ".env.example"
    ]
    
    required_dirs = [
        "../script/output",  # Input directory
        "../sql/omop"       # OMOP SQL directory
    ]
    
    results = {"passed": True, "details": {"files": {}, "directories": {}}}
    
    # Test files
    for file_path in required_files:
        full_path = current_dir / file_path
        if full_path.exists():
            results["details"]["files"][file_path] = "[OK]"
        else:
            results["passed"] = False
            results["details"]["files"][file_path] = "[MISSING]"
    
    # Test directories
    for dir_path in required_dirs:
        full_path = current_dir / dir_path
        if full_path.exists():
            results["details"]["directories"][dir_path] = "[OK]"
        else:
            results["passed"] = False
            results["details"]["directories"][dir_path] = "[MISSING]"
    
    return results

def test_duckdb_functionality() -> Dict[str, Any]:
    """Test basic DuckDB functionality."""
    try:
        import duckdb
        
        # Create in-memory database
        conn = duckdb.connect(":memory:")
        
        # Test basic operations
        conn.execute("CREATE TABLE test (id INTEGER, name VARCHAR)")
        conn.execute("INSERT INTO test VALUES (1, 'test')")
        result = conn.execute("SELECT COUNT(*) FROM test").fetchone()
        
        conn.close()
        
        if result[0] == 1:
            return {"passed": True, "details": "[OK] DuckDB basic operations work"}
        else:
            return {"passed": False, "details": "[FAIL] DuckDB query returned unexpected result"}
            
    except Exception as e:
        return {"passed": False, "details": f"[FAIL] DuckDB test failed: {e}"}

def test_parquet_functionality() -> Dict[str, Any]:
    """Test Parquet file handling."""
    try:
        import pandas as pd
        import pyarrow as pa
        import tempfile
        from pathlib import Path
        
        # Create test DataFrame
        df = pd.DataFrame({
            'id': [1, 2, 3],
            'name': ['Alice', 'Bob', 'Charlie'],
            'age': [25, 30, 35]
        })
        
        # Write to Parquet
        with tempfile.NamedTemporaryFile(suffix='.parquet', delete=False) as tmp:
            df.to_parquet(tmp.name)
            tmp_path = Path(tmp.name)
        
        # Read back
        df_read = pd.read_parquet(tmp_path)
        
        # Cleanup
        tmp_path.unlink()
        
        if len(df_read) == 3 and list(df_read.columns) == ['id', 'name', 'age']:
            return {"passed": True, "details": "[OK] Parquet read/write works"}
        else:
            return {"passed": False, "details": "[FAIL] Parquet data mismatch"}
            
    except Exception as e:
        return {"passed": False, "details": f"[FAIL] Parquet test failed: {e}"}

def test_configuration() -> Dict[str, Any]:
    """Test configuration loading."""
    try:
        from config import DatabaseConfig
        
        config = DatabaseConfig()
        
        # Test basic attributes
        required_attrs = [
            'input_directory', 'output_directory', 'database_name',
            'schema_name', 'memory_limit', 'threads'
        ]
        
        for attr in required_attrs:
            if not hasattr(config, attr):
                return {"passed": False, "details": f"[FAIL] Missing config attribute: {attr}"}
        
        return {"passed": True, "details": "[OK] Configuration loads correctly"}
        
    except Exception as e:
        return {"passed": False, "details": f"[FAIL] Configuration test failed: {e}"}

def main():
    """Run all installation tests."""
    print("Testing Parquet to DuckDB Installation\n")
    
    tests = [
        ("Package Imports", test_imports),
        ("Local Modules", test_local_modules), 
        ("File Structure", test_file_structure),
        ("DuckDB Functionality", test_duckdb_functionality),
        ("Parquet Functionality", test_parquet_functionality),
        ("Configuration", test_configuration)
    ]
    
    all_passed = True
    
    for test_name, test_func in tests:
        print(f"Testing {test_name}...")
        result = test_func()
        
        if result["passed"]:
            print(f"[OK] {test_name}: PASSED")
        else:
            print(f"[FAIL] {test_name}: FAILED")
            all_passed = False
        
        # Print details
        if isinstance(result["details"], dict):
            for key, value in result["details"].items():
                if isinstance(value, dict):
                    print(f"  {key}:")
                    for subkey, subvalue in value.items():
                        print(f"    {subkey}: {subvalue}")
                else:
                    print(f"  {key}: {value}")
        else:
            print(f"  {result['details']}")
        
        print()
    
    # Summary
    if all_passed:
        print("All tests passed! The installation is ready to use.")
        print("\nNext steps:")
        print("1. Review configuration in .env file")
        print("2. Ensure Parquet files are in the input directory")
        print("3. Run: python parquet_to_duckdb.py load")
        return 0
    else:
        print("Some tests failed. Please check the issues above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())