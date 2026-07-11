
Cette vue s'appuie également sur la ressource Patient, mais pour alimenter la table OMOP `location`. 
Elle contient la latitude et la longitude du patient, lorsque ces coordonnées sont renseignées dans son adresse.

| Colonne | Signification métier |
|---|---|
| location_id | Identifiant du lieu |
| person_id | Référence vers le patient concerné |
| latitude | Latitude géographique |
| longitude | Longitude géographique |
{: .grid}
