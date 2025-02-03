# AP-HP - DM : Data Management with FHIR

Le **AP-HP - DM** (acronyme pour Data Management) est une initiative visant à rassembler l'ensemble des connaissances 
sur la couche sémantique du Hub de donnée de santé.

Ce référentiel contient le **AP-HP - DM Implementation Guide (IG)**. Un IG est "un ensemble de règles sur comment les
ressources FHIR sont utilisées (ou devraient être utilisées) pour résoudre un problème particulier, avec la
documentation associée pour supporter et clarifier les usages" ([source](https://www.hl7.org/fhir/implementationguide.html)).

Pour plus d'information :

- Si vous êtes nouveau dans la communauté et l'écosystème FHIR, [ce tutoriel explique FHIR, le profilage, et les guides d'implementation](https://fire.ly/blog/how-to-create-your-first-fhir-profile/)

## Contexte

Ce guide d'implémentation présente une méthodlogie visant la construction d'une couche sémantique pour un Hub de donnée de santé en utilisant comme langage commun : ***FHIR**.

## Construction de l'IG

"Construction de l'IG" signifie générer une représentation web, lisible par un humain, des informations structurées et
de la documentation d'accompagnement définies dans ce référentiel. Cela se fait via le [FHIR Implementation Guide Publisher](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation)
("IG Publisher"), un programme Java fourni par l'équipe FHIR pour la construction de guides d'implementation dans une
présentation standardisée.

Si vous souhaitez le générer localement, ouvrez une fenêtre de commande et naviguer où le référentiel a été cloné.
Exécutez ensuite cette commande :

- Linux/macOS: `./gradlew buildIG`
- Windows: `.\gradlew.bat buildIG`

Ce script fera automatiquement deux choses pour vous :

1. Exécuter [SUSHI](https://fshschool.org/docs/sushi/). L'IG AP-HP - EDS est développé en [FHIR Shorthand (FSH)](http://build.fhir.org/ig/HL7/fhir-shorthand/),
   un langage spécifique de domaine (DSL) permettant de définir le contenu des FHIR IG. SUSHI transpile les fichiers FSH en
   fichiers JSON attendus par IG Publisher
2. Exécuter IG Publisher

Vous aurez besoin d'une connexion Internet active pour construire l'IG. Cela prend jusqu'à 30 minutes pour construire
pour la première fois ; les versions suivantes devraient être plus rapides (5 à 7 minutes) sur un ordinateur portable
moderne.

Lorsque la construction est terminée, vous pouvez ouvrir `output/index.html` dans votre navigateur pour voir l'IG
construit localement.

### Dépendances pour la construction de l'IG

1. Vous avez besoin d'[installer java](https://adoptium.net/)
2. Vous avez besoin d'[installer jekyll](https://jekyllrb.com/docs/installation/)

### Exécution de SUSHI indépendamment de l'IG Publisher

Si vous souhaitez exécuter SUSHI sans créer l'intégralité de l'IG, vous pouvez exécuter la tâche gradle `runSushi`.

### Obtenir une version propre

Bien que cela ne soit normalement pas nécessaire, vous pouvez supprimer les dossiers suivants pour obtenir une version
propre :

- `fsh-generated/` (sortie SUSHI - contient notamment les fichiers json généré à partir des fichier en FSH)
- `output/` (sortie IG Publisher - contient notamment le site web construit par 'buildIG')
- `input-cache/` (cache local de l'IG Publisher ; notez que sa suppression augmentera considérablement le temps de
  génération de la prochaine version)

## Répertoires et fichiers clés dans l'IG

- Les fichiers FHIR Shorthand (`.fsh`) définissant les ressources dans cet IG se trouvent dans `input/fsh/`.
    - Il existe une [extension de coloration syntaxique FSH](https://marketplace.visualstudio.com/items?itemName=MITRE-Health.vscode-language-fsh)
      pour [VSCode](https://code.visualstudio.com).
      Les fichiers FSH sont préfixés en fonction de ce qu'ils contiennent.
- Les pages principales de l'IG construit sont générées à partir de [Markdown](https://daringfireball.net/projects/markdown/)
  trouvé dans `input/pagecontent/`. Ces pages doivent également être incluses dans `sushi-config.yaml` pour être compilées
  en HTML par l'IG Publisher.
- Il existe un certain nombre d'autres options de configuration importantes dans `sushi-config.yaml`, y compris le
  contenu du menu de l'IG construit.
- La source des diagrammes UML dans l'IG se trouve dans `input/images-source/` et DOIT avoir une extension `.plantuml`.
  Ceux-ci sont automatiquement convertis en SVG par l'éditeur IG et insérés en ligne dans les fichiers Markdown à l'aide
  de `{%include some-diagram.svg%}` (qui correspond à `input/images-source/some-diagram.plantuml`).

## Acronymes

* IG : Implementation Guide
* FHIR : Fast Healthcare Interoperability Resources
* FIG : FHIR Implementation Guide
* HL7 : Health Level Seven
* AP-HP : Assistance Publique - Hôpitaux de Paris
* EDS : Entrepôt de Données de Santé

## Dépendances du guide d'implémentation

Vous trouverez la liste des dépendances dans `sushi-config.yaml` dans la section `dependencies` du fichier.

## Recueil des besoins

TODO FormBuilder

## Conception de formulaire

TODO FormBuilder

## Execution des ressources StructureMap

Les ressources StructureMap écrites à l'aide du FML peuvent être exécutées afin de vérifier que les attendus du processus de transformation soient conforme aux spécifications.

### Mise en oeuvre de l'environnement d'execution des fichiers FML

### Prérequis

#### Mise en oeuvre du moteur d'execution du FML

Il existe de nombreuses solutions permettant l'execution d'un fichier FML. Nous nous proposons de décrire l'installation et l'utilisation de la solution [Matchbox](https://github.com/ahdis/matchbox).

Par la suite, nous considerons que les notions relatives à l'utilisation de l'outil `git` sont connues du lecteur. La première étape que nous recommandons est de créer un fork du projet [Matchbox](https://github.com/ahdis/matchbox) et de se positionner sur le commit de la dernière release. La gestion des dépendances de ce projet est réalisée par maven, nous précisons cela car ce projet est multimodule et va nécéssiter de modifier deux sous-modules. Comme précisé précédement ce projet est composé de trois sous-module :

1. matchbox-engine
2. matchbox-frontend
3. matchbox-server

Dans le sous-module matchbox-engine, nous devons ajouter dans le répertoire `src/main/resources` les packages de ce guide d'implémentation et de toutes ses dépendances, y compris le packages du standard FHIR.

Puis dans le sous-module matchbox-server, nous devons ajouter ces packages dans le fichier `src/main/resources/application.yml` à la section `hapi.fhir.implementationguides`. Aussi dans la section `matchbox.fhir.context.onlyOneEngine` fixer à `true`.

Une fois ces deux étapes de spécialisation au contexte du contenu de ce guide d'implémentation, nous devons constuire le projet, puis l'image Docker et enfin créer le conteneur. Comme pour l'utilisation de l'outil git, nous considérons que le lecteur est au fait de l'installation et de l'utilisation de `maven` et de `docker`.

La construction du projet peut se faire à l'aide de maven et plus précisement à l'aide de la commande suivante : `mvn clean package -DskipTests`. Une fois cette étape réalisée, nous devons lancer la création de l'image Docker. Dans le sous-module matchbox-server, lancer la commande : `docker build -t matchbox .` pour construire l'image. Enfin toujours dans le sous-module matchbox-server, se positionner dans le répertoire with-postgres pour lancer la commande `docker-compose up -d` pour créer et executer l'image précédement construite associée à une base de donnée PostgreSQL.

#### Ajout de l'extension RESTClient

Prérequis : installation d'un client REST, par exemple [RESTClient (identifiant: humao.rest-client)](https://marketplace.visualstudio.com/items?itemName=humao.rest-client#:~:text=Once%20you%20prepared%20a%20request,press%20F1%20and%20then%20select%2F)

##### Fichier /input/test-map/test_fml.http.example

Ce fichier contient la documentation et les commandes permettant de tester les maps

Il convient de ne pas le modifier, mais d'en faire une copy dans le dossier /input/test-map/local/

Pour lancer une commande, ouvrir ce fichier et cliquer sur le lien `Send Request` au niveau de la commande correspondante (Attention aux paramètres de la requête) : 

![lancer une requête](input/images/RESTQuery.png)

##### Convention d'utilisation 

Le paramétrage du fichier test_fml.http fait en local pour ses besoins propres n'a pas vocation à être poussé sur le repo distant. 

Les ressources de test et les structuremap le doivent, respectivement dans les dossiers /input/test-map/ et /input/fml/ d'usage correspondant. 

Si les ressources sont partagées, les conventions usuelles de classement et de nommage s'appliquent pour les structuremap, les conventions de l'IG s'appliquent. 


### Validation des alignements de structures 

TODO MapBuilder
