# AP-HP - DM : Data Management with FHIR

Le **AP-HP - DM** (acronyme pour Data Management) est une initiative visant à rassembler l'ensemble des connaissances 
sur la couche sémantique du Hub de donnée de santé.

Ce référentiel contient le **AP-HP - DM Implementation Guide (IG)**. Un IG est "un ensemble de règles sur comment les
ressources FHIR sont utilisées (ou devraient être utilisées) pour résoudre un problème particulier, avec la
documentation associée pour supporter et clarifier les usages" ([source](https://www.hl7.org/fhir/implementationguide.html)).

Pour plus d'information :

- Si vous êtes nouveau dans la communauté et l'écosystème FHIR, [ce tutoriel explique FHIR, le profilage, et les guides d'implementation](https://fire.ly/blog/how-to-create-your-first-fhir-profile/)

## Contexte

### Contexte métier du projet

[A COMPLETER : doit contenir la description fonctionnelle du projet destinée à un profil non technique]

### Contexte technique du projet

Ce guide d'implémentation présente la couche sémantique d'un Hub de donnée de santé.

[A COMPLETER : doit expliquer brièvement quelles ressources / profils sont utilisés, exemple implémentation où IG est utilisé]

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

## Validation des alignements de structures (StructureMap)

TODO MapBuilder

### Prérequis

Prérequis : installation d'un client REST, par exemple [RESTClient (identifiant: humao.rest-client)](https://marketplace.visualstudio.com/items?itemName=humao.rest-client#:~:text=Once%20you%20prepared%20a%20request,press%20F1%20and%20then%20select%2F)

### Fichier /input/test-map/test_fml.http.example

Ce fichier contient la documentation et les commandes permettant de tester les maps

Il convient de ne pas le modifier, mais d'en faire une copy dans le dossier /input/test-map/local/

Pour lancer une commande, ouvrir ce fichier et cliquer sur le lien `Send Request` au niveau de la commande correspondante (Attention aux paramètres de la requête) : 

![lancer une requête](input/images/RESTQuery.png)

### Convention d'utilisation 

Le paramétrage du fichier test_fml.http fait en local pour ses besoins propres n'a pas vocation à être poussé sur le repo distant. 

Les ressources de test et les structuremap le doivent, respectivement dans les dossiers /input/test-map/ et /input/fml/ d'usage correspondant. 

Si les ressources sont partagées, les conventions usuelles de classement et de nommage s'appliquent pour les structuremap, les conventions de l'IG s'appliquent. 
