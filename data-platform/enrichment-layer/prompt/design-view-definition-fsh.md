<goal>
Create a ViewDefinition files in FHIR Shorhand format to transform FHIR resources into OMOP Tables.
</goal>

<instructions>
- EXPLORE and THINK about the project to understand what you need in order to complete the task. Read all the files that are USEFUL for your task. Especially the OMOP files into `data-platform\eds\sql\omop\OMOPCDM_duckdb_5.4_ddl.sql` directory. You explore as `search-specialist` agent the sql on FHIR `https://build.fhir.org/ig/FHIR/sql-on-fhir-v2/StructureDefinition-ViewDefinition.html` information to know ViewDefinition and `https://build.fhir.org/ig/HL7/fhir-shorthand/reference.html` for FHIR Shorthand format.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You should as `fsh-specialist` agent follow the plan exactly, focusing only on the requested task.
</instructions>

<recommandations>
- Your working directory is `input\fsh\eds\logicals`.
- The List of OMOP Table to be mapped : person, visit_occurrence, condition_occurrence, drug_exposure, procedure_occurrence, measurement, death, specimen, location, care_site, provider, drug_strength
- No terminological mapping.
</recommandations>

<output>
A ViewDefinition containing the mapping between the appropriate FHIR resource, the elements of this resource, and the corresponding OMOP table and its columns. On file per OMOP Table in FSH format.
</output>