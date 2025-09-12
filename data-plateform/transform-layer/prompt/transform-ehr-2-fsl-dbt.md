<goal>
Operationalize the transformation between the EHR data model and the FHIR Semantic Layer.
</goal>

<functional-architecture>
The PostgreSQL instance (`localhost:5432`) contains two databases:
1. **ehr** – the source database.  
2. **transform_layer** – dedicated to transformation processes.

Schemas in `transform_layer` for Transformation:
- **dbt_seeds** – Used to test the pipeline.  
- **dbt_staging** – Extracts source data.  
- **dbt_intermediate** – Performs complex transformations.  
- **dbt_fhir_semantic_layer** – Stores the final transformed data.
</functional-architecture>

<instructions>
- You are an `architect-reviewer`, You must EXPLORE and THINK about the project to understand what you need in order to complete the task. Read all the files that are USEFUL for your task, especially the source data model, target data model and the transformation specification is defined in a StructureMap expressed in FML format.
- You are an `architect-reviewer`, You must PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result, especially how to configure DBT the local project.
- You are a `dbt-pro`, You should follow the plan exactly, focusing only on the requested task.
- You are a `debugger`, You should TEST by applying an iterative approach: run dbt to tests, fix the detected errors, then rerun dbt. Repeat this process until the entire result executes with a 100% success rate.
</instructions>

<working-directory>
data-plateform\transform-layer\data-ingestor
</working-directory>

<dbt-config>
data-plateform\transform-layer\data-ingestor\dbt_project.yml
data-plateform\transform-layer\data-ingestor\profiles.yml
</dbt-config>

<source>
data-plateform\ehr\sql\ehr-ddl.sql
</source>
<target>
data-plateform\semantic-layer\sql\fhir-core-ddl.sql
</target>
<mapping>
input\fml\StructureMap-EHR2FSL.fml
</mapping>
<test-script>
data-plateform\transform-layer\data-ingestor\run_dbt.ps1
</test-script>
<test-data>
Files into data-plateform\transform-layer\data-ingestor\seeds\*.csv
</test-data>

<recommandations>
- Do not alter the source or target schemas.
- Do not alter the mapping defined in a StructureMap expressed in FML format.
- The charset is UTF-8 for files and databases.
- The PostgreSQL is installed with French locale (French_France.1252)
</recommandations>

<output>
dbt project well define able to transform EHR data into FHIR Semantic Layer database into `data-plateform\transform-layer\data-ingestor` directory.
</output>