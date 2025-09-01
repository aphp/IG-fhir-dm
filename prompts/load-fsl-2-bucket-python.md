<subagent>
Use subagent python-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
Use subagent debugger
</subagent>

<goal>
Develop a loader in python to transfert the data from FHIR Semantic Layer (source) to Object Storage Server (target) in NDJSON format.
</goal>

<source>
type: postgres
host: "{{ env_var('DBT_HOST', 'localhost') }}"
port: "{{ env_var('DBT_PORT', 5432) | int }}"
user: "{{ env_var('DBT_USER') }}"
pass: "{{ env_var('DBT_PASSWORD') }}"
dbname: "{{ env_var('DBT_DATABASE', 'data_core') }}"
schema: "{{ env_var('DBT_SCHEMA', 'dbt_fhir_semantic_layer') }}"

definition: input/sql/semantic-layer/fhir-core-ddl.sql
</source>
<target>
API: http://127.0.0.1:9000
RootUser: minioadmin
RootPass: minioadmin123
</target>

<instructions>
- EXPLORE and THINK about the project to understand what you need in order to complete the task. Read all the files that are USEFUL for your task.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You should follow the plan exactly, focusing only on the requested task.
- You should TEST by applying an iterative approach: run script to tests, fix the detected errors, then rerun script. Repeat this process until the entire result executes with a 100% success rate.
</instructions>

<recommandations>
- Your working directory is `bucket-s3`.
- The charset is UTF-8 for files and databases.
- The PostgreSQL is installed with French locale (French_France.1252)
</recommandations>

<expected-output>
python subproject well define able to load FHIR data into Object Storage Server.
</expected-output>