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

Ce guide d’implémentation constitue le support à la gestion des données. Plus spécifiquement, il est dédié à la mise en 
œuvre d'une couche sémantique dans le cadre de la construction du Hub de données d’un système d’information hospitalier (SIH). 
L’objectif de ce Hub est de permettre à une organisation de déployer efficacement sa gouvernance des données 
par la mise en œuvre d'une couche sémantique afin que l'ensemble du SIH utilise le même langage : **FHIR**.

Il a été démontré que le modèle **hub-and-spoke** est le plus efficace pour optimiser les efforts d’interopérabilité 
des systèmes.

[//]: # ("Il a été démontré que le modèle **hub-and-spoke** est le plus efficace" <== ça mériterait une référence)

### Gouvernance

Le guide d'implémentation AP-HP Data Management est géré par le Domaine Management Stratégique des Données au sein de 
la Direction des Services Numériques (DSN) de l'AP-HP.

### Auteurs et contributeurs

| Role               | Nom             | Organisation | Contact                 |
|--------------------|-----------------|--------------|-------------------------|
| **Primary Editor** | David Ouagne    | AP-HP        | david.ouagne@aphp.fr    |
| **Primary Editor** | Nicolas Griffon | AP-HP        | nicolas.griffon@aphp.fr |

### Dépendances

{% include dependency-table.xhtml %}
