<subagent>
Use subagent sql-pro
Use subagent fsh-specialist
Use subagent achitect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Create a comprehensive EHR model - Integration all dimensions
</goal>

<instructions>
- EXPLORE and THINK about the project to understand what you need in order to complete the task. Read the input file that is USEFUL for your task.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You should follow the plan exactly, focusing only on the requested task, especially you should create a StructureDefinition of kind logical, including all EHR dimensions while preserving the original names but while respecting the naming rules, and write it to the input/fsh/applications/ehr/logicals/StructureDefinition-EHR.fsh.
</instructions>

<input>
A source of tables is input/sql/applications/ehr/questionnaire-core-ddl.sql.
</input>

<expected-output>
The expected result is a translation of an SQL table into a StructureDefinition of kind logical, including all EHR dimensions while preserving the original names but while respecting the naming rules, and write it to the input/fsh/applications/ehr/logicals/StructureDefinition-EHR.fsh in FSH format.
</expected-output>