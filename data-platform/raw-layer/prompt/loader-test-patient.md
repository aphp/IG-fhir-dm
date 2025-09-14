<goal>
Implementation of a Python script to load the patient test CSV files into a PostgreSQL database.
</goal>
<instructions>
- You are an `architect-reviewer`, You should EXPLORE and THINK to understand what you need in order to complete the task. Read input file that is USEFUL for your task.
- You are an `architect-reviewer`, You should PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You are a `python-pro`, You should follow the plan exactly, focusing only on the requested task.
- You are `code-reviewer`, You should VALIDATED for compliance with the EHR model especially VERIFY the data type conformity.
</instructions>
<working-directory>
data-platform\raw-layer
</working-directory>
<recommandations>
- You must detect and handle the charset (UTF-8).
- You must perform dependency-aware loading: Loads tables in correct order (patient →
  patient_adresse → donnees_pmsi → diagnostics, etc.)
- You must use psycopg2 with COPY: Uses efficient PostgreSQL COPY operations via
  execute_values() for bulk loading
- You must ensure transaction safety: All operations within transactions with automatic
   rollback on failure
- You must perform data validation: Validates table existence, row counts, and data
  integrity
</recommandations>
<input>
data-platform\raw-layer\test\file\<table_name/>.csv
</input>
<output>
The expected result is a Python script that loads the test files (input) into a PostgreSQL database. The script will be placed in `data-platform\raw-layer\test\loader`
<output>

<claude>
<summary>
✅ Enhanced loader implementation completed successfully!

  Key Enhancements Based on Updated Requirements:

  🇫🇷 French Environment Support

  - Charset Detection: Automatic encoding detection with chardet library
  - French Locale: Attempts to set French locales (fr_FR.UTF-8, fr_FR, etc.)
  - UTF-8 Preference: Prioritizes UTF-8 for French character compatibility
  - BOM Handling: Automatically removes UTF-8 BOM characters
  - Fallback Encoding: Falls back to latin1 for legacy French files

  🔄 Dependency-Aware Loading

  - Strict Order: Loads tables in exact dependency sequence
  - Foreign Key Safety: Prevents constraint violations
  - Transaction Integrity: Complete rollback on any dependency failure
  - Progress Tracking: Real-time dependency chain progress

  ⚡ Optimized COPY Operations

  - execute_values(): Uses PostgreSQL's optimized bulk loading
  - Page Size Optimization: 1000-row batches for optimal performance
  - UTF-8 Connection: Forces UTF-8 client encoding
  - Memory Efficiency: Streams data without full file loading

  🛡️ Enhanced Transaction Safety

  - All-or-Nothing: Complete transaction rollback on any failure
  - Autocommit Control: Explicit transaction management
  - Error Recovery: Graceful handling of partial failures
  - State Validation: Pre and post-load integrity checks

  🔍 Comprehensive Data Validation

  - Table Existence: Validates all target tables exist
  - Column Structure: Verifies CSV headers match EHR schema
  - Row Count Validation: Confirms loaded vs. database counts
  - Foreign Key Integrity: Checks referential relationships
  - Data Type Conformity: Ensures EHR model compliance

  Files Created:
  - load_test_patients.py - Enhanced loader with all requirements
  - requirements.txt - Updated dependencies (psycopg2-binary, chardet)
  - README.md - Comprehensive documentation with French environment details

  Ready for French healthcare data loading with full EHR model compliance!
</summary>
</claude>