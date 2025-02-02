# AP-HP - EDS : Entrepôt de Données de Santé

[![pipeline status](https://gitlab.data.aphp.fr/ID/ed/dm/ig/fig-eds/badges/main/pipeline.svg)](https://gitlab.data.aphp.fr/ID/ed/dm/ig/fig-eds/-/commits/main)
[![Latest Release](https://gitlab.data.aphp.fr/ID/ed/dm/ig/fig-eds/-/badges/release.svg)](https://gitlab.data.aphp.fr/ID/ed/dm/ig/fig-eds/-/releases)

Le **AP-HP - EDS** (acronyme pour Entrepôt de Données de Santé de l'AP-HP) est une initiative visant à rassembler
l'ensemble des connaissances sur les services FHIR de l'EDS de l'AP-HP dans un espace commun afin de partager.

Ce référentiel contient le **AP-HP - EDS Implementation Guide (IG)**. Un IG est "un ensemble de règles sur comment les
ressources FHIR sont utilisées (ou devraient être utilisées) pour résoudre un problème particulier, avec la
documentation associée pour supporter et clarifier les usages" ([source](https://www.hl7.org/fhir/implementationguide.html)).

L'adresse de publication CI est : https://id.pages.data.aphp.fr/ed/dm/ig/fig-eds

Pour plus d'information :

- Si vous êtes nouveau dans la communauté et l'écosystème FHIR, [ce tutoriel explique FHIR, le profilage, et les guides d'implementation](https://fire.ly/blog/how-to-create-your-first-fhir-profile/)

## Contexte

### Contexte métier du projet

[A COMPLETER : doit contenir la description fonctionnelle du projet destinée à un profil non technique]

### Contexte technique du projet

Ce guide d'implémentation présente les spécifications techniques du serveur FHIR de l'EDS de l'AP-HP.

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

| Prefix | Description          |
|--------|----------------------|
| 'AL'   | Aliases              |
| 'DEF'  | Autres définitions   |
| 'EX'   | Exemples             |
| 'SD'   | StructureDefinitions |

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

## CI/CD

Pour la CI, il a été mis en place un environnement de build qui contient toutes les dépendances nécessaires pour lancer les étapes du build local.
Cet environnement est décrit dans un [Dockerfile](https://gitlab.eds.aphp.fr/ID/pfm/portails-et-apis/dev/devops-images/-/blob/main/fhir-ig-builder/Dockerfile?ref_type=heads) et est publié sur l'espace harbor de cohort 360.
-> Il faudrait le publier sur l'espace publique.

La ci (configurée par le fichier `.gitlab-ci.yml`) défini la réalisation des étapes du build local en deux temps pour produire l'IG sous forme de gitlab pages et d'artifact stocké dans gitlab.

La résolution des dépendances (avant la phase de build "sushi") entre IGs internes et réalisée en récupérant l'artifact de build (le `output/package.tar.gz` des projets des autres IGs) via l'API gitlab. Pour cela il est nécessaire de récupérer le projet ID gitlab et d'autoriser les projets dépendants (https://docs.gitlab.com/ee/ci/jobs/ci_job_token.html#add-a-project-to-the-job-token-scope-allowlist)
-> Il n'y a pour le moment aucune gestion de version / branches, le script récupere le dernier build de la branche main
-> Ce n'est pas automatisé vis à vis des dépendances décrites dans `sushi-config.yaml`, cette résolution de dépendance est manuellement ajoutée dans le process de build.

## validation des structures map

From https://github.com/ahdis/matchbox/blob/main/matchbox-server/fml.http

### Prérequis

Prérequis: Installation d'un client REST, par exemple [RESTClient (identifiant: humao.rest-client)](https://marketplace.visualstudio.com/items?itemName=humao.rest-client#:~:text=Once%20you%20prepared%20a%20request,press%20F1%20and%20then%20select%2F)

### Fichier /input/test-map/test_fml.http.example

Ce fichier contient la documentation et les commandes permettant de tester les maps

Il convient de ne pas le modifier mais d'en faire une copy dans le dossier /input/test-map/local/

Pour lancer une commande, ouvrir ce fichier et cliquer sur le lien `Send Request` au niveau de la commande correspondante (Attention aux paramètres de la requête) : 

![lancer une requête](input/images/RESTQuery.png)

### Convention d'utilisation 

Le paramétrage du fichier test_fml.http fait en local pour ses besoins propres n'a pas vocation a être poussé sur le repo distant. 

Les ressources de test et les structuremap le doivent, respectivement dans les dossier /input/test-map/ et /input/fml/ d'usage correspondant. 

Si les ressources sont partagées, les conventions usuelles de classement et de nommage s'appliquePour les structuremap, les conventions de l'IG s'appliquent. 

## Dépannage

### Structure Definition is Missing Snapshot Error

Some non-HL7 FHIR packages are distributed without snapshot elements in their profiles. If your IG uses one of these profiles, SUSHI will report an error like the following:
Certains packages FHIR non HL7 sont distribués sans snapshot dans leurs profils. Si votre IG utilise l'un de ces profils, SUSHI signalera une erreur comme la suivante :

Structure Definition http://interopsante.org/fhir/StructureDefinition/FrPatient is missing snapshot. Snapshot is required for import.

Since SUSHI does not implement its own snapshot generator, you must update the package in your FHIR cache so that its profiles include snapshot elements. Fortunately, the [Firely Terminal](https://fire.ly/products/firely-terminal/) provides a way to do this.
Étant donné que SUSHI n'implémente pas son propre générateur de snapshot, vous devez mettre à jour le package dans votre cache FHIR afin que ses profils incluent les snapshots. Heureusement, le [Firely Terminal](https://fire.ly/products/firely-terminal/) fournit un moyen de le faire.

Tout d'abord, vous devez installer [Firely Terminal](https://docs.fire.ly/projects/Firely-Terminal/getting_started/InstallingFirelyTerminal.html). Utilisez ensuite Firely Terminal pour remplir les éléments du snapshot dans le package des dépendances.

1. Lancer la commande : fhir install <package> (<version>), remplacer <package> par l'ID du package dépendant.
   Par exemple, fhir install hl7.fhir.fr.core 1.1.0
2. Lancer sushi une nouvelle fois. L'erreur à propos des snapshot manquant ne devrait plus être affiché.

