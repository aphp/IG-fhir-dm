#!/usr/bin/env python3
"""
FHIR QuestionnaireResponse to PostgreSQL Database Population Script

This script processes FHIR QuestionnaireResponse JSON files and populates
a PostgreSQL health data warehouse with proper security controls and validation.

Author: Generated for APHP FHIR Implementation Guide
Date: 2025-08-29
Python Version: 3.11+

Dependencies:
    pandas>=2.1.0
    psycopg2-binary>=2.9.7
    sqlalchemy>=2.0.20
    cryptography>=41.0.4
    python-dateutil>=2.8.2
    structlog>=23.1.0

Security Features:
    - Field-level encryption for PII/PHI data
    - SQL injection prevention through parameterized queries
    - Comprehensive audit logging
    - GDPR compliance support
    - Database connection security
"""

import os
import json
import logging
import hashlib
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime, date
from contextlib import contextmanager
import re

import pandas as pd
import psycopg2
from psycopg2 import pool
import sqlalchemy as sa
from sqlalchemy import create_engine, text
from cryptography.fernet import Fernet
import structlog


# Configure structured logging
structlog.configure(
    processors=[
        structlog.dev.ConsoleRenderer(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer()
    ],
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


class HealthcareSecurityService:
    """Security service for handling sensitive healthcare data"""
    
    def __init__(self):
        # Initialize encryption - in production, key should come from secure key management
        encryption_key = os.getenv('FHIR_ENCRYPTION_KEY')
        if not encryption_key:
            # Generate key for development (DO NOT USE IN PRODUCTION)
            encryption_key = Fernet.generate_key().decode()
            logger.warning("Using generated encryption key - not suitable for production")
        
        if isinstance(encryption_key, str):
            encryption_key = encryption_key.encode()
            
        self.fernet = Fernet(encryption_key)
        
    def encrypt_field(self, value: str) -> str:
        """Encrypt sensitive field for database storage"""
        if not value:
            return value
        return self.fernet.encrypt(value.encode()).decode()
    
    def hash_patient_id(self, patient_data: Dict) -> str:
        """Generate consistent but non-reversible patient identifier"""
        # Combine stable identifiers for hashing
        combined = f"{patient_data.get('nom_patient', '')}{patient_data.get('nir', '')}"
        return hashlib.sha256(combined.encode()).hexdigest()[:16]


class FHIRDataValidator:
    """Validator for FHIR and French healthcare data standards"""
    
    # French NIR (National Insurance Number) pattern
    NIR_PATTERN = re.compile(r'^[0-9]{13}$|^[0-9]{15}$')
    
    # LOINC code pattern
    LOINC_PATTERN = re.compile(r'^[0-9]{1,5}-[0-9]$')
    
    # ICD-10 code pattern
    ICD10_PATTERN = re.compile(r'^[A-Z][0-9]{2}(\.[0-9]{1,2})?$')
    
    @classmethod
    def validate_nir(cls, nir: str) -> bool:
        """Validate French NIR format"""
        if not nir or not isinstance(nir, str):
            return False
        return bool(cls.NIR_PATTERN.match(nir.strip()))
    
    @classmethod
    def validate_loinc_code(cls, code: str) -> bool:
        """Validate LOINC code format"""
        if not code:
            return True  # Optional field
        return bool(cls.LOINC_PATTERN.match(code.strip()))
    
    @classmethod
    def validate_icd10_code(cls, code: str) -> bool:
        """Validate ICD-10 diagnostic code format"""
        if not code:
            return True  # Optional field
        return bool(cls.ICD10_PATTERN.match(code.strip()))
    
    @classmethod
    def validate_date_constraints(cls, birth_date: str, other_date: str = None) -> bool:
        """Validate healthcare-specific date constraints"""
        try:
            birth = datetime.strptime(birth_date, '%Y-%m-%d').date()
            
            # Birth date cannot be in future
            if birth > date.today():
                logger.warning("Birth date in future", birth_date=birth_date)
                return False
            
            # If comparing with another date
            if other_date:
                other = datetime.strptime(other_date, '%Y-%m-%d').date()
                if other < birth:
                    logger.warning("Date before birth date", 
                                 birth_date=birth_date, other_date=other_date)
                    return False
                    
            return True
        except ValueError as e:
            logger.error("Invalid date format", error=str(e))
            return False
    
    @classmethod
    def validate_coordinates(cls, latitude: float, longitude: float) -> bool:
        """Validate geographic coordinates"""
        if not (-90 <= latitude <= 90):
            return False
        if not (-180 <= longitude <= 180):
            return False
        return True


class DatabaseManager:
    """Database connection and transaction management"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.engine = None
        self._setup_database_connection()
    
    def _setup_database_connection(self):
        """Setup SQLAlchemy engine with connection pooling"""
        db_url = (
            f"postgresql://{self.config['user']}:{self.config['password']}"
            f"@{self.config['host']}:{self.config['port']}/{self.config['database']}"
            f"?sslmode={self.config.get('sslmode', 'require')}"
        )
        
        self.engine = create_engine(
            db_url,
            pool_size=self.config.get('pool_size', 5),
            max_overflow=self.config.get('max_overflow', 10),
            pool_timeout=self.config.get('pool_timeout', 30),
            pool_recycle=self.config.get('pool_recycle', 3600),
            echo=self.config.get('echo', False)
        )
        
        logger.info("Database connection established", 
                   host=self.config['host'], database=self.config['database'])
    
    @contextmanager
    def get_connection(self):
        """Get database connection with automatic cleanup"""
        conn = None
        try:
            conn = self.engine.connect()
            yield conn
        except Exception as e:
            if conn:
                conn.rollback()
            logger.error("Database operation failed", error=str(e))
            raise
        finally:
            if conn:
                conn.close()
    
    def insert_dataframe(self, table_name: str, df: pd.DataFrame, 
                        if_exists: str = 'append') -> int:
        """Insert DataFrame into database table"""
        with self.get_connection() as conn:
            rows_inserted = df.to_sql(
                table_name,
                conn,
                if_exists=if_exists,
                index=False,
                method='multi',
                chunksize=1000
            )
            logger.info("Data inserted", table=table_name, rows=len(df))
            return rows_inserted


class FHIRQuestionnaireProcessor:
    """Main processor for FHIR QuestionnaireResponse data"""
    
    # Mapping from FHIR linkId to database table and column
    LINK_ID_MAPPING = {
        # Patient identity mappings
        '8605698058770': ('identite_patient', 'nom_patient'),
        '6214879623503': ('identite_patient', 'prenom_patient'),
        '5711960356160': ('identite_patient', 'nir'),
        '5036133558154': ('identite_patient', 'date_naissance'),
        
        # Geographic mappings
        '3709843054556': ('geocodage', 'latitude'),
        '7651448032665': ('geocodage', 'longitude'),
        '1185653257776': ('geocodage', 'date_recueil'),
        
        # Demographics mappings
        '8164976487070': ('donnees_socio_demographiques', 'age'),
        '1690778867802': ('donnees_socio_demographiques', 'date_recueil_age'),
        '3894630481120': ('donnees_socio_demographiques', 'sexe'),
    }
    
    def __init__(self, db_manager: DatabaseManager, security_service: HealthcareSecurityService):
        self.db_manager = db_manager
        self.security_service = security_service
        self.validator = FHIRDataValidator()
        self.processing_stats = {
            'records_processed': 0,
            'validation_errors': 0,
            'insertion_errors': 0
        }
    
    def process_questionnaire_response(self, file_path: Path) -> Dict[str, Any]:
        """Process a single FHIR QuestionnaireResponse file"""
        logger.info("Processing QuestionnaireResponse", file_path=str(file_path))
        
        try:
            # Load and validate JSON
            with open(file_path, 'r', encoding='utf-8') as f:
                questionnaire_data = json.load(f)
            
            # Extract patient ID from subject
            patient_id = self._extract_patient_id(questionnaire_data)
            
            # Extract data for each table
            extracted_data = self._extract_table_data(questionnaire_data, patient_id)
            
            # Validate extracted data
            validated_data = self._validate_extracted_data(extracted_data)
            
            # Insert data into database in proper order (respecting foreign keys)
            insertion_results = self._insert_data_in_order(validated_data)
            
            self.processing_stats['records_processed'] += 1
            
            logger.info("QuestionnaireResponse processed successfully",
                       patient_id=patient_id, 
                       tables_updated=list(insertion_results.keys()))
            
            return {
                'success': True,
                'patient_id': patient_id,
                'tables_updated': list(insertion_results.keys()),
                'insertion_results': insertion_results
            }
            
        except Exception as e:
            self.processing_stats['insertion_errors'] += 1
            logger.error("Failed to process QuestionnaireResponse", 
                        file_path=str(file_path), error=str(e))
            return {
                'success': False,
                'error': str(e),
                'file_path': str(file_path)
            }
    
    def _extract_patient_id(self, questionnaire_data: Dict) -> str:
        """Extract patient ID from questionnaire response"""
        try:
            # Extract from subject.identifier.value or subject.reference
            subject = questionnaire_data.get('subject', {})
            if 'identifier' in subject:
                return subject['identifier']['value']
            elif 'reference' in subject:
                # Extract from reference like "Patient/123"
                ref = subject['reference']
                return ref.split('/')[-1]
            else:
                # Fallback: generate from questionnaire ID
                return questionnaire_data.get('id', 'unknown')
        except Exception as e:
            logger.warning("Could not extract patient ID", error=str(e))
            return 'unknown'
    
    def _extract_table_data(self, questionnaire_data: Dict, patient_id: str) -> Dict[str, Dict]:
        """Extract data for each database table from questionnaire response"""
        extracted_data = {
            'identite_patient': {'patient_id': patient_id},
            'geocodage': {'patient_id': patient_id},
            'donnees_socio_demographiques': {'patient_id': patient_id}
        }
        
        # Recursively extract data from questionnaire items
        def extract_from_items(items: List[Dict]):
            for item in items:
                link_id = item.get('linkId')
                
                # Check if this linkId maps to a database field
                if link_id in self.LINK_ID_MAPPING:
                    table_name, column_name = self.LINK_ID_MAPPING[link_id]
                    
                    # Extract answer value
                    answers = item.get('answer', [])
                    if answers:
                        value = self._extract_answer_value(answers[0])
                        if value is not None:
                            extracted_data[table_name][column_name] = value
                
                # Recursively process nested items
                if 'item' in item:
                    extract_from_items(item['item'])
        
        # Start extraction from root items
        items = questionnaire_data.get('item', [])
        extract_from_items(items)
        
        return extracted_data
    
    def _extract_answer_value(self, answer: Dict) -> Any:
        """Extract value from FHIR answer object"""
        # Handle different value types
        for key in answer.keys():
            if key.startswith('value'):
                value = answer[key]
                # Handle special cases
                if key == 'valueCoding':
                    return value.get('display', value.get('code'))
                return value
        return None
    
    def _validate_extracted_data(self, extracted_data: Dict[str, Dict]) -> Dict[str, pd.DataFrame]:
        """Validate extracted data and convert to DataFrames"""
        validated_data = {}
        
        for table_name, data in extracted_data.items():
            if not data or len(data) <= 1:  # Only patient_id
                continue
                
            # Create DataFrame
            df = pd.DataFrame([data])
            
            # Apply table-specific validation
            if table_name == 'identite_patient':
                df = self._validate_patient_data(df)
            elif table_name == 'geocodage':
                df = self._validate_geocoding_data(df)
            elif table_name == 'donnees_socio_demographiques':
                df = self._validate_demographic_data(df)
            
            if not df.empty:
                validated_data[table_name] = df
        
        return validated_data
    
    def _validate_patient_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Validate patient identity data"""
        if df.empty:
            return df
        
        # Validate NIR format
        if 'nir' in df.columns:
            valid_nir = df['nir'].apply(self.validator.validate_nir)
            if not valid_nir.all():
                self.processing_stats['validation_errors'] += 1
                logger.warning("Invalid NIR format detected", 
                              invalid_count=len(df) - valid_nir.sum())
                df = df[valid_nir]
        
        # Validate birth date
        if 'date_naissance' in df.columns:
            valid_dates = df['date_naissance'].apply(
                lambda x: self.validator.validate_date_constraints(x) if pd.notna(x) else True
            )
            if not valid_dates.all():
                self.processing_stats['validation_errors'] += 1
                logger.warning("Invalid birth dates detected",
                              invalid_count=len(df) - valid_dates.sum())
                df = df[valid_dates]
        
        # Apply security: encrypt NIR and names
        if 'nir' in df.columns:
            df['nir'] = df['nir'].apply(
                lambda x: self.security_service.encrypt_field(x) if pd.notna(x) else x
            )
        
        for col in ['nom_patient', 'prenom_patient']:
            if col in df.columns:
                df[col] = df[col].apply(
                    lambda x: self.security_service.encrypt_field(x) if pd.notna(x) else x
                )
        
        # Add audit timestamps
        df['created_at'] = pd.Timestamp.now()
        df['updated_at'] = pd.Timestamp.now()
        
        return df
    
    def _validate_geocoding_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Validate geographic data"""
        if df.empty:
            return df
        
        # Validate coordinates
        if 'latitude' in df.columns and 'longitude' in df.columns:
            df['latitude'] = pd.to_numeric(df['latitude'], errors='coerce')
            df['longitude'] = pd.to_numeric(df['longitude'], errors='coerce')
            
            valid_coords = df.apply(
                lambda row: self.validator.validate_coordinates(
                    row.get('latitude', 0), row.get('longitude', 0)
                ) if pd.notna(row.get('latitude')) and pd.notna(row.get('longitude')) else False,
                axis=1
            )
            
            if not valid_coords.all():
                self.processing_stats['validation_errors'] += 1
                logger.warning("Invalid coordinates detected",
                              invalid_count=len(df) - valid_coords.sum())
                df = df[valid_coords]
        
        # Convert date_recueil to proper date format
        if 'date_recueil' in df.columns:
            df['date_recueil'] = pd.to_datetime(df['date_recueil'], errors='coerce').dt.date
        
        # Add audit timestamp
        df['created_at'] = pd.Timestamp.now()
        
        return df
    
    def _validate_demographic_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Validate demographic data"""
        if df.empty:
            return df
        
        # Validate age range
        if 'age' in df.columns:
            df['age'] = pd.to_numeric(df['age'], errors='coerce')
            valid_age = (df['age'] >= 0) & (df['age'] <= 150)
            if not valid_age.all():
                self.processing_stats['validation_errors'] += 1
                logger.warning("Invalid ages detected",
                              invalid_count=len(df) - valid_age.sum())
                df = df[valid_age]
        
        # Validate gender values
        if 'sexe' in df.columns:
            valid_genders = ['Homme', 'Femme', 'Autre', 'Inconnu']
            valid_gender = df['sexe'].isin(valid_genders)
            if not valid_gender.all():
                self.processing_stats['validation_errors'] += 1
                logger.warning("Invalid gender values detected",
                              invalid_count=len(df) - valid_gender.sum())
                df = df[valid_gender]
        
        # Convert date fields
        for date_col in ['date_recueil_age']:
            if date_col in df.columns:
                df[date_col] = pd.to_datetime(df[date_col], errors='coerce').dt.date
        
        # Add audit timestamps
        df['created_at'] = pd.Timestamp.now()
        df['updated_at'] = pd.Timestamp.now()
        
        return df
    
    def _insert_data_in_order(self, validated_data: Dict[str, pd.DataFrame]) -> Dict[str, int]:
        """Insert data in correct order respecting foreign key constraints"""
        insertion_order = [
            'identite_patient',
            'geocodage', 
            'donnees_socio_demographiques'
        ]
        
        results = {}
        
        for table_name in insertion_order:
            if table_name in validated_data:
                df = validated_data[table_name]
                try:
                    result = self.db_manager.insert_dataframe(table_name, df)
                    results[table_name] = len(df)
                    logger.info("Successfully inserted data", 
                               table=table_name, rows=len(df))
                except Exception as e:
                    self.processing_stats['insertion_errors'] += 1
                    logger.error("Failed to insert data", 
                                table=table_name, error=str(e))
                    raise
        
        return results
    
    def get_processing_stats(self) -> Dict[str, int]:
        """Get processing statistics"""
        return self.processing_stats.copy()


def load_database_config() -> Dict[str, Any]:
    """Load database configuration from environment variables"""
    config = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': int(os.getenv('DB_PORT', 5432)),
        'database': os.getenv('DB_NAME', 'test'),
        'user': os.getenv('DB_USER', 'test'),
        'password': os.getenv('DB_PASSWORD', 'test'),
        'sslmode': os.getenv('DB_SSLMODE', 'prefer'),
        'pool_size': int(os.getenv('DB_POOL_SIZE', 5)),
        'max_overflow': int(os.getenv('DB_MAX_OVERFLOW', 10)),
        'pool_timeout': int(os.getenv('DB_POOL_TIMEOUT', 30)),
        'pool_recycle': int(os.getenv('DB_POOL_RECYCLE', 3600)),
        'echo': os.getenv('DB_ECHO', 'false').lower() == 'true'
    }
    
    # Validate required configuration
    required_fields = ['database', 'user', 'password']
    missing_fields = [field for field in required_fields if not config[field]]
    if missing_fields:
        raise ValueError(f"Missing required database configuration: {missing_fields}")
    
    return config


def main():
    """Main entry point"""
    logger.info("Starting FHIR QuestionnaireResponse processing")
    
    try:
        # Load configuration
        db_config = load_database_config()
        
        # Initialize services
        security_service = HealthcareSecurityService()
        db_manager = DatabaseManager(db_config)
        processor = FHIRQuestionnaireProcessor(db_manager, security_service)
        
        # Process the questionnaire response file
        input_file = Path('/data/projets/code/IG-fhir-dm/input/resources/usages/core/QuestionnaireResponse-test-usage-core.json')
        
        if not input_file.exists():
            logger.error("Input file not found", file_path=str(input_file))
            return 1
        
        # Process the file
        result = processor.process_questionnaire_response(input_file)
        
        # Display results
        if result['success']:
            logger.info("Processing completed successfully", 
                       patient_id=result['patient_id'],
                       tables_updated=result['tables_updated'])
        else:
            logger.error("Processing failed", error=result['error'])
            return 1
        
        # Display statistics
        stats = processor.get_processing_stats()
        logger.info("Processing statistics", **stats)
        
        return 0
        
    except Exception as e:
        logger.error("Fatal error during processing", error=str(e))
        return 1


if __name__ == '__main__':
    exit(main())