##### Conception fonctionnelle

La conception fonctionnelle permet de décrire le format cible des données pour répondre aux besoins métiers préalablement identifiés, puis le mapping du modèle métier vers le format cible.  
Le format cible est le format FHIR, décrit à l'aide des artefacts suivants :
(cliquez sur les liens pour obtenir plus d'information sur les artefacts)

###### **Les Profils FHIR**
Les Profils précisent des ensembles de règles supplémentaires définies en plus de la spécification FHIR de base pour 
gérer le traitement des ressources.  
Les profils FHIR correspondants à notre usage sont le profil Patient (pour l'identifiant du patient, le genre et la date de naissance) 
et les profils Observations pour la taille, le poids.

  * Patient : [DMPatient]
  * Taille : [DMObservationBodyHeight]
  * Poids : [DMObservationBodyWeight] 
  

{% include markdown-link-references.md %}