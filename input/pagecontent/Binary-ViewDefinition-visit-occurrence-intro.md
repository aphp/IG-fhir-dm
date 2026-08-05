
Construite à partir de la ressource **`Encounter`**, qui représente un séjour ou une prise en charge, cette vue prépare et structure les données en vue de leur chargement dans la table OMOP **`visit_occurrence`**.

Elle contient la référence vers le `patient` concerné, les `dates de début et de fin` du séjour, ainsi que le `type de prise en charge` (hospitalisation, consultation externe, urgences). Un calcul détermine le `concept_id` correspondant : il multiplie chaque `concept_id` candidat par 1 si la modalité correspondante est vérifiée, et par 0 sinon, de sorte que seul le `concept_id` correspondant à la modalité réellement présente apparaît dans le résultat.

La `provenance` du patient à l'entrée et sa `destination` à la sortie sont établies selon le même principe.

L'origine de cette information est tracée par une constante (`44818518`) si elle est saisie dans le dossier patient.

| Colonne | Signification métier |
|---|---|
| visit_occurrence_id | Identifiant du séjour |
| person_id | Référence vers le patient concerné |
| visit_start_date | Date de début du séjour |
| visit_end_date | Date de fin du séjour |
| visit_concept_id | Type de prise en charge, codé selon le référentiel standard OMOP |
| visit_source_value | Type de prise en charge tel que libellé dans la source |
| visit_source_concept_id | Code source du type de prise en charge |
| visit_coding_source_system | Système de codage du code source |
| visit_type_concept_id | Origine de l'enregistrement de la donnée |
| admitted_from_concept_id | Provenance du patient à l'admission, codée selon le référentiel standard OMOP |
| admitted_from_source_value | Provenance du patient telle que libellée dans la source |
| admitted_from_source_concept_id | Code source de la provenance |
| discharged_to_concept_id | Destination du patient à la sortie, codée selon le référentiel standard OMOP |
| discharged_to_source_value | Destination telle que libellée dans la source |
| discharged_to_source_concept_id | Code source de la destination |
{: .grid}
