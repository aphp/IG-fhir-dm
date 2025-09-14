<goal>
Develop a loader in python to import contents of `data-platform\share-layer\test\mimic-iv-clinical-database-demo-on-fhir-2.1.0\fhir\*.ndjson.gz` into instance of HAPI FHIR server at `http://localhost:8080/fhir` with using $import operation (bulk import).
</goal>

<instructions>
- EXPLORE and THINK about the project to understand what you need in order to complete the task. Read all the files that are USEFUL for your task.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You should as `python-pro` agent follow the plan exactly, focusing only on the requested task.
- You should as `debugger` agent TEST by applying an iterative approach: run script to tests, fix the detected errors, then rerun script. Repeat this process until the entire result executes with a 100% success rate.
</instructions>

<recommandations>
- Your working directory is `data-platform/share-layer/test/script`.
- You take account the `hapi-fhir-server` context configuration.
</recommandations>

<hapi-fhir-server>
- url: http://localhost:8080/fhir
- version: 8.4.0
- fhir: R4
- database: postgreSQL
</hapi-fhir-server>

<output>
python project well define able to load FHIR data into HAPI server by using $import operation (bulk import).
</output>