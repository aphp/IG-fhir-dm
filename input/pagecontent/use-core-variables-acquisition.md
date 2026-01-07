{% include markdown-link-references.md %}

Les [exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html)
référencées issues des travaux du GT Standards & Interopérabilité.

### Modéle conceptuel

<div id="conceptual-model" style="height: 270px;" markdown="1">
{% include conceptual-model.mermaid %}
</div>

### Glossaire métier

| Concept | Description | Note | Aussi connu comme | Lien/Dépendance | Références |
|---------|-------------|------|-------------------|-----------------|------------|
| Patient | Identifiant du patient | | | | |
| Séjour | Identifiant du séjour | | | | |
| Acte | Ensemble des actes dont le patient a bénéficié | | | | |
| Diagnostic | Ensemble des diagnostics qui ont été faits | | | | |
| Erythrocytes | Taux d'érythocrytes circulants dans le sang. Les érythrocytes sont des cellules issues de la moëlle osseuse qui produise l'hémoglogine pour transporter l'oxygène. | Paramètre peu utilisé pour le raisonnement clinique. Valeur normale comprise entre 4 et 5.5 T/L. | Hématies, Globules rouges, GR | | [789-8](https://loinc.org/789-8/){:target="_blank"} |
| Hémoglobine | Taux d'hémoglobine dans le sang. L'hémoglobine est une molécule présente dans les globules rouges permettant de transporter l'oxygène vers les tissus. | Un taux anormal peut être observé dans de nombreuses situations notamment en cas de carence en fer ou vitaminique, de pathologie hématologique néoplasique, d'infection, de prise médicamenteuse, de maladie génétique. Valeur normale comprise entre 13 et 17 g/dL chez les hommes et 12-16 g/dL chez les femmes.| Hb | | [718-7](https://loinc.org/718-7/){:target="_blank"} |
| Hématocrite | Rapport du volume occupé par les érythrocytes sur le volume sanguin. | Un niveau anormal peut être observé en cas en cas d'anémie, de pathologie hématologique néoplasique, de maladie respiratoire chronique. Valeur normale comprise entre 40 et 50% chez l'homme et 37-45% chez la femme. | Ht | Volume globulaire moyen, Erythrocytes | [4544-3](https://loinc.org/4544-3/){:target="_blank"} |
| Volume globulaire moyen | Volume moyen des érythrocytes circulants dans le sang. | Un niveau anormal peut être observé en cas en cas d'anémie, d'intoxication alcoolique chronique ou de prise médicamenteuse. Valeur normale comprise entre 80 et 100 fL. | VGM | | [30428-7](https://loinc.org/30428-7/){:target="_blank"} |
| Plaquettes | Taux de plaquettes circulantes dans le sang. Les plaquettes sont des cellules issues de la moëlle osseuse et sont un des principaux acteurs impliqués dans le processus de l'hémostase et de la coagulation.| Un taux anormal peut être observé dans de nombreuses situations notamment en cas de carence en fer ou vitaminique, d'infection, de prise médicamenteuse ou de pathologie hématologique néoplasique. Valeur normal comprise entre 150 et 450 G/L.| Thrombocytes | | [777-3](https://loinc.org/777-3/){:target="_blank"} |
| Leucocytes | Taux de leucocytes circulants dans le sang. Les leucocytes sont des cellules produites dans la moëlle osseuse et sont des acteurs de première ligne du système immunitaire. Ils correspondent à la somme des neutrophiles, éosinophiles, basophiles, lymphocytes et monocytes.| Une diminution ou une augmentation peut être causée par de multiples causes notamment une infection, une pathologie hématologique néoplasique ou un médicament. Valeur normale comprise entre 4 et 10 G/L. | Globules blancs, GB | | [6690-2](https://loinc.org/6690-2/){:target="_blank"} |
| Neutrophiles | Taux de neutrophiles circulants dans le sang. Les neutrophiles sont un type de leucocyte et jouent un rôle primordial dans le système immunitaire, en particulier dans la défense contre les infections bactérinnes. | Un taux anormal peut être observé dans de nombreuses situations notamment en cas d'infection, de pathologie hématologique néoplasique ou de prise médicamenteuse. Valeur normale comprise entre 1.5 et 7 G/L. | Polynucléaires neutrophiles, PNN | Leucocytes | [26499-4](https://loinc.org/26499-4/){:target="_blank"} |
| Lymphocytes | Taux de lymphocytes circulants dans le sang. Les lymphocytes sont un type de leucocyte et jouent un rôle primordial dans le système immunitaire pour la défense contre les infections et la défense anti-tumorale.| Un taux anormal peut être observé dans de nombreuses situations notamment en cas d'infection, de pathologie hématologique néoplasique ou de prise médicamenteuse. Valeur normale comprise entre 1 et 4 G/L.| | Leucocytes | [26474-7](https://loinc.org/26474-7/){:target="_blank"} |
| Eosinophiles | Taux d'éosinophiles circulants dans le sang. Les éosinophiles sont un type de leucocyte et jouent un rôle primordial dans le système immunitaire pour la défense contre les infections parasitaires et sont également impliqués dans les réactions allergiques.| Un taux élevé peut être observé dans de nombreuses situations notamment en cas d'allergie, d'infection parasitaire, de pathologie hématologique néoplasique ou de prise médicamenteuse. Valeur normale < 0.5 G/L. | Polynucléaires éosinophiles, PNE | Leucocytes | [26449-9](https://loinc.org/26449-9/){:target="_blank"} |
| Monocytes | Taux de monocytes circulants dans le sang. Les monocytes sont un type de leucocyte et jouent un rôle important, notamment via leur capacité de phagocytose, d'épuration des cellules sanguines dysfonctionnelles et d'activation de l'immunité adaptative. | Un taux anormal peut être observé dans de nombreuses situations notamment en cas d'infection, de pathologie hématologique néoplasique ou de prise médicamenteuse. Valeur normale comprise entre 0.2 et 1 G/L. | | Leucocytes | [26484-6](https://loinc.org/26484-6/){:target="_blank"} |
| Taux prothrombine (TP) | Paramètre calculé à partir du temps de Quick (TQ) permettant d'évaluer la capacité de coagulation en explorant la voie extrinsèque de la coagulation. | Une diminution peut être observée notamment en cas de traitement anticoagulant, d'insuffisance hépato-cellulaire, de déficit en vitamine K ou de maladies génétiques. Valeur normale comprise entre 70 et 100%.| | | [5894-1](https://loinc.org/5894-1/){:target="_blank"} |
| Temps de céphaline activée (TCA) | Paramètre permettant d'évaluer la capacité de coagulation en explorant la voie intrinsèque de la coagulation. | Une augmentation du TCA (ou allongement) peut être observée notamment en cas de traitement anticoagulant, d'insuffisance hépato-cellulaire, de carence en vitamine K, de maladie auto-immune ou de maladie génétique. Valeur normale comprise entre 0.8 et 1.2 s.| | | [14979-9](https://loinc.org/14979-9/){:target="_blank"} et [13488-2](https://loinc.org/13488-2/){:target="_blank"} et [63561-5](https://loinc.org/63561-5/){:target="_blank"} |
| Créatininémie | Taux de créatinine dans le sang. La créatinine est un produit de dégradation de la phosphocréatine et de la déshydratation de la créatine dans le muscle. | Taux fonction de la masse musculaire. Reflet de la fonction rénale (molécule éliminée en quasi totalité par le rein). | créatinine dans le sang, créatinine sérique | | [14682-9](https://loinc.org/14682-9/){:target="_blank"} ou [2160-0](https://loinc.org/2160-0/){:target="_blank"} |
| Débit de filtration glomérulaire (DFG) | Volume filtré par le rein par unité de temps. Le DFG permet de quantifier l'activité rénale. | Méthode de référence : mesure de l'élimination d'un élément radioactif par l'urine (rarement réalisé). Actuellement essentiellement estimé à partir de la créatininémie, de l'âge et du sexe avec plusieurs formules possibles : MDRD, CKD-EPI ou Cockroft. On utilise CKD-EPI par défaut (recommandation HAS) | DFG | Créatininémie, sexe, âge | [62238-1](https://loinc.org/62238-1){:target="_blank"} ou [77147-7](https://loinc.org/77147-7/){:target="_blank"} ou [35591-7](https://loinc.org/35591-7/){:target="_blank"} |
| Urée | Taux d'urée dans le sang. L'urée est un catabolite composé formé dans le foie à partir de l'ammoniac produit par la désamination des acides aminés. C'est le principal produit final du catabolisme des protéines et il constitue environ la moitié des solides urinaires totaux. | Reflet de la fonction rénale | Dosage de l'urée dans le sang, urémie | | [22664-7](https://bioloinc.fr/bioloinc/KB/index#Concept:uri=http://www.aphp.fr/LOINC_CircuitBio_Demande/22664-7_Ur%25C3%25A9e){:target="_blank"} |
| Glycémie à jeun | Taux de glucose dans le sang à jeun (c'est à dire après une période sans apport alimentaire d'au moins 8 heures). | | | | [14749-6](https://loinc.org/14749-6/){:target="_blank"} ou [40193-5](https://loinc.org/40193-5/){:target="_blank"} |
| Hémoglobine glyquée | Forme glyquée de la molécule de l'hémoglobine dans le sang. Sa valeur biologique est le reflet de la concentration de glucose dans le sang (glycémie) sur trois mois. | Paramètre de référence dans la surveillance de l'équilibre glycémique chez les patients diabétiques. | HbA1c | | [4548-4](https://loinc.org/4548-4/){:target="_blank"} ou [59261-8](https://loinc.org/59261-8/){:target="_blank"} |
| Aspartate aminotransférase (ASAT) | Taux d'ASAT dans le sang. L'ASAT est une enzyme faisant partie des transaminases qui intervient dans la navette malate-aspartate de transfert des électrons du NADH cytosolique vers le NAD+ mitochondrial. | Se trouve en quantité importante dans les muscles (cardiaque  et squelettiques), le rein et le cerveau. Normales généralement comprises entre 20 et 40 UI/L. Unité de référence : UI/L. | Aspartate aminotransférase (AST), glutamate oxaloacétique transaminase (SGOT ou GOT) | | [30239-8](https://loinc.org/30239-8/){:target="_blank"} ou [1920-8](https://loinc.org/1920-8/){:target="_blank"} |
| Alamine aminotransférase (ALAT) | Taux d'ALAT dans le sang. L'ALAT est une enzyme faisant partie des transaminases qui se trouve en quantité importante surtout dans le foie. | Son augmentation dans le plasma sanguin signe une cytolyse hépatique. Normales généralement comprises entre 20 et 40 UI/L. Unité de référence : UI/L. | Alamine aminotransférase (ALT), glutamate pyruvate transaminase (GPT ou TGP) | | [1742-6](https://loinc.org/1742-6/){:target="_blank"} ou [1743-4](https://loinc.org/1743-4/){:target="_blank"} |
| Gamma-glutamyl transférase (GGT) | Taux de GGT dans le sang. Aminoacyltransférase impliquées dans la catalyse d'enzymes hépatiques impliquées dans le métabolisme des acides aminés. | La détermination de l'activité sérique des GGT est un indice d'anomalie du foie. Pour un adulte le taux normal ne doit pas dépasser 55UI/L. Unité de référence : UI/L. | gamma-glutamyltranspeptidase | | [2324-2](https://loinc.org/2324-2/){:target="_blank"} |
| Bilirubine totale | Taux de bilirubine dans le sang. La bilirubine est un pigment jaune produit de la dégradation de l'hémoglobine, et d'autres hémoprotéines (cytochrome ou catalases). | Catabolisme assuré par le foie. Une élévation importante peut être causée par une hémolyse ou une maladie génétique (maladie de Gilbert). Valeur normale < 17µmol/L. | | | [14631-6](https://loinc.org/14631-6/){:target="_blank"} |
| Bilirubine conjuguée | Taux de la fraction conjuguée de la bilirubine dans le sang. La bilirubine conjuguée est le produit du processus enzymatique de glucurono-conjugaison de la bilirubine libre assuré par les hépatocytes. Elle est ensuite excrétée dans les voies biliaires. | Une élévation importante peut être causée par un obstacle sur les voies biliaires. Valeur normale < 3 µmol/L.| | Bilirubine totale | [29760-6](https://loinc.org/29760-6/){:target="_blank"} |
| Phosphatases alcalines (PAL) | Taux de PAL dans le sang. La PAL est une enzyme dont le rôle est encore mal défini participant notamment au fonctionnement hépatique et osseux. | Un taux élevé peut être observé notamment en cas d'obstruction des voies biliaires, de pathologie hépatique ou de pathologie osseuse. Valeur normale comprise entre 35 et 120 UI/L.| | | [6768-6](https://loinc.org/6768-6/){:target="_blank"} |
| Prescription médicamenteuse | Ensemble de chaque médicament prescrit avec sa posologie | | | | |
| Posologie | Il semble peu pertinent de dissocier la posologie du médicament. | | | | |
| Médicament prescrit | Il semble peu pertinent de dissocier le médicament de la posologie. | | | | |
| Administration médicamenteuse | Ensemble de chaque médicament administré avec sa dose | | | | |
| Dosage | Il semble peu pertinent de dissocier le dosage du médicament. | | | | |
| Médicament administré | Il semble peu pertinent de dissocier le médicament du dosage. | | | | |
| Poids | Masse du patient exprimée en kg (ou g en pédiatrie) | | | | [29463-7](https://loinc.org/29463-7/){:target="_blank"} |
| Taille | Taille du patient exprimée en m ou cm | | | | [8302-2](https://loinc.org/8302-2/){:target="_blank"} |
| Pression artérielle | Pression qui s'exerce sur la paroi des artères. On distingue la pression artérielle systolique, qui correspond à la pression pendant la phase d'éjection du sang par le coeur, de la pression artérielle diastolique, qui correspond à la pression pendant la phase de remplissage du coeur. | Elle est souvent notée selon le format X/Y mmHg où X correspond à la pression artérielle systolique (PAS), Y correspond à la pression artérielle diastolique (PAD) et mmHg correspond à l'unité dans laquelle la pression artérielle est exprimée. Valeurs usuelles de la PAS entre 100 et 140 mmHg et de la PAD entre 60 et 90 mmHg | | | diastolique : [8462-4](https://loinc.org/8462-4/){:target="_blank"}<br/> systolique : [8480-6](https://loinc.org/8480-6/){:target="_blank"} |
| Consommation de tabac | Statut tabagique du patient (non-fumeur/sevré/actif) avec estimation quantitative | On utilise le nombre de paquet-année pour l'estimation quantitative de la consommation tabagique cumulée. Un paquet-année correspond à la consommation d'un paquet de cigarette par jour pendant un an.| | | |
| Consommation d'alcool | Préciser formellement ce qui est attendu. | | | | [11331-6](https://loinc.org/11331-6/){:target="_blank"} |
| Consommation d'autres drogues | Préciser formellement ce qui est attendu. | | | | [11343-1](https://loinc.org/11343-1/){:target="_blank"} |
| Activité physique | Préciser formellement ce qui est attendu. | | | | [99285-9](https://loinc.org/99285-9/){:target="_blank"} |
{: .grid}

### Exemples

Exemples pour valider avec les experts le modèle conceptuel ... Ces exemples serviront également pour valider le processus de formalisation des données et le processus de standardisation.

#### Cas 1 : Infarctus du myocarde

{% include QuestionnaireResponse-cas-1-usage-core-intro.md %}

#### Cas 2 : Ulcère gastrique

{% include QuestionnaireResponse-cas-2-usage-core-intro.md %}

#### Cas 3 : Accouchement simple

{% include QuestionnaireResponse-cas-3-usage-core-intro.md %}

#### Cas 4 : Choc cardiogénique

{% include QuestionnaireResponse-cas-4-usage-core-intro.md %}

#### Cas 5 : Pyélonéphrite aigue

{% include QuestionnaireResponse-cas-5-usage-core-intro.md %}

#### Cas 6 : Suivi de cardiopathie ischémique

{% include QuestionnaireResponse-cas-6-usage-core-intro.md %}

#### Cas 7 : État de mal migraineux

{% include QuestionnaireResponse-cas-7-usage-core-intro.md %}

#### Cas 8 : Chirurgie d'une fracture fémorale

{% include QuestionnaireResponse-cas-8-usage-core-intro.md %}

#### Cas 9 : Ponction évacuatrice d'ascite

{% include QuestionnaireResponse-cas-9-usage-core-intro.md %}

#### Cas 10 : Exacerbation de BPCO

{% include QuestionnaireResponse-cas-10-usage-core-intro.md %}

#### Cas 11 : Suivi diabète de type 2

{% include QuestionnaireResponse-cas-11-usage-core-intro.md %}
