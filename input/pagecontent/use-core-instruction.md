#### Modéle de donnée conceptuel

<div style="text-align: center; width: 100%; max-width: 100%;" id="conceptual-model">
  <a href="use-core-conceptual.png" target="_blank">
    <img style="max-width: 100%; box-sizing: border-box;" src="use-core-conceptual.png" alt="Modèle de donnée conceptuel" />
  </a>
</div>

<table width="100%">
  <tr><th>Concept</th><th>Description</th><th>Note</th><th>Aussi connu comme</th><th>Lien/Dépendance</th></tr>
  <tr><td>Patient</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Urémie</td><td>Taux d'urée dans le sang. 
L'urée est un catabolite composé formé dans le foie à partir de l'ammoniac produit par la désamination des acides aminés. C'est le principal produit final du catabolisme des protéines et il constitue environ la moitié des solides urinaires totaux.</td><td>Reflet de la fonction rénale</td><td>Dosage de l'urée dans le sang</td><td></td></tr>
  <tr><td>Créatininémie</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Débit de filtration glomérulaire</td><td></td><td></td><td></td><td>Créatininémie, sexe, âge</td></tr>
  <tr><td>Glycémie à jeun</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Hémoglobine glyquée</td><td></td><td></td><td>HbA1c</td><td></td></tr>
  <tr><td>Aspartate aminotransférase (ASAT)</td><td></td><td></td><td>Aspartate aminotransférase (AST)</td><td></td></tr>
  <tr><td>Alamine aminotransférase (ALAT)</td><td></td><td></td><td>Alamine aminotransférase (ALT)</td><td></td></tr>
  <tr><td>Gamma-glutamyl transférase (GGT)</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Bilirubine totale</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Bilirubine conjuguée</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Leucocytes</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Hémoglobine</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Hématocrite</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Erythrocytes</td><td></td><td></td><td>Globule rouge</td><td></td></tr>
  <tr><td>Volume globulaire moyen</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Plaquettes</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Neutrophiles</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Lymphocytes</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Eosinophiles</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Monocytes</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Taux prothrombine (TP)</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Temps de céphaline activée (TCA)</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Prescription médicamenteuse</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Posologie</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Médicament prescript</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Administration médicamenteuse</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Dosage</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Médicament administré</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Poids</td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Taille</td><td></td><td></td><td></td><td></td></tr>
</table>

#### Formulaire des exigences

Dans notre approche, nous formalisons les exigences d’un cas d'usage en créant une ressource `Questionnaire`, car celle-ci possède la flexibilité nécessaire pour représenter l'ensemble des variables d'un cas d'usage tout en les organisant. [Le formulaire des exigences](Questionnaire-UsageCore.html) est le résultat du processus de formalisation à partir du fichier d'[exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html) du cas d'usage.

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