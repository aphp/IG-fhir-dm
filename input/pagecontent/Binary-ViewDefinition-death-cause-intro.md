
Construite à partir de la ressource **`Condition`**, cette vue complète la table OMOP **`death`** avec la cause du décès.

Un filtre sélectionne le diagnostic. Dans sa version actuelle, la ViewDefinition cible un seul `patient` (patient décédé). Elle contient la référence vers le `patient`.

Le diagnostic **n'est pas rattaché** à un concept standard (colonne à 0), mais le code d'origine reste disponible dans une colonne source dédiée.

| Colonne | Signification métier |
|---|---|
| person_id | Référence vers le patient concerné |
| cause_concept_id | Cause du décès codée selon le référentiel standard OMOP |
| cause_source_value | Cause du décès telle que libellée dans la source |
| cause_source_concept_id | Code source de la cause du décès |
| cause_coding_source_system | Système de codage du code source |
{: .grid}
