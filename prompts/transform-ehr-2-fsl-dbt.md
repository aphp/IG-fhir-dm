<subagent>
Use subagent fml-specialist
Use subagent dbt-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Operationalize the transformation between the EHR database and the FHIR Semantic Layer database.
</goal>

<tasks>
- EXPLORE and THINK about the project to understand what you need in order to complete the task. Read all the files that are USEFUL for your task, especially the source data model, target data model and the transformation specification is defined in a StructureMap expressed in FML format.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result, especially how to configure DBT the local project.
- You should follow the plan exactly, focusing only on the requested task.
</tasks>

<source>
input/sql/applications/ehr/questionnaire-core-ddl.sql
</source>
<target>
input/sql/semantic-layer/fhir-core-ddl.sql
</target>
<mapping>
input/fml/StructureMap-EHR2FSL.fml
</mapping>

<expected-output>
dbt project well define able to transform EHR data into FHIR Semantic Layer database into `transform_layer` directory.
</expected-output>

TODO precise the name of database, schemas and maybe conection information
ALSO no change input schema and output schema never !!!
Define the working directory and never change during the workflow