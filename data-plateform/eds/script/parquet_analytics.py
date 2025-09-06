import duckdb
import pandas as pd
from typing import List, Optional

class ParquetAnalyzer:
    def __init__(self, connection: Optional[duckdb.DuckDBPyConnection] = None):
        """
        Initialize DuckDB connection for Parquet file analytics
        
        Args:
            connection: Optional existing DuckDB connection
        """
        self.con = connection or duckdb.connect()
    
    def read_parquet_files(
        self, 
        file_pattern: str, 
        columns: Optional[List[str]] = None,
        filter_condition: Optional[str] = None
    ) -> pd.DataFrame:
        """
        Read Parquet files with optional column selection and filtering
        
        Args:
            file_pattern: Glob pattern for Parquet files
            columns: List of columns to select (optional)
            filter_condition: SQL WHERE clause for filtering (optional)
        
        Returns:
            Pandas DataFrame with queried data
        """
        query = f"SELECT {', '.join(columns) if columns else '*'} FROM read_parquet('{file_pattern}')"
        
        if filter_condition:
            query += f" WHERE {filter_condition}"
        
        return self.con.sql(query).df()
    
    def aggregate_parquet_data(
        self, 
        file_pattern: str, 
        group_by_columns: List[str],
        aggregate_column: str,
        aggregate_function: str = 'AVG'
    ) -> pd.DataFrame:
        """
        Perform aggregations on Parquet files
        
        Args:
            file_pattern: Glob pattern for Parquet files
            group_by_columns: Columns to group by
            aggregate_column: Column to aggregate
            aggregate_function: Aggregation function (default: AVG)
        
        Returns:
            Pandas DataFrame with aggregated results
        """
        query = f"""
        SELECT 
            {', '.join(group_by_columns)}, 
            {aggregate_function}({aggregate_column}) as aggregated_value
        FROM read_parquet('{file_pattern}')
        GROUP BY {', '.join(group_by_columns)}
        ORDER BY aggregated_value DESC
        """
        
        return self.con.sql(query).df()
    
    def write_optimized_parquet(
        self, 
        data: pd.DataFrame, 
        output_path: str, 
        row_group_size: int = 100_000
    ):
        """
        Write DataFrame to Parquet with optimized settings
        
        Args:
            data: Pandas DataFrame to write
            output_path: Output Parquet file path
            row_group_size: Optimal row group size
        """
        # Register DataFrame as a temporary table
        self.con.register('temp_table', data)
        
        # Write with optimized Parquet settings
        self.con.sql(f"""
        COPY (SELECT * FROM temp_table) 
        TO '{output_path}' (
            FORMAT parquet, 
            ROW_GROUP_SIZE {row_group_size}
        )
        """)
    
    def close(self):
        """Close the DuckDB connection"""
        self.con.close()

def main():
    # Example usage
    analyzer = ParquetAnalyzer()
    
    try:
        # Read all Parquet files in a directory
        patient_data = analyzer.read_parquet_files(
            'data/*.parquet', 
            columns=['patient_id', 'measurement', 'date'],
            filter_condition="date > '2023-01-01'"
        )
        
        # Perform aggregation
        aggregated_data = analyzer.aggregate_parquet_data(
            'data/*.parquet', 
            group_by_columns=['patient_id'], 
            aggregate_column='measurement'
        )
        
        print("Patient Data Sample:")
        print(patient_data.head())
        
        print("\nAggregated Data:")
        print(aggregated_data.head())
        
        # Write optimized Parquet
        analyzer.write_optimized_parquet(
            aggregated_data, 
            'output/aggregated_data.parquet'
        )
    
    finally:
        analyzer.close()

if __name__ == '__main__':
    main()