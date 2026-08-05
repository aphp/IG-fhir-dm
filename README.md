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

## Plateforme de Données (Data Platform)

Le répertoire [data-platform/](data-platform/) contient l'infrastructure et les outils pour gérer les données de santé à travers différentes couches :

### Couche Raw Layer
La [couche de données brutes](data-platform/raw-layer/) fournit :
- Infrastructure PostgreSQL conteneurisée avec support français optimisé
- Schéma de base de données EHR (Electronic Health Records)
- [Loader Python](data-platform/raw-layer/test/loader/) pour le chargement des données de test
- Données de test avec 10 patients et support complet des caractères français

**Démarrage rapide :**
```bash
cd data-platform/raw-layer/ehr-docker
docker-compose up -d
cd ../test/loader
python load_test_patients.py --database ehr --user ehr_user --clear
```

Voir la [documentation complète de la raw layer](data-platform/raw-layer/README.md) pour plus d'informations.

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


## Pipeline FHIR R4 → OMOP CDM v5.4 avec Pathling

Documentation d'installation et d'utilisation de **Pathling** dans le cadre du projet de conversion des données FHIR de l'**IG EDSH socle commun** (AP-HP — 51 variables socle, 10 cas d'usage) vers le modèle **OMOP CDM v5.4**.

APHP — Direction des Services Numériques (Domaine MSD/DSN)

