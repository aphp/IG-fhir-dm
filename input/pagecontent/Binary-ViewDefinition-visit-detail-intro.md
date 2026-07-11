
Construite à partir de la ressource Encounter, cette vue alimente la table OMOP `visit_detail`. 
Elle contient la référence vers le patient et vers le séjour, ainsi que les dates de début et de fin du détail de séjour. 
Le type de séjour et les informations de provenance et de destination sont établis par un calcul qui multiplie chaque concept_id candidat par 1 si la modalité correspondante est vérifiée, et par 0 sinon, de sorte que seul le concept_id correspondant à la modalité réellement présente apparaît dans le résultat. 
L'origine de la donnée est tracée par une constante (44818518).
Cette viewdefinition vise à apporter un niveau de détail plus fin du séjour.
Dans la version actuelle, le détail du séjour n'est pas distingué du séjour global : la référence vers le séjour reprend le même identifiant que le détail lui-même.

| Colonne | Signification métier |
|---|---|
| visit_detail_id | Identifiant du détail de séjour |
| person_id | Référence vers le patient concerné |
| visit_occurrence_id | Référence vers le séjour |
| visit_detail_start_date | Date de début du détail de séjour |
| visit_detail_start_datetime | Date et heure de début du détail de séjour |
| visit_detail_end_date | Date de fin du détail de séjour |
| visit_detail_end_datetime | Date et heure de fin du détail de séjour |
| visit_detail_concept_id | Type de prise en charge, codé selon le référentiel standard OMOP |
| visit_detail_source_value | Type de prise en charge tel que libellé dans la source |
| visit_detail_source_concept_id | Code source du type de prise en charge |
| visit_detail_type_concept_id | Origine de l'enregistrement de la donnée |
| admitted_from_concept_id | Provenance du patient à l'admission, codée selon le référentiel standard OMOP |
| admitted_from_source_value | Provenance du patient telle que libellée dans la source |
| admitted_from_source_concept_id | Code source de la provenance |
| discharged_to_concept_id | Destination du patient à la sortie, codée selon le référentiel standard OMOP |
| discharged_to_source_value | Destination telle que libellée dans la source |
| discharged_to_source_concept_id | Code source de la destination |
{: .grid}
