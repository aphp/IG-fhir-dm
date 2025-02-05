### Définitions de base

| Concept      | Définition                                                                                                                                                                                                                                                              |
|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ConceptMap` | Une ressource `ConceptMap` est un patron de conception standard **FHIR**. Il permet de formaliser des alignements entre deux `ValueSet` afin de supporter la tâche de traduction notamment dans le cadre d'un échange de donnée impliquant une normalisation des codes. |

### Conventions de nommage

#### Ressources de conformité
- id : PascalCase sans espace. Commence par une lettre (en majuscule donc). Contient uniquement des lettres et des chiffres. Il doit être unique dans son sous type (CodeSystem, Extension, ValueSet, etc.) et signifiant (proche du titre). 
- name : identique à l'id (PascalCase sans espace donc).
- url : [base]/[ResourceType]/[id] 

On nommera les fichiers selon la convention suivante : [ResourceType]-[Id].[extension fsh/json].

Par exemple, pour le questionnaire de représentation du modèle métier de l'usage "variables socles", on aura : 
-	id = name = UsageCore
-	url = [base]/Questionnaire/UsageCore
-	nom du fichier = Questionnaire-UsageCore.fsh

à noter que ces règles ne sont pas conformes [aux conventions préconisées par l'ANS](https://interop.esante.gouv.fr/ig/documentation/bonnes_pratiques_modeler.html#r%C3%A8gles-de-nommage-des-ressources-de-conformit%C3%A9)

##### Cas particulier des StructureDefinition

- id doit préciser à quel type il s’applique (c’est-à-dire son Base)

Par exemple pour le profil dédié au poids : 
-	id = name = DMObservationBodyWeight
-	nom du fichier est : StructureDefinition-DMObservationBodyWeight.fsh
-	url = [base]/StructureDefinition/DMObservationBodyWeight

#### Autres ressources (exemples, ou instances)
Id est un UUID. 
On pourra colliger les ressources afférentes à un cas d'usage dans un fichier dont le nom explicitera le cas d'usage. 

#### uri des sources
On décide, pour chaque ressource FHIR intégrée dans le Hub de donnée, de préciser l'application source de cette ressource via l'attribut `meta.source`. Cet attribut attend une uri qui sera, autant que possible, créée selon la convention suivante :
1. https://
2. nom de domaine de l'éditeur
3. nom de l'application (autant que possible issue de la liste maintenue par l'urbanisme).
4. detail dans l'application

Par exemple :
- https://editeur.com/DPI

### Description des processus de production des données sources
La description des processus de production des données sources est systématisée pour l'ensemble des ressources intégrées dans le Hub de données. 
Cette description constitue un des éléments qui doit permettre aux chercheurs et chercheuses de l'AP-HP d'apprécier la pertinence des données contenues dans le Hub de données pour répondre à leurs questions de recherche. 

Les situations documentées de production des enregistrements sont synthétisées dans une figure.
On trouve aussi une brève description du jeu de données, stratifiée par processus de production (nombre d'enregistrements, date du premier enregistrement, taux de rafraichissement).

Chacune des situations illustrées par la figure donne lieu à la production d'une section qui décrit: 
- le contexte de production proprement dit selon la méthode QQOQCP : Qui ? Quoi ? Où ? Quand ? Comment ? Pourquoi ? (voir la description du tableau [ci-dessous](#aide-de-lecture-pour-le-tableau-de-description-des-processus))
- des précautions d'utilisation spécifiques.

#### Aide de lecture pour le tableau de description des processus

| Caractéristique de l'enregistrement | Définition                                                                                                                                  |
|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Agent                               | Personne, parfois dispositif médical, impliqué dans la production de la donnée. Il peut y en avoir plusieurs.                               |
| Nature                              | Description des informations saisies par l'agent : la donnée d'intérêt, mais également ses métadonnées et des données liées.                |
| Lieu                                | Endroit où les données sont produites.                                                                                                      |
| Temps                               | Période pendant laquelle les données sont produites et saisies.                                                                             |
| Modalité                            | La production de la donnée relève en générale d'une expertise métier, on se concentrera sur les manière dont les données sont enregistrées. |
| Raison d'être                       | C'est le contexte métier qui a poussé au recueil et à la saisie de l'information.                                                           |

{% include markdown-link-references.md %}