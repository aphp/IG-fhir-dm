
Construite à partir de la ressource **`Organization`**, cette vue prépare et structure les données en vue de leur chargement dans la table OMOP **`care_site`**.

Elle contient l'identifiant et le nom de l'établissement ou de l'unité de soins, l'identifiant de l'élément `address` principal, ainsi que des valeurs sources pour le type de lieu de prise en charge.

> Cette ViewDefinition provient de l'ancien module d'export Python de la plateforme (`data-exporter`). Elle n'a pas encore été testée sur le corpus de la plateforme de données de santé (PDS).

| Colonne | Signification métier |
|---|---|
| care_site_id | Identifiant de l'unité de soins |
| care_site_name | Nom de l'unité de soins |
| location_id | Identifiant de l'élément `address` principal (et non une référence vers une ressource `Location`) |
| care_site_source_value | Valeur source de l'unité de soins |
| place_of_service_source_value | Type de lieu de prise en charge, tel qu'enregistré dans la source FHIR |
{: .grid}
