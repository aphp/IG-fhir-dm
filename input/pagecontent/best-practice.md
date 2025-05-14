L'application des bonnes pratiques constitue un facteur clé de réussite pour tout projet d'interopérabilité. Elle garantit la cohérence, la pérennité et la réutilisabilité des ressources produites, tout en facilitant leur adoption par l'ensemble des acteurs impliqués.

### L'écosystème

Pour produire des guides d'implémentation FHIR conduisant à des mises en œuvre réellement interopérables, il est essentiel de s'appuyer sur les bonnes pratiques établies par l'écosystème FHIR.

Voici une liste non exhaustive des bonnes pratiques à considérer :

* [Bonnes pratiques nationales pour la modélisation](https://interop.esante.gouv.fr/ig/documentation/bonnes_pratiques_modeler.html)
* [Bonnes pratiques nationales pour la mise en oeuvre](https://interop.esante.gouv.fr/ig/documentation/bonnes_pratiques_implementer.html)
* [Bonnes pratiques internationales](https://build.fhir.org/ig/FHIR/ig-guidance/best-practice.html)

### Règles de nommage des ressources

Chaque ressource est caractérisée par un ensemble d'éléments permettant son identification. Si les formats de ces propriétés sont imposés par l'écosystème FHIR, le choix de nommer une ressource relève toutefois de notre responsabilité.

#### Détermination des noms

La détermination des noms doit prendre en compte le "périmètre d’usage" de la ressource ou de l'élément. Autrement dit : quelles en sont les limites fonctionnelles ?

Les noms doivent :
* utiliser **le terme le plus largement reconnu dans le domaine** pour désigner l'objet, tout en évitant les risques de confusion avec d'autres éléments ;
* ne pas supposer de connaissance préalable des autres standards HL7 (comme v2, v3 ou CDA), sauf dans le cadre d'une **compréhension globale et courante** dans le domaine ;
* autant que possible, sans nuire à l'intuitivité pour les implémenteurs ;
* exprimer l'**ensemble du sens du concept** ;
* être **sensibles aux considérations politiques internationales** ;
* être exprimés au **singulier**, même si l'élément est répétable ;
* utiliser des **abréviations uniquement si elles sont parfaitement comprises** par l'ensemble du public visé ;
  * lorsqu'elles sont utilisées, considérer l'abréviation comme un mot, notamment pour les règles de casse (ex. : `targetUri` pour un nom d'élément) ;
* utiliser des noms **différents pour des éléments différents**, sauf si le **sens est identique dans chaque contexte** ;
  * par exemple, utiliser `.name` pour `sponsor.name` et `contact.name` est acceptable si le sens de `name` est cohérent entre les deux ;
* choisir des noms **distincts de concepts qui ne font pas partie du cœur de la ressource**, mais qui existent dans le domaine FHIR et pourraient prêter à confusion ;
* être **concis** : la différenciation sémantique par le nom n'est nécessaire qu'au sein d'une même ressource. La description complète figure dans les définitions ;
  * cela inclut l'**évitement de la redondance avec le contexte**. Par exemple, ne pas répéter une partie du nom du parent dans celui du fils ;
* rester **cohérents avec les éléments similaires** dans la même ressource ou dans d'autres, sauf si la terminologie usuelle de l'industrie justifie une différence ;
  * par exemple, `birthDate` et `dateOfDeath` forment une mauvaise paire, car incohérente ;
* être suffisamment différents des autres noms présents dans le même espace (éléments d'une ressource, ressources associées, opérations liées) pour éviter toute confusion à l'oral (ex. : `update` et `updates` posent problème) ;
* **ne pas inclure de suffixe indiquant le type de données** de l'élément (ex. : ne pas terminer un nom par `code`, `indicator`, etc.) ;
* lorsqu’un concept est **connu sous plusieurs noms**, utiliser des **alias** pour fournir ces noms alternatifs ;
* si un nom **tend à être souvent abrégé** dans les discussions de comité, c’est sans doute qu’il est **trop long**, et cela doit éveiller les soupçons ;
* utiliser **skmtglossary.org** et un **thésaurus** pour évaluer les noms candidats en cas de doute ;
* si la recherche d’un nom industrielement reconnu s’avère très difficile, cela peut indiquer que la **granularité** du concept ne correspond pas aux besoins réels du secteur.

L'objectif est de fournir un **maximum de clarté pour un développeur non familier**, afin qu'il comprenne immédiatement "ce qu'est cette chose". Les noms sont aussi utilisés pour la recherche. Leur longueur influence la taille des instances et la lisibilité du code : il faut donc trouver le bon **compromis entre précision sémantique et simplicité d’usage**.


La documentation officielle se trouve dans [règles de nommage et guide de bonnes pratiques](https://confluence.hl7.org/spaces/FHIR/pages/35718826/Guide+to+Designing+Resources#GuidetoDesigningResources-NamingRules&Guidelines).

Nous avons choisi de catégoriser les ressources selon qu'elles sont de type conformité, à usage de "définition", ou à vocation d'exemple.

#### Règles de nommage des ressources de conformité (ayant une URL)

Une ressource canonique est une ressource FHIR dont l'élément `url` sert d'identifiant unique global, stable et pérenne. Elle est conçue pour être réutilisée, partagée et référencée dans différents contextes.

Voici un tableau récapitulatif des ressources FHIR de conformité, leurs descriptions et des exemples d'usage.

| Ressource                   | Description                                                           | Exemple d'usage                                              |
| --------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------ |
| **ActivityDefinition**      | Définit une activité pouvant être instanciée dans un plan de soins.   | Ordre pré-rempli de médication.                              |
| **CapabilityStatement**     | Décrit les capacités d'un système FHIR.                               | Définir les opérations supportées par un serveur.            |
| **CodeSystem**              | Définit un système de codification.                                   | SNOMED CT, LOINC.                                            |
| **CompartmentDefinition**   | Définit les règles de compartiment d'accès aux données.               | Accès restreint aux données d'un patient.                    |
| **ConceptMap**              | Fait le lien entre deux systèmes de codes.                            | Conversion de codes internes vers un standard.               |
| **ImplementationGuide**     | Regroupe les artefacts pour un guide d'implémentation.                | IG d'un programme régional.                                  |
| **Library**                 | Contient de la logique clinique (souvent en CQL).                     | Règles de calcul de scores de risque.                        |
| **Measure**                 | Représente une mesure clinique ou de qualité.                         | Pourcentage de vaccination dans une population.              |
| **MessageDefinition**       | Spécifie la structure d'un message FHIR.                              | Message d'admission d'un patient.                            |
| **NamingSystem**            | Définit un système d'identifiants (OID, URI…).                        | Identifiants de patients.                                    |
| **OperationDefinition**     | Décrit une opération personnalisée.                                   | Opération `$validate`.                                       |
| **PlanDefinition**          | Représente un plan ou un protocole de soins.                          | Protocole de traitement d'un cancer.                         |
| **Questionnaire**           | Modèle de formulaire/questionnaire.                                   | Questionnaire de dépistage.                                  |
| **SearchParameter**         | Définit un paramètre de recherche.                                    | Permet la recherche sur une extension spécifique.            |
| **StructureDefinition**     | Définit un profil, une extension ou une contrainte sur une ressource. | Profil structuré pour `Patient`.                             |
| **StructureMap**            | Spécifie des règles de transformation entre structures.               | Mapper CDA vers FHIR.                                        |
| **TerminologyCapabilities** | Décrit les capacités d'un serveur de terminologie.                    | Indique les formats acceptés pour l'expansion de `ValueSet`. |
| **ValueSet**                | Spécifie un ensemble de codes autorisés.                              | Liste des sexes valides (`male`, `female`, etc.).            |

​Ces règles de nommage ont été établies en s'appuyant sur [les recommandations de l'ANS](https://interop.esante.gouv.fr/ig/documentation/bonnes_pratiques_modeler.html#r%C3%A8gles-de-nommage-des-ressources-de-conformit%C3%A9) et des bonnes pratiques indiquées par [Canonical Resource Management Infrastructure Implementation Guide](https://hl7.org/fhir/uv/crmi/artifact-conventions.html).

| **Paramètre** | **Objet concerné** | **Règle** | **Exemple** |
| ----- | ----- | ----- | ----- |
| id | ressources de conformité | utiliser le format kebab-case, ex : fr-core-patient. (/!\ sur Forge, l'id n'est pas obligatoire, il est important de le rajouter !). Lors de la création d'un IG pour un projet en particulier, il est possible de préfixer l'ensemble des ressources de conformité par le trigramme du projet (ex : "ror-...") | us-core-patient |
| title | ressources de conformité |  similaire au nom, avec espaces. Ex : Fr Core Patient | US Core Patient Profile |
| name | ressources de conformité |  Utiliser le format PascalCase sans espace. Ex : FrCorePatient | USCorePatientProfile |
| url | ressources de conformité |  [base]/[ResourceType]/[id] (généré automatiquement par sushi). A noter que [ResourceType] doit respecter le nom et la casse des ressources définies dans FHIR core (ex: StructureDefinition). | http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient |
| code  | SearchParameter|  toujours en minuscule, mots séparés par des tirets "-" si besoin | - |
| name | slice |  utiliser l'id de l'extension s'il s'agit d'une extension sinon utiliser le format lowerCamelCase | us-core-genderIdentity |
| id | package |  utiliser des minuscules | hl7.fhir.us.core [lien vers la documentation](https://confluence.hl7.org/display/FHIR/NPM+Package+Specification) |
{: .grid }

#### Règles de nommage des ressource à usage de définition

#### Règles de nommage des ressource à usage d'exemple

### Règles de nommage des fichiers

#### FHIR Shorthand (*.fsh)

Les fichiers de type `fsh` (FHIR Shorhand) devant produire après traitement de sushi une ressource FHIR doivent contenir la spécification d'une seule ressource. Par le respect de cette règle, il devient trivial de respecter les règles de nommage de l'outil IG Publisher.

TODO expliciter les règles de nommage de l'outils IG Publisher.

Par catégorie :

1. `StructureDefinition` : Profil & Extension
2. `resource.resourceType` : CodeSystem, ValueSet, ConceptMap, Instance

#### FHIR Mapping Language (*.fml)

Tous les fichiers doivent être préfixé par le `resource.resourceType` : `StructureMap`, selon 

```

StructureMap-{resource.id}.fml

```

Nom de fichier pour la transformation FHIR vers OMOP :

```

StructureMap-CoreFHIR2OMOP.fml

```
