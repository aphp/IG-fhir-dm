
Construite à partir de la ressource Patient, cette vue alimente la table OMOP `person`. 
Elle contient l'identifiant du patient, sa date de naissance, ainsi que son sexe traduit vers les codes standards attendus par OMOP. 
Cette traduction repose sur un calcul qui multiplie chaque concept_id candidat par 1 si la modalité correspondante est vérifiée, et par 0 sinon, de sorte que seul le concept_id correspondant au sexe réellement renseigné apparaît dans le résultat (8532 pour féminin, 8507 pour masculin).

| Colonne | Signification métier |
|---|---|
| person_id | Identifiant du patient |
| gender_concept_id | Sexe codé selon le référentiel standard OMOP |
| birth_date | Date de naissance |
| year_of_birth | Année de naissance |
| month_of_birth | Mois de naissance |
| day_of_birth | Jour de naissance |
| location_id | Référence vers le lieu de résidence du patient |
| gender_source_value | Sexe tel qu'enregistré dans la source FHIR |
{: .grid}
