<subagent>
Use subagent fsh-specialist
Use subagent sql-pro
Use subagent achitect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>
<goal>
Create SQL scripts to build tables based on FHIR profiles. Each FHIR profile can be translated into a SQL table, but choosing to optimize tables by resource type is also a way to reduce the number of tables and ultimately their specificity.
</goal>
<input>
A source of profiles is input/fsh/semantic-layer/profiles
</input>
<expected-output>
A script SQL for postgres version 17.x into input/sql/semantic-layer/
</expected-output>