
Construite à partir de la ressource Observation, pour les résultats ne portant qu'une seule valeur, par exemple une glycémie, cette vue alimente la table OMOP `measurement`.
Elle contient la référence vers le patient et vers le séjour concernés, la date du résultat, sa valeur, son unité, ainsi que les bornes de normalité lorsqu'elles sont disponibles. 
Le résultat n'est pas encore rattaché à un concept standard (colonne à 0) mais le code d'origine reste disponible dans une colonne source dédiée.
L'origine de la donnée, un résultat de laboratoire, est tracée par une constante (44818702).
Un filtre restreint cette viewdefinition aux observations qui ne comportent pas plusieurs résultats liés ; celles qui en comportent sont prises en charge par une seconde viewdefinition (Measurement (composite)), également destinée à la table `measurement`.

| Colonne | Signification métier |
|---|---|
| measurement_id | Identifiant du résultat |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| measurement_date | Date du résultat |
| measurement_concept_id | Analyse codée selon le référentiel standard OMOP |
| measurement_source_value | Analyse telle que libellée dans la source |
| measurement_source_concept_id | Code source de l'analyse |
| measurement_coding_source_system | Système de codage du code source |
| measurement_type_concept_id | Origine de l'enregistrement de la donnée |
| value_as_number | Valeur numérique du résultat |
| unit_concept_id | Unité de mesure, codée |
| unit_source_value | Unité telle que libellée dans la source |
| range_low | Borne basse de normalité |
| range_high | Borne haute de normalité |
{: .grid}
 