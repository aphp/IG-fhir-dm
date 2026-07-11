
Cette vue s'appuie sur les ressources Patient pour alimenter la table OMOP `death`. 
Ce filtre n'inclut que les patients pour lesquels une date de décès est renseignée dans FHIR, et retient cette date. 
L'origine de la donnée est tracée par une constante (32817).

| Colonne | Signification métier |
|---|---|
| person_id | Référence vers le patient concerné |
| death_date | Date du décès |
| death_datetime | Date et heure du décès |
| death_type_concept_id | Origine de l'enregistrement de la donnée |
{: .grid}
