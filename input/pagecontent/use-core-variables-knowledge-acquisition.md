{% include markdown-link-references.md %}

Les [exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html) 
référencées issues des travaux du GT Standards & Interopérabilité. 


### Modéle conceptuel

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div class="viewer-container" style="height: 592px;">
  <div class="svg-container" id="conceptual-model">
    {% include use-core-conceptual.svg %}
  </div>
</div>

### Glossaire métier

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

### Exemples

Exemples pour valider avec les experts le modèle conceptuel ... Ces exemples serviront également pour valider le processus de formalisation des données et le processus de standardisation.

#### Cas 1 : ???

{% include QuestionnaireResponse-test-usage-core-complet-intro.md %}

#### Cas 2 : ???

TODO