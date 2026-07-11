
Construite à partir de la ressource Condition, cette vue complète la table OMOP `death` avec la cause du décès. 
Le diagnostic est sélectionné par un filtre qui, dans sa version actuelle, cible un patient déterminé (patient décédé).
Le diagnostic n'est pas encore rattaché à un concept standard (colonne à 0), mais le code d'origine reste disponible dans une colonne source dédiée.

| Colonne | Signification métier |
|---|---|
| person_id | Référence vers le patient concerné |
| cause_concept_id | Cause du décès codée selon le référentiel standard OMOP |
| cause_source_value | Cause du décès telle que libellée dans la source |
| cause_source_concept_id | Code source de la cause du décès |
| cause_coding_source_system | Système de codage du code source |
{: .grid}
