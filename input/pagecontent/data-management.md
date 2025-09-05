
### Introduction

Dans un contexte de transformation numérique du secteur de la santé, les [systèmes d'information (SI)](glossary.html#si) jouent un rôle central dans la gestion et l'exploitation des données cliniques, administratives et médico-techniques. Ces systèmes, de plus en plus interconnectés, **produisent un volume considérable de données à fort potentiel de valorisation**, que ce soit pour améliorer la qualité des soins, optimiser les organisations ou soutenir la recherche. Toutefois, cette richesse informationnelle se heurte à un obstacle majeur : **l'hétérogénéité des systèmes et l'absence fréquente d'interopérabilité**.

L'[interopérabilité](glossary.html#io) des SI de santé, entendue comme la capacité des systèmes à échanger, comprendre et utiliser des données de manière cohérente, s'impose donc comme une condition indispensable à la continuité des soins et à l'exploitation secondaire des données. Pour y répondre, de nouvelles approches de conception des systèmes émergent, qui privilégient la modélisation en amont, la standardisation et l'automatisation du passage vers le code exécutable.

Dans ce cadre, l'approche [design first](glossary.html#design-first), qui consiste à centrer la conception logicielle sur les modèles avant toute implémentation, s'impose comme une bonne pratique pour structurer les échanges et faciliter leur alignement avec des standards. Elle est souvent couplée à l'[ingénierie dirigée par les modèles (IDM)](glossary.html#mde), une méthodologie qui permet de générer automatiquement des artefacts logiciels à partir de modèles formels. En santé, ces approches prennent tout leur sens dans le cadre de l'usage du standard [HL7 Fast Healthcare Interoperability Resources (FHIR)](glossary.html#fhir), conçu pour offrir un cadre normatif robuste, extensible et aligné sur les technologies modernes du web.

On se propose d'examiner ces éléments en articulant les enjeux de valorisation des données de santé avec les concepts clés que sont l'interopérabilité, l'approche design first, l'ingénierie dirigée par les modèles, et l'utilisation du standard FHIR. Il vise ainsi à fournir un socle conceptuel et technique pour penser et concevoir des systèmes d'information de santé interopérables, durables et adaptables.

#### La valorisation des données de santé

Les systèmes d'information (SI) de santé génèrent un volume considérable de données, provenant de sources hétérogènes telles que les dossiers médicaux électroniques, les systèmes de gestion hospitalière, les dispositifs médicaux connectés ou encore les applications mobiles de santé. Dans un contexte où les données deviennent un levier stratégique pour l'amélioration des soins, la recherche clinique, la gestion des établissements ou la santé publique, les organisations cherchent à valoriser ces données de manière optimale. Cette valorisation implique leur accès, leur compréhension, leur analyse et leur réutilisation dans des contextes variés. Toutefois, cette ambition se heurte souvent à des obstacles liés à l'hétérogénéité et au cloisonnement des SI.

#### Le besoin d'interopérabilité

Pour surmonter ces obstacles, l'interopérabilité entre les SI de santé devient une exigence incontournable. L'interopérabilité se décline en plusieurs dimensions — syntaxique, sémantique, technique et organisationnelle — et vise à assurer l'échange, la compréhension et l'exploitation cohérente des données entre systèmes. Cette capacité est d'autant plus cruciale dans les environnements pluriels et distribués des écosystèmes de santé, où les acteurs doivent collaborer efficacement tout en respectant des exigences réglementaires strictes (comme le RGPD en Europe).

#### L'approche **design first** pour favoriser l'interopérabilité

Dans une perspective d'ingénierie des SI de santé interopérables, une transition méthodologique s'opère vers une approche dite design first. Contrairement à l'approche **code first** — qui consiste à générer des modèles à partir du code source —, le design first privilégie la conception préalable des modèles de données, de processus et d'interfaces. Cette approche favorise une documentation claire, un alignement entre les équipes techniques et métier, et surtout une capacité à générer des artefacts cohérents en aval du cycle de développement. Elle s'inscrit dans une logique d'**interopérabilité by design** en intégrant les contraintes de standardisation dès les premières phases de la conception.

#### L'ingénierie dirigée par les modèles ou Model-Driven Engineering (MDE)

Pour opérationnaliser cette approche **design first** et automatiser la génération de code à partir des modèles, l'[ingénierie dirigée par les modèles (MDE)](glossary.html#mde) est mobilisée. Le MDE permet de formaliser la modélisation à différents niveaux d'abstraction (modèles métiers, modèles techniques, modèles d'exécution) et d'assurer leur transformation vers des artefacts opérationnels (code, configurations, schémas d'échange, etc.). En contexte de santé, cette approche est particulièrement adaptée pour maîtriser la complexité des structures de données et garantir la conformité aux standards d'interopérabilité.

#### HL7 FHIR : un standard pivot pour l'interopérabilité en santé

Parmi les standards existants, [HL7 Fast Healthcare Interoperability Resources (FHIR)](glossary.html#fhir) s'impose comme le standard de référence pour l'interopérabilité des SI de santé. Conçu selon une logique modulaire et fondé sur les technologies du web (REST, JSON, XML), FHIR propose une bibliothèque de ressources normalisées (templates) permettant notamment de modéliser les entités cliniques (patients, observations, diagnostics, prescriptions, etc.). Aussi, FHIR permet de définir des profils, des extensions et des jeux valeurs de codes, offrant ainsi des mécanismes puissants pour adapter les modéles au contexte. Au delà de la modélisation, FHIR permet de spécifiquer des alignements structurels et sémantiques notamment avec l'usage de ressources tel que `StructureMap`, `ConceptMap` et `ValueSet`. En cela, FHIR soutient une **interopérabilité by design**, en rendant possible l'intégration des principes **MDE** et **design first** dans le développement et le déploiement des SI de santé.

### Gestion des données avec FHIR

La méthodologie de gestion des données avec FHIR (Data Management with FHIR) s'appuie sur Le MDE faisant notamment de la modélisation le coeur de la stratégie de développement logiciel que nous appliquons à la donnée et notamment à la donnée de santé.

[Respect des bonnes pratiques](best-practice.html).

#### Modèle de donnée conceptuel

Un modèle conceptuel est une représentation abstraite et simplifiée de la réalité, utilisée pour organiser, structurer et formaliser des idées ou des connaissances sur un domaine donné. Il sert principalement à décrire les entités (ou objets d'intérêt), leurs propriétés (ou attributs) et les relations entre elles, sans se préoccuper des détails techniques d'implémentation.

Cette étape produit deux livrables :

1. Une représentation graphique des concepts, propriétés et relations les plus importants d'un sujet
2. Un glossaire référençant pour chaque entité représentée sa définition/description
3. Des exemples permettant de supporter les activités de validation

#### Modèle de donnée logique : Questionnaire

#### Modèle de donnée standardisé : profils + ressources sémantiques FHIR

**Le standard HL7 FHIR permet de modéliser les niveaux PIM, PSM et aussi les transformations par l'usage du [FHIR Mapping Language (FML)](glossary.html#fml)**.

Les ressources FHIR de type `StructureDefinition` permettent soit de définir des structures logiques traduisant le contenu d'une représentation conceptuelle, soit de contraindre une ressource pour un cas d'usage (dans ce cas le résultat est de type PIM) ou encore soit de définir des structures logiques pour représenter des schémas de base de donnée (dans ce cas le résultat est de type PSM).

#### Modéle de donnée propriétaire : `StructureDefinition` de type logique


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

