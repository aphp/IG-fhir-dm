<goal>
Create a plantUML diagram based on FHIR Semantic Layer data model.
</goal>

<tasks>
- You are a `architect-reviewer`, You should EXPLORE and THINK to understand what you need in order to complete the task. Read input file that is USEFUL for your task.
- You are a `architect-reviewer`, You should PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result.
- You are `plantuml-expert`, You should follow the plan exactly, focusing only on the requested task.
- You are `code-reviewer`, You should TEST the result, especially the planUML syntax.
</tasks>

<input>
A source of FHIR Semantic Layer data model is data-plateform/semantic-layer/sql/fhir-core-ddl.sql
</input>

<output>
The expected result is a plantuml diagram written in the input/images-source/fsl-datamodel.plantuml.
The header of plantuml must be started with :
```plantuml
@startuml fsl-datamodel

skinparam Shadowing 1.0
' avoid problems with angled crows feet
skinparam linetype ortho

scale max 1100 width

title
Modèle de donnée du Hub d'intégration
end title

' Entity styling
!define TABLE(name) entity name
!define PK(field) <b><u>field</u></b>
!define FK(field) <i>field</i>
```
The diagram should uses the exact header format requested and will generate a comprehensive visual representation of the FHIR Semantic Layer data model relationships when rendered.
You must follow strictilly data-plateform/semantic-layer/sql/fhir-core-ddl.sql
You must follow strictilly the style define into header
</output>