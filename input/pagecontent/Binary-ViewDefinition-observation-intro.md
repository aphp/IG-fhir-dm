
Certains éléments de la ressource Condition ne correspondent pas à un diagnostic actif mais à un antécédent médical, un style de vie ou une information administrative.
Cette viewdefinition les extrait pour alimenter la table OMOP `observation`, distincte de la table `condition_occurrence` bien que la ressource source soit la même. 
Elle contient la référence vers le patient et vers le séjour concernés, ainsi que la date d'enregistrement. 
Un filtre, symétrique de celui appliqué pour les diagnostics actifs, retient précisément les codes qui en sont exclus. 
Le code n'est pas encore rattaché à un concept standard (colonne à 0), mais le code d'origine reste disponible dans une colonne source dédiée.
L'origine de la donnée est tracée par une constante (38000280).

| Colonne | Signification métier |
|---|---|
| observation_id | Identifiant de l'observation |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| observation_date | Date d'enregistrement |
| observation_datetime | Date et heure d'enregistrement |
| observation_concept_id | Élément codé selon le référentiel standard OMOP |
| observation_source_value | Élément tel que libellé dans la source |
| observation_source_concept_id | Code source de l'élément |
| observation_coding_source_system | Système de codage du code source |
| observation_type_concept_id | Origine de l'enregistrement de la donnée |
{: .grid}
