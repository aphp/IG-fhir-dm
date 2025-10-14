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

| Concept | Description | Note | Aussi connu comme | Lien/Dépendance | Références |
|---------|-------------|------|-------------------|-----------------|------------|
| Patient | | | | | |
| Séjour | | | | | |
| Acte | | | | | |
| Diagnostic | | | | | |
| Urée | Taux d'urée dans le sang. L'urée est un catabolite composé formé dans le foie à partir de l'ammoniac produit par la désamination des acides aminés. C'est le principal produit final du catabolisme des protéines et il constitue environ la moitié des solides urinaires totaux. | Reflet de la fonction rénale | Dosage de l'urée dans le sang | | [22664-7](https://bioloinc.fr/bioloinc/KB/index#Concept:uri=http://www.aphp.fr/LOINC_CircuitBio_Demande/22664-7_Ur%25C3%25A9e){:target="_blank"} |
| Créatininémie | Taux de créatinine dans le sang. La créatinine est un produit de dégradation de la phosphocréatine et de la déshydratation de la créatine dans le muscle. | Taux fonction de la masse musculaire. Reflet de la fonction rénale (molécule éliminée en quasi totalité par le rein). | créatinine dans le sang, créatinine sérique | | [14682-9](https://loinc.org/14682-9/){:target="_blank"} ou [2160-0](https://loinc.org/2160-0/){:target="_blank"} |
| Débit de filtration glomérulaire | Volume filtré par le rein par unité de temps. Quantification de l'activité du rein. Le DFG est estimé par la créatinine sérique. | Méthode de référence : mesure de l'élimination d'un élément radioactif par l'urine (rarement réalisé). Actuellement essentiellement estimé à partir de la créatinine et de la surface corporelle. Plusieurs formules possibles : MDRD, EPI-CKD ou Cockroft ici EPI CKD par défaut (recommandation HAS) | DFG | Créatininémie, sexe, âge | [62238-1](https://loinc.org/62238-1){:target="_blank"} ou [77147-7](https://loinc.org/77147-7/){:target="_blank"} ou [35591-7](https://loinc.org/35591-7/){:target="_blank"} |
| Glycémie à jeun | Taux de glucose dans le sang à jeun (c'est à dire après une période sans apport alimentaire d'au moins 8 heures). | | | | [14749-6](https://loinc.org/14749-6/){:target="_blank"} ou [40193-5](https://loinc.org/40193-5/){:target="_blank"} |
| Hémoglobine glyquée | Forme glycquée de la molécule de l'hémoglobine dans le sang. Sa valeur biologique est le reflet de la concentration de glucose dans le sang (glycémie) sur trois mois. | Paramètre de référence dans la surveillance de l'équilibre glycémique chez les patients diabétiques. | HbA1c | | [4548-4](https://loinc.org/4548-4/){:target="_blank"} ou [59261-8](https://loinc.org/59261-8/){:target="_blank"} |
| Aspartate aminotransférase (ASAT) | Taux d'ASAT dans le sang. L'ASAT est une enzyme faisant partie des transaminases qui intervient dans la navette malate-aspartate de transfert des électrons du NADH cytosolique vers le NAD+ mitochondrial. | Se trouve en quantité importante dans les muscles (cardiaque  et squelettiques), le rein et le cerveau. Normales généralement comprises entre 20 et 40 UI/L. Unité de référence : UI/L | Aspartate aminotransférase (AST), glutamate oxaloacétique transaminase (SGOT ou GOT) | | [30239-8](https://loinc.org/30239-8/){:target="_blank"} ou [1920-8](https://loinc.org/1920-8/){:target="_blank"} |
| Alamine aminotransférase (ALAT) | Taux d'ALAT dans le sang. L'ALAT est une enzyme faisant partie des transaminases qui se trouve en quantité importante surtout dans le foie. | Son augmentation dans le plasma sanguin signe une cytolyse hépatique. Normales généralement comprises entre 20 et 40 UI/L. Unité de référence : UI/L | Alamine aminotransférase (ALT), glutamate pyruvate transaminase (GPT ou TGP) | | [1742-6](https://loinc.org/1742-6/){:target="_blank"} ou [1743-4](https://loinc.org/1743-4/){:target="_blank"} |
| Gamma-glutamyl transférase (GGT) | Taux sanguin de GGT. Aminoacyltransférase impliquées dans la catalyse d'enzymes hépatiques impliquées dans le métabolisme des acides aminés. | La détermination de l'activité sérique des GGT est un indice d'anomalie du foie. Pour un adulte le taux normal ne doit pas dépasser 55UI/L. Unité de référence : UI/L | gamma-glutamyltranspeptidase | | [2324-2](https://loinc.org/2324-2/){:target="_blank"} |
| Bilirubine totale | Taux de bilirubine sanguin. La bilirubine est un pigment jaune produit de la dégradation de l'hémoglobine, et d'autres hémoprotéines (cytochrome ou catalases). | Catabolisme assuré par le foie. Une élévation importante peut être causé par une hémolyse ou une maladie génétique (maladie de Gilbert). Valeure normale < 17µmol/L | | | [14631-6](https://loinc.org/14631-6/){:target="_blank"} |
| Bilirubine conjuguée | | | | | [29760-6](https://loinc.org/29760-6/){:target="_blank"} |
| Leucocytes | | | | | [6690-2](https://loinc.org/6690-2/){:target="_blank"} |
| Hémoglobine | | | | | [718-7](https://loinc.org/718-7/){:target="_blank"} |
| Hématocrite | | | | | [4544-3](https://loinc.org/4544-3/){:target="_blank"} |
| Erythrocytes | | | Globule rouge | | [789-8](https://loinc.org/789-8/){:target="_blank"} |
| Volume globulaire moyen | | | | | [30428-7](https://loinc.org/30428-7/){:target="_blank"} |
| Plaquettes | | | | | [777-3](https://loinc.org/777-3/){:target="_blank"} |
| Neutrophiles | | | | | [26499-4](https://loinc.org/26499-4/){:target="_blank"} |
| Lymphocytes | | | | | [26474-7](https://loinc.org/26474-7/){:target="_blank"} |
| Eosinophiles | | | | | [26449-9](https://loinc.org/26449-9/){:target="_blank"} |
| Monocytes | | | | | [26484-6](https://loinc.org/26484-6/){:target="_blank"} |
| Taux prothrombine (TP) | | | | | [5894-1](https://loinc.org/5894-1/){:target="_blank"} |
| Temps de céphaline activée (TCA) | | | | | [14979-9](https://loinc.org/14979-9/){:target="_blank"} et [13488-2](https://loinc.org/13488-2/){:target="_blank"} et [63561-5](https://loinc.org/63561-5/){:target="_blank"} |
| Phosphatases alcaline | | PAL | | | [6768-6](https://loinc.org/6768-6/){:target="_blank"} |
| Prescription médicamenteuse | | | | | |
| Posologie | | | | | |
| Médicament prescript | | | | | |
| Administration médicamenteuse | | | | | |
| Dosage | | | | | |
| Médicament administré | | | | | |
| Poids | | | | | |
| Taille | | | | | |
{: .grid}

### Exemples

Exemples pour valider avec les experts le modèle conceptuel ... Ces exemples serviront également pour valider le processus de formalisation des données et le processus de standardisation.

#### Cas 1 : ???

{% include QuestionnaireResponse-test-usage-core-complet-intro.md %}

#### Cas 2 : ???

TODO
