
Cette vue s'appuie sur la ressource **`Patient`** et prépare les données en vue de leur chargement dans la table OMOP **`death`**.

Un filtre est appliqué pour ne retenir que les patients pour lesquels une date de décès est renseignée dans FHIR, et pour conserver cette date. Elle contient la référence vers le `patient`.

L'origine de la donnée est tracée par une constante (`32817`).

| Colonne | Signification métier |
|---|---|
| person_id | Référence vers le patient concerné |
| death_date | Date du décès |
| death_datetime | Date et heure du décès |
| death_type_concept_id | Origine de l'enregistrement de la donnée |
{: .grid}