> Les commandes et endpoints de ce document suivent la documentation officielle du serveur Pathling (<https://pathling.csiro.au/docs/server>).

> **Comment lire ce document.** Les sections 1 à 3 et 8 à 13 décrivent le pipeline, les résultats et les limites en langage courant, sans code. Les sections 4 à 7 décrivent la mise en œuvre technique (installation, import, exécution des vues) ; un seul exemple concret de règle de transformation (ViewDefinition) est montré en §7 pour illustrer le principe. Un lecteur non technique peut passer directement de §3 à §8 sans perdre le fil.



#### Présentation

[Pathling](https://pathling.csiro.au/) est un serveur FHIR d'analyse, construit sur Apache Spark, qui implémente le standard **SQL-on-FHIR v2**. Il permet de :

- importer des ressources FHIR au format **NDJSON**, déposées sur un stockage objet **MinIO**,
- projeter ces ressources en tables relationnelles via des **ViewDefinitions** (des règles de transformation écrites en **FHIRPath**, un langage qui indique où trouver chaque information dans une ressource FHIR),
- exporter le résultat en **CSV, NDJSON ou Parquet**.

Chaque opération Pathling (import, ViewDefinition, export) porte toujours sur **un seul type de ressource FHIR à la fois** — impossible de croiser deux ressources (par exemple `Patient` et `Condition`) en une seule opération ; cette limite est détaillée en §8.

Dans ce projet, Pathling est utilisé pour transformer les ressources `Patient`, `Encounter`, `Condition`, `Observation`, `Procedure`, `MedicationRequest` et `MedicationAdministration` (profils APHP) en tables OMOP (`person`, `visit_occurrence`, `condition_occurrence`, `measurement`, `procedure_occurrence`, `drug_exposure`, `death`, `location`, `observation`). Les règles de transformation projettent directement les ressources FHIR vers le schéma OMOP : les colonnes de sortie portent déjà les noms des champs OMOP cibles (`person_id`, `gender_concept_id`, etc.), et les codes OMOP connus (`concept_id`) sont calculés directement pendant la transformation.

Objectif du projet : mesurer les écarts structurels et sémantiques entre FHIR et OMOP, identifier les contraintes techniques de la transformation, et déterminer les conditions d'industrialisation du mapping pour l'usage secondaire des données de santé.



#### Architecture du pipeline

```
Ressources FHIR conformes (Patient, Encounter, Condition, Observation, Procedure, MedicationRequest/Administration)
        │  conversion JSON → NDJSON
        ▼
Dépôt sur MinIO (stockage objet S3)
        │
        ▼
Import Pathling  →  Règles de transformation OMOP (ViewDefinitions)  →  Export CSV / NDJSON / Parquet
        │
        ▼
Tables OMOP CDM v5.4
        │
        ▼
WhiteRabbit (profilage)  →  Rabbit-in-a-Hat (documentation visuelle du mapping)
        │
        ▼
SQL post-export (UNION ALL measurement, jointure death)
        │
        ▼
Mapping Athena (concept_id restants : SNOMED, LOINC, RxNorm)
```

Les ViewDefinitions produisent directement les tables OMOP ; WhiteRabbit et Rabbit-in-a-Hat n'interviennent pas pour transformer les données mais pour documenter et vérifier a posteriori le mapping réalisé (profilage des CSV exportés, correspondances champ par champ).



#### Prérequis

Les outils suivants sont nécessaires pour faire tourner le pipeline (serveur Pathling, stockage MinIO, scripts de préparation des données). Docker et MinIO sont les seuls éléments réellement indispensables : Pathling ne peut pas fonctionner sans un endpoint S3 à interroger, et MinIO joue ce rôle localement. Java n'est nécessaire que si Pathling est utilisé comme librairie Scala/Java plutôt que comme serveur conteneurisé, ce qui n'est pas le cas dans ce projet.

| Outil | Rôle | Requis |
|---|---|---|
| Docker + Docker Compose | Déploiement conteneurisé de Pathling et MinIO | ✅ |
| MinIO | Stockage objet (S3) des fichiers NDJSON, source d'ingestion pour Pathling | ✅ |
| Python 3.x | Préparation/correction des fichiers NDJSON, conversion JSON → NDJSON | ✅ |
| curl ou Postman | Appels à l'API REST FHIR et à l'API Pathling | recommandé |
| Java 21 | Uniquement pour usage de la librairie Pathling hors Docker | optionnel |
{: .grid}

> **Contrainte réseau APHP** : le proxy réseau APHP peut bloquer le téléchargement direct de certaines dépendances (ex. packages FHIR Implementation Guide `aphp.fhir.fr.edsh`) ou d'images Docker externes. Prévoir un build local des dépendances mises en cache dans `~/.fhir/packages/`, ou un mirroir interne / import d'image `.tar` pré-téléchargée si nécessaire.



#### Installation de Pathling

Configuration utilisée dans le projet : Pathling importe directement depuis un bucket MinIO (protocole S3A), sans montage de dossier local. Deux services Docker sont déployés ensemble : `pathling` (le serveur d'analyse, accessible sur le port 8080) et `minio` (le stockage objet, accessible sur les ports 9000/9001). Pathling est configuré pour n'accepter que les imports provenant du bucket `data-fhir`, et pour s'y connecter avec les identifiants MinIO définis ci-dessous.

```yaml
services:
  pathling:
    image: ghcr.io/aehrc/pathling:latest
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - SPRING_APPLICATION_JSON={
          "pathling.import.allowableSources":["s3a://data-fhir/"],
          "fs.s3a.endpoint":"http://minio:9000",
          "fs.s3a.access.key":"admin",
          "fs.s3a.secret.key":"password123",
          "fs.s3a.path.style.access":"true",
          "fs.s3a.connection.ssl.enabled":"false"}

  minio:
    image: quay.io/minio/minio:latest
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=password123
    volumes:
      - minio_data:/data

volumes:
  minio_data:
```

```bash
docker compose up -d
```

- `pathling.import.allowableSources` restreint l'import aux URL commençant par `s3a://data-fhir/` . C'est le seul bucket que Pathling est autorisé à lire.
- Les paramètres `fs.s3a.*` configurent l'accès S3A au serveur MinIO interne au réseau Docker, en path-style access (requis par MinIO) et sans TLS.
- Le bucket `data-fhir` doit être créé dans MinIO avant le premier import (voir §6).
- Aucun volume n'est monté sur le service `pathling` : l'entrepôt de données (warehouse) n'est pas persistant entre deux redémarrages du conteneur dans cette configuration.
- Une fois démarré, on vérifie que le serveur répond correctement en visitant son adresse de métadonnées (`http://localhost:8080/fhir/metadata`) dans un navigateur : une réponse JSON confirme qu'il est opérationnel.



#### Acquisition et préparation des données sources

Pathling exige **une ressource FHIR par ligne**, sans indentation multi-lignes (format NDJSON). Un JSON indenté sur plusieurs lignes provoque des erreurs de parsing côté Spark. Concrètement, chaque patient, séjour, diagnostic, etc. devient une seule ligne de texte dans un fichier, une ligne par ressource.

Points de vigilance appliqués dans ce projet, à reproduire lors de toute nouvelle préparation de données :

- **Identifiants patients** : conserver les UUID FHIR (chaînes de caractères) comme identifiants ; ne jamais utiliser le NIR, y compris de façon transitoire (RGPD).
- **Champs `display` manquants** : vérifier que chaque code de catégorie possède un libellé lisible ; les corriger en amont si absents.
- **Cohérence des systèmes de codage** : documenter les mélanges de vocabulaires (ex. ICD-10 / ICD-11) plutôt que de les corriger silencieusement, ils seront traités lors du mapping Athena.



#### Dépôt sur MinIO et import dans Pathling

Avant le premier import, le bucket `data-fhir` est créé une seule fois dans MinIO (via sa console web, ou en ligne de commande avec le client `mc`).

L'import proprement dit se fait via une opération standard du serveur FHIR (`$import`) : on lui indique le type de ressource (`Patient`, `Encounter`, etc.) et l'adresse du fichier dans le bucket MinIO (`s3a://data-fhir/Patient.ndjson`). Cette opération est répétée pour chaque type de ressource : `Encounter`, `Condition`, `Observation`, `Procedure`, `MedicationRequest`, `MedicationAdministration`. Elle peut soit remplacer les données déjà présentes pour ce type de ressource (`overwrite`), soit les compléter (`merge`).



#### Création et exécution des vues de transformation (ViewDefinitions)

##### Principe : à quoi ressemble une ViewDefinition ?

Une ressource FHIR est comme une **fiche patient très détaillée**, avec des informations rangées dans des rubriques et des sous-rubriques (identité, adresse, contacts, sexe, date de naissance...). Cette fiche est bien organisée, mais elle n'est pas présentée sous forme de tableau : c'est plutôt une fiche imbriquée, avec des dossiers dans des dossiers.

Une **ViewDefinition** est la **feuille de route** qui explique comment transformer cette fiche en une ligne de tableau : elle dit, pour chaque colonne qu'on veut obtenir, *où aller chercher l'information* dans la fiche, et *comment l'appeler* une fois sortie. C'est un peu comme remplir un tableau Excel à partir d'un dossier papier : pour chaque colonne du tableau, on indique dans quelle case du dossier aller chercher la valeur.

Une ViewDefinition se compose toujours des mêmes éléments :

- **La ressource visée** (`resource`) : quel type de fiche on utilise ici, `Patient`.
- **Les colonnes à produire** (`select` / `column`) : la liste des informations qu'on veut extraire, avec pour chacune :
  - un **chemin** (`path`) : l'adresse de l'information dans la fiche FHIR (écrit dans un langage appelé FHIRPath),
  - un **nom de sortie** (`name`) : le nom de la colonne dans le tableau final dans ce projet, directement le nom du champ OMOP attendu (`person_id`, `gender_concept_id`, etc.).
- **Un statut** (`status`) : une case administrative qui indique le stade de vie de la règle (`draft` = en cours de construction/test, `active` = validée). Dans ce projet, les vues sont laissées en `draft` tant qu'elles n'ont pas été revalidées après un changement.
- **Une description** (`description`) : un texte libre, en langage courant, qui explique à quoi sert la vue — utile pour qu'une personne non technique comprenne l'intention sans lire les chemins FHIRPath.
- Parfois, un **filtre** (`where`) : pour ne garder que certaines fiches (par exemple, uniquement les diagnostics de type "principal").

Dans ce projet, chaque table OMOP (ou presque) correspond à une ViewDefinition : `Person` pour la table `person`, une vue dédiée pour `visit_occurrence`, etc. Une feuille de route par table à produire.

##### Exécution via l'admin UI

La façon la plus simple de tester une ViewDefinition est l'interface d'administration de Pathling : on colle la feuille de route dans l'onglet **SQL on FHIR**, et l'aperçu du résultat s'affiche directement, sans avoir besoin d'écrire de commande. Une API est disponible pour automatiser l'exécution de ces vues dans un pipeline.

##### Exemple commenté : de `Patient` à `person`

Voici un exemple de ViewDefinition utilisée dans le projet pour produire la table OMOP `person` à partir de la ressource `Patient`. Chaque ligne de `column` correspond à une colonne de la future table :

```json
{
  "resourceType": "ViewDefinition",
  "status": "draft",
  "name": "Person",
  "description": "Vue se rapprochant de la table OMOP person",
  "resource": "Patient",
  "select": [
    {
      "column": [
        { "path": "id", "name": "person_id" },
        { "path": "gender.where($this = 'female').count() * 8532 + gender.where($this = 'male').count() * 8507", "name": "gender_concept_id" },
        { "path": "birthDate", "name": "birth_date" },
        { "path": "birthDate", "name": "year_of_birth" },
        { "path": "birthDate", "name": "month_of_birth" },
        { "path": "birthDate", "name": "day_of_birth" },
        { "path": "id", "name": "location_id" },
        { "path": "gender", "name": "gender_source_value" }
      ]
    }
  ]
}
```

**Colonne par colonne, en langage métier :**

| Colonne produite | Ce qu'on va chercher | Explication |
|---|---|---|
| `person_id` | `id` | L'identifiant unique du patient, tel quel. C'est la case "numéro de dossier" de la fiche. |
| `gender_concept_id` | calcul à partir de `gender` | Le code OMOP du sexe du patient (voir explication détaillée ci-dessous). |
| `birth_date` | `birthDate` | La date de naissance complète, recopiée telle quelle. |
| `year_of_birth` | `birthDate` | La même date de naissance, recopiée telle quelle sous un autre nom de colonne (**pas encore découpée** pour n'en garder que l'année). |
| `month_of_birth` | `birthDate` | Idem, en vue d'en garder le mois. |
| `day_of_birth` | `birthDate` | Idem, en vue d'en garder le jour. |
| `location_id` | `id` | Le même identifiant patient est réutilisé comme identifiant de localisation, pour pouvoir relier la table `person` à la table `location` plus tard. |
| `gender_source_value` | `gender` | La valeur brute du sexe telle qu'écrite dans FHIR (`female` ou `male`), conservée à titre de traçabilité, à côté du code OMOP. |
{: .grid}

**Pourquoi `year_of_birth`, `month_of_birth` et `day_of_birth` contiennent-elles la date complète ?**

OMOP attend trois colonnes séparées (année, mois, jour), mais Pathling ne sait pas découper une date en morceaux (`substring()` n'est pas supporté, cf. §9). La ViewDefinition ne fait donc que **dupliquer la date de naissance complète sous ces trois noms de colonnes** ; le véritable découpage (ne garder que l'année dans `year_of_birth`, etc.) est réalisé après l'export, en SQL classique sur les données extraites.

**Le cas particulier de `gender_concept_id` : comment calculer un code sans "si...alors" ?**

OMOP attend un code numérique pour le sexe (8532 pour féminin, 8507 pour masculin), mais Pathling n'a pas de fonction "si...alors" (`iif()`) pour dire *"si le sexe est féminin, mettre 8532, sinon mettre 8507"*. La solution retenue utilise une astuce arithmétique, qu'on peut voir comme deux interrupteurs qui ne peuvent jamais être allumés en même temps :

- `gender.where($this = 'female').count()` vaut **1** si le patient est de sexe féminin, **0** sinon (l'interrupteur "féminin").
- `gender.where($this = 'male').count()` vaut **1** si le patient est de sexe masculin, **0** sinon (l'interrupteur "masculin").
- On multiplie chaque interrupteur par le code correspondant (`× 8532` et `× 8507`), puis on additionne les deux résultats.

Comme un seul des deux interrupteurs peut être à 1 à la fois, un seul des deux codes "passe" dans le résultat final, l'autre étant multiplié par zéro. Un patient de sexe féminin donne : `1 × 8532 + 0 × 8507 = 8532`. Cette même logique (compter puis multiplier) est réutilisée dans tout le projet chaque fois qu'un code OMOP doit être déduit d'une valeur FHIR (type de séjour, mode d'entrée/sortie, type de diagnostic — voir §9, ligne `iif()`).



#### Limite importante : pas de requête inter-ressources dans Pathling

Chaque ViewDefinition porte sur **une seule ressource FHIR à la fois**. Il est possible de compter ou de filtrer à l'intérieur d'une même ressource — par exemple le nombre de patients de sexe masculin dans `Patient`, ou une fois le mapping fait, dans la vue `person` — mais **Pathling ne permet pas de croiser deux ressources ou deux vues dans une seule opération**. Impossible donc d'obtenir directement, en une seule opération Pathling, le nombre de patients de sexe masculin atteints d'une affection donnée : cela suppose de combiner deux tables (`person` et `condition_occurrence`), ce que le serveur ne sait pas faire nativement.

Concrètement, toute question qui nécessite de relier deux ressources ou deux vues doit être traitée **après export**, en SQL classique sur les CSV/NDJSON/Parquet obtenus (cf. §11 pour les cas déjà rencontrés dans ce projet : jointure `death`/cause, `UNION ALL` sur `measurement`).



#### Fonctions FHIRPath — compatibilité Pathling

Toutes les fonctions FHIRPath ne sont pas supportées par Pathling. Les fonctions supportées (première partie du tableau ci-dessous) couvrent l'essentiel des besoins de navigation et de filtrage : sélectionner un élément, filtrer une collection, vérifier une présence, compter, typer une valeur ambiguë et dérouler un tableau. Les fonctions non supportées ont toutes la même origine : Pathling traduit ces expressions en requêtes Spark SQL, et certaines opérations (indexation positionnelle, sous-chaînes, hachage, conditionnelles, projections imbriquées) n'ont pas d'équivalent direct dans ce moteur — la colonne "Alternative" indique, pour chacune, le contournement retenu dans le projet. La plupart reposent sur la combinaison `where().count()`, qui elle est nativement traduisible en SQL.

> ⚠️ À ne pas confondre : la clé `"select"` d'une ViewDefinition (qui liste les colonnes à extraire) est une structure normale du format SQL-on-FHIR, toujours utilisée. La ligne `select()` du tableau ci-dessous désigne une **fonction FHIRPath** distincte (comme `where()` ou `first()`), utilisable à l'intérieur d'un chemin pour projeter une collection — c'est elle qui n'est pas supportée par Pathling.

| Fonction | Statut | Alternative |
|---|---|---|
| `first()` | ✅ Supporté | — |
| `where()` | ✅ Supporté | — |
| `exists()` | ✅ Supporté | — |
| `count()` | ✅ Supporté | — |
| `ofType()` | ✅ Supporté | — |
| `not()` | ✅ Supporté | — |
| `forEach` (dans la ViewDefinition) | ✅ Supporté | — |
| Indexation `[0]` | ❌ Erreur 500 | `coding.first()` |
| `iif()` | ❌ Non supporté | `where(...).count() * concept_id` |
| `substring()` | ❌ Non supporté | Post-traitement Python/SQL |
| `hash()` | ❌ Non supporté | Conserver l'UUID tel quel |
| fonction FHIRPath `select()` | ❌ Non supporté | `where().count() * ...` |
| Éléments primitifs étendus (`_line`, etc.) | ❌ Type `VOID` | Colonne à supprimer |
{: .grid}



#### Autres bugs rencontrés avec le moteur Pathling

Au-delà des fonctions FHIRPath non supportées (§9) et des écarts de modèle entre FHIR et OMOP (§11), deux comportements inattendus, propres au moteur d'exécution de Pathling (Spark SQL), ont été rencontrés pendant le projet. Ils ne relèvent ni d'une fonction FHIRPath manquante, ni d'une différence de modélisation entre les deux standards : ce sont des particularités internes au moteur, à connaître avant de nommer une colonne ou d'extraire une valeur numérique.

| Problème | Cause | Solution |
|---|---|---|
| Erreur 500 sur `Encounter.class` | `class` est un mot réservé Spark SQL | Renommer la colonne de sortie (`name`) en `classe_code`, `classe_display`, `classe_system` |
| Caractères corrompus sur `valueQuantity.value` | Type polymorphique `value[x]` non résolu | `valueQuantity.where($this is Quantity).value` |
{: .grid}



#### Écarts entre FHIR et OMOP

Certains écarts entre les deux modèles sont structurels : ils tiennent à des logiques de modélisation différentes entre FHIR (échange clinique) et OMOP (recherche observationnelle), et se retrouvent systématiquement, quelle que soit la ressource concernée. Un même principe explique la majorité des lignes ci-dessous : **FHIR autorise plusieurs valeurs ou plusieurs représentations là où OMOP impose une seule colonne typée**. C'est vrai pour les codages (tableau vs code unique), les dates (types multiples vs deux colonnes fixes) et les mesures composites (tableau de composants vs lignes séparées). Le traitement retenu suit donc systématiquement la même logique : conserver l'information FHIR sans perte immédiate (dans une colonne source, un export intermédiaire, ou une valeur dupliquée), puis résoudre l'écart soit par une règle de mapping simple, soit par un traitement SQL en aval lorsque la transformation dépasse ce qu'une seule vue peut exprimer (§8).

| Concept | FHIR | OMOP | Traitement retenu |
|---|---|---|---|
| Identifiants | UUID string | integer NOT NULL | UUID conservé en `VARCHAR` (limitation documentée) |
| Codes multiples | `coding[]` | un seul code | `coding.first()` — perte des codages alternatifs, source conservée dans `*_source_value` |
| Dates | `date` / `dateTime` / `Period` polymorphiques | colonnes `date` et `datetime` séparées | Même valeur `dateTime` injectée dans les deux colonnes ; dissociation par `CAST()`/`DATE()` en post-traitement |
| Date de naissance | champ unique ISO 8601 | `year_of_birth` / `month_of_birth` / `day_of_birth` | Date complète dupliquée dans `birth_date`, `year_of_birth`, `month_of_birth`, `day_of_birth` ; découpage réel via `SUBSTRING()` en SQL après export |
| Observation : profils multiples | Une ressource `Observation` couvre biologie, signes vitaux et pression artérielle composite | une seule table `measurement` | Séparation en vues distinctes (`Measurement_simple` / `Measurement_blood_pressure`), fusionnées via `UNION ALL` après export |
| PA composite | `component[]` | lignes séparées | `forEach: component` — 2 lignes par mesure |
| Cause du décès | `Condition` liée séparément au patient | `death.cause_concept_id` (même table) | 2 ViewDefinitions + `JOIN` SQL sur `person_id` (cf. §8) |
| Diagnostics | DP/DA (PMSI) | `condition_type_concept_id` | Mapping direct (32902/32908) |
| Diagnostics non pathologiques (allergies, antécédents, grossesse) | `Condition` FHIR générique, sans distinction | `condition_occurrence` (diagnostics) vs `observation` (états non diagnostiques) | Routage selon le domaine associé au code CIM |
| Provenance de la donnée | Non représentée explicitement | Champs `*_type_concept_id` obligatoires | Concepts OMOP standardisés déduits du type et du contexte de production de la ressource FHIR source |
| Codes CIM | ICD-10 et ICD-11 mixtes | SNOMED attendu | `condition_concept_id = 0`, à mapper via Athena |
| Médicaments | ATC | RxNorm attendu | `drug_concept_id = 0`, à mapper via Athena |
| Unités | UCUM | UCUM | Identique, pas de mapping nécessaire |
{: .grid}



#### Tables OMOP hors périmètre du projet

Le projet vise un ensemble précis de tables OMOP, déterminé par les 51 variables du socle de la PDS (Plateforme de Données de Snaté) : `person`, `location`, `visit_occurrence`, `visit_detail`, `condition_occurrence`, `observation`, `measurement`, `procedure_occurrence`, `drug_exposure`, `death`. Plusieurs autres tables du modèle OMOP CDM v5.4  `observation_period`, `condition_era`, `drug_era`, `dose_era`, `fact_relationship`, `device_exposure`, `note` **n'ont jamais fait partie de ce périmètre** : elles ne correspondent à aucune des 51 variables socle et n'ont donc pas été produites, ce qui n'est pas un blocage rencontré en cours de projet mais un choix de cadrage initial.

À titre indicatif seulement, si ces tables devaient un jour être ajoutées au périmètre, deux natures d'obstacle sont à anticiper. `observation_period`, `condition_era`, `drug_era` et `dose_era` nécessitent des regroupements par patient (`MIN`/`MAX` de dates, algorithmes ERA de l'écosystème OHDSI) qui dépassent ce qu'une seule ViewDefinition peut produire (§8) et demanderaient un traitement SQL après export ; `fact_relationship` nécessite de relier plusieurs tables entre elles, même limitation. `device_exposure` et `note`, en revanche, ne pourraient être produites dans aucun cas avec les données actuelles : aucune ressource FHIR `Device` ou `DocumentReference` n'existe dans le corpus source, quel que soit le périmètre retenu.

| Table OMOP | Statut dans ce projet | Si le périmètre évoluait |
|---|---|---|
| `observation_period` | Hors périmètre (non demandée) | Nécessiterait un regroupement `MIN`/`MAX` par patient en SQL post-export |
| `condition_era`, `drug_era`, `dose_era` | Hors périmètre (non demandées) | Nécessiteraient l'algorithme ERA OHDSI en SQL post-export |
| `fact_relationship` | Hors périmètre (non demandée) | Nécessiterait des jointures entre plusieurs tables |
| `device_exposure`, `note` | Hors périmètre (non demandées) | Resteraient non produisibles : aucune ressource FHIR source correspondante |
{: .grid}



#### Ressources

Les liens ci-dessous pointent vers la documentation officielle consultée pour rédiger ce README (serveur Pathling, opérations FHIR utilisées), ainsi que vers les standards et outils tiers mobilisés dans le pipeline (SQL-on-FHIR, OMOP CDM, Athena, WhiteRabbit, MinIO). Les liens vers les opérations Pathling sont les plus utiles au quotidien pour un usage technique : ce sont les pages de référence pour vérifier la syntaxe exacte des paramètres en cas de changement de version.

| Ressource | Lien |
|---|---|
| Documentation Pathling (serveur) | <https://pathling.csiro.au/docs/server> |
| Guide de démarrage | <https://pathling.csiro.au/docs/server/getting-started> |
| Opération Import | <https://pathling.csiro.au/docs/server/operations/import> |
| Opération Run view (`$viewdefinition-run`) | <https://pathling.csiro.au/docs/server/operations/view-run> |
| Opération Export view (`$viewdefinition-export`) | <https://pathling.csiro.au/docs/server/operations/view-export> |
| Admin UI | <https://pathling.csiro.au/docs/server/admin-ui> |
| Configuration | <https://pathling.csiro.au/docs/server/configuration> |
| Dépôt GitHub Pathling | <https://github.com/aehrc/pathling> |
| Spécification SQL-on-FHIR v2 | <https://sql-on-fhir.org/> |
| OMOP CDM v5.4 (OHDSI) | <https://ohdsi.github.io/CommonDataModel/> |
| Athena (vocabulaires OMOP) | <https://athena.ohdsi.org/> |
| WhiteRabbit / Rabbit-in-a-Hat | <https://github.com/OHDSI/WhiteRabbit> |
| MinIO | <https://min.io/> |
| Profils APHP/EDSH — IG EDSH socle commun | `https://interop.aphp.fr/ig/fhir/dm/` |
{: .grid}



*Document technique — pipeline FHIR R4 → OMOP CDM v5.4, projet APHP DSN (Domaine MSD/DSN).*
