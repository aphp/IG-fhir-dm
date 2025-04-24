La méthodologie de gestion des données avec FHIR (Data Management with FHIR) s'inspire du [Model Driven Architecture (MDA)](glossary.html#mda) faisant notamment de la modélisation le coeur de la stratégie de développement logiciel que nous appliquons à la donnée et notamment à la donnée de santé.

Pour rappel, les objectifs de l'approche MDA est de favoriser la portabilité des applications, d'améliorer la réutilisabilité et la productivité, de faciliter la maintenance de systèmes et enfin de promouvoir la standardisation. Ces objectifs s'alignent pleinement avec l'usage du standard FHIR comme langage unique du SIH.

L'approche MDA référence trois types de modèles :

1. CIM (Computation Independant Model) : ce sont des modèles indépendant de l'informatique, focalisé sur les besoins métiers, il est fréquent de trouver le terme de modèle conceptuel.
2. PIM (Platform Independent Model) : ce sont des modèles indépendant des plateformes décrivant les fonctionnalités des systèmes sans ce soucier de la technologie, il est fréquent de trouver le terme de modèle logique.
3. PSM (Platform Specific Model) : ce sont des modèles spécifiques à une plateforme technique, il est fréquent de trouver le terme de modèle physique.

Dans l'approche MDA, le rôle des transformations de modèles est centrale et elles doivent être le plus automatisée possible notamment pour passer de CIM -> PIM (compréhension métier -> modélisation fonctionnelle), de PIM -> PSM (modélisation fonctionnelle -> structure technique) et de PSM -> Code (génération de code automatisée).

L'approche MDA a été initialement conçue pour le développement logiciel, avec pour objectif de structurer les applications autour de modèles formels et transformables. Toutefois, lorsqu'on cherche à transposer cette approche au contexte de la donnée, une adaptation est nécessaire.

En effet, bien que le monde du logiciel et celui de la donnée soient étroitement liés, ils reposent sur des fondamentaux différents. Le logiciel s'inscrit dans une logique fonctionnelle, orientée vers des comportements et des processus d'exécution, tandis que la donnée s'ancre dans une logique informationnelle, centrée sur la structure, la qualité, le cycle de vie et la gouvernance des données.

Ainsi, appliquer directement les méthodes MDA issues du développement logiciel au domaine de la donnée reviendrait à négliger des spécificités essentielles, comme la variabilité des sources, la volatilité des formats, la traçabilité ou encore les enjeux d'intégration et d'interopérabilité. Cela nécessite une réinterprétation du MDA pour l'adapter aux exigences du data-driven.

