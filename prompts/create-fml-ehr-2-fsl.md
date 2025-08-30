<subagent>
Use subagent fml-specialist
Use subagent fsh-specialist
Use subagent achitect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>
<goal>
Create a StructureMap in FHIR Mapping Language (FML) format beetwen ehr StructureDefinition and FHIR semantic-layer StructureDefinition.
</goal>
<tasks>ok
1. You will first analyze the source files and the target files.
2. Then, you present your plan before proceeding further.
3. If validated, you perform the mapping task concept by concept. A mapping may require multiple sources for a single target.
4. The validation service enforces that the first group contains only one source and one target.
5. To work around this limitation, in FHIR you must use the Bundle resource, and for logical models, you must create a logical model that consolidates all the structures to be mapped.
</tasks>
<source>
A source of ehr StructureDefinition is into input/fsh/applications/ehr/logicals/*.fsh
</source>
<target>
A target of FHIR semantic layer StructureDefinition is into input/fsh/semantic-layer/profiles/*.fsh
</target>
<expected-output>
The expected result is a mapping in FHIR Mapping Language into input/fml/ehr2fsl/StructureMap-Source2Target.fml (Source2Target Should be replaced by the name of object source and name of object target). Caution: the keyword uses refers exclusively to resources or to logical StructureDefinitions, and nothing else.
</expected-output>