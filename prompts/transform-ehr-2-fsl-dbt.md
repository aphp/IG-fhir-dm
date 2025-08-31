<subagent>
Use subagent fml-specialist
Use subagent dbt-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
Use subagent debugger
</subagent>

<goal>
Operationalize the transformation between the EHR data model and the FHIR Semantic Layer.
</goal>

<functional-architecture>
The PostgreSQL instance (`localhost:5432`) contains two databases:
1. **ehr** – the source database.  
2. **data_core** – dedicated to transformation processes.

Schemas in `data_core` for Transformation:
- **dbt_seeds** – Used to test the pipeline.  
- **dbt_staging** – Extracts source data.  
- **dbt_intermediate** – Performs complex transformations.  
- **fhir_semantic_layer** – Stores the final transformed data.
</functional-architecture>

<instructions>
- EXPLORE and THINK about the project to understand what you need in order to complete the task. Read all the files that are USEFUL for your task, especially the source data model, target data model and the transformation specification is defined in a StructureMap expressed in FML format.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result, especially how to configure DBT the local project.
- You should follow the plan exactly, focusing only on the requested task.
- You should TEST by applying an iterative approach: run dbt to tests, fix the detected errors, then rerun dbt. Repeat this process until the entire result executes with a 100% success rate.
</instructions>

<dbt-config>
transform_layer/dbt_project.yml
transform_layer/profiles.yml
</dbt-config>

<source>
input/sql/applications/ehr/questionnaire-core-ddl.sql
</source>
<target>
input/sql/semantic-layer/fhir-core-ddl.sql
</target>
<mapping>
input/fml/StructureMap-EHR2FSL.fml
</mapping>
<test-script>
transform_layer/run_dbt.ps1
</test-script>
<test-data>
Files into transform_layer/seeds/*.csv
</test-data>

<recommandations>
- Do not alter the source or target schemas.
- Do not alter the mapping defined in a StructureMap expressed in FML format.
- Your working directory is transform_layer.
- The charset is UTF-8 for files and databases.
- The PostgreSQL is installed with French locale (French_France.1252)
</recommandations>

<expected-output>
dbt project well define able to transform EHR data into FHIR Semantic Layer database into `transform_layer` directory.
</expected-output>