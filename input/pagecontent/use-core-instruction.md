#### Modéle conceptuel

<div style="text-align: center;" id="conceptual-model">
  <img style="width: 100%" src="use-core-conceptual.png" alt="Modèle conceptuel"/>
</div>

| Concept | Description | Note | Aussi connu comme | Lien/Dépendance |
|---------|-------------|------|-------------------|-----------------|
||||||

#### Formulaire des exigences

Dans notre approche, nous formalisons les exigences d’un cas d'usage en créant une ressource `Questionnaire`, car celle-ci possède la flexibilité nécessaire pour représenter l'ensemble des variables d'un cas d'usage tout en les organisant. [Le formulaire des exigences](Questionnaire-UsageCore.html) est le résultat du processus de formalisation à partir du fichier [exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html) du cas d'usage.

#### Identification des applications sources

Pour l'exemple, nous allons simuler le scénario où l'ensemble des données identifiées dans les exigences portent totalement sur le DPI générique.

#### Data discovery

##### Périmètre initial

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div style="text-align: center; width: 100%;">{%include core-mpd.svg%}</div>

<table width="100%">
  <tr><th>Table</th><th>Description</th><th>DDL</th></tr>
  <tr><td>PATIENT</td><td>Table des patients</td><td><a href="StructureDefinition-CorePatient.html">CorePatient</a></td></tr>
  <tr><td>SEJOUR</td><td>Table des NDA</td><td><a href="StructureDefinition-CoreSejour.html">CoreSejour</a></td></tr>
  <tr><td>MOUV</td><td>Table des mouvements</td><td><a href="StructureDefinition-CoreMouv.html">CoreMouv</a></td></tr>
  <tr><td>BIOLOGY</td><td>Table contenant les résultats de biologie</td><td><a href="StructureDefinition-CoreBiology.html">CoreBiology</a></td></tr>
  <tr><td>CLINICAL</td><td>Table contenant les informations cliniques</td><td><a href="StructureDefinition-CoreClinical.html">CoreClinical</a></td></tr>
  <tr><td>MEDICATION_ADM</td><td>Table contenant les informations d'administration des médicaments</td><td><a href="StructureDefinition-CoreMedicationAdm.html">CoreMedicationAdm</a></td></tr>
  <tr><td>MEDICATION_PRE</td><td>Table contenant les informations de prescription des médicaments</td><td><a href="StructureDefinition-CoreMedicationPre.html">CoreMedicationPre</a></td></tr>
</table>

##### Périmètre final

L'alignement du modèle métier, issu des exigences en donnée de l'usage, vers le modèle "physique" (modèle de l'application DPI)  permet d'identifier les tables et les champs d'intérêt.

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div style="text-align: center; width: 100%;">{%include core-map.svg%}</div>

Vous pouvez trouver l'alignement formel entre le modèle métier et le modèle physique : [Modèle métier vers modèle physique](StructureMap-CoreBusiness2Physical.html)

#### Profilage des données

Le profilage des données permet de découvrir, de comprendre et d'organiser les données en identifiant leurs caractéristiques et en évaluant leur qualité. 
Cette opération permet de savoir si les données sont complètes ou uniques, de détecter les erreurs et les schémas inhabituels, et de déterminer si elles peuvent être exploitées facilement.

Le profilage décrit ici s'appuie sur la norme 8000-81. Le profilage des données s'applique à des données au format tabulaire et consiste en trois processus :

- réaliser une analyse de la structure de données (détermination des concepts d'éléments de données) ;
- réaliser une analyse du contenu des colonnes (identification des éléments de données pertinents et statistiques sur les éléments de données) ;
- réaliser une analyse des relations (identification des dépendances).

##### Analyse de la structure de données

La première étape du profilage pour un usage est l'analyse de la structure de données. Il s'agit d'identifier les tables et les champs d'intérêt. Les résultats sont présentés par table.

{% include markdown-link-references.md %}