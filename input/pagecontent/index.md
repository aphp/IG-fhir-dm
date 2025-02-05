### Introduction

Dans un monde de plus en plus axé sur la donnée, le **Data Management** (ou gestion des données) joue un rôle essentiel 
dans la valorisation, la gouvernance et l’exploitation des informations au sein des organisations. Il regroupe 
l’ensemble des processus, des méthodes et des technologies permettant de collecter, stocker, structurer, sécuriser et 
analyser les données tout en garantissant leur qualité et leur conformité réglementaire.

Une gestion efficace des données permet aux entreprises et institutions de prendre des décisions éclairées, d’améliorer 
leur performance opérationnelle et d’assurer la conformité aux exigences légales (comme le RGPD). 
Le **Data Management** repose sur plusieurs disciplines clés, telles que :
- **La gouvernance des données** : définition des politiques et des responsabilités pour assurer la qualité et la 
sécurité des données.
- **L’architecture et le stockage des données** : mise en place d’infrastructures adaptées (bases de données, 
data lakes, data warehouses).
- **L’interopérabilité et l’intégration** : facilitation des échanges entre différents systèmes et applications.
- **La qualité et la fiabilité des données** : contrôle et correction des erreurs pour garantir des données exploitables.
- **La sécurité et la conformité** : mise en œuvre de mécanismes de protection contre les risques de fraude, de 
cyberattaques et de non-conformité réglementaire.

Avec l’essor du **Big Data**, de l’**intelligence artificielle** et de l’**analyse prédictive**, le Data Management est 
devenu un levier stratégique pour l’innovation et la compétitivité. Maîtriser ces enjeux est aujourd’hui indispensable 
pour toute organisation souhaitant exploiter pleinement la valeur de ses données.

Ce guide d’implémentation sert de référence pour la gestion des données. Plus précisément, il accompagne la mise en place 
d’une couche sémantique dans le cadre de la construction du Hub de données d’un système d’information hospitalier (SIH).

L’objectif de ce Hub est de permettre à une organisation de renforcer sa gouvernance des données en instaurant une couche 
sémantique homogène, garantissant ainsi que l’ensemble du SIH adopte un langage commun : **FHIR**.

Des études ont démontré que le modèle d’interaction **hub-and-spoke** est le plus efficace pour optimiser les efforts 
d’interopérabilité des systèmes, notamment en comparaison avec le modèle **point-à-point** [1].

### Gouvernance

Le guide d'implémentation AP-HP Data Management est géré par le Domaine Management Stratégique des Données au sein de 
la Direction des Services Numériques (DSN) de l'AP-HP. Ce guide est le support de la stratégie de le DSN en matière de gestion des données.

### Auteurs et contributeurs

| Role               | Nom             | Organisation | Contact                 |
|--------------------|-----------------|--------------|-------------------------|
| **Primary Editor** | David Ouagne    | AP-HP        | david.ouagne@aphp.fr    |
| **Primary Editor** | Nicolas Griffon | AP-HP        | nicolas.griffon@aphp.fr |

### Dépendances

{% include dependency-table.xhtml %}

### Références

[1] Dama International. 2017. DAMA-DMBOK: Data Management Body of Knowledge (2nd Edition). Technics Publications, LLC, Denville, NJ, USA.
