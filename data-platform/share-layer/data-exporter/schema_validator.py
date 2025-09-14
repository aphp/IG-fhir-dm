"""DDL-based schema validation for OMOP Common Data Model."""

import re
import sqlite3
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Any, Union
from dataclasses import dataclass
from enum import Enum

import duckdb
import pandas as pd
import structlog

from utils import FHIRExportError, ValidationError, safe_json_load

logger = structlog.get_logger(__name__)


class ColumnType(Enum):
    """OMOP column data types."""
    INTEGER = "INTEGER"
    VARCHAR = "VARCHAR"
    DATE = "DATE"
    TIMESTAMP = "TIMESTAMP"
    NUMERIC = "NUMERIC"
    TEXT = "TEXT"


@dataclass
class ColumnDefinition:
    """OMOP table column definition."""
    name: str
    data_type: ColumnType
    length: Optional[int] = None
    nullable: bool = True
    primary_key: bool = False
    foreign_key: Optional[str] = None
    description: Optional[str] = None
    
    def __post_init__(self):
        """Normalize column attributes."""
        self.name = self.name.lower()
        if isinstance(self.data_type, str):
            self.data_type = ColumnType(self.data_type.upper())


@dataclass
class TableDefinition:
    """OMOP table definition."""
    name: str
    columns: List[ColumnDefinition]
    primary_keys: List[str]
    foreign_keys: Dict[str, str]
    indexes: List[str]
    description: Optional[str] = None
    
    def __post_init__(self):
        """Normalize table attributes."""
        self.name = self.name.lower()
        self.primary_keys = [pk.lower() for pk in self.primary_keys]
        self.foreign_keys = {k.lower(): v for k, v in self.foreign_keys.items()}
        self.indexes = [idx.lower() for idx in self.indexes]
    
    def get_column(self, column_name: str) -> Optional[ColumnDefinition]:
        """Get column definition by name."""
        column_name = column_name.lower()
        for column in self.columns:
            if column.name == column_name:
                return column
        return None
    
    def get_column_names(self) -> Set[str]:
        """Get set of column names."""
        return {col.name for col in self.columns}


