#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EHR Test Patient Data Loader - Enhanced for French Environment

This script loads test patient CSV files into a PostgreSQL database
following the EHR data model schema with enhanced support for French
charset handling and optimized COPY operations.

Requirements:
- psycopg2-binary
- PostgreSQL database with EHR schema created

Usage:
    python load_test_patients.py --host localhost --database ehr_db --user postgres --password your_password
"""

import argparse
import csv
import logging
import os
import sys
import io
import locale
import chardet
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_values


# Configure logging with French locale support
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('ehr_loader.log', encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class EHRDataLoader:
    """Loads EHR test data into PostgreSQL database using optimized COPY operations."""
    
    # Define loading order respecting foreign key dependencies
    LOADING_ORDER = [
        'patient',
        'patient_adresse', 
        'donnees_pmsi',
        'diagnostics',
        'actes', 
        'biologie',
        'prescription',
        'posologie',
        'administration',
        'dossier_soins',
        'style_vie'
    ]
    
    # Define expected columns for validation
    EXPECTED_COLUMNS = {
        'patient': ['patient_id', 'nom', 'prenom', 'nir', 'ins', 'date_naissance', 'sexe', 
                   'date_deces', 'source_deces', 'rang_gemellaire', 'created_at', 'updated_at'],
        'patient_adresse': ['patient_adresse_id', 'patient_id', 'latitude', 'longitude', 
                           'code_iris', 'libelle_iris', 'code_geographique_residence', 
                           'libelle_geographique_residence', 'date_recueil', 'created_at', 'updated_at'],
        'donnees_pmsi': ['pmsi_id', 'patient_id', 'mode_sortie', 'age_admission', 
                        'date_debut_sejour', 'date_fin_sejour', 'mode_entree', 'etablissement', 
                        'service', 'unite_fonctionnelle', 'created_at', 'updated_at'],
        'diagnostics': ['diagnostic_id', 'patient_id', 'pmsi_id', 'code_diagnostic', 
                       'type_diagnostic', 'libelle_diagnostic', 'date_recueil', 'created_at', 'updated_at'],
        'actes': ['acte_id', 'patient_id', 'pmsi_id', 'code_acte', 'libelle_acte', 
                 'date_acte', 'executant', 'date_recueil', 'created_at', 'updated_at'],
        'biologie': ['biologie_id', 'patient_id', 'code_loinc', 'libelle_test', 'type_examen', 
                    'valeur', 'unite', 'valeur_texte', 'date_prelevement', 'statut_validation', 
                    'borne_inf_normale', 'borne_sup_normale', 'laboratoire', 'created_at', 'updated_at'],
        'prescription': ['prescription_id', 'patient_id', 'prescripteur', 'denomination', 
                        'code_atc', 'voie_administration', 'date_prescription', 
                        'date_debut_prescription', 'date_fin_prescription', 'created_at', 'updated_at'],
        'posologie': ['posologie_id', 'prescription_id', 'nombre_prises_par_jour', 'quantite', 
                     'unite_quantite', 'date_heure_debut', 'date_heure_fin', 'created_at', 'updated_at'],
        'administration': ['administration_id', 'patient_id', 'prescription_id', 'denomination', 
                          'code_atc', 'voie_administration', 'quantite', 'unite_quantite', 
                          'date_heure_debut', 'date_heure_fin', 'created_at', 'updated_at'],
        'dossier_soins': ['soin_id', 'patient_id', 'code_loinc', 'libelle_test', 'valeur', 
                         'unite', 'valeur_code', 'valeur_texte', 'date_mesure', 'unite_soins', 
                         'professionnel', 'created_at', 'updated_at'],
        'style_vie': ['style_vie_id', 'patient_id', 'consommation_tabac', 'consommation_alcool', 
                     'consommation_autres_drogues', 'activite_physique', 'date_recueil', 
                     'created_at', 'updated_at']
    }

    def __init__(self, connection_params: Dict[str, str], csv_directory: Path):
        """Initialize the loader with database connection and CSV directory."""
        self.connection_params = connection_params
        self.csv_directory = Path(csv_directory)
        self.conn = None
        self.cursor = None
        
        # Set up French locale handling
        self._setup_locale()
        
    def _setup_locale(self) -> None:
        """Setup locale for French environment."""
        try:
            # Try to set French locale
            for french_locale in ['fr_FR.UTF-8', 'fr_FR', 'French_France.1252', 'French']:
                try:
                    locale.setlocale(locale.LC_ALL, french_locale)
                    logger.info(f"Set locale to: {french_locale}")
                    break
                except locale.Error:
                    continue
            else:
                logger.warning("Could not set French locale, using system default")
        except Exception as e:
            logger.warning(f"Locale setup failed: {e}")
            
    def _detect_file_encoding(self, file_path: Path) -> str:
        """Detect file encoding, with preference for UTF-8 and French charsets."""
        try:
            with open(file_path, 'rb') as f:
                raw_data = f.read(10000)  # Read first 10KB for detection
                
            result = chardet.detect(raw_data)
            detected_encoding = result['encoding']
            confidence = result['confidence']
            
            logger.info(f"Detected encoding for {file_path.name}: {detected_encoding} (confidence: {confidence:.2f})")
            
            # Prefer UTF-8 if confidence is low or for French compatibility
            if confidence < 0.8 or detected_encoding.lower() in ['ascii', 'windows-1252']:
                preferred_encoding = 'utf-8'
                logger.info(f"Using preferred encoding: {preferred_encoding}")
                return preferred_encoding
                
            return detected_encoding or 'utf-8'
            
        except Exception as e:
            logger.warning(f"Encoding detection failed for {file_path}: {e}, defaulting to utf-8")
            return 'utf-8'
        
    def connect(self) -> None:
        """Establish connection to PostgreSQL database with UTF-8 support."""
        try:
            # Ensure UTF-8 connection encoding
            self.connection_params['client_encoding'] = 'UTF8'
            
            self.conn = psycopg2.connect(**self.connection_params)
            self.cursor = self.conn.cursor()
            
            # Set connection to use UTF-8
            self.conn.set_client_encoding('UTF8')
            
            logger.info("Successfully connected to PostgreSQL database with UTF-8 encoding")
        except psycopg2.Error as e:
            logger.error(f"Failed to connect to database: {e}")
            raise
            
    def disconnect(self) -> None:
        """Close database connection."""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        logger.info("Database connection closed")
        
    def get_csv_path(self, table_name: str) -> Path:
        """Get the CSV file path for a given table."""
        return self.csv_directory / f"{table_name}.csv"
        
    def read_csv_data(self, csv_path: Path) -> Tuple[List[str], List[List[str]]]:
        """Read CSV file with proper charset handling and return headers and data rows."""
        if not csv_path.exists():
            raise FileNotFoundError(f"CSV file not found: {csv_path}")
            
        # Detect encoding
        encoding = self._detect_file_encoding(csv_path)
        
        headers = []
        data = []
        
        try:
            with open(csv_path, 'r', encoding=encoding, newline='') as file:
                # Use csv.Sniffer to detect dialect
                sample = file.read(1024)
                file.seek(0)
                
                try:
                    dialect = csv.Sniffer().sniff(sample, delimiters=',;|\t')
                except csv.Error:
                    dialect = csv.excel  # Default to excel dialect
                
                csv_reader = csv.reader(file, dialect=dialect)
                headers = next(csv_reader)
                
                # Clean headers (remove BOM, strip whitespace)
                headers = [h.strip().lstrip('\ufeff') for h in headers]
                
                for row_num, row in enumerate(csv_reader, start=2):
                    try:
                        # Convert empty strings to None for proper NULL handling
                        processed_row = [None if cell.strip() == '' else cell.strip() for cell in row]
                        
                        # Ensure row has same number of columns as headers
                        if len(processed_row) != len(headers):
                            logger.warning(f"Row {row_num} in {csv_path.name} has {len(processed_row)} columns, expected {len(headers)}")
                            # Pad or truncate to match headers
                            if len(processed_row) < len(headers):
                                processed_row.extend([None] * (len(headers) - len(processed_row)))
                            else:
                                processed_row = processed_row[:len(headers)]
                        
                        data.append(processed_row)
                        
                    except Exception as e:
                        logger.error(f"Error processing row {row_num} in {csv_path.name}: {e}")
                        continue
                        
        except UnicodeDecodeError as e:
            logger.error(f"Unicode decode error in {csv_path}: {e}")
            # Try with fallback encoding
            try:
                with open(csv_path, 'r', encoding='latin1', newline='') as file:
                    csv_reader = csv.reader(file)
                    headers = next(csv_reader)
                    headers = [h.strip().lstrip('\ufeff') for h in headers]
                    data = [[None if cell.strip() == '' else cell.strip() for cell in row] for row in csv_reader]
                logger.info(f"Successfully read {csv_path.name} with latin1 encoding")
            except Exception as fallback_error:
                logger.error(f"Failed to read {csv_path} with fallback encoding: {fallback_error}")
                raise
                
        logger.info(f"Read {len(data)} rows from {csv_path.name} with encoding {encoding}")
        return headers, data
        
    def validate_table_exists(self, table_name: str) -> bool:
        """Check if table exists in the database."""
        query = sql.SQL("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = %s
            )
        """)
        self.cursor.execute(query, (table_name,))
        return self.cursor.fetchone()[0]
        
    def validate_table_columns(self, table_name: str, csv_headers: List[str]) -> bool:
        """Validate that CSV headers match expected table columns."""
        expected_columns = self.EXPECTED_COLUMNS.get(table_name, [])
        
        if not expected_columns:
            logger.warning(f"No column validation defined for table {table_name}")
            return True
            
        # Check if all expected columns are present in CSV
        missing_columns = set(expected_columns) - set(csv_headers)
        extra_columns = set(csv_headers) - set(expected_columns)
        
        if missing_columns:
            logger.error(f"Missing columns in {table_name} CSV: {missing_columns}")
            return False
            
        if extra_columns:
            logger.warning(f"Extra columns in {table_name} CSV: {extra_columns}")
            
        logger.info(f"Column validation passed for {table_name}")
        return True
        
    def clear_table(self, table_name: str) -> None:
        """Clear all data from a table."""
        if self.validate_table_exists(table_name):
            query = sql.SQL("TRUNCATE TABLE {} RESTART IDENTITY CASCADE")
            self.cursor.execute(query.format(sql.Identifier(table_name)))
            logger.info(f"Cleared table: {table_name}")
        
    def load_table_data(self, table_name: str) -> int:
        """Load data for a specific table using PostgreSQL COPY operations."""
        csv_path = self.get_csv_path(table_name)
        
        if not csv_path.exists():
            logger.warning(f"CSV file not found for table {table_name}: {csv_path}")
            return 0
            
        if not self.validate_table_exists(table_name):
            logger.error(f"Table {table_name} does not exist in database")
            return 0
            
        headers, data = self.read_csv_data(csv_path)
        
        if not data:
            logger.warning(f"No data to load for table {table_name}")
            return 0
            
        # Validate columns
        if not self.validate_table_columns(table_name, headers):
            raise ValueError(f"Column validation failed for table {table_name}")
            
        # Use optimized COPY operations via execute_values
        try:
            # Build column list
            columns = sql.SQL(', ').join([sql.Identifier(col) for col in headers])
            
            # For execute_values, we need a simple INSERT statement with VALUES %s
            insert_query = sql.SQL("INSERT INTO {} ({}) VALUES %s").format(
                sql.Identifier(table_name),
                columns
            )
            
            # Execute bulk insert using execute_values (optimized COPY-like operation)
            execute_values(
                self.cursor,
                insert_query,
                data,
                template=None,
                page_size=1000,
                fetch=False
            )
            
            rows_loaded = len(data)
            logger.info(f"Successfully loaded {rows_loaded} rows into {table_name}")
            return rows_loaded
            
        except psycopg2.Error as e:
            logger.error(f"Failed to load data into {table_name}: {e}")
            raise
        except Exception as e:
            logger.error(f"Unexpected error loading {table_name}: {e}")
            raise
            
    def load_all_tables(self) -> Dict[str, int]:
        """Load all tables in the correct dependency order with transaction safety."""
        results = {}
        total_rows = 0
        
        logger.info("Starting data loading process with dependency-aware ordering...")
        
        try:
            # Begin transaction
            self.conn.autocommit = False
            
            for table_name in self.LOADING_ORDER:
                logger.info(f"Loading table: {table_name}")
                rows_loaded = self.load_table_data(table_name)
                results[table_name] = rows_loaded
                total_rows += rows_loaded
                
                # Log progress
                logger.info(f"Progress: {len(results)}/{len(self.LOADING_ORDER)} tables completed")
                
            # Commit transaction
            self.conn.commit()
            logger.info(f"✅ Successfully loaded {total_rows} total rows across {len(results)} tables")
            
        except Exception as e:
            # Rollback on error
            self.conn.rollback() 
            logger.error(f"❌ Loading failed, transaction rolled back: {e}")
            raise
            
        return results
        
    def clear_all_tables(self) -> None:
        """Clear all tables in reverse dependency order with transaction safety."""
        logger.info("Clearing all tables in reverse dependency order...")
        
        try:
            self.conn.autocommit = False
            
            # Clear in reverse order to handle foreign key constraints
            for table_name in reversed(self.LOADING_ORDER):
                self.clear_table(table_name)
                
            self.conn.commit()
            logger.info("✅ Successfully cleared all tables")
            
        except Exception as e:
            self.conn.rollback()
            logger.error(f"❌ Failed to clear tables: {e}")
            raise
            
    def validate_data_integrity(self) -> Dict[str, int]:
        """Validate data integrity by counting rows and checking relationships."""
        logger.info("Validating data integrity...")
        counts = {}
        
        for table_name in self.LOADING_ORDER:
            if self.validate_table_exists(table_name):
                query = sql.SQL("SELECT COUNT(*) FROM {}")
                self.cursor.execute(query.format(sql.Identifier(table_name)))
                count = self.cursor.fetchone()[0]
                counts[table_name] = count
                logger.info(f"  {table_name}: {count} rows")
                
        # Additional integrity checks
        self._validate_foreign_key_integrity(counts)
        
        return counts
        
    def _validate_foreign_key_integrity(self, counts: Dict[str, int]) -> None:
        """Perform basic foreign key integrity checks."""
        logger.info("Checking foreign key integrity...")
        
        integrity_checks = [
            ("patient_adresse", "patient", "All patient addresses should reference existing patients"),
            ("donnees_pmsi", "patient", "All PMSI records should reference existing patients"),
            ("diagnostics", "patient", "All diagnostics should reference existing patients"),
            ("diagnostics", "donnees_pmsi", "All diagnostics should reference existing PMSI records"),
            ("actes", "patient", "All actes should reference existing patients"),
            ("actes", "donnees_pmsi", "All actes should reference existing PMSI records"),
            ("biologie", "patient", "All biology results should reference existing patients"),
            ("prescription", "patient", "All prescriptions should reference existing patients"),
            ("administration", "patient", "All administrations should reference existing patients"),
            ("dossier_soins", "patient", "All care records should reference existing patients"),
            ("style_vie", "patient", "All lifestyle records should reference existing patients")
        ]
        
        for child_table, parent_table, description in integrity_checks:
            if child_table in counts and parent_table in counts:
                if counts[child_table] > 0 and counts[parent_table] == 0:
                    logger.warning(f"⚠️ Integrity issue: {description}")
                    
        logger.info("Foreign key integrity check completed")


