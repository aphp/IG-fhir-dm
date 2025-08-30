<subagent>
Use subagent sql-pro
Use subagent fsh-specialist
Use subagent achitect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>
<goal>
Create a StructureDefinition king logic in FHIR Shorthand (FSH) format based on table SQL definition
</goal>
<input>
A source of tables is input/sql/applications/ehr/questionnaire-core-ddl.sql.
</input>
<expected-output>
The expected result is a translation of an SQL table into a StructureDefinition in FSH format. One FSH file per SQL table into input/fsh/applications/ehr/logicals/StructureDefinition-NameOfTable.sql. The foreignKey should be transform into Reference.reference (to respect referential integrity) or logical relationship should be use Reference.identifier and type.
</expected-output>