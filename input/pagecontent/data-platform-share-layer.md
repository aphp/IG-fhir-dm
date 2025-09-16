{% include markdown-link-references.md %}

>* API REST (HAPI)
>* Pathling
>* Bucket 
>* OMOP (StructureDefinition logic)
>* ViewDefinition / per OMOP Table
>* Parquet
>* DuckDB

{% include data-export-process.mermaid %}

Vous pouvez trouver l'alignement formel entre la couche sémantique FHIR et le modèle physique OMOP : 

* Patient : [FHIR Patient vers Modèle physique OMOP](StructureMap-CoreFHIRPatient2OMOP.html)
* Claim : [FHIR Claim vers Modèle physique OMOP]()
