
Construite à partir de la ressource Procedure, qui représente un acte réalisé, cette vue alimente la table OMOP `procedure_occurrence`. 
Elle contient la référence vers le patient et vers le séjour concernés, la date et la nature de l'acte. 
L'acte n'est pas encore rattaché à un concept standard (colonne à 0), mais le code d'origine reste disponible dans une colonne source dédiée.
L'origine de la donnée est tracée par une constante (38000275).

| Colonne | Signification métier |
|---|---|
| procedure_occurrence_id | Identifiant de l'acte |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| procedure_date | Date de l'acte |
| procedure_datetime | Date et heure de l'acte |
| procedure_concept_id | Acte codé selon le référentiel standard OMOP |
| procedure_source_value | Acte tel que libellé dans la source |
| procedure_source_concept_id | Code source de l'acte |
| procedure_coding_source_system | Système de codage du code source |
| procedure_type_concept_id | Origine de l'enregistrement de la donnée |
{: .grid}
