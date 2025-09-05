<subagent>
sql-pro
achitect-reviewer
backend-architect

code-reviewer
</subagent>
<goal>
Create a StructureDefinition king logic in FHIR Shorthand (FSH) format based on table SQL definition
</goal>
<input>
A source of tables is input/sql/applications/ehr/questionnaire-core-ddl.sql.
You can find a FSH reference --> https://build.fhir.org/ig/HL7/fhir-shorthand/reference.html
You can find a FSH a lexer grammar --> https://github.com/FHIR/sushi/blob/v3.8.0/antlr/src/main/antlr/FSHLexer.g4
You can find a FHR parser grammar --> https://github.com/FHIR/sushi/blob/v3.8.0/antlr/src/main/antlr/FSH.g4
</input>
<expected-output>
The expected result is a translation of an SQL table into a StructureDefinition in FSH format. One FSH file per SQL table into input/fsh/applications/ehr
</expected-output>