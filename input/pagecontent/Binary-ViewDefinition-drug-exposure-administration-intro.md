
Construite à partir de la ressource MedicationAdministration, qui représente une administration effective de médicament, cette vue alimente elle aussi la table OMOP `drug_exposure`. 
Elle contient la référence vers le patient et vers le séjour concernés, le médicament réellement administré, la période réelle, la voie et la dose. 
Le médicament n'est pas encore rattaché à un concept standard (colonne à 0), mais le code d'origine reste disponible dans une colonne source dédiée. 
L'origine de la donnée est ici tracée par une constante différente (38000180), qui distingue une administration effective d'une prescription.

| Colonne | Signification métier |
|---|---|
| drug_exposure_id | Identifiant de l'exposition médicamenteuse |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour concerné |
| visit_detail_id | Référence vers le détail du séjour |
| drug_exposure_start_date | Date de début réelle du traitement |
| drug_exposure_start_datetime | Date et heure de début réelle du traitement |
| drug_exposure_end_date | Date de fin réelle du traitement |
| drug_exposure_end_datetime | Date et heure de fin réelle du traitement |
| drug_concept_id | Médicament codé selon le référentiel standard OMOP |
| drug_source_value | Médicament tel que libellé dans la source |
| drug_source_concept_id | Code source du médicament |
| drug_coding_source_system | Système de codage du code source |
| drug_type_concept_id | Origine de l'enregistrement de la donnée (ici, une administration) |
| route_source_value | Voie d'administration réelle, telle que libellée dans la source |
| route_source_concept_id | Code source de la voie d'administration |
| route_coding_source_system | Système de codage du code source |
| quantity | Dose administrée |
| dose_unit_source_value | Unité de la dose, telle que libellée dans la source |
{: .grid}