class OMOPSchemaParser:
    """Parser for OMOP DDL files to extract schema definitions."""
    
    def __init__(self):
        self.logger = logger.bind(component="OMOPSchemaParser")
        
        # Regex patterns for DDL parsing
        self.table_pattern = re.compile(
            r'CREATE\s+TABLE\s+(?:@cdmDatabaseSchema\.)?(\w+)\s*\(',
            re.IGNORECASE | re.MULTILINE
        )
        
        self.column_pattern = re.compile(
            r'(\w+)\s+(INTEGER|VARCHAR|DATE|TIMESTAMP|NUMERIC|TEXT)(?:\((\d+)\))?\s*(NOT\s+NULL|NULL)?\s*(?:,|$)',
            re.IGNORECASE | re.MULTILINE
        )
        
        self.primary_key_pattern = re.compile(
            r'PRIMARY\s+KEY\s*\(([^)]+)\)',
            re.IGNORECASE
        )
        
        self.foreign_key_pattern = re.compile(
            r'FOREIGN\s+KEY\s*\(([^)]+)\)\s+REFERENCES\s+(\w+)\s*\(([^)]+)\)',
            re.IGNORECASE
        )
    
    def parse_ddl_file(self, ddl_file: Union[str, Path]) -> Dict[str, TableDefinition]:
        """Parse DDL file and extract table definitions.
        
        Args:
            ddl_file: Path to DDL file
            
        Returns:
            Dictionary mapping table names to TableDefinition objects
            
        Raises:
            ValidationError: If DDL parsing fails
        """
        ddl_file = Path(ddl_file)
        
        try:
            self.logger.info("Parsing DDL file", file=str(ddl_file))
            
            with open(ddl_file, 'r', encoding='utf-8') as f:
                ddl_content = f.read()
            
            tables = {}
            
            # Split DDL content by table statements
            table_statements = self._extract_table_statements(ddl_content)
            
            for statement in table_statements:
                table_def = self._parse_table_statement(statement)
                if table_def:
                    tables[table_def.name] = table_def
            
            self.logger.info("DDL parsing completed", table_count=len(tables))
            return tables
            
        except Exception as e:
            raise ValidationError(
                f"Failed to parse DDL file: {ddl_file}",
                details={"error": str(e)}
            ) from e
    
    def _extract_table_statements(self, ddl_content: str) -> List[str]:
        """Extract individual table creation statements."""
        # Remove comments
        ddl_content = re.sub(r'--.*$', '', ddl_content, flags=re.MULTILINE)
        
        # Split by CREATE TABLE statements
        statements = []
        parts = re.split(r'(?i)CREATE\s+TABLE', ddl_content)
        
        for i, part in enumerate(parts):
            if i == 0:  # Skip content before first CREATE TABLE
                continue
            
            # Find the end of the table definition (next CREATE TABLE or end of content)
            next_create = re.search(r'(?i)CREATE\s+TABLE', part)
            if next_create:
                table_def = part[:next_create.start()]
            else:
                table_def = part
            
            # Add back the CREATE TABLE prefix
            full_statement = f"CREATE TABLE {table_def}"
            statements.append(full_statement.strip())
        
        return statements
    
    def _parse_table_statement(self, statement: str) -> Optional[TableDefinition]:
        """Parse a single CREATE TABLE statement."""
        try:
            # Extract table name
            table_match = self.table_pattern.search(statement)
            if not table_match:
                return None
            
            table_name = table_match.group(1).lower()
            
            # Extract table body (content between parentheses)
            paren_start = statement.find('(', table_match.end())
            paren_count = 1
            paren_end = paren_start + 1
            
            while paren_end < len(statement) and paren_count > 0:
                if statement[paren_end] == '(':
                    paren_count += 1
                elif statement[paren_end] == ')':
                    paren_count -= 1
                paren_end += 1
            
            if paren_count > 0:
                # Malformed statement
                return None
            
            table_body = statement[paren_start + 1:paren_end - 1]
            
            # Parse columns
            columns = self._parse_columns(table_body)
            
            # Parse constraints (basic implementation)
            primary_keys = self._extract_primary_keys(table_body)
            foreign_keys = self._extract_foreign_keys(table_body)
            
            return TableDefinition(
                name=table_name,
                columns=columns,
                primary_keys=primary_keys,
                foreign_keys=foreign_keys,
                indexes=[]  # Indexes would be parsed from separate DDL files
            )
            
        except Exception as e:
            self.logger.warning(
                "Failed to parse table statement", 
                error=str(e), 
                statement_preview=statement[:100]
            )
            return None
    
    def _parse_columns(self, table_body: str) -> List[ColumnDefinition]:
        """Parse column definitions from table body."""
        columns = []
        
        # Split by lines and parse each column definition
        lines = [line.strip() for line in table_body.split('\n') if line.strip()]
        
        for line in lines:
            # Skip constraint definitions
            if any(keyword in line.upper() for keyword in ['PRIMARY KEY', 'FOREIGN KEY', 'CONSTRAINT']):
                continue
            
            # Remove trailing comma
            line = line.rstrip(',')
            
            # Parse column definition
            column_match = self.column_pattern.search(line)
            if column_match:
                column_name = column_match.group(1).lower()
                data_type_str = column_match.group(2).upper()
                length_str = column_match.group(3)
                nullable_str = column_match.group(4)
                
                try:
                    data_type = ColumnType(data_type_str)
                except ValueError:
                    # Handle unknown data types
                    if data_type_str in ['INT', 'BIGINT']:
                        data_type = ColumnType.INTEGER
                    elif data_type_str in ['STRING', 'CHAR']:
                        data_type = ColumnType.VARCHAR
                    else:
                        data_type = ColumnType.TEXT
                
                length = int(length_str) if length_str else None
                nullable = nullable_str is None or 'NOT NULL' not in nullable_str.upper()
                
                columns.append(ColumnDefinition(
                    name=column_name,
                    data_type=data_type,
                    length=length,
                    nullable=nullable
                ))
        
        return columns
    
    def _extract_primary_keys(self, table_body: str) -> List[str]:
        """Extract primary key columns."""
        pk_match = self.primary_key_pattern.search(table_body)
        if pk_match:
            pk_columns = [col.strip().lower() for col in pk_match.group(1).split(',')]
            return pk_columns
        return []
    
    def _extract_foreign_keys(self, table_body: str) -> Dict[str, str]:
        """Extract foreign key relationships."""
        foreign_keys = {}
        
        for fk_match in self.foreign_key_pattern.finditer(table_body):
            local_column = fk_match.group(1).strip().lower()
            referenced_table = fk_match.group(2).lower()
            referenced_column = fk_match.group(3).strip().lower()
            
            foreign_keys[local_column] = f"{referenced_table}.{referenced_column}"
        
        return foreign_keys


