
Construite à partir de la ressource **`Medication`**, cette vue prépare et structure les données en vue de leur chargement dans la table OMOP **`drug_strength`**.

Elle décrit le dosage d'un médicament : le médicament et son premier principe actif, la quantité de principe actif (numérateur et dénominateur, avec leurs unités) et la taille du conditionnement.

> Cette ViewDefinition provient de l'ancien module d'export Python de la plateforme (`data-exporter`). Elle n'a pas encore été testée sur le corpus de la plateforme de données de santé (PDS). Les dates de validité reprennent provisoirement la date de péremption du lot (`batch.expirationDate`), et les `*_concept_id` contiennent les codes sources, sans traduction vers le vocabulaire standard OMOP.

| Colonne | Signification métier |
|---|---|
| drug_concept_id | Médicament |
| ingredient_concept_id | Principe actif |
| amount_value | Quantité de principe actif |
| amount_unit_concept_id | Unité de la quantité de principe actif |
| numerator_value | Numérateur du dosage |
| numerator_unit_concept_id | Unité du numérateur |
| denominator_value | Dénominateur du dosage |
| denominator_unit_concept_id | Unité du dénominateur |
| box_size | Taille du conditionnement |
| valid_start_date | Début de validité (provisoire) |
| valid_end_date | Fin de validité (provisoire) |
| invalid_reason | Motif d'invalidité, repris du statut du médicament |
{: .grid}
