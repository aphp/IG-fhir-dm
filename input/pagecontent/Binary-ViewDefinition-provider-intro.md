
Construite à partir de la ressource **`Practitioner`**, cette vue prépare et structure les données en vue de leur chargement dans la table OMOP **`provider`**.

Elle contient l'identifiant et le nom du professionnel de santé, sa spécialité, son rattachement à une unité de soins, son année de naissance et son sexe.

> Cette ViewDefinition provient de l'ancien module d'export Python de la plateforme (`data-exporter`). Elle n'a pas encore été testée sur le corpus de la plateforme de données de santé (PDS). Les colonnes `npi` et `dea` lisent des identifiants américains (`us-npi`, `us-dea-number`). Dans un contexte français, il faudrait plutôt lire le RPPS ou l'ADELI. Les colonnes `specialty_concept_id` et `gender_concept_id` contiennent les codes sources, sans traduction vers le vocabulaire standard OMOP.

| Colonne | Signification métier |
|---|---|
| provider_id | Identifiant du professionnel |
| provider_name | Nom du professionnel |
| npi | Identifiant NPI (États-Unis) |
| dea | Identifiant DEA (États-Unis) |
| specialty_concept_id | Spécialité |
| care_site_id | Référence vers l'unité de soins de rattachement |
| year_of_birth | Année de naissance |
| gender_concept_id | Sexe |
| provider_source_value | Identifiant du professionnel dans la source |
| specialty_source_value | Spécialité telle qu'enregistrée dans la source FHIR |
| specialty_source_concept_id | Concept source de la spécialité (0 par défaut) |
| gender_source_value | Sexe tel qu'enregistré dans la source FHIR |
| gender_source_concept_id | Concept source du sexe (0 par défaut) |
{: .grid}
