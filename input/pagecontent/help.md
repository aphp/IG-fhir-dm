
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

- id doit préciser à quel type il s'applique (c'est-à-dire son Base)

Par exemple pour le profil dédié au poids : 
-	id = name = DMObservationBodyWeight
-	nom du fichier est : StructureDefinition-DMObservationBodyWeight.fsh
-	url = [base]/StructureDefinition/DMObservationBodyWeight

#### Autres ressources (exemples, ou instances)

Id est un UUID. 
On pourra colliger les ressources afférentes à un cas d'usage dans un fichier dont le nom explicitera le cas d'usage. 

#### NammingSystem

La plupart des ressources FHIR propose un attribut `identifier` qui permet de renseigner 0 à n identifiants métiers a une ressource. Ces identifiants permettent notamment de créer des liens logiques entre les ressources (via les attributs de type `reference` et leur attribut `identifier`). 

Cet attribut `identifier` est particulièrement intéressant pour le lineage des ressources, lorsqu'il s'agit de créer une ressource FHIR à partir d'un objet déjà existant, dans un autre format, au sein du système d'information. 

Cela impose néanmoins une gestion rigoureuse des namespace. On part sur le principe que les namespaces seront défini comme suit : 

[base APHP]/[type de ressource FHIR]/[identifiant unique d'un processus de génération d'identifiant unique]

avec : 
- [base APHP] = `https://aphp.fr/meta`
- [type de ressource FHIR] appartient au ValueSet [ResourceType](http://hl7.org/fhir/ValueSet/resource-types)
- [identifiant de processus] est à construire en interne, par exemple : `ipp` (il n'y a qu'un processus de création d'ipp à l'APHP : par le SIU Orbis), `ProduitChimioAVC` (il y a des médicament dans CHIMIO et dans d'autres outils, plusieurs CHIMIO et plusieurs 'type' de médicament dans chaque CHIMIO)

Plusieurs stratégies sont envisageable pour s'assurer de l'unicité des namespace _by design_ :
- mettre en oeuvre un registre interne des namespace : un serveur FHIR dans lequel chaque responsable de namespace enregistrerait une ressource NamingSystem pour chacun des namespace qu'il gère, en s'assurant qu'il n'existe pas déjà. 
- fournir à chaque responsable de namespace un code unique qui serait inclus dans l'identifiant de processus du namespace
- consolider un codesystem contenant tous les namespace utiles, charge à chaque responsable de namespace d'enrichir ce CS en tant que de besoin. 

Une difficulté réside dans le souhait, exprimé par des responsable de namespace, de ne pas publicisé, auprès de partenaires extérieurs, certains namespace. 

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
| Raison d'être                       | C'est le contexte métier qui a poussé au recueil et à la saisie de l'information.                           