La puissance du standard FHIR permet d'adresser les niveaux PIM, PSM et aussi les transformations entre les niveaux PIM et PSM par l'usage du [FHIR Mapping Language (FML)](glossary.html#fml).

Les ressources FHIR de type `StructureDefinition` permettent soit de définir des structures logiques pouvant exprimer tous types de structure de donnée notammant les schémas de base de donnée et dans cet exemple ces struc

### Contexte

Un [Hub de Données de Santé](glossary.html#hds) est un dépôt central de données standardisées provenant de sources multiples au sein d'un SIH. Il est conçu pour :

- Soutenir la recherche scientifique
- Développer des recherches multicentriques
- Appuyer la recherche clinique
- Appuyer l'innovation dans le domaine de la santé
- Faciliter le pilotage de l'activité hospitalière

#### Disclaimer

Nous nous permettons d'attirer l'attention des utilisateurs sur les éléments d'information apportés concernant la manière dont les données ont été produites.

Même s'il s'agit d'une description d'assez haut niveau, qui peut être déclinée de manière très variable au niveau des hôpitaux, pôles, services et équipes de soins, elle permet de mieux apprécier l'usage qui peut être fait des données présentes dans le Hub de données.

### Sources multiples

On peut avoir différentes sources dans le système d'information (SI) de production qui peuvent fournir des informations équivalentes avec des status différents. 
Idéalement, on s'attachera à reconstruire, au niveau du Hub de données, le cycle de vie de la ressource, avec les experts métiers. 
Cette tâche peut néanmoins être difficile et on pourra être amené à intégrer dans un hub de données, depuis deux sources différentes, des données qui correspondent à une seule information à un stade différent dans son cycle de vie. 
On s'astreindra donc à toujours mentionner la source (via l'attribut `meta.source`) dans les ressources FHIR manipulées au niveau du Hub de données (voir [convention de nommage des uris source](help.html#uri-des-sources)). 

Dans tous les cas, on essayera d'expliciter dans les ressources l'étape du cycle de vie, au-delà de la source de l'information. 

Ces décisions seront documentées dans le présent IG ainsi que les profils/extensions à mettre en œuvre le cas échéant. 

### Gestion de version

La gestion des versions s'appuie sur le mécanisme proposé par HL7 FHIR. En FHIR, il y a trois niveaux de version pour une ressource :

1.	La version d'enregistrement : change à chaque fois que la ressource change (habituellement géré par le serveur)
2.	La version métier : change à chaque fois que le contenu d'une ressource change (géré par un l'auteur humain ou par des règles métiers)
3.	La version FHIR : la version de FHIR dans laquelle la ressource est représentée (contrôlé par l'auteur de la ressource)

Références : [FHIR R4](http://hl7.org/fhir/R4/resource.html#versions)

#### Version FHIR

Pour ce qui est de la version FHIR, [la version promue actuellement en France est la version R4](https://interop.esante.gouv.fr/ig/documentation/bonnes_pratiques_modeler.html#choix-de-la-version-de-fhir).  

#### Business version

Pour ce qui est de la version métier (business version), portée par l'attribut `Questionnaire.version` par exemple, elle sera directement reprise du SI de production. 
Chaque version integrée dans le Hub de données donnera lieu à la création d'une nouvelle instance de Questionnaire avec :

 - le même nom
 - la même url
 - une version différente

La gestion des versions doit suivre un algorithme documenté pour permettre à un utilisateur d'être sur qu'il utilise la dernière version.

**En l'état actuel de la situation, l'IG publisher ne permet pas d'intégrer dans un FHIR IG deux ressources de même id (l'url étant construite sur la base de l'id).** 
il n'est donc pas possible de publier plusieurs business version dans le FIG. Le serveur HAPI n'a pas cette contrainte.  

Références : [ici](https://chat.fhir.org/#narrow/stream/179255-questionnaire/topic/Questionnaire.20versioning/near/419859167)
et [là](https://brianpos.com/2022/12/13/canonical-versioning-in-your-fhir-server/)

#### Record version

Pour ce qui est de la version d'enregistrement (record version), portée par l'attribut `.meta.versionId`, elle est gérée par le serveur Fhir, et incrémenté à chaque modification.  

Dans FHIR, toutes les ressources sont conceptuellement versionnés, et chaque ressource se trouve en tête d'une liste linéaire de versions antérieures. Les versions antérieures sont remplacées par la version actuelle et ne sont disponibles qu'à des fins d'audit/d'intégrité. L'information de version peut être référencée dans une référence de ressource. Elle peut être utilisée pour garantir que les mises à jour sont basées sur la dernière version de la ressource. La version peut être unique au monde ou limitée par l'ID logique de la ressource. Les identifiants de version sont généralement soit un identifiant incrémenté en série limité par l'identifiant logique, soit un "uuid", bien qu'aucune de ces approches ne soit requise. Il n'y a pas d'ordre fixe pour les identifiants de version - les clients ne peuvent pas supposer qu'un identifiant de version qui vient après un autre, numériquement ou alphabétiquement, représente une version ultérieure. Le même "versionId" ne peut jamais être utilisé pour plusieurs versions de la même ressource. Dans le cas de l'API RESTful : lors de la réception d'une mise à jour, d'un correctif ou d'une autre opération FHIR ayant un impact sur l'attribut "meta" d'une ressource, le serveur DOIT mettre à jour cet élément à la valeur actuelle ou le supprimer. Notez que les serveurs DEVRAIENT prendre en charge les versions, mais certains sont incapables de le faire.

### Processus de livraison

Cette page décrit le processus de livraison de données faisant suite aux traitements d'un cas d'usage (expression de besoins).

<div style="text-align: center;">{%include delivery-process.svg%}</div>

#### Qualification

La description du processus de "Qualification" est hors sujet pour le moment. Néanmoins, nous pouvons préciser que  l'objectif de ce processus est de produire les exigences d'un cas d'usage afin d'être en capacité de démarrer le processus d'instruction.

#### Instruction

{% include dm-instruction.md %}

#### Réalisation

La description du processus de "Réalisation" est hors sujet pour le moment. Néanmoins, nous pouvons préciser que l'objectif de ce processus est de mettre en œuvre les spécifications fonctionnelles et techniques produites lors de l'étape d'instruction.

#### Recette

La description du processus de "Recette" est hors sujet pour le moment. Néanmoins, nous pouvons préciser que l'objectif de ce processus est de vérifier que la mise en œuvre issue du processus de "Réalisation" est conforme à la spécification issue du processus d'"Instruction".

#### Mise en production

La description du processus de "Mise en production" est hors sujet pour le moment. Néanmoins, nous pouvons préciser que l'objectif de ce processus est de suivre les procédures de mise en production.

#### Amélioration continue

La description du processus de "Amélioration continue" est hors sujet pour le moment. Néanmoins, nous pouvons préciser que l'objectif de ce processus est d'assurer que les données livrées soient conformes aux exigences de nos utilisateurs.

{% include markdown-link-references.md %}