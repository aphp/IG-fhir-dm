

<a name="fhir-conceptmap" />**ConceptMap** : une ressource `ConceptMap` est un patron de conception standard **FHIR**. Il permet de formaliser des alignements entre deux `ValueSet` afin de supporter la tâche de traduction notamment dans le cadre d'un échange de donnée impliquant une normalisation des codes.

<a name="design-first" />**Design First** : approche de développement logiciel dans laquelle la conception des modèles (données, processus, interfaces) est réalisée en amont du développement. Elle s'oppose à l'approche code first, où les modèles sont dérivés du code existant. Le design first favorise la clarté, la standardisation, la communication entre métiers et techniques, et s'inscrit dans une logique d'interopérabilité by design.

<a name="dsl" />**Domain Specific Language** : un Domain-Specific Language (DSL) est un langage de programmation ou de modélisation conçu spécifiquement pour un domaine d'application particulier. Contrairement aux langages généralistes (comme Python ou Java), un DSL vise à exprimer de façon simple, lisible et efficace des concepts propres à un métier ou un usage donné.

<a name="fhir" />**Fast Healthcare Interoperability Resources (FHIR)** : standard d'interopérabilité développé par HL7, conçu pour faciliter l'échange de données cliniques à l'ère du web. FHIR propose :

* des ressources normalisées (Patient, Observation, Encounter, etc.),
* des profils pour spécialiser les ressources à un contexte donné,
* des mécanismes d'alignement structurel et sémantique (StructureMap et ConceptMap),
* un usage natif des technologies web (REST, JSON, XML),

permettant une interopérabilité structurée, extensible et moderne, adaptée aussi bien aux besoins des systèmes hospitaliers qu'à ceux des applications mobiles ou des projets de recherche.

<a name="fml" />**FHIR Mapping Language** : le FHIR Mapping Language (FML) est un langage de transformation développée par HL7. Il permet de décrire les règles de transformation de données entre différents modèles d'information de santé, notamment entre des structures FHIR et des formats non-FHIR (comme HL7 v2, CDA, ou des systèmes propriétaires).

<a name="hds" />**Hub de Données de Santé** : un Hub de Données de Santé est un dépôt central de données standardisées provenant de sources multiples au sein d'un SIH.

<a name="io" />**Interopérabilité** : Capacité de différents systèmes d'information à échanger, comprendre et exploiter des données de manière cohérente. Elle peut être :

* technique (échange de données au niveau des formats et protocoles),
* syntaxique/sémantique (structure des données/signification des données),
* organisationnelle (alignement des usages et processus).

En santé, l'interopérabilité est essentielle pour assurer la continuité des soins et la réutilisation des données à des fins de soins, de pilotage ou de recherche.

<a name="cdm" />**Modèle de donnée conceptuel** : l'objectif d'un modèle de donnée conceptuel (MDC) est de saisir la vision d'ensemble sur un périmètre précis : quels sont les concepts fondamentaux d'un domaine, d'un périmètre fonctionnel ou d'un processus métier et comment sont-ils liés entre eux ? Le modélisateur doit d'écouter "le métier" — les experts du domaine et les personnes sur le terrain qui comprennent comment les choses fonctionnent. Le modélisateur va apprendre leur "langage métier" et identifier les concepts clés nécessaires pour modéliser un domaine, un périmètre fonctionnel ou un processus métier. La priorité est la clarté, la structure et la compréhension partagée, au niveau le plus abstrait. En termes génériques, il s'agit d'identifier des entités et la manière dont elles sont liées entre elles. Le MDC est un outil de communication. Une analogie possible est celle d'un "plan de ville".

<a name="mde" />**Ingénierie Dirigée par les Modèles (IDM) / Model-Driven Engineering (MDE)** : méthodologie d'ingénierie logicielle qui repose sur l'utilisation systématique de modèles formels à différents niveaux d'abstraction pour concevoir, transformer et générer automatiquement des éléments du système (code source, documentation, configuration, etc.). Le MDE est particulièrement utile pour garantir la traçabilité, la réutilisabilité et la conformité aux standards, notamment dans les systèmes complexes comme ceux de la santé.

<a name="si" />**Système d'Information** : un Système d'Information (SI) est un ensemble organisé de ressources humaines, matérielles, logicielles, de données et de procédures qui permet de collecter, stocker, traiter et diffuser l'information au sein d'une organisation, en vue de soutenir ses activités, sa prise de décision et sa stratégie.

<a name="sih" />**Système d'Information Hospitalier** : un Système d'Information Hospitalier (SIH) est l'ensemble organisé des ressources (logiciels, bases de données, équipements, procédures, etc.) qui permet de gérer l'ensemble des flux d'informations au sein d'un établissement de santé. Il vise à soutenir l'activité médicale, soignante, administrative et logistique de l'hôpital en assurant la circulation, le stockage, la sécurité et la traçabilité des données.

{% include markdown-link-references.md %}