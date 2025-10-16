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

Le guide d'implémentation **Data Management with FHIR** est géré par le domaine Management Stratégique des Données de la Direction des Services Numériques (DSN) de l'AP-HP.

### Outils

Pour supporter l'approche, plusieurs outils sont facilitant notamment :

* [FHIR IG Publisher](https://github.com/HL7/fhir-ig-publisher) : le FHIR IG Publisher permet la construction des guides d'implémentation notamment il valide les ressources de conformité et produit un [rapport qualité](qa.html)
* [FHIR MapBuilder](https://github.com/aphp/fhir-mapbuilder) : le FHIR MapBuilder facilite l'édition de fichier [FHIR Mapping Language (FML)](glossary.html#fml) permettant notamment de documenter le linéage colonne entre deux définition de structure (`StructureDefinition`).
* [AP-HP FormBuilder](https://github.com/aphp/formbuilder) : le AP-HP FormBuilder est un éditeur de ressource `Questionnaire` permettant notamment de définir un recceuil d'information. Dans le contexte de l'approche, deux usages sont référencés, (i) conception d'un formulaire du (pour le) SIH, (ii) édition d'un modèle logique issue d'un modèle conceptuel pour un cas d'usage.

### Organisation du guide

Le guide d'implémentation **Data Management with FHIR** s'appuie sur l'outil [HL7 FHIR IG Publisher](https://github.com/HL7/fhir-ig-publisher) impactant le rendu. Dans la barre de navigation où se trouve les entrées de premier niveau du guide. Les entrées sont :

1. Accueil (cette page)
2. [Variables socles pour les EDSH](use-core-variables.html) : présente notamment la standardisation des données au format **FHIR**
3. [Health Data Platform (démo)](data-platform.html) : présente les éléments opérationnels
4. [Ressources de conformité](artifacts.html) : présente tous les artefacts FHIR
5. [Notes de version](changelog.html)
6. Plus

### Auteurs et contributeurs

| Rôle | Nom | Organisation | Contact |
|------|-----|--------------|---------|
| **Primary Editor** | Christel Gérardin | Assistance Publique - Hôpitaux de Paris | christel.gerardin@aphp.fr |
| **Primary Editor** | David Ouagne | Assistance Publique - Hôpitaux de Paris | david.ouagne@aphp.fr |
| **Primary Editor** | Nicolas Griffon | Assistance Publique - Hôpitaux de Paris | nicolas.griffon@aphp.fr |
{: .grid}

### Dépendances

{% include dependency-table.xhtml %}

### Références

[1] Dama International. 2017. DAMA-DMBOK: Data Management Body of Knowledge (2nd Edition). Technics Publications, LLC, Denville, NJ, USA.
