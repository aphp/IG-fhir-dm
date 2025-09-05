"""
Script to check which tables actually exist in the database and diagnose the issue.
"""

import psycopg2
from psycopg2.extras import RealDictCursor
from config import settings

def check_database_tables():
    """Check what tables and schemas exist in the database."""
    
    config = settings.database

    print(f"Connection details:")
    print(f"  Host: {config.host}")
    print(f"  Port: {config.port}")
    print(f"  Database: {config.database}")
    print(f"  User: {config.user}")
    print(f"  Schema: {config.schema}")
    
    try:
        # Connect to database
        conn = psycopg2.connect(
            host=config.host,
            port=config.port,
            database=config.database,
            user=config.user,
            password=config.password
        )
        
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            # 1. Check if schema exists
            print(f"\n1. Checking if schema '{config.schema}' exists...")
            cursor.execute("""
                SELECT schema_name 
                FROM information_schema.schemata 
                WHERE schema_name = %s
            """, (config.schema,))
            
            schema_result = cursor.fetchone()
            if schema_result:
                print(f"   ✓ Schema '{config.schema}' exists")
            else:
                print(f"   ✗ Schema '{config.schema}' NOT FOUND")
                
                # List available schemas
                cursor.execute("""
                    SELECT schema_name 
                    FROM information_schema.schemata 
                    WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
                    ORDER BY schema_name
                """)
                schemas = cursor.fetchall()
                print("\n   Available schemas:")
                for s in schemas:
                    print(f"     - {s['schema_name']}")
            
            # 2. List all tables in the configured schema
            print(f"\n2. Tables in schema '{config.schema}':")
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = %s
                ORDER BY table_name
            """, (config.schema,))
            
            tables = cursor.fetchall()
            if tables:
                for t in tables:
                    print(f"   - {t['table_name']}")
            else:
                print(f"   No tables found in schema '{config.schema}'")
            
            # 3. Check configured tables
            configured_tables = settings.loader.export_tables_list
            print(f"\n3. Checking configured tables:")
            print(f"   Configured schema: {config.schema}")
            print(f"   Configured tables: {configured_tables}")
            
            for table_name in configured_tables:
                # Check exact match
                cursor.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = %s AND table_name = %s
                """, (config.schema, table_name))
                
                if cursor.fetchone():
                    print(f"   ✓ {table_name} - EXISTS")
                else:
                    # Check case-insensitive
                    cursor.execute("""
                        SELECT table_name 
                        FROM information_schema.tables 
                        WHERE table_schema = %s AND LOWER(table_name) = LOWER(%s)
                    """, (config.schema, table_name))
                    
                    result = cursor.fetchone()
                    if result:
                        print(f"   ⚠ {table_name} - CASE MISMATCH (actual: {result['table_name']})")
                    else:
                        # Check if exists in other schemas
                        cursor.execute("""
                            SELECT table_schema, table_name 
                            FROM information_schema.tables 
                            WHERE LOWER(table_name) = LOWER(%s)
                            LIMIT 5
                        """, (table_name,))
                        
                        other_schemas = cursor.fetchall()
                        if other_schemas:
                            print(f"   ✗ {table_name} - NOT IN SCHEMA (found in: {', '.join([s['table_schema'] for s in other_schemas])})")
                        else:
                            print(f"   ✗ {table_name} - NOT FOUND ANYWHERE")
            
            # 4. Look for FHIR-related tables in any schema
            print(f"\n4. FHIR-related tables in all schemas:")
            cursor.execute("""
                SELECT table_schema, table_name 
                FROM information_schema.tables 
                WHERE table_name LIKE '%fhir%' OR table_name LIKE '%patient%' OR table_name LIKE '%encounter%'
                ORDER BY table_schema, table_name
                LIMIT 20
            """)
            
            fhir_tables = cursor.fetchall()
            if fhir_tables:
                current_schema = None
                for t in fhir_tables:
                    if t['table_schema'] != current_schema:
                        current_schema = t['table_schema']
                        print(f"\n   Schema: {current_schema}")
                    print(f"     - {t['table_name']}")
            else:
                print("   No FHIR-related tables found")
                
        conn.close()
        
    except Exception as e:
        print(f"\nError connecting to database: {e}")
        print(f"Connection details:")
        print(f"  Host: {config.host}")
        print(f"  Port: {config.port}")
        print(f"  Database: {config.database}")
        print(f"  User: {config.user}")
        print(f"  Schema: {config.schema}")


if __name__ == "__main__":
    print("=" * 60)
    print("DATABASE TABLE CHECKER")
    print("=" * 60)
    check_database_tables()
    print("\n" + "=" * 60)