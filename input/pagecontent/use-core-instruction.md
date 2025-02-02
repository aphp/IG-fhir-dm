##### Contexte

TODO mettre ici le contexte des variables socles pour les EDSH.

##### Modèle métier

Le modèle métier reflète une compréhension orientée donnée des exigences d’un cas d'usage. Les spécificités du cas 
d’usage sont portées par le questionnaire. En effet, dans notre approche, nous formalisons les exigences d’un cas 
d’usage en créant une ressource `Questionnaire`, car celle-ci possède la flexibilité nécessaire pour représenter 
l’ensemble des variables d’un cas d’usage tout en les structurant en groupes logiques (groupes métier ?).

TODO : faire la ressource Questionnaire pour les variables socles

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div style="text-align: center;">{%include core-logical.svg%}</div>

| Nom du modèle                    | Lien vers le modèle          |
|----------------------------------|------------------------------|
| Patient                          | [UseCorePatient]             |
| Contact avec le système de santé | [UseCoreContactSystemeSante] |
| Hôpital                          | [UseCoreHopital]             |
| Questionnaire                    | [UseCoreQuestionnaire]       |

##### Identification des applications sources

Pour l'exemple, nous allons simuler le scénario où l'ensemble des données identifié dans les exigences en donnée portent totalement sur l'application DPI.

##### Data discovery

###### Périmètre initial

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div style="text-align: center;">{%include core-mpd.svg%}</div>

| Table          | Description                                                       | DDL                 |
|----------------|-------------------------------------------------------------------|---------------------|
| ENCOUNTER      | Table des NDA                                                     | [CoreEncounter]     |
| PATIENT        | Table des patients                                                | [CorePatient]       |
| BIOLOGY        | Table contenant les résultats de biologie                         | [CoreBiology]       |
| CLINICAL       | Table contenant les informations cliniques                        | [CoreClinical]      |
| MEDICATION_ADM | Table contenant les informations d'administration des médicaments | [CoreMedicationAdm] |
| MEDICATION_PRE | Table contenant les informations de prescription des médicaments  | [CoreMedicationPre] |

###### Périmètre final

Remarque, nous n'avons pas de directive sur la profondeur historique.

L'alignement entre le modèle "physique" (modèle de l'application DPI) et le modèle métier issu des exigences en donnée de l'usage permet d'identifier les tables et les champs d'intérêt.

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div style="text-align: center;">{%include core-map.svg%}</div>

Vous pouvez trouver l'alignement formel entre le modèle physique et les profils FHIR : [Modèle physique vers FHIR](StructureMap-CorePhysical2FHIR.html)

##### Profilage

Le profilage des données permet de découvrir, de comprendre et d'organiser les données en identifiant leurs caractéristiques et en évaluant leur qualité. 
Cette opération permet de savoir si les données sont complètes ou uniques, de détecter les erreurs et les schémas inhabituels, et de déterminer si elles peuvent être exploitées facilement.

Le profilage décrit ici s'appuie sur la norme 8000-81. Le profilage des données s'applique à des données au format tabulaire et consiste en trois processus :

- réaliser une analyse de la structure de données (détermination des concepts d'éléments de données) ;
- réaliser une analyse du contenu des colonnes (identification des éléments de données pertinents et statistiques sur les éléments de données) ;
- réaliser une analyse des relations (identification des dépendances).

###### Analyse de la structure de données

La première étape du profilage pour un usage est l'analyse de la structure de données. Il s'agit d'identifier les tables
et les champs d'intérêt. Les résultats sont présentés par table.

Ici pour l'exemple, nous n'avons pas adressé ce point. Néanmoins, et pour l'exercice, nous envisageons de la faire prochainement.

{% include markdown-link-references.md %}