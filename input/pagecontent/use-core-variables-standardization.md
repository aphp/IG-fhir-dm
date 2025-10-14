{% include markdown-link-references.md %}

Les [exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html) 
référencées issues des travaux du GT Standards & Interopérabilité. 

### Modèles standardisés (Profils FHIR)

Le tableau ci-dessous référence tous les profils FHIR résultat du processus de standardisation des données au format FHIR.

| Groupe | Données | Caractéristiques |
|--------|---------|------------------|
| Identité patient | [Patient](StructureDefinition-DMPatient.html) | Données maîtres |
| PMSI | [Séjour](StructureDefinition-DMEncounter.html) | Données d'intérêt |
| PMSI | [Diagnostic CIM10](StructureDefinition-DMCondition.html) | Données d'intérêt |
| PMSI | [Acte CCAM](StructureDefinition-DMProcedure.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Urémie](StructureDefinition-DMObservationLaboratoryUremie.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Créatininémie](StructureDefinition-DMObservationLaboratoryFonctionRenale.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Débit de filtration glomérulaire (DFG)](StructureDefinition-DMObservationLaboratoryFonctionRenale.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Leucocytes](StructureDefinition-DMObservationLaboratoryLeucocytes.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Hémoglobine](StructureDefinition-DMObservationLaboratoryHemoglobine.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Hématocrite](StructureDefinition-DMObservationLaboratoryHematocrite.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Globules rouges](StructureDefinition-DMObservationLaboratoryErythrocytes.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Volume Globulaire Moyen (VGM)](StructureDefinition-DMObservationLaboratoryVGM.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Plaquettes](StructureDefinition-DMObservationLaboratoryPlaquettes.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Neutrophiles](StructureDefinition-DMObservationLaboratoryNeutrophiles.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Lymphocytes](StructureDefinition-DMObservationLaboratoryLymphocytes.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Eosinophiles](StructureDefinition-DMObservationLaboratoryEosinophiles.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Monocytes](StructureDefinition-DMObservationLaboratoryMonocytes.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Taux de prothrombine (TP)](StructureDefinition-DMObservationLaboratoryTP.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Temps de céphaline activée (TCA)](StructureDefinition-DMObservationLaboratoryTCA.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Aspartate aminotransférase (AST)](StructureDefinition-DMObservationLaboratoryASAT.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Gamma-glutamyl transférase (GGT)](StructureDefinition-DMObservationLaboratoryGGT.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Phosphatases alcalines (PAL)](StructureDefinition-DMObservationLaboratoryPAL.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Bilirubine totale](StructureDefinition-DMObservationLaboratoryBilirubineTotale.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Bilirubine conjuguée](StructureDefinition-DMObservationLaboratoryBilirubineConjuguee.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Glycémie à jeun](StructureDefinition-DMObservationLaboratoryGlycemieAJeun.html) | Données d'intérêt |
| Résultats d'examens biologiques | [Hémoglobine glyquée](StructureDefinition-DMObservationLaboratoryHbA1c.html) | Données d'intérêt |
| Exposition médicamenteuse | [Médicament prescrit](StructureDefinition-DMMedicationRequest.html) | Données d'intérêt |
| Exposition médicamenteuse | [Médicament administré](StructureDefinition-DMMedicationAdministration.html) | Données d'intérêt |
| Dossier de soin | [Poids](StructureDefinition-DMObservationBodyWeight.html) | Données d'intérêt |
| Dossier de soin | [Taille](StructureDefinition-DMObservationBodyHeight.html) | Données d'intérêt |
| Dossier de soin | [Pression artérielle](StructureDefinition-DMObservationBloodPressure.html) | Données d'intérêt |
| Style de vie | [Consommation de tabac](StructureDefinition-DMObservationSmokingStatus.html) | Données d'intérêt |
| Style de vie | [Consommation d'alcool](StructureDefinition-DMObservationAlcoholUseStatus.html) | Données d'intérêt |
| Style de vie | [Consommation d'autres drogues](StructureDefinition-DMObservationSubstanceUseStatus.html) | Données d'intérêt |
| Style de vie | [Activité physique](StructureDefinition-DMObservationExerciceStatus.html) | Données d'intérêt |

Indications de lecture : 
- Colonne "Groupe" : Il s'agit souvent d'une information issue du fichier du [GT socle de données](DocumentReference-CoreExigences.html).
- Colonne "Données" : Nom et référence du profil FHIR. 
- Colonne "Caractéristiques" :
  - Données transactionnelles: données qui représentent l'achèvement d'une action ou d'un plan d'action « métier ».  il ne s’agit pas ici de « transaction » au sens informatique de « suite d’opérations modifiant l’état d’une base de données », mais de transaction au sens commercial ; dans notre contexte, un épisode de soin, par exemple, représente une transaction. On distingue :
    - **Données issues de formulaire** : ces données sont restituées sous la forme sous laquelle elles ont été saisies. Leur forte adhérence à des processus de production spécifiques les rend difficilement utilisables pour des agents non au fait desdits processus. 
    - **Données d'intérêt** : ces données ont bénéficié d'une étape de standardisation lors de leur intégration dans le Hub de donnée, ce qui favorise leur réutilisabilité.
  - **Données de références** : il s'agit des données utilisées pour organiser ou catégoriser d'autres données, ou pour relier des données à des informations à l'intérieur et à l'extérieur des limites de l'hôpital. Il s'agit généralement de codes et de descriptions ou de définitions.
  - **Données maîtres** : elles fournissent le contexte des données relatives à l'activité métier sous la forme de concepts communs et abstraits qui se rapportent à l'activité. Elles comprennent les détails (définitions et identifiants) des objets internes et externes impliqués dans les transactions métier, tels que les clients, les produits, les employés, les fournisseurs et les domaines contrôlés (valeurs de code).

### Exemples

#### Cas 1 : ???

TODO

#### Cas 2 : ???

TODO