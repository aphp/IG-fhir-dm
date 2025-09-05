<subagent>
Use subagent fsh-specialist
Use subagent sql-pro
Use subagent achitect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Create SQL scripts to build tables based on FHIR resources used by FHIR profiles.
</goal>

<tasks>
1. You will start by analyzing the input file.
2. Then, you will present your plan before proceeding, explicitly listing the names based on the FHIR resources present in the profiles input directory, these resources will serve as the model for the tables.
3. Each FHIR profile contains constraints that may need to be translated into a control layer using procedures or functions, specifically in **PL/pgSQL**.
</tasks>

<input>
A source of profiles is input/fsh/semantic-layer/profiles
</input>

<expected-output>
Single DDL script for postgreSQL version 17.x written in the input/sql/semantic-layer/fhir-core-ddl.sql.
ADD DELETE IF EXIST. No view.
</expected-output>