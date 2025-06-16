### Introduction

Dans un monde de plus en plus axé sur la donnée, le **Data Management** (ou gestion des données) joue un rôle essentiel dans la valorisation, la gouvernance et l'exploitation des informations au sein des organisations. Il regroupe l'ensemble des processus, des méthodes et des technologies permettant de collecter, stocker, structurer, sécuriser et  analyser les données tout en garantissant leur qualité et leur conformité réglementaire.

Une gestion efficace des données permet aux entreprises et institutions de prendre des décisions éclairées, d'améliorer leur performance opérationnelle et d'assurer la conformité aux exigences légales (comme le RGPD).
Le **Data Management** repose sur plusieurs disciplines clés, telles que :
- **La gouvernance des données** : définition des politiques et des responsabilités pour assurer la qualité et la 
sécurité des données.
- **L'architecture et le stockage des données** : mise en place d'infrastructures adaptées (bases de données, 
data lakes, data warehouses).
- **L'interopérabilité et l'intégration** : facilitation des échanges entre différents systèmes et applications.
- **La qualité et la fiabilité des données** : contrôle et correction des erreurs pour garantir des données exploitables.
- **La sécurité et la conformité** : mise en œuvre de mécanismes de protection contre les risques de fraude, de 
cyberattaques et de non-conformité réglementaire.

Avec l'essor du **Big Data**, de l'**intelligence artificielle** et de l'**analyse prédictive**, le Data Management est devenu un levier stratégique pour l'innovation et la compétitivité. Maîtriser ces enjeux est aujourd'hui indispensable pour toute organisation souhaitant exploiter pleinement la valeur de ses données.

Ce guide d'implémentation sert de référence pour la gestion des données. Plus précisément, il accompagne la mise en place d'une couche sémantique dans le cadre de la construction du Hub de données d'un système d'information hospitalier (SIH).

L'objectif de ce Hub est de permettre à une organisation de renforcer sa gouvernance des données en instaurant une couche sémantique homogène, garantissant ainsi que l'ensemble du SIH adopte un langage commun : **FHIR**.

Des études ont démontré que le modèle d'interaction **hub-and-spoke** est le plus efficace pour optimiser les efforts d'interopérabilité des systèmes, notamment en comparaison avec le modèle **point-à-point** [1].

### Gouvernance

Le guide d'implémentation **Data Management with FHIR** est géré par le domaine Management Stratégique des Données du pôle Innovation et Données (I&D) de la Direction des Services Numériques (DSN) de l'AP-HP.

### Contexte

L'utilisation secondaire des données collectées dans le cadre des soins au sein des établissements de santé à des fins de recherche, d'études, d'évaluations ou encore de pilotage se développe rapidement en France. Cette tendance est notablement renforcée grâce à la mise en place d'entrepôts de données de santé (EDS). En harmonisant les efforts de collecte, de mise en qualité et de standardisation des données hospitalières vers un objectif commun, il devient possible de massifier la collecte de données d'intérêt et de concrétiser la consolidation d'un patrimoine national des données de santé. Cela favorise également le rapprochement de ces données de santé avec la base principale du Système National des Données de Santé.

Le groupe de travail mandaté en janvier 2023 par le comité stratégique des données de santé, constitué auprès des ministres chargés de la santé et de la recherche, propose à terme que l'ensemble des EDS hospitaliers du territoire national adopte un socle commun de 51 items. Ce socle permettra de caractériser l'ensemble des séjours et des patients, quels que soient les motifs de leur recours aux soins. Le socle est composé principalement des données les plus couramment collectées par les établissements dans le cadre des soins, notamment les données cliniques, médicamenteuses, les données socio-démographiques, ainsi que les résultats biologiques. Ces données sont généralement collectées de manière structurée et fiable au sein des systèmes d'information hospitaliers.

Dans le but d'engager efficacement les travaux d'intégration du socle au sein des EDS hospitaliers, celui-ci se divise en deux lots de données.

Le premier lot est composé d'items dont l'intégration est estimée comme prioritaire. Il s'agit de données essentiellement recueillies dans le cadre des soins, et dont la collecte au sein des systèmes d'information des hôpitaux est généralement structurée et fiable. Ce premier segment du socle comprend :

