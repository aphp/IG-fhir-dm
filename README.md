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

1. Exécuter [SUSHI](https://fshschool.org/docs/sushi/). L'IG AP-HP - DM est développé en [FHIR Shorthand (FSH)](http://build.fhir.org/ig/HL7/fhir-shorthand/),
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

Dans ce projet, Pathling est utilisé pour transformer les ressources `Patient`, `Encounter`, `Condition`, `Observation`, `Procedure`, `MedicationRequest` et `MedicationAdministration` (profils APHP) en tables OMOP (`person`, `visit_occurrence`, `visit_detail`, `condition_occurrence`, `measurement`, `procedure_occurrence`, `drug_exposure`, `death`, `location`, `observation`). Les règles de transformation projettent directement les ressources FHIR vers le schéma OMOP : les colonnes de sortie portent déjà les noms des champs OMOP cibles (`person_id`, `gender_concept_id`, etc.), et les codes OMOP connus (`concept_id`) sont calculés directement pendant la transformation.

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

Le projet vise un ensemble précis de tables OMOP, déterminé par les 51 variables du socle de la PDS (Plateforme de Données de Santé) : `person`, `location`, `visit_occurrence`, `visit_detail`, `condition_occurrence`, `observation`, `measurement`, `procedure_occurrence`, `drug_exposure`, `death`. Plusieurs autres tables du modèle OMOP CDM v5.4  `observation_period`, `condition_era`, `drug_era`, `dose_era`, `fact_relationship`, `device_exposure`, `note` **n'ont jamais fait partie de ce périmètre** : elles ne correspondent à aucune des 51 variables socle et n'ont donc pas été produites, ce qui n'est pas un blocage rencontré en cours de projet mais un choix de cadrage initial.

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



## Test de FHIR Mapping Language (FML) pour la transformation FHIR → OMOP

Après avoir développé une approche déclarative avec **Pathling + SQL-on-FHIR v2 ViewDefinitions**, ce document couvre l'évaluation comparative de **FHIR Mapping Language (FML)** comme approche alternative, testée sur les 10 cas cliniques synthétiques du corpus EDSH (`cas1` à `cas10`).

Les tests ont été exécutés avec l'extension VSCode **aphp.fhir-mapbuilder** (v1.4.0), qui embarque **Matchbox 4.1.1** (moteur `org.hl7.fhir.core` 6.9.4) comme serveur FML local. Le pipeline final validé est dans ce projet **`IG-fhir-dm`**, qui dispose nativement de modèles logiques `OMOP*` complets pour les 26 tables du CDM v5.4, avec un préfixe `OMOP` systématique (par exemple `OMOPPerson`, `OMOPConditionOccurrence`).

### Source des `StructureMap` (.fml)

Le point de départ est le travail officiel de HL7/Vulcan, l'IG **FHIR to OMOP** (`hl7.fhir.uv.omop`, v2.0.0-ballot) :
- Dépôt source : https://github.com/HL7/fhir-omop-ig
- Build continu : https://build.fhir.org/ig/HL7/fhir-omop-ig
- **FHIR R5**, `fhirVersion: 5.0.0` confirmé dans le `sushi-config.yaml` du dépôt. Nos ressources sources étant en **FHIR R4**, chaque fichier a nécessité une adaptation.

#### Différences structurelles R5 → R4 identifiées et corrigées

| Champ R5 (HL7 original) | Équivalent R4 (EDSH) |
|---|---|
| `Encounter.actualPeriod` | `Encounter.period` |
| `Encounter.admission.admitSource` / `.dischargeDisposition` | `Encounter.hospitalization.admitSource` / `.dischargeDisposition` |
| `Encounter.class` (liste `CodeableConcept`) | `Encounter.class` (un seul `Coding`, pas de `.coding` intermédiaire) |
| `Procedure.occurrence[x]` (choice type) | `Procedure.performedDateTime` / `performedPeriod` |
| `MedicationStatement.medication : CodeableReference` | `MedicationAdministration.medicationCodeableConcept` / `MedicationRequest.medicationCodeableConcept` (champs directs) |
{: .grid}

#### Statut de chaque fichier

| Fichier | Groupe(s) | Statut | Donnée testée |
|---|---|---|---|
| `PersonMap.fml` | `Person` | Validé | `Patient-cas1-pat-01` |
| `LocationMap.fml` | `LocationOccurrence` | Validé | `Location-cas1-*` |
| `EncounterVisitMap.fml` | `VisitOccurrence` | Validé | `Encounter-cas1-sej-01` |
| `ConditionMap.fml` | `ConditionOccurrence` | Validé | `Condition-cas1-diag-01` |
| `ProcedureMap.fml` | `ProcedureOccurrence` | Validé | `Procedure-cas1-acte-*` |
| `MeasurementMap.fml` | `Measures` | Validé | `Observation-cas*-bio-*` (labo) |
| `BloodPressureVitalSignsMap.fml` | `BloodPressure`, `parentTable`, `Systolic`, `Diastolic` | Validé | `Observation-cas1-exam-tas-01-*` |
| `SimpleVitalSignsMap.fml` | `VitalSigns` | Validé | Signes vitaux (poids/taille) |
| `VisitDetailMap.fml` | `VisitDetail` | Validé, construction maison (voir note) | `Encounter-cas10-sej-01` |
| `MedAdminMap.fml` | `MedAdminExposure` | Validé | `MedicationAdministration-cas1-*` |
| `MedRequestMap.fml` | `MedRequestExposure` | Validé | `MedicationRequest-cas1-*` |
| `RecordSetMap.fml` | `RecordSet` (orchestrateur) | Validé | `Bundle-cas1-recordset` (29 ressources assemblées) |
| `AllergyMap.fml` | `Allergy` | Non testable | Pas de ressource `AllergyIntolerance` dans le corpus, les allergies sont modélisées comme `Condition` |
| `ObservationMap.fml` | `Observe` | Non testable | Corpus limité aux catégories `laboratory` et `vital-signs` ; les actes type échographie sont modélisés en `Procedure`, pas en `Observation` catégorisée `exam` |
| `ImmunizationMap.fml` | `DrugExposure` | Non applicable | Pas de ressource `Immunization` dans le corpus ; le fichier HL7 original contenait une erreur de syntaxe (`.first()` chaîné, cf. enseignement technique n°2) corrigée lors de l'adaptation R4, mais le fichier reste non testable faute de donnée |
{: .grid}

### `ConceptMap`, deux niveaux de fiabilité

##### Contenu vérifié (HL7 officiel authentique ou vrai vocabulaire OHDSI)

Deux origines possibles pour ce contenu vérifié. D'une part le contenu HL7 officiel authentique, copié verbatim depuis les fichiers `.fsh` ou pages du dépôt HL7/Vulcan, seule l'URL de domaine étant adaptée. D'autre part le contenu construit depuis le vrai vocabulaire OHDSI, suite au téléchargement réel du vocabulaire OMOP standardisé (`athena.ohdsi.org`, vocabulaire v5.0 27-FEB-26, incluant `CIM10` édition française ATIH, `CCAM` ATIH, `LOINC` 2.80 et `UCUM` 1.8.2), où les fichiers `CONCEPT.csv` et `CONCEPT_RELATIONSHIP.csv` ont été interrogés directement pour extraire les vrais `concept_id`.

| Fichier | Origine | Source vérifiée | Couverture réelle sur le corpus | Utilisée par (`translate()` dans les `.fml`) |
|---|---|---|---|---|
| `GenderClass` | HL7 officiel | `ConceptMap-GenderClass.ttl.html`, non listée dans l'index principal, retrouvée par URL directe | Complète | `PersonMap.fml` |
| `EncounterClass` | HL7 officiel | `ConceptMap-EncounterClass.html` | Complète (`IMP`, `AMB`, `EMER`) | `EncounterVisitMap.fml` |
| `EncounterAdmitSource` / `EncounterDischargeDisposition` | HL7 officiel | Pages HL7 officielles, avec un ajout non-HL7 du code `"8"` confirmé par l'équipe comme signifiant urgence / domicile | Codes HL7 non utilisés par EDSH ; le code `"8"` est notre propre ajout documenté | `EncounterVisitMap.fml` |
| `BloodPressureCodes` | HL7 officiel | `ConceptMap-BloodPressureCodes.html` | Complète | `BloodPressureVitalSignsMap.fml` |
| `VitalSignsCodes` | HL7 officiel | `ConceptMap-VitalSignsCodes.html` | Partielle selon signes vitaux du corpus | `SimpleVitalSignsMap.fml` |
| `ConditionConcepts` | HL7 officiel | Fichier `.fsh` source (12 entrées SNOMED) | Aucune, il s'agit de SNOMED, pas de CIM-10 | Aucune, non appelée par un `translate()` |
| `ProcedureType` | HL7 officiel | Fichier `.fsh` source (3 entrées SNOMED), non listée dans l'index principal | Aucune, il s'agit de SNOMED, pas de CCAM | `ProcedureMap.fml` |
| `ConditionStatusConcepts` | HL7 officiel | Fichier `.fsh` source (1 entrée) | Non applicable, EDSH utilise `category`, pas `clinicalStatus` | Aucune, non appelée par un `translate()` |
| `AllergyType`, `IntoleranceType`, `AllergySubstanceType` | HL7 officiel | Fichiers `.fsh` sources | Non applicable, type de ressource (`AllergyIntolerance`) absent du corpus | `AllergyMap.fml` |
| `ImmunizationVaccine`, `ImmunizationRoute` | HL7 officiel | Fichiers `.fsh` sources | Non applicable, type de ressource (`Immunization`) absent du corpus | `ImmunizationMap.fml` |
| `ImmunizationSource` | HL7 officiel | Fichier `.fsh` source | Non applicable, type de ressource (`Immunization`) absent du corpus | Aucune, non appelée par un `translate()` |
| `UCUM` | Vocabulaire OHDSI réel | `CONCEPT.csv`, 4 unités : `mm[Hg]` vers 8876, `umol/L` vers 8749, `g/dL` vers 8713, `[iU]/L` vers 8923 | Concepts standards vérifiés, `translate()` pleinement fonctionnel | `BloodPressureVitalSignsMap.fml`, `MeasurementMap.fml` |
| `LabConcepts` | Vocabulaire OHDSI réel | `CONCEPT.csv`, 3 codes LOINC : ALAT vers 3006923, hémoglobine vers 3000963, créatinine vers 3020564 | Concepts standards vérifiés, `translate()` pleinement fonctionnel | `MeasurementMap.fml` |
| `ConditionConceptsCIM10` | Vocabulaire OHDSI réel | `CONCEPT.csv`, 23 codes CIM-10 réels du corpus (les 10 cas), tous vérifiés | Utilisable uniquement pour `condition_source_concept_id`. Aucune relation `Maps to` vers un concept standard n'existe pour le vocabulaire CIM10 édition française dans cette version d'Athena, vérifié exhaustivement | `ConditionMap.fml` |
| `ProcedureTypeCCAM` | Vocabulaire OHDSI réel | `CONCEPT.csv`, 4 codes CCAM réels du corpus, tous vérifiés | Utilisable uniquement pour `procedure_source_concept_id`. 0 relation `Maps to` sur les 10 206 concepts CCAM du vocabulaire, vérification exhaustive, pas un vide partiel | `ProcedureMap.fml` |
{: .grid}

##### Placeholders vides (structure valide, aucune entrée)

Ces fichiers permettent à `translate()` de se résoudre sans erreur bloquante, en attendant un futur enrichissement, sans jamais retoucher le `.fml` associé.

| Fichier | Champ concerné | Utilisée par (`translate()` dans les `.fml`) |
|---|---|---|
| `ObservationConcepts` | `observation_concept_id`, aucune ConceptMap générique disponible pour les catégories non mesurables | `ObservationMap.fml` |
| `VisitDetailType` | `visit_detail_concept_id`, construction maison, aucune référence HL7 | `VisitDetailMap.fml` |
{: .grid}

### Modèles logiques (`StructureDefinition`)

Tous les modèles OMOP utilisés sont les modèles natifs du projet `IG-fhir-dm` (`OMOPPerson`, `OMOPLocation`, `OMOPConditionOccurrence`, `OMOPProcedureOccurrence`, `OMOPMeasurement`, `OMOPDrugExposure`, `OMOPVisitOccurrence`, `OMOPVisitDetail`, `OMOPObservation`), déjà présents dans le projet avant ce travail.

Un seul modèle logique a dû être construit spécifiquement : `RecordSet`, un conteneur intermédiaire sans équivalent natif, utilisé par `BloodPressureVitalSignsMap.fml` (routage vers plusieurs `Measurement` indépendants) et `RecordSetMap.fml` (orchestrateur `Bundle` vers plusieurs tables OMOP).

> **Point de modélisation confirmé par la pratique** : les champs de composition de `RecordSet` (`measurement`, `condition`, `allergy`, `visitOccurrence`, `procedure`) doivent être typés en composition directe (`OMOPMeasurement`) et non en `Reference(OMOPMeasurement)`. L'usage de `Reference()` provoque l'erreur `Cannot set property measurement_id on measurement`.

### Enseignements techniques sur le moteur FML (Matchbox 4.1.1)

Ces observations sont issues de l'expérimentation directe, pas de la documentation officielle. Elles sont à revérifier en cas de changement de moteur FML.

1. **Deux règles de structure à respecter systématiquement.** D'une part, toute règle à cibles multiples séparées par une virgule doit porter un nom explicite (`"nom_regle"`), sous peine d'erreur `Complex rules must have an explicit name`. D'autre part, le pattern `src.a as x, x.b as y -> ...` (deux sources liées au même niveau, séparées par une virgule) échoue à l'exécution avec `Rule "...": not handled yet` ; il faut systématiquement lui préférer le pattern imbriqué `src.a as x -> tgt then { x.b as y -> ... }`.
2. **`.first()` chaîné directement sur une variable déjà liée** (`variable.first() as X`) casse le parsing avec `Found "(" expecting ";"`. La correction consiste à accéder directement au champ sur la variable liée (`variable.champ as X`), fiable car les données EDSH n'ont jamais qu'un seul élément par collection en pratique.
3. **`cast(valeur, "date")` sur un `dateTime` complet** (avec heure et millisecondes) échoue avec `Invalid date/time string ... does not support MILLI precision`. La correction consiste à extraire manuellement la date via `(valeur.toString().substring(0, 10))`, sans `cast()`.
4. **`cast(id, "integer")` sur un id non numérique** échoue avec `NumberFormatException`. Ce n'est pas une limitation du moteur FML en tant que telle : les identifiants hospitaliers réels (NDA, IPP) sont habituellement numériques, et `cast()` fonctionnerait probablement sans problème sur de vraies données de production. C'est le format lisible choisi pour le corpus de test synthétique (`cas1-pat-01`, `cas1-sej-01`, etc., plutôt que des entiers) qui provoque l'échec ici. Sur ce corpus précis, il faut donc toujours assigner l'id directement, sans `cast()`.
5. **Les champs `*_concept_id` et `*_id` (clés étrangères) du modèle `IG-fhir-dm` natif sont typés `Reference(OMOPXxx)`**, pas `string` ni `integer`. Cela nécessite la construction explicite d'une structure `Reference` via `create('Reference') as ref then { valeur as v -> ref.reference = v; }`, faute de quoi le champ reste silencieusement vide, sans erreur levée.
6. **Les blocs de commentaires `///` trop longs** (plusieurs lignes numérotées) provoquent une erreur de parsing (`Unrecognised name /// on StructureMap`). Il faut garder les en-têtes courts, cinq lignes maximum, et documenter les décisions ailleurs.
7. **Une expression chaînée utilisée directement comme argument d'une fonction** (`translate(code.valeur, ...)`, `cast(x.toString().substring(...), ...)`) casse le parsing. Il faut toujours lier l'expression à sa propre variable via `as` avant de l'utiliser en argument.

### Références

- IG FHIR to OMOP (HL7/Vulcan) : https://build.fhir.org/ig/HL7/fhir-omop-ig
- Dépôt source : https://github.com/HL7/fhir-omop-ig
- Portail vocabulaire OHDSI (Athena) : https://athena.ohdsi.org
- Extension VSCode utilisée : `aphp.fhir-mapbuilder`, avec Matchbox 4.1.1 embarqué
- IG EDSH socle commun (corpus source des 10 cas cliniques) : https://aphp.github.io/IG-FHIR-EDSH-SOCLE-COMMUN

## Comparaison synthétique avec Pathling

| Aspect | Pathling / SQL-on-FHIR | FML |
|---|---|---|
| Modélisation cible OMOP | Aucune, juste des noms de colonnes | `StructureDefinition` de type `kind: logical` obligatoire, résolue par le moteur avant exécution |
| `forEach` sur un tableau, par exemple `Observation.component` | Natif (`forEach: component`) | Non supporté, limitation confirmée aussi par le papier TermX (Frontiers, 2026). Nécessite plusieurs groupes indépendants (`Systolic`/`Diastolic`) reliés a posteriori par `measurement_event_id` |
| Conversion d'un id en entier | Non testé avec des id numériques réels (le corpus source utilise des id lisibles type `cas1-pat-01`) | `cast(id,'integer')` échoue sur ce corpus précis, id non numériques. À revérifier sur de vraies données de production avec des identifiants numériques (NDA, IPP) |
| Terminologie (CIM-10, CCAM vers OMOP) | `%terminologies.translate()` non disponible en pratique | `translate()` et `ConceptMap` fonctionnels, mais dépendent entièrement de la disponibilité réelle des correspondances dans le vocabulaire OHDSI, très incomplet pour la CIM-10 et la CCAM à ce jour |
{: .grid}


*Document technique — pipeline FHIR R4 → OMOP CDM v5.4, projet APHP DSN (Domaine MSD/DSN).*
