<subagent>
Use subagent fml-specialist
Use subagent fsh-specialist
Use subagent achitect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Create a StructureMap in FHIR Mapping Language (FML) format beetwen EHR StructureDefinition and FHIR Resources.
</goal>

<tasks>
1. You will first analyze the source files and the target files.
2. Then, you present your plan before proceeding further.
3. If validated, you perform the mapping task concept by concept. A mapping may require multiple sources for a single target. Each FHIR resource created must conform to the profiles defined in the FHIR Implementation Guide.
4. The validation service enforces that the first group contains only one source and one target. To work around this limitation, in FHIR you must use the Bundle resource.
</tasks>

<source>
A source of EHR StructureDefinition is into input/fsh/applications/ehr/logicals/StructureDefinition-EHR.fsh
</source>

<profile>
All profiles of FHIR semantic layer StructureDefinition is into input/fsh/semantic-layer/profiles/*.fsh
</profile>

<expected-output>
The expected result is a mapping in FHIR Mapping Language written in the input/fml/StructureMap-EHR2FSL.fml. Each FHIR resource created must conform to the profiles defined in the FHIR Implementation Guide. Caution: the keyword uses refers exclusively to resource StructureDefinitions or to logical StructureDefinitions, and not profiles.
</expected-output>