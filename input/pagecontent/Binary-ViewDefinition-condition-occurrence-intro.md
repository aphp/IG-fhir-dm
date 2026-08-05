
Construite à partir de la ressource **`Condition`**, cette vue prépare et structure les données en vue de leur chargement dans la table **`condition_occurrence`** du modèle OMOP.

Elle contient la référence vers le `patient` et vers le `séjour` concernés, la `date d'enregistrement` du diagnostic, ainsi que son `statut` (principal ou associé). Un calcul détermine le `concept_id` correspondant au statut : il multiplie chaque `concept_id` candidat par 1 si la modalité correspondante est vérifiée, et par 0 sinon, de sorte que seul le `concept_id` correspondant à la modalité réellement présente apparaît dans le résultat.

Le diagnostic **n'est pas rattaché** à un concept standard OMOP (la colonne correspondante est laissée à 0), mais le code d'origine reste disponible dans une colonne source dédiée.

L'origine de la donnée est tracée par une constante (`32817`).

Certains codes ne correspondant pas à un diagnostic actif (antécédents médicaux, style de vie ou informations administratives): les inclure ici fausserait le contenu de la table **``condition_occurrence``** qui doit ne représenter que des diagnostics. 

C'est pourquoi ils sont exclus par un filtre de cette vue, et pris en charge par une ViewDefinition distincte, destinée à la table **`observation`**.


| Colonne | Signification métier |
|---|---|
| condition_occurrence_id | Identifiant du diagnostic |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| condition_start_date | Date d'enregistrement du diagnostic |
| condition_concept_id | Diagnostic codé selon le référentiel standard OMOP |
| condition_source_value | Diagnostic tel que libellé dans la source |
| condition_source_concept_id | Code source du diagnostic |
| condition_coding_source_system | Système de codage du code source |
| condition_type_concept_id | Origine de l'enregistrement de la donnée |
| condition_status_concept_id | Statut du diagnostic (principal ou associé), codé selon le référentiel standard OMOP |
| condition_status_source_value | Statut du diagnostic tel que libellé dans la source |
{: .grid}
