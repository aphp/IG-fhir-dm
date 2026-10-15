
Construite à partir de la ressource **`Specimen`**, cette vue prépare et structure les données en vue de leur chargement dans la table OMOP **`specimen`**.

Elle contient l'identifiant de l'échantillon, la référence vers le patient, la date et l'heure du prélèvement, la quantité prélevée, ainsi que des valeurs sources pour le type d'échantillon, le site anatomique et l'état pathologique.

> Cette ViewDefinition provient de l'ancien module d'export Python de la plateforme (`data-exporter`). Elle n'a pas encore été testée sur le corpus de la plateforme de données de santé (PDS).

| Colonne | Signification métier |
|---|---|
| specimen_id | Identifiant de l'échantillon |
| person_id | Référence vers le patient |
| specimen_date | Date du prélèvement |
| specimen_datetime | Date et heure du prélèvement |
| quantity | Quantité prélevée |
| specimen_source_id | Identifiant de l'échantillon dans la source |
| specimen_source_value | Type d'échantillon tel qu'enregistré dans la source FHIR |
| unit_source_value | Unité de la quantité prélevée |
| anatomic_site_source_value | Site anatomique du prélèvement |
| disease_status_source_value | État pathologique |
{: .grid}
