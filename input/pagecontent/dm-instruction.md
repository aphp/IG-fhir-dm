Le processus d'instruction se compose de 5 étapes :
##### Modèle conceptuel
Il s'agit de définir, avec les acteurs métiers, [les principaux concepts manipulés dans leur domaine et de les définir](#modèle-de-donnée-conceptuel)

##### Modèle métier

À l'aide du [FormBuilder](https://formbuilder-prod-ext-k8s.eds.aphp.fr/), une ressource `Questionnaire` est produite en tenant compte des exigences.

##### Data discovery

###### Qu'est-ce que la **Data Discovery** ?

La **Data Discovery** (ou découverte des données) est un processus clé en **Data Management** qui consiste à identifier, 
explorer et analyser les données disponibles au sein d’une organisation. Son objectif est de permettre aux utilisateurs 
– qu’ils soient analystes, data scientists ou responsables métiers – de mieux comprendre leurs données, d’en extraire 
des insights pertinents et d’améliorer la prise de décision.

###### Les étapes clés de la Data Discovery

1. **Identification et collecte des données**
  - Recensement des sources de données internes et externes (bases de données, fichiers, API, applications métiers, 
etc.).
  - Détection des relations entre les différentes sources pour mieux les exploiter.

2. **Profilage et analyse des données**
  - Évaluation de la **qualité des données** (cohérence, duplication, erreurs, valeurs manquantes).
  - Analyse des schémas et des tendances pour mieux comprendre la structure des données.

3. **Visualisation et exploration**
  - Utilisation d’outils de **data visualization** pour représenter graphiquement les données et faciliter leur 
interprétation.
  - Découverte de corrélations et de modèles grâce à des techniques analytiques avancées.

4. **Sécurisation et conformité**
  - Identification des **données sensibles** (ex : données personnelles soumises au RGPD).
  - Mise en place de règles de gouvernance et de sécurité pour assurer une utilisation conforme des données.

###### Pourquoi la Data Discovery est-elle importante ?

- **Meilleure prise de décision** : en explorant les données sous différents angles, les organisations peuvent 
identifier des opportunités et anticiper des risques.
- **Amélioration de la qualité des données** : la découverte des incohérences permet de corriger les erreurs et 
d’optimiser les processus.
- **Facilitation de la gouvernance des données** : en comprenant mieux où se trouvent les données et comment elles sont 
utilisées, les entreprises assurent une meilleure gestion de leurs actifs data.
- **Innovation et agilité** : la capacité à identifier rapidement des insights favorise l’innovation et accélère la 
transformation digitale.

La **Data Discovery** est donc un levier essentiel pour toute organisation souhaitant exploiter au mieux la valeur de 
ses données, en garantissant transparence, qualité et conformité.

###### Supports

Afin de construire la preuve résultant du processus de "Data Discovery", un alignement est réalisé entre les modèles 
physiques des sources identifiées et une ressource `QuestionnaireResponse` correspondant [au `Questionnaire` des exigences](data-management.html#mod%C3%A8le-m%C3%A9tier). Cette preuve a deux vertus :

1. Documenter ce qui a été découvert,
2. Valider, car cette preuve s'appuie sur un langage formel et standard permettant le calcul de couverture (PKI).

##### Validation

Le processus de "Validation" consiste à s'assurer sur un échantillon représentatif que la collecte des données va 
permettre de répondre aux exigences du cas d'usage. En fonction du résultat, les étapes suivantes peuvent différer à tel 
point que le résultat peut provoquer l'abandon du cas d'usage.

##### Conception de la couche sémantique

À l'issue de la "Data Discovery" et une fois avoir apporté la preuve que le cas d'usage peut se faire, l'identification 
des ressources FHIR est réalisée. En priorité, nous choisissons les ressources compatibles avec l'écosystème français 
(guides d'implémentation de l'ANS et d'Interop'santé). Récemment, de nombreux efforts ont été réalisés au niveau européen 
et par conséquent et de plus en plus, nous devons également tenir compte des guides d'implémentation FHIR européen, nous 
préparant ainsi à l'European Health Data Space (EHDS).

###### Alignement liste de variables (modèle métier) vers FHIR

Un alignement est réalisé entre le `QuestionnaireResponse` créé lors de la data discovery et les ressource FHIR pertinentes 
identifiées. Cela permet de formaliser les preuves que l'ensemble des variables d'un usage a été traitée.

###### Alignement modèle physique vers FHIR

Un alignement est réalisé entre les élements du modèle physique des source de données et et les ressource FHIR pertinentes 
identifiées. Cela permet de formaliser les règles d'alimentation du Hub de données de santé (couche sémantique).

##### Publication dans le catalogue des données

TODO à définir