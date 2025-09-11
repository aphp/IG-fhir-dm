{% include markdown-link-references.md %}

### Architecture fonctionnelle

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div id="dm-schema-fonctionnel">
  <img src="dm-schema-fonctionnel.jpg" alt="Le schéma suivant représente la data plateforme cible" height="auto" width="100%" />
</div>

### Démo Health Data Platform

La **Health Data Platform** propose une démonstration complète illustrant comment le standard **FHIR** peut structurer et fluidifier l'usage des données de santé dans un cadre sécurisé et interopérable.  

Notre démonstration s'articule autour de plusieurs couches fonctionnelles (dans l'ordre) :  

- **[DPI](data-plateform-ehr.html)** : un Dossier Patient Informatisé central, socle de la collecte et de la traçabilité des données cliniques.  
- **[Transformation Layer](data-plateform-transform-layer.html)** : un moteur de conversion garantissant la mise en conformité et la normalisation des flux entrants.  
- **[Hub d'intégration](data-plateform-semantic-layer.html)** : un référentiel sémantique qui relie, aligne et enrichit les données en exploitant les terminologies standards.  
- **[Sharing Layer](data-plateform-share-layer.html)** : une couche de diffusion qui permet de partager les données de manière sélective et gouvernée, à destination des usages cliniques et de recherche.  
- **[EDS (CNIL)](data-plateform-eds.html)** : un entrepôt de données de santé respectant les recommandations réglementaires, en particulier celles de la CNIL.  

Cette démo illustre la capacité d'une organisation à **maîtriser la chaîne de valeur de la donnée de santé**, depuis la saisie jusqu'au partage, tout en anticipant les enjeux de gouvernance et d'innovation. Elle constitue un **levier stratégique** pour accélérer la transformation numérique et l'exploitation responsable des données cliniques.  