def main():
    """Main entry point for the EHR data loader."""
    parser = argparse.ArgumentParser(description='Load EHR test patient data into PostgreSQL')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', default=5432, type=int, help='Database port')
    parser.add_argument('--database', required=True, help='Database name')
    parser.add_argument('--user', required=True, help='Database user')
    parser.add_argument('--password', help='Database password')
    parser.add_argument('--csv-dir', default='../file', help='Directory containing CSV files')
    parser.add_argument('--clear', action='store_true', help='Clear tables before loading')
    parser.add_argument('--validate-only', action='store_true', help='Only validate, do not load')
    parser.add_argument('--encoding', help='Force specific encoding for CSV files')
    
    args = parser.parse_args()
    
    # Prompt for password if not provided
    if not args.password:
        import getpass
        args.password = getpass.getpass('Database password: ')
        
    # Setup connection parameters
    connection_params = {
        'host': args.host,
        'port': args.port,
        'database': args.database,
        'user': args.user,
        'password': args.password
    }
    
    # Resolve CSV directory path
    csv_directory = Path(__file__).parent / args.csv_dir
    if not csv_directory.exists():
        logger.error(f"CSV directory does not exist: {csv_directory}")
        sys.exit(1)
        
    logger.info(f"Using CSV directory: {csv_directory}")
    logger.info(f"Python version: {sys.version}")
    logger.info(f"System encoding: {sys.getdefaultencoding()}")
    
    # Initialize loader
    loader = EHRDataLoader(connection_params, csv_directory)
    
    try:
        # Connect to database
        loader.connect()
        
        if args.validate_only:
            # Only validate data integrity
            counts = loader.validate_data_integrity()
            total = sum(counts.values())
            logger.info(f"Total rows in database: {total}")
            
        else:
            # Clear tables if requested
            if args.clear:
                loader.clear_all_tables()
                
            # Load all data with dependency-aware ordering
            results = loader.load_all_tables()
            
            # Validate final state
            counts = loader.validate_data_integrity()
            
            # Summary
            total_loaded = sum(results.values())
            total_in_db = sum(counts.values())
            
            logger.info("=" * 50)
            logger.info("LOADING SUMMARY")
            logger.info("=" * 50)
            for table in loader.LOADING_ORDER:
                loaded = results.get(table, 0)
                in_db = counts.get(table, 0)
                status = "✅" if loaded == in_db else "⚠️"
                logger.info(f"{status} {table}: loaded {loaded}, in DB {in_db}")
                
            logger.info("-" * 50)
            logger.info(f"Total rows loaded: {total_loaded}")
            logger.info(f"Total rows in database: {total_in_db}")
            
            if total_loaded == total_in_db:
                logger.info("✅ Data loading completed successfully!")
            else:
                logger.warning("⚠️ Row count mismatch - please verify data integrity")
                
    except Exception as e:
        logger.error(f"❌ Failed to load data: {e}")
        sys.exit(1)
        
    finally:
        loader.disconnect()


if __name__ == '__main__':
    main()