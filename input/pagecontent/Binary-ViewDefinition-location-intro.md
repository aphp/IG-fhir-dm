
Cette vue s'appuie également sur la ressource **`Patient`**, et prépare les données en vue de leur chargement dans la table OMOP **`location`**.

Elle contient la `latitude` et la `longitude` du lieu de résidence du patient, lorsque ces coordonnées sont renseignées dans son adresse, ainsi que la référence vers le `patient`.

| Colonne | Signification métier |
|---|---|
| location_id | Identifiant du lieu |
| person_id | Référence vers le patient concerné |
| latitude | Latitude géographique |
| longitude | Longitude géographique |
{: .grid}