class SchemaValidator:
    """Validator for OMOP data against schema definitions."""
    
    def __init__(self, schema_definitions: Dict[str, TableDefinition]):
        """Initialize schema validator.
        
        Args:
            schema_definitions: Dictionary of table definitions
        """
        self.schema_definitions = schema_definitions
        self.logger = logger.bind(component="SchemaValidator")
    
    @classmethod
    def from_ddl_files(
        cls, 
        ddl_file: Union[str, Path],
        constraints_file: Optional[Union[str, Path]] = None,
        primary_keys_file: Optional[Union[str, Path]] = None
    ) -> 'SchemaValidator':
        """Create validator from DDL files.
        
        Args:
            ddl_file: Main DDL file with table definitions
            constraints_file: Optional constraints file
            primary_keys_file: Optional primary keys file
            
        Returns:
            Configured SchemaValidator instance
        """
        parser = OMOPSchemaParser()
        schema_definitions = parser.parse_ddl_file(ddl_file)
        
        # TODO: Parse additional constraint and primary key files
        # This would enhance the schema definitions with more detailed constraints
        
        return cls(schema_definitions)
    
    def validate_table_schema(
        self, 
        table_name: str, 
        data: pd.DataFrame
    ) -> Dict[str, Any]:
        """Validate DataFrame schema against OMOP table definition.
        
        Args:
            table_name: Name of OMOP table
            data: DataFrame to validate
            
        Returns:
            Validation report dictionary
            
        Raises:
            ValidationError: If table definition not found
        """
        table_name = table_name.lower()
        
        if table_name not in self.schema_definitions:
            raise ValidationError(
                f"Table definition not found: {table_name}",
                details={"available_tables": list(self.schema_definitions.keys())}
            )
        
        table_def = self.schema_definitions[table_name]
        
        self.logger.info("Validating table schema", table=table_name, rows=len(data))
        
        report = {
            "table_name": table_name,
            "validation_timestamp": pd.Timestamp.now().isoformat(),
            "row_count": len(data),
            "column_count": len(data.columns),
            "issues": [],
            "warnings": [],
            "summary": {}
        }
        
        # Check column presence
        expected_columns = table_def.get_column_names()
        actual_columns = set(col.lower() for col in data.columns)
        
        missing_columns = expected_columns - actual_columns
        extra_columns = actual_columns - expected_columns
        
        if missing_columns:
            report["issues"].append({
                "type": "missing_columns",
                "description": f"Missing required columns: {list(missing_columns)}",
                "columns": list(missing_columns)
            })
        
        if extra_columns:
            report["warnings"].append({
                "type": "extra_columns",
                "description": f"Unexpected columns found: {list(extra_columns)}",
                "columns": list(extra_columns)
            })
        
        # Validate each column
        for column_name in actual_columns:
            if column_name in expected_columns:
                column_def = table_def.get_column(column_name)
                if column_def:
                    column_issues = self._validate_column(
                        data[column_name], column_def
                    )
                    report["issues"].extend(column_issues)
        
        # Validate primary keys
        pk_issues = self._validate_primary_keys(data, table_def)
        report["issues"].extend(pk_issues)
        
        # Generate summary
        report["summary"] = {
            "total_issues": len(report["issues"]),
            "total_warnings": len(report["warnings"]),
            "is_valid": len(report["issues"]) == 0,
            "missing_columns_count": len(missing_columns),
            "extra_columns_count": len(extra_columns)
        }
        
        self.logger.info(
            "Schema validation completed",
            table=table_name,
            issues=len(report["issues"]),
            warnings=len(report["warnings"])
        )
        
        return report
    
    def _validate_column(
        self, 
        series: pd.Series, 
        column_def: ColumnDefinition
    ) -> List[Dict[str, Any]]:
        """Validate individual column data."""
        issues = []
        
        # Check nullability
        if not column_def.nullable and series.isnull().any():
            null_count = series.isnull().sum()
            issues.append({
                "type": "null_constraint_violation",
                "column": column_def.name,
                "description": f"Column {column_def.name} contains {null_count} null values but is NOT NULL",
                "null_count": null_count
            })
        
        # Check data type compatibility
        type_issues = self._check_data_type(series, column_def)
        issues.extend(type_issues)
        
        # Check length constraints for VARCHAR columns
        if column_def.data_type == ColumnType.VARCHAR and column_def.length:
            length_issues = self._check_varchar_length(series, column_def)
            issues.extend(length_issues)
        
        return issues
    
    def _check_data_type(
        self, 
        series: pd.Series, 
        column_def: ColumnDefinition
    ) -> List[Dict[str, Any]]:
        """Check data type compatibility."""
        issues = []
        
        # Skip null values for type checking
        non_null_series = series.dropna()
        
        if len(non_null_series) == 0:
            return issues
        
        if column_def.data_type == ColumnType.INTEGER:
            # Check if values can be converted to integer
            try:
                pd.to_numeric(non_null_series, errors='raise', downcast='integer')
            except (ValueError, TypeError):
                issues.append({
                    "type": "data_type_mismatch",
                    "column": column_def.name,
                    "description": f"Column {column_def.name} contains non-integer values",
                    "expected_type": "INTEGER"
                })
        
        elif column_def.data_type in [ColumnType.DATE, ColumnType.TIMESTAMP]:
            # Check if values can be parsed as dates
            invalid_dates = 0
            for value in non_null_series:
                try:
                    pd.to_datetime(value)
                except (ValueError, TypeError):
                    invalid_dates += 1
            
            if invalid_dates > 0:
                issues.append({
                    "type": "data_type_mismatch",
                    "column": column_def.name,
                    "description": f"Column {column_def.name} contains {invalid_dates} invalid date values",
                    "expected_type": column_def.data_type.value,
                    "invalid_count": invalid_dates
                })
        
        elif column_def.data_type == ColumnType.NUMERIC:
            # Check if values are numeric
            try:
                pd.to_numeric(non_null_series, errors='raise')
            except (ValueError, TypeError):
                issues.append({
                    "type": "data_type_mismatch",
                    "column": column_def.name,
                    "description": f"Column {column_def.name} contains non-numeric values",
                    "expected_type": "NUMERIC"
                })
        
        return issues
    
    def _check_varchar_length(
        self, 
        series: pd.Series, 
        column_def: ColumnDefinition
    ) -> List[Dict[str, Any]]:
        """Check VARCHAR length constraints."""
        issues = []
        
        if not column_def.length:
            return issues
        
        # Check string lengths
        non_null_series = series.dropna()
        string_series = non_null_series.astype(str)
        
        too_long_mask = string_series.str.len() > column_def.length
        too_long_count = too_long_mask.sum()
        
        if too_long_count > 0:
            max_length = string_series.str.len().max()
            issues.append({
                "type": "length_constraint_violation",
                "column": column_def.name,
                "description": f"Column {column_def.name} contains {too_long_count} values exceeding max length {column_def.length}",
                "max_length_allowed": column_def.length,
                "max_length_found": max_length,
                "violation_count": too_long_count
            })
        
        return issues
    
    def _validate_primary_keys(
        self, 
        data: pd.DataFrame, 
        table_def: TableDefinition
    ) -> List[Dict[str, Any]]:
        """Validate primary key constraints."""
        issues = []
        
        if not table_def.primary_keys:
            return issues
        
        # Check if all PK columns exist
        pk_columns = table_def.primary_keys
        existing_pk_columns = [col for col in pk_columns if col in data.columns]
        
        if len(existing_pk_columns) != len(pk_columns):
            missing_pk_columns = set(pk_columns) - set(existing_pk_columns)
            issues.append({
                "type": "missing_primary_key_columns",
                "description": f"Missing primary key columns: {list(missing_pk_columns)}",
                "missing_columns": list(missing_pk_columns)
            })
            return issues
        
        # Check for duplicate primary key values
        duplicates = data[existing_pk_columns].duplicated()
        duplicate_count = duplicates.sum()
        
        if duplicate_count > 0:
            issues.append({
                "type": "primary_key_violation",
                "description": f"Found {duplicate_count} duplicate primary key values",
                "duplicate_count": duplicate_count,
                "primary_key_columns": pk_columns
            })
        
        # Check for null values in primary key columns
        for pk_col in existing_pk_columns:
            null_count = data[pk_col].isnull().sum()
            if null_count > 0:
                issues.append({
                    "type": "primary_key_null_violation",
                    "column": pk_col,
                    "description": f"Primary key column {pk_col} contains {null_count} null values",
                    "null_count": null_count
                })
        
        return issues
    
    def create_duckdb_schema(
        self, 
        db_connection: duckdb.DuckDBPyConnection,
        table_names: Optional[List[str]] = None
    ) -> None:
        """Create OMOP tables in DuckDB database.
        
        Args:
            db_connection: DuckDB connection
            table_names: Optional list of specific tables to create
        """
        if table_names is None:
            table_names = list(self.schema_definitions.keys())
        
        for table_name in table_names:
            if table_name not in self.schema_definitions:
                self.logger.warning("Table definition not found", table=table_name)
                continue
            
            table_def = self.schema_definitions[table_name]
            ddl_sql = self._generate_duckdb_ddl(table_def)
            
            try:
                self.logger.info("Creating table in DuckDB", table=table_name)
                db_connection.execute(f"DROP TABLE IF EXISTS {table_name}")
                db_connection.execute(ddl_sql)
            except Exception as e:
                self.logger.error(
                    "Failed to create table",
                    table=table_name,
                    error=str(e)
                )
    
    def _generate_duckdb_ddl(self, table_def: TableDefinition) -> str:
        """Generate DuckDB DDL for table definition."""
        column_definitions = []
        
        for column in table_def.columns:
            col_def = f"{column.name} {self._map_to_duckdb_type(column)}"
            if not column.nullable:
                col_def += " NOT NULL"
            column_definitions.append(col_def)
        
        # Add primary key constraint
        if table_def.primary_keys:
            pk_constraint = f"PRIMARY KEY ({', '.join(table_def.primary_keys)})"
            column_definitions.append(pk_constraint)
        
        ddl = f"CREATE TABLE {table_def.name} (\n"
        ddl += ",\n".join(f"  {col_def}" for col_def in column_definitions)
        ddl += "\n)"
        
        return ddl
    
    def _map_to_duckdb_type(self, column: ColumnDefinition) -> str:
        """Map OMOP column type to DuckDB type."""
        if column.data_type == ColumnType.INTEGER:
            return "INTEGER"
        elif column.data_type == ColumnType.VARCHAR:
            if column.length:
                return f"VARCHAR({column.length})"
            return "VARCHAR"
        elif column.data_type == ColumnType.DATE:
            return "DATE"
        elif column.data_type == ColumnType.TIMESTAMP:
            return "TIMESTAMP"
        elif column.data_type == ColumnType.NUMERIC:
            return "NUMERIC"
        else:
            return "TEXT"