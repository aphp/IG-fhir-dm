"""
Debug script to check environment variable loading.
"""

import os
from dotenv import load_dotenv, find_dotenv

# First, let's check what's in the environment before loading .env
print("=" * 60)
print("ENVIRONMENT VARIABLE DEBUG")
print("=" * 60)

print("\n1. Environment variables BEFORE loading .env:")
dbt_vars_before = {k: v for k, v in os.environ.items() if k.startswith('DBT')}
if dbt_vars_before:
    for k, v in dbt_vars_before.items():
        print(f"   {k} = {v}")
else:
    print("   No DBT_ variables found")

# Load .env file
print("\n2. Loading .env file...")
env_file = find_dotenv()
if env_file:
    print(f"   Found .env at: {env_file}")
    load_dotenv(env_file, override=True)
else:
    print("   No .env file found")

print("\n3. Environment variables AFTER loading .env:")
dbt_vars_after = {k: v for k, v in os.environ.items() if k.startswith('DBT')}
for k, v in dbt_vars_after.items():
    print(f"   {k} = {v}")

# Now test the config loading
print("\n4. Testing DatabaseConfig loading:")
from config import DatabaseConfig

# Create instance
db_config = DatabaseConfig()

print(f"   host: {db_config.host}")
print(f"   port: {db_config.port}")
print(f"   user: {db_config.user}")
print(f"   database: {db_config.database}")
print(f"   schema: {db_config.schema}")

# Also check if there's a system environment variable overriding
print("\n5. Checking for system environment variables:")
print(f"   DBT_SCHEMA from os.environ: {os.environ.get('DBT_SCHEMA', 'NOT SET')}")

# Check if there's another .env file
print("\n6. Checking for other .env files:")
import pathlib
current_dir = pathlib.Path.cwd()
parent_dir = current_dir.parent

for path in [current_dir, parent_dir]:
    env_files = list(path.glob('.env*'))
    if env_files:
        print(f"   In {path}:")
        for f in env_files:
            print(f"     - {f.name}")
            if f.name == '.env':
                with open(f, 'r') as file:
                    lines = [line.strip() for line in file if 'DBT_SCHEMA' in line]
                    if lines:
                        print(f"       Contains: {lines[0]}")

print("\n" + "=" * 60)