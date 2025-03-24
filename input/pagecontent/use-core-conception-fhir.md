
La conception de la couche sémantique permet de décrire les données répondant aux besoins métiers préalablement identifiés de sorte que elles soient le plus réutilisable possible afin d'améliorer leur valeur.

La couche sémantique (au format FHIR), se décrit à l'aide des artefacts suivants :
(cliquez sur les liens pour obtenir plus d'information sur les artefacts)

##### Les profils
Les Profils précisent des ensembles de règles supplémentaires définies en plus de la spécification FHIR de base pour 
gérer le traitement des ressources.  
Les profils FHIR correspondants à notre usage sont le profil Patient (pour l'identifiant du patient, le genre et la date de naissance) 
et les profils Observations pour la taille, le poids.

  * Patient : [DMPatient]
  * Taille : [DMObservationBodyHeight]
  * Poids : [DMObservationBodyWeight] 
  

{% include markdown-link-references.md %}