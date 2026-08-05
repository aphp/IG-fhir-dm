
Construite à partir de la ressource **`Observation`**, pour les résultats qui rassemblent plusieurs mesures liées (par exemple une pression artérielle associant une valeur systolique et une valeur diastolique), cette ViewDefinition prépare elle aussi les données en vue de leur chargement dans la table OMOP **`measurement`**.

Elle contient la référence vers le `patient` et vers le `séjour` concernés, ainsi que la `date` du résultat.

Une clause `forEach` répète la transformation pour chaque composant de la mesure, de sorte que chacun donne lieu à une ligne distincte, plutôt que d'être condensé dans une seule ligne.

Comme pour les résultats à valeur unique, le résultat **n'est pas rattaché** à un concept standard (la colonne correspondante est laissée à 0), mais le code d'origine reste disponible dans une colonne source dédiée. L'origine de la donnée est tracée par la même constante (`44818702`).

Un filtre restreint cette vue aux observations qui comportent effectivement plusieurs résultats liés.

| Colonne | Signification métier |
|---|---|
| measurement_id | Identifiant du résultat |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| measurement_date | Date du résultat |
| measurement_concept_id | Analyse codée selon le référentiel standard OMOP |
| measurement_type_concept_id | Origine de l'enregistrement de la donnée |
| measurement_event_id | Référence vers l'observation d'origine regroupant les différents composants |
| measurement_source_value | Composant tel que libellé dans la source |
| measurement_source_concept_id | Code source du composant |
| measurement_coding_source_system | Système de codage du code source |
| value_as_number | Valeur numérique du composant |
| unit_concept_id | Unité de mesure, codée |
| unit_source_value | Unité telle que libellée dans la source |
{: .grid}
