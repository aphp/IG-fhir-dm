<subagent>
sql-pro
achitect-reviewer
backend-architect
code-reviewer
</subagent>
<goal>
Create a StructureMap in FHIR Mapping Language (FML) format beetwen ehr StructureDefinition and FHIR semantic-layer StructureDefinition.
</goal>
<input>
A source of ehr StructureDefinition is into input/fsh/applications/ehr/logicals/*.fsh
A target of FHIR semantic layer StructureDefinition is into input/fsh/semantic-layer/profiles/*.fsh
You can find a FSH reference --> https://build.fhir.org/ig/HL7/fhir-shorthand/reference.html
You can find a FSH a lexer grammar --> https://github.com/FHIR/sushi/blob/v3.8.0/antlr/src/main/antlr/FSHLexer.g4
You can find a FSH perser grammar --> https://github.com/FHIR/sushi/blob/v3.8.0/antlr/src/main/antlr/FSH.g4
You can find a FML reference --> https://build.fhir.org/mapping-language.html
You can find a FML grammar --> https://build.fhir.org/mapping.g4
You can find a FHIRPath reference --> https://hl7.org/fhirpath/
You can find a FHIRPath grammar --> https://hl7.org/fhirpath/fhirpath.g4
</input>
<expected-output>
The expected result is a mapping in FHIR Mapping Language into input/fml/StructureMap-EHR2FSL.fml
</expected-output>