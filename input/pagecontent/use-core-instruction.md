#### Modéle de donnée conceptuel

<div style="text-align: center; width: 100%; max-width: 100%;" id="conceptual-model">
  <a href="use-core-conceptual.png" target="_blank">
    <img style="max-width: 100%; box-sizing: border-box;" src="use-core-conceptual.png" alt="Modèle de donnée conceptuel" />
  </a>
</div>

<a href="https://miro.com/app/board/uXjVI2D5ilU=/?share_link_id=531605220269" target="_blank">Voir la version navigable du modèle conceptuel</a>

<table width="100%">
  <tr><th>Concept</th><th>Description</th><th>Note</th><th>Aussi connu comme</th><th>Lien/Dépendance</th><th>Références</th></tr>
  <tr><td>Patient</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Séjour</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Acte</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Diagnostic</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Urée</td><td>Taux d'urée dans le sang. L'urée est un catabolite composé formé dans le foie à partir de l'ammoniac produit par la désamination des acides aminés. C'est le principal produit final du catabolisme des protéines et il constitue environ la moitié des solides urinaires totaux.</td><td>Reflet de la fonction rénale</td><td>Dosage de l'urée dans le sang</td><td></td><td><a href="https://bioloinc.fr/bioloinc/KB/index#Concept:uri=http://www.aphp.fr/LOINC_CircuitBio_Demande/22664-7_Ur%25C3%25A9e" target="_blank">22664-7</a></td></tr>
  <tr><td>Créatininémie</td><td>Taux de créatinine dans le sang. La créatinine est un produit de dégradation de la phosphocréatine et de la déshydratation de la créatine dans le muscle.</td><td>Taux fonction de la masse musculaire. Reflet de la fonction rénale (molécule éliminée en quasi totalité par le rein).</td><td>créatinine dans le sang, créatinine sérique</td><td></td><td><a href="https://loinc.org/14682-9/" target="_blank">14682-9</a> ou <a href="https://loinc.org/2160-0/" target="_blank">2160-0</a></td></tr>
  <tr><td>Débit de filtration glomérulaire</td><td>Volume filtré par le rein par unité de temps. Quantification de l'activité du rein. Le DFG est estimé par la créatinine sérique.</td><td>Méthode de référence : mesure de l'élimination d'un élément radioactif par l'urine (rarement réalisé). Actuellement essentiellement estimé à partir de la créatinine et de la surface corporelle. Plusieurs formules possibles : MDRD, EPI-CKD ou Cockroft
ici EPI CKD par défaut (recommandation HAS)</td><td>DFG</td><td>Créatininémie, sexe, âge</td><td><a href="https://loinc.org/62238-1" target="_blank">62238-1</a> ou <a href="https://loinc.org/77147-7/" target="_blank">77147-7</a> ou <a href="https://loinc.org/35591-7/" target="_blank">35591-7</a></td></tr>
  <tr><td>Glycémie à jeun</td><td>Taux de glucose dans le sang à jeun (c'est à dire après une période sans apport alimentaire d'au moins 8 heures).</td><td></td><td></td><td></td><td><a href="https://loinc.org/14749-6/" target="_blank">14749-6</a> ou <a href="https://loinc.org/40193-5/" target="_blank">40193-5</a></td></tr>
  <tr><td>Hémoglobine glyquée</td><td>Forme glycquée de la molécule de l'hémoglobine dans le sang. Sa valeur biologique est le reflet de la concentration de glucose dans le sang (glycémie) sur trois mois.</td><td>Paramètre de référence dans la surveillance de l'équilibre glycémique chez les patients diabétiques.</td><td>HbA1c</td><td></td><td><a href="https://loinc.org/4548-4/" target="_blank">4548-4</a> ou <a href="https://loinc.org/59261-8/" target="_blank">59261-8</a></td></tr>
  <tr><td>Aspartate aminotransférase (ASAT)</td><td>Taux d'ASAT dans le sang. L'ASAT est une enzyme faisant partie des transaminases qui intervient dans la navette malate-aspartate de transfert des électrons du NADH cytosolique vers le NAD+ mitochondrial.</td><td>Se trouve en quantité importante dans les muscles (cardiaque  et squelettiques), le rein et le cerveau. Normales généralement comprises entre 20 et 40 UI/L.
Unité de référence : UI/L</td><td>Aspartate aminotransférase (AST), glutamate oxaloacétique transaminase (SGOT ou GOT)</td><td></td><td><a href="https://loinc.org/30239-8/" target="_blank">30239-8</a> ou <a href="https://loinc.org/1920-8/" target="_blank">1920-8</a></td></tr>
  <tr><td>Alamine aminotransférase (ALAT)</td><td>Taux d'ALAT dans le sang. L'ALAT est une enzyme faisant partie des transaminases qui se trouve en quantité importante surtout dans le foie.</td><td>Son augmentation dans le plasma sanguin signe une cytolyse hépatique.