* Des données du PMSI collectées localement par les hôpitaux. Bien qu'elles soient déjà disponibles et consolidées à l'échelle nationale via la base principale du SNDS, le groupe de travail propose de capitaliser sur la collecte et les mécanismes de mise en qualité du PMSI déjà en place au sein des établissements. L'objectif est d'obtenir une caractérisation globale des patients et de leur séjour à l'hôpital au sein du socle. Le groupe de travail recommande donc l'inclusion d'un socle minimal de 9 items génériques collectés par les recueils PMSI dans les quatre "champs de soins de santé".

Initialement recueillies à des fins médico-administratives, la qualité des données du PMSI en fait désormais une source d'information largement utilisée pour la gestion des établissements, l'évaluation des parcours de soins, ainsi que pour la recherche.

Par conséquent, la collecte des données du PMSI doit être durable et indépendante du modèle de financement des hôpitaux.

* Des données socio-démographiques. Ces données complètent la caractérisation générale des patients par des données administratives qui ne sont pas collectées dans le cadre du PMSI. Parmi ces données, figurent les identifiants nationaux tels que le NIR, l'INS ou l'adresse géocodée. En tant que clés d'appariement direct, elles revêtent une importance primordiale pour rendre plus fiable et exhaustif le croisement des données cliniques collectées à l'hôpital avec d'autres bases de données nationales, notamment la base principale du SNDS, ainsi que des bases environnementales ou sociales (bases de données de la statistique publique). La mise en relation de ces données permettrait de promouvoir l'analyse des déterminants sociaux ou environnementaux de la santé, mesurés au moins à l'échelon collectif, sinon à un échelon individuel.

Actuellement, le traitement de ces données sensibles à des fins d'appariement suscite des interrogations légitimes pour les EDS conformes au référentiel sur les entrepôts de données de santé établi par la CNIL qui ne les autorise, ni ne les interdit explicitement.

* Les données de prescription et d'administration permettant de caractériser l'exposition médicamenteuse des patients. Ces données sont essentielles pour décrire les maladies et pour évaluer le rôle des médicaments comme déterminant de santé.

Ces données répondent à un besoin exprimé des utilisateurs pour améliorer la qualité des études en vie réelle en complétant les données médico-administratives de prescription et de délivrance en ville, disponibles dans la base principale du SNDS.

Disposer d'une vision globale de l'exposition médicamenteuse des patients sur l'ensemble de leur parcours de soins vise à améliorer l'évaluation des prises en charge des patients.

Le socle inclut les données relatives aux prescriptions et à l'administration des médicaments dans le milieu hospitalier quel que soit le type de traitement. A terme, le socle commun consolidera l'ensemble des informations concernant l'exposition médicamenteuse individuelle des patients à l'hôpital, ce qui constitue une évolution très favorable pour cette source d'information.

* Des résultats d'examens de biologie médicale. Élément majeur de la prise en charge des patients, contribuant au diagnostic, à apprécier la gravité ou le pronostic d'une maladie ou encore à évaluer la tolérance des produits de santé, les résultats des examens de biologie médicale ont un intérêt scientifique majeur. Les résultats de certains examens de biologie médicale réalisés à l'hôpital complètent les données relatives aux actes de dépistage et de diagnostic disponibles dans le PMSI. Étant donné la grande diversité des examens réalisables et le volume de données généré, le groupe de travail propose un socle minimal de 23 items, correspondant aux examens de routine, offrant une vision globale de l'état de santé du patient. Ces items incluent l'hémogramme, une caractérisation des fonctions rénale et hépatique et du bilan glycémique.

* Des données issues de l'examen clinique des patients. Des pratiques hétérogènes de collecte, privilégiant notamment une collecte de l'information au sein des comptes-rendus plutôt que dans les champs structurés alloués dans les logiciels métier, complique la collecte standardisée et leur utilisation secondaire. Le groupe de travail a néanmoins souhaité soutenir la collecte d'un nombre limité et prioritaire de données cliniques (taille, poids, pression artérielle) qui ne sont disponibles par ailleurs dans aucune grande base de données nationale en dehors d'enquêtes ponctuelles en population générale.

Un second lot de données comprend quatre items relatifs à des comportements à risque pour la santé, mesurés à l'échelle individuelle : consommation de tabac, consommation d'alcool, autres addictions, activité physique. Faisant partie des bonnes pratiques de soins et essentielles à la conduite d'études et d'évaluations dans le domaine de la santé, le recueil de ces données au sein des EDS reste aujourd'hui insuffisamment structuré pour une utilisation secondaire. Par ailleurs, selon la finalité de leur utilisation, les informations concernant ces comportements à risque pour la santé peuvent être collectées de différentes manières, que ce soit à l'échelon des unités médicales, des établissements de santé ou à l'échelle nationale. Cela rend l'interprétation de ces informations fortement dépendante du contexte de leur collecte. Leur collecte structurée et pérenne nécessite donc des travaux complémentaires, notamment en s'appuyant sur des définitions utilisées dans de grandes enquêtes européenne (par exemple, EHIS) ou nationale (par exemple, baromètre de Santé publique France), et en promouvant les travaux de comparaison, voire de généralisation des résultats issus des EDS hospitaliers, à la population française. Ce lot ne pourra donc pas être mis en œuvre simultanément avec la première partie du socle.

Enfin, le socle commun se compose d'informations généralement structurées à la source, mais les difficultés d'extraction de données depuis les systèmes d'information hospitaliers devront être considérées. En effet, certains éditeurs, sur la base de considérations liées aux droits de copyright et aux investissements à réaliser, choisissent de restreindre l'accès aux données, ce qui peut rendre l'extraction particulièrement complexe ou coûteuse pour les établissements, tout en limitant leur réutilisation au sein des EDS.

### Outils

Pour supporter l'approche, plusieurs outils sont facilitant notamment :

* [FHIR IG Publisher](https://github.com/HL7/fhir-ig-publisher) : le FHIR IG Publisher permet la construction des guides d'implémentation notamment il valide les ressources de conformité et produit un [rapport qualité](qa.html)
* [FHIR MapBuilder](https://github.com/aphp/fhir-mapbuilder) : le FHIR MapBuilder facilite l'édition de fichier [FHIR Mapping Language (FML)](glossary.html#fml) permettant notamment de documenter le linéage colonne entre deux définition de structure (`StructureDefinition`).
* [AP-HP FormBuilder](https://github.com/aphp/formbuilder) : le AP-HP FormBuilder est un éditeur de ressource `Questionnaire` permettant notamment de définir un recceuil d'information. Dans le contexte de l'approche, deux usages sont référencés, (i) conception d'un formulaire du (pour le) SIH, (ii) édition d'un modèle logique issue d'un modéle conceptuel pour un cas d'usage.

### Organisation du guide

Le guide d'implémentation **Data Management with FHIR** s'appuie sur l'outil [HL7 FHIR IG Publisher](https://github.com/HL7/fhir-ig-publisher) impactant le rendu. Dans la barre de navigation où se trouve les entrées de premier niveau du guide. Les entrées sont :

1. Accueil (cette page)
2. [Dictionnaire des données](data-dictionary.html) : présente la liste des variables du socle pour les EDSH
3. [Usages](use-case.html) : présente la liste des cas d'usage
4. [Gestion des données](data-management.html) : présente les éléments méthodologiques
5. [Ressources de conformité](artifacts.html) : présente les artefacts FHIR
6. [Notes de version](change_log.html)
7. Plus

### Auteurs et contributeurs

| Role               | Nom             | Organisation | Contact                 |
|--------------------|-----------------|--------------|-------------------------|
| **Primary Editor** | David Ouagne    | AP-HP        | david.ouagne@aphp.fr    |
| **Primary Editor** | Nicolas Griffon | AP-HP        | nicolas.griffon@aphp.fr |

### Dépendances

{% include dependency-table.xhtml %}

### Références

[1] Dama International. 2017. DAMA-DMBOK: Data Management Body of Knowledge (2nd Edition). Technics Publications, LLC, Denville, NJ, USA.
