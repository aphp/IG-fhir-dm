{% include markdown-link-references.md %}

La **Health Data Platform** propose une démonstration complète illustrant comment le standard **FHIR** peut structurer et fluidifier l'usage des données de santé dans un cadre sécurisé et interopérable. Cette démo illustre la capacité d'une organisation à **maîtriser la chaîne de valeur de la donnée de santé**, depuis la saisie jusqu'au partage, tout en anticipant les enjeux de gouvernance et d'innovation. Elle constitue un **levier stratégique** pour accélérer la transformation numérique et l'exploitation responsable des données cliniques.  

### Architecture fonctionnelle

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div id="dm-schema-fonctionnel">
  <img src="dm-schema-fonctionnel.jpg" alt="Le schéma suivant représente la data platforme cible" height="auto" width="100%" />
</div>

La mise en place d’une platforme de données de santé moderne suppose de combiner rigueur méthodologique et ambition collective. L’architecture prototypique que nous proposons repose sur cinq couches fonctionnelles clairement identifiées. Chaque couche contribue à la robustesse, à la sécurité et à la valorisation des données, depuis leur collecte brute jusqu’à leur exploitation stratégique. 

### [Raw layer](data-platform-raw-layer.html)

Cette première couche accueille les données dans leur état d’origine. Elle intègre :


>* les dossiers patients informatisés (DPI),
>* les plateaux techniques (biologie, pharmacie),
>* l'imagerie médicale,
>* la facturation et données administratives.


Elle joue le rôle de socle, garantissant l’exhaustivité et la traçabilité, tout en respectant les normes de sécurité.

### [Transformation layer](data-platform-transform-layer.html)

Ici s'opère la normalisation et la structuration des flux :


>* Change Data Capture pour détecter et synchroniser les évolutions,
>* ETL / ELT pour transformer et harmoniser les données.


Cette couche agit comme un filtre qualitatif, indispensable pour préparer la mise en valeur des informations.

### [Semantic layer](data-platform-semantic-layer.html)

Véritable hub d'intégration, cette couche assure la mise en cohérence des données. Elle applique des modèles de référence (FHIR ici) afin de rendre les données interopérables, comparables et partageables. Elle est au cœur de la convergence entre les systèmes cliniques, administratifs et décisionnels.

### [Sharing layer](data-platform-share-layer.html)

Une fois harmonisées, les données sont distribuées selon les besoins :


>* exports sécurisés,
>* livraison aux applications partenaires,
>* accès contrôlé aux professionnels de santé ou aux institutions.


Cette couche renforce la transparence et la confiance, en garantissant une gouvernance fine des usages.

### Perspectives

Au-delà de ce prototype, la vision stratégique est claire :


>* Consolider la confiance en plaçant la gouvernance et la protection des données au premier plan.
>* Stimuler l'innovation grâce à un socle technique agile, prêt à intégrer l'IA, l'analyse prédictive et la médecine personnalisée.
>* Fédérer les acteurs autour d’une ambition collective : faire de la donnée de santé un bien commun au service du patient, des soignants et de la recherche.


Cette architecture n'est pas seulement technique : elle constitue une boussole stratégique pour guider l'écosystème vers une utilisation responsable, innovante et pérenne de la donnée de santé.