Normales généralement comprises entre 20 et 40 UI/L.
Unité de référence : UI/L</td><td>Alamine aminotransférase (ALT), glutamate pyruvate transaminase (GPT ou TGP)</td><td></td><td><a href="https://loinc.org/1742-6/" target="_blank">1742-6</a> ou <a href="https://loinc.org/1743-4/" target="_blank">1743-4</a></td></tr>
  <tr><td>Gamma-glutamyl transférase (GGT)</td><td>Taux sanguin de GGT. Aminoacyltransférase impliquées dans la catalyse d'enzymes hépatiques impliquées dans le métabolisme des acides aminés.</td><td>La détermination de l'activité sérique des GGT est un indice d'anomalie du foie. Pour un adulte le taux normal ne doit pas dépasser 55UI/L. Unité de référence : UI/L</td><td>gamma-glutamyltranspeptidase</td><td></td><td><a href="https://loinc.org/2324-2/" target="_blank">2324-2</a></td></tr>
  <tr><td>Bilirubine totale</td><td>Taux de bilirubine sanguin. La bilirubine est un pigment jaune produit de la dégradation de l'hémoglobine, et d'autres hémoprotéines (cytochrome ou catalases).</td><td>Catabolisme assuré par le foie. Une élévation importante peut être causé par une hémolyse ou une maladie génétique (maladie de Gilbert). Valeure normale < 17µmol/L</td><td></td><td></td><td><a href="https://loinc.org/14631-6/" target="_blank">14631-6</a></td></tr>
  <tr><td>Bilirubine conjuguée</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/29760-6/" target="_blank">29760-6</a></td></tr>
  <tr><td>Leucocytes</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/6690-2/" target="_blank">6690-2</a></td></tr>
  <tr><td>Hémoglobine</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/718-7/" target="_blank">718-7</a></td></tr>
  <tr><td>Hématocrite</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/4544-3/" target="_blank">4544-3</a></td></tr>
  <tr><td>Erythrocytes</td><td></td><td></td><td>Globule rouge</td><td></td><td><a href="https://loinc.org/789-8/" target="_blank">789-8</a></td></tr>
  <tr><td>Volume globulaire moyen</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/30428-7/" target="_blank">30428-7</a></td></tr>
  <tr><td>Plaquettes</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/777-3/" target="_blank">777-3</a></td></tr>
  <tr><td>Neutrophiles</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/26499-4/" target="_blank">26499-4</a></td></tr>
  <tr><td>Lymphocytes</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/26474-7/" target="_blank">26474-7</a></td></tr>
  <tr><td>Eosinophiles</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/26449-9/" target="_blank">26449-9</a></td></tr>
  <tr><td>Monocytes</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/26484-6/" target="_blank">26484-6</a></td></tr>
  <tr><td>Taux prothrombine (TP)</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/5894-1/" target="_blank">5894-1</a></td></tr>
  <tr><td>Temps de céphaline activée (TCA)</td><td></td><td></td><td></td><td></td><td><a href="https://loinc.org/14979-9/" target="_blank">14979-9</a> et <a href="https://loinc.org/13488-2/" target="_blank">13488-2</a> et <a href="https://loinc.org/63561-5/" target="_blank">63561-5</a></td></tr>
  <tr><td>Phosphatases alcaline</td><td></td><td>PAL</td><td></td><td></td><td><a href="https://loinc.org/6768-6/" target="_blank">6768-6</a></td></tr>
  <tr><td>Prescription médicamenteuse</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Posologie</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Médicament prescript</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Administration médicamenteuse</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Dosage</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Médicament administré</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Poids</td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>Taille</td><td></td><td></td><td></td><td></td><td></td></tr>
</table>

#### Formulaire des exigences

Dans notre approche, nous formalisons les exigences d’un cas d'usage en créant une ressource `Questionnaire`, car celle-ci possède la flexibilité nécessaire pour représenter l'ensemble des variables d'un cas d'usage tout en les organisant. [Le formulaire des exigences](Questionnaire-UsageCore.html) est le résultat du processus de formalisation à partir du fichier d'[exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html) du cas d'usage.

#### Identification des applications sources

Pour l'exemple, nous allons simuler le scénario où l'ensemble des données identifiées dans les exigences portent totalement sur le DPI générique.

#### Data discovery

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div style="text-align: center; width: 100%; max-width: 100%;" id="physical-model">
  <div style="width: 100%;">{% include core-mpd.svg %}</div>
</div>

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

#### Profilage des données (à faire ici ?)

Le profilage des données permet de découvrir, de comprendre et d'organiser les données en identifiant leurs caractéristiques et en évaluant leur qualité. 
Cette opération permet de savoir si les données sont complètes ou uniques, de détecter les erreurs et les schémas inhabituels, et de déterminer si elles peuvent être exploitées facilement.

Le profilage décrit ici s'appuie sur la norme 8000-81. Le profilage des données s'applique à des données au format tabulaire et consiste en trois processus :

- réaliser une analyse de la structure de données (détermination des concepts d'éléments de données) ;
- réaliser une analyse du contenu des colonnes (identification des éléments de données pertinents et statistiques sur les éléments de données) ;
- réaliser une analyse des relations (identification des dépendances).

##### Analyse de la structure de données

La première étape du profilage pour un usage est l'analyse de la structure de données. Il s'agit d'identifier les tables et les champs d'intérêt. Les résultats sont présentés par table.

{% include markdown-link-references.md %}