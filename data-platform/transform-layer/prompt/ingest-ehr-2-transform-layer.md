<goal>
Copy a content of PostgreSQL 
</goal>
<instructions>
- You are an `architect-reviewer`, You should EXPLORE and THINK to understand what you need in order to complete the task. Read input file that is USEFUL for your task.
- You are an `architect-reviewer`, You should PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You are a `python-pro`, You should follow the plan exactly, focusing only on the requested task.
- You are a `code-reviewer`, You should VALIDATED for compliance with the EHR model especially VERIFY the data type conformity.
</instructions>
<working-directory>
data-platform\transform-layer\data-ingestor
</working-directory>
<input>
PostgreSQL
</input>
<recommandations>
- You must define and use an .env file system to manage source and target databases
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
<output>
The expected result is a Python script that loads the `ehr` database  into `transform_layer` PostgreSQL database. The script will be placed in `data-platform\transform-layer\data-transformer`
</output>