
Construite à partir de la ressource MedicationRequest, qui représente une prescription médicamenteuse, cette vue alimente la table OMOP `drug_exposure`. 
Elle contient la référence vers le patient et vers le séjour concernés, le médicament prescrit, la période prévue de traitement, et la voie d'administration prévue. 
Le médicament n'est pas encore rattaché à un concept standard (colonne à 0), mais le code d'origine reste disponible dans une colonne source dédiée.
L'origine de la donnée, une prescription, est tracée par une constante (38000177).

| Colonne | Signification métier |
|---|---|
| drug_exposure_id | Identifiant de l'exposition médicamenteuse |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| drug_exposure_start_date | Date de début prévue du traitement |
| drug_exposure_end_date | Date de fin prévue du traitement |
| drug_concept_id | Médicament codé selon le référentiel standard OMOP |
| drug_source_value | Médicament tel que libellé dans la source |
| drug_source_concept_id | Code source du médicament |
| drug_coding_source_system | Système de codage du code source |
| drug_type_concept_id | Origine de l'enregistrement de la donnée (ici, une prescription) |
| route_source_value | Voie d'administration prévue, telle que libellée dans la source |
| route_source_concept_id | Code source de la voie d'administration |
| route_coding_source_system | Système de codage du code source |
{: .grid}
