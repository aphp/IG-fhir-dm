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

1. Vous avez besoin d'[installer java](https://adoptium.net/) 21
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

## Validation des StructureMap

Dans les FIG de l'AP-HP, les StructureMap sont rédigées en fml, disponibles dans le dossier input/fml. 

La validation de ces fml recouvre : 
- la transformation en ressource StructureMap
- la validation de la conformité de la ressource StructureMap
- l'éxecution de l'opération $transform appliquant la ressource StructureMap à une source, et l'obtention d'une target 
- La validation de la conformité de la target au profil correspondant. 

Plusieurs options permettent de couvrir ces niveaux de validation : 
- Le [plugin VSCode "FHIR MapBuilder"](https://github.com/aphp/fhir-mapbuilder)couvre les trois premiers niveaux de validation (sous réserve de disposer d'une source testable)et facilite la rédaction des maps grace à ses fonctions de coloration syntaxique et d'aide au codage. 
- La [construction de l'IG](#construction-de-lig) va générer la ressource StructureMap et valider la conformité des ressources (la StructureMap, et, si disponibles, les ressources sources et target). 
- L'utilisation de la solution [Matchbox](https://github.com/ahdis/matchbox), plus compliquée. 