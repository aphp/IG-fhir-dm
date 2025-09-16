
### Vue d'ensemble

Cette documentation décrit le schéma de base de données PostgreSQL optimisé pour le stockage des variables du socle EDSH (Entrepôt de Données de Santé en répartition), généré à partir du questionnaire FHIR `Questionnaire-UsageCore.json`.

Le schéma implémente une architecture relationnelle normalisée permettant de stocker l'ensemble des données de santé core définies dans le questionnaire FHIR, avec un focus sur l'interopérabilité et les performances d'interrogation.

#### Architecture générale

Le schéma comprend **11 tables principales** organisées autour de l'entité centrale `patient` :

- **patient** : Données démographiques et identité
- **patient_adresse** : Informations de géolocalisation
- **donnees_pmsi** : Données de séjours et prises en charge (table de liaison centrale)
- **diagnostics** : Codes diagnostiques CIM-10
- **actes** : Actes médicaux et procédures CCAM
- **biologie** : Résultats d'examens biologiques consolidés
- **prescription** : Prescriptions médicamenteuses
- **administration** : Administrations médicamenteuses réelles
- **posologie** : Détails de posologie
- **dossier_soins** : Observations et mesures cliniques
- **style_vie** : Facteurs de mode de vie

---

#### Schéma Entité/Relation

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div class="viewer-container" style="height: 520px;">
  <div class="svg-container" id="physical-model">
    {% include ehr-datamodel.svg %}
  </div>
</div>

### Documentation des Tables

#### Table `patient`

**Description** : Table consolidée des informations démographiques et d'identité patient, combinant les éléments d'identité (linkId: 2958000860428) et de géocodage (linkId: 5491974639955) du questionnaire FHIR.

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 patient_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique du patient</td>
    </tr>
    <tr>
      <td>nom</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Nom patient (linkId: 8605698058770)</td>
    </tr>
    <tr>
      <td>prenom</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Prénom patient (linkId: 6214879623503)</td>
    </tr>
    <tr>
      <td>nir</td>
      <td>VARCHAR(15)</td>
      <td>CHECK format</td>
      <td>-</td>
      <td>Numéro inscription au Répertoire - NIR (linkId: 5711960356160)</td>
    </tr>
    <tr>
      <td>ins</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Identité Nationale de Santé - INS (linkId: 3764723550987)</td>
    </tr>
    <tr>
      <td>date_naissance</td>
      <td>DATE</td>
      <td>CHECK validité</td>
      <td>-</td>
      <td>Date de naissance (linkId: 5036133558154)</td>
    </tr>
    <tr>
      <td>sexe</td>
      <td>VARCHAR(20)</td>
      <td>CHECK ('h', 'f')</td>
      <td>-</td>
      <td>Sexe consolidé depuis PMSI (linkId: 3894630481120)</td>
    </tr>
    <tr>
      <td>date_deces</td>
      <td>DATE</td>
      <td>CHECK cohérence</td>
      <td>-</td>
      <td>Date de décès (linkId: 5633552097315)</td>
    </tr>
    <tr>
      <td>source_deces</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Source de la date de décès (linkId: 9098810065693)</td>
    </tr>
    <tr>
      <td>rang_gemellaire</td>
      <td>INTEGER</td>
      <td>CHECK (1-10)</td>
      <td>-</td>
      <td>Rang gémellaire du bénéficiaire (linkId: 6931296968515)</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index principaux** :
- `idx_patient_nir` : Index sur NIR (WHERE nir IS NOT NULL)
- `idx_patient_ins` : Index sur INS (WHERE ins IS NOT NULL)
- `idx_patient_nom_prenom` : Index composé nom/prénom
- `idx_patient_date_naissance` : Index sur date de naissance
- `idx_patient_search` : Index GIN pour recherche textuelle française
- `idx_patient_nir_hash` : Index de hachage pour recherche exacte NIR
- `idx_patient_ins_hash` : Index de hachage pour recherche exacte INS

---

#### Table `patient_adresse`

**Description** : Informations de géolocalisation et adressage patient (linkId: 5491974639955).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 patient_adresse_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique de l'adresse</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>latitude</td>
      <td>DECIMAL(10,7)</td>
      <td>CHECK (-90 à 90)</td>
      <td>-</td>
      <td>Latitude du domicile patient (linkId: 3709843054556)</td>
    </tr>
    <tr>
      <td>longitude</td>
      <td>DECIMAL(10,7)</td>
      <td>CHECK (-180 à 180)</td>
      <td>-</td>
      <td>Longitude du domicile patient (linkId: 7651448032665)</td>
    </tr>
    <tr>
      <td>code_iris</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Code IRIS du lieu de résidence</td>
    </tr>
    <tr>
      <td>libelle_iris</td>
      <td>VARCHAR(200)</td>
      <td>-</td>
      <td>-</td>
      <td>Libellé IRIS du lieu de résidence</td>
    </tr>
    <tr>
      <td>code_geographique_residence</td>
      <td>VARCHAR(10)</td>
      <td>-</td>
      <td>-</td>
      <td>Code géographique de résidence</td>
    </tr>
    <tr>
      <td>libelle_geographique_residence</td>
      <td>VARCHAR(200)</td>
      <td>-</td>
      <td>-</td>
      <td>Libellé géographique de résidence</td>
    </tr>
    <tr>
      <td>date_recueil</td>
      <td>DATE</td>
      <td>-</td>
      <td>-</td>
      <td>Date de recueil de l'information</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index spécialisés** :
- `idx_patient_coords_gist` : Index spatial GIST pour les coordonnées géographiques
- `idx_patient_adresse_iris` : Index sur code IRIS
- `idx_patient_adresse_date` : Index composé patient/date de recueil

---

#### Table `donnees_pmsi`

**Description** : Table centrale des données de séjour PMSI (Programme de médicalisation des systèmes d'information) - point de liaison pour toutes les données cliniques (linkId: 2825244231605).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 pmsi_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique du séjour PMSI</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>mode_sortie</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Mode de sortie du séjour</td>
    </tr>
    <tr>
      <td>age_admission</td>
      <td>INTEGER</td>
      <td>CHECK (0-150)</td>
      <td>-</td>
      <td>Âge à l'admission (nécessaire si pas de date de naissance)</td>
    </tr>
    <tr>
      <td>date_debut_sejour</td>
      <td>DATE</td>
      <td>-</td>
      <td>-</td>
      <td>Date de début du séjour</td>
    </tr>
    <tr>
      <td>date_fin_sejour</td>
      <td>DATE</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date de fin du séjour</td>
    </tr>
    <tr>
      <td>mode_entree</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Mode d'entrée dans l'établissement</td>
    </tr>
    <tr>
      <td>etablissement</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Établissement de soins</td>
    </tr>
    <tr>
      <td>service</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Service médical</td>
    </tr>
    <tr>
      <td>unite_fonctionnelle</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Unité fonctionnelle</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index de performance** :
- `idx_pmsi_patient_id` : Index sur patient_id
- `idx_pmsi_date_debut` : Index sur date de début de séjour
- `idx_pmsi_date_fin` : Index sur date de fin de séjour
- `idx_pmsi_etablissement` : Index sur établissement
- `idx_pmsi_patient_date` : Index composé patient/date de début
- `idx_pmsi_covering` : Index couvrant avec INCLUDE
- `idx_pmsi_duree_sejour` : Index calculé sur la durée de séjour

---

#### Table `diagnostics`

**Description** : Codes diagnostiques et informations liées aux séjours utilisant les classifications CIM-10 (linkId: 9391816419630).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 diagnostic_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique du diagnostic</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>🔗 pmsi_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers séjour PMSI</td>
    </tr>
    <tr>
      <td>code_diagnostic</td>
      <td>VARCHAR(20)</td>
      <td>NOT NULL, CHECK longueur</td>
      <td>-</td>
      <td>Code diagnostic CIM-10</td>
    </tr>
    <tr>
      <td>type_diagnostic</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Type de diagnostic (principal, associé, etc.)</td>
    </tr>
    <tr>
      <td>libelle_diagnostic</td>
      <td>TEXT</td>
      <td>-</td>
      <td>-</td>
      <td>Libellé descriptif du diagnostic</td>
    </tr>
    <tr>
      <td>date_recueil</td>
      <td>DATE</td>
      <td>CHECK ≤ CURRENT_DATE</td>
      <td>-</td>
      <td>Date de recueil de l'information</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index de recherche** :
- `idx_diagnostics_pmsi_id` : Index sur pmsi_id
- `idx_diagnostics_code` : Index sur code diagnostic
- `idx_diagnostics_type` : Index sur type de diagnostic
- `idx_diagnostics_pmsi_code` : Index composé pmsi/code
- `idx_diagnostics_patient_code` : Index composé patient/code/date

---

#### Table `actes`

**Description** : Actes médicaux et procédures réalisés durant les séjours utilisant les classifications CCAM et autres standards (linkId: 591926901726).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 acte_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique de l'acte</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>🔗 pmsi_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers séjour PMSI</td>
    </tr>
    <tr>
      <td>code_acte</td>
      <td>VARCHAR(20)</td>
      <td>NOT NULL, CHECK longueur</td>
      <td>-</td>
      <td>Code de l'acte médical (CCAM, etc.)</td>
    </tr>
    <tr>
      <td>libelle_acte</td>
      <td>TEXT</td>
      <td>-</td>
      <td>-</td>
      <td>Libellé descriptif de l'acte</td>
    </tr>
    <tr>
      <td>date_acte</td>
      <td>TIMESTAMP</td>
      <td>CHECK ≤ CURRENT_TIMESTAMP</td>
      <td>-</td>
      <td>Date et heure de réalisation de l'acte</td>
    </tr>
    <tr>
      <td>executant</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Professionnel exécutant (non prévu dans le socle)</td>
    </tr>
    <tr>
      <td>date_recueil</td>
      <td>DATE</td>
      <td>CHECK ≤ CURRENT_DATE</td>
      <td>-</td>
      <td>Date de recueil de l'information</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index optimisés** :
- `idx_actes_pmsi_id` : Index sur pmsi_id
- `idx_actes_code` : Index sur code d'acte
- `idx_actes_date` : Index sur date d'acte
- `idx_actes_date_recueil` : Index sur date de recueil
- `idx_actes_pmsi_code` : Index composé pmsi/code
- `idx_actes_patient_code` : Index composé patient/code/date

---

#### Table `biologie`

**Description** : Table consolidée des résultats d'examens biologiques, différenciés par codes LOINC et types d'examens incluant fonction rénale, bilan hépatique, hémogramme et autres tests (linkId: 7702944131447).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 biologie_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique du résultat biologique</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>code_loinc</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Code LOINC identifiant le test biologique</td>
    </tr>
    <tr>
      <td>libelle_test</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Libellé descriptif du test</td>
    </tr>
    <tr>
      <td>type_examen</td>
      <td>VARCHAR(100)</td>
      <td>CHECK types valides</td>
      <td>-</td>
      <td>Type examen: fonction_renale, bilan_hepatique, hemogramme, autres</td>
    </tr>
    <tr>
      <td>valeur</td>
      <td>DECIMAL(15,6)</td>
      <td>CHECK ≥ 0</td>
      <td>-</td>
      <td>Valeur numérique du résultat</td>
    </tr>
    <tr>
      <td>unite</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Unité de mesure</td>
    </tr>
    <tr>
      <td>valeur_texte</td>
      <td>TEXT</td>
      <td>-</td>
      <td>-</td>
      <td>Valeur textuelle du résultat</td>
    </tr>
    <tr>
      <td>date_prelevement</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>CHECK ≤ CURRENT_TIMESTAMP</td>
      <td>-</td>
      <td>Date et heure du prélèvement</td>
    </tr>
    <tr>
      <td>statut_validation</td>
      <td>VARCHAR(50)</td>
      <td>CHECK valeurs valides</td>
      <td>-</td>
      <td>Statut de validation (en_attente, valide, rejete, en_cours)</td>
    </tr>
    <tr>
      <td>borne_inf_normale</td>
      <td>DECIMAL(15,6)</td>
      <td>CHECK cohérence bornes</td>
      <td>-</td>
      <td>Borne inférieure de normalité</td>
    </tr>
    <tr>
      <td>borne_sup_normale</td>
      <td>DECIMAL(15,6)</td>
      <td>CHECK cohérence bornes</td>
      <td>-</td>
      <td>Borne supérieure de normalité</td>
    </tr>
    <tr>
      <td>laboratoire</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Laboratoire d'analyse (non prévu dans le socle)</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index spécialisés pour biologie** :
- `idx_biologie_patient_id` : Index sur patient_id
- `idx_biologie_code_loinc` : Index sur code LOINC
- `idx_biologie_type_examen` : Index sur type d'examen
- `idx_biologie_date_prelevement` : Index sur date de prélèvement
- `idx_biologie_statut_validation` : Index sur statut de validation
- `idx_biologie_patient_loinc` : Index composé patient/LOINC
- `idx_biologie_patient_type` : Index composé patient/type
- `idx_biologie_covering` : Index couvrant avec INCLUDE
- `idx_biologie_loinc_hash` : Index de hachage pour recherche exacte LOINC
- `idx_biologie_valeur_non_null` : Index partiel sur valeurs non nulles
- `idx_biologie_date_patient` : Index optimisé date/patient

---

#### Table `prescription`

**Description** : Données de prescription médicamenteuse avec codage ATC pour la pharmacovigilance et la recherche clinique (linkId: 817801935685).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 prescription_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique de la prescription</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>prescripteur</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Professionnel prescripteur</td>
    </tr>
    <tr>
      <td>denomination</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Dénomination du médicament</td>
    </tr>
    <tr>
      <td>code_atc</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Code ATC du médicament</td>
    </tr>
    <tr>
      <td>voie_administration</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Voie d'administration prévue</td>
    </tr>
    <tr>
      <td>date_prescription</td>
      <td>DATE</td>
      <td>-</td>
      <td>-</td>
      <td>Date de la prescription (non prévu dans le socle)</td>
    </tr>
    <tr>
      <td>date_debut_prescription</td>
      <td>DATE</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date de début de la prescription</td>
    </tr>
    <tr>
      <td>date_fin_prescription</td>
      <td>DATE</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date de fin de la prescription</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index de prescription** :
- `idx_prescription_patient_id` : Index sur patient_id
- `idx_prescription_code_atc` : Index sur code ATC
- `idx_prescription_date_prescription` : Index sur date de prescription
- `idx_prescription_patient_atc` : Index composé patient/ATC
- `idx_prescription_covering` : Index couvrant avec INCLUDE
- `idx_prescription_atc_hash` : Index de hachage pour recherche exacte ATC
- `idx_prescription_active` : Index partiel sur prescriptions actives
- `idx_prescription_period` : Index sur période de prescription

---

#### Table `posologie`

**Description** : Informations détaillées de posologie pour les médicaments (linkId: 6348237104421).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 posologie_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique de la posologie</td>
    </tr>
    <tr>
      <td>🔗 prescription_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers prescription</td>
    </tr>
    <tr>
      <td>nombre_prises_par_jour</td>
      <td>INTEGER</td>
      <td>CHECK (1-24)</td>
      <td>-</td>
      <td>Nombre de prises par jour</td>
    </tr>
    <tr>
      <td>quantite</td>
      <td>DECIMAL(10,3)</td>
      <td>CHECK > 0</td>
      <td>-</td>
      <td>Quantité par prise</td>
    </tr>
    <tr>
      <td>unite_quantite</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Unité de la quantité</td>
    </tr>
    <tr>
      <td>date_heure_debut</td>
      <td>TIMESTAMP</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date et heure de début</td>
    </tr>
    <tr>
      <td>date_heure_fin</td>
      <td>TIMESTAMP</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date et heure de fin</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

---

#### Table `administration`

**Description** : Données d'exposition médicamenteuse avec codage ATC pour la pharmacovigilance et la recherche clinique, traçant les administrations réelles (linkId: 817801935685).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 administration_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique de l'administration</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>🔗 prescription_id</td>
      <td>BIGINT</td>
      <td>FK</td>
      <td>-</td>
      <td>Référence vers prescription (optionnelle)</td>
    </tr>
    <tr>
      <td>denomination</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Dénomination du médicament administré</td>
    </tr>
    <tr>
      <td>code_atc</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Code ATC du médicament</td>
    </tr>
    <tr>
      <td>voie_administration</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Voie d'administration réelle</td>
    </tr>
    <tr>
      <td>quantite</td>
      <td>DECIMAL(10,3)</td>
      <td>CHECK > 0</td>
      <td>-</td>
      <td>Quantité administrée</td>
    </tr>
    <tr>
      <td>unite_quantite</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Unité de la quantité</td>
    </tr>
    <tr>
      <td>date_heure_debut</td>
      <td>TIMESTAMP</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date et heure de début d'administration</td>
    </tr>
    <tr>
      <td>date_heure_fin</td>
      <td>TIMESTAMP</td>
      <td>CHECK cohérence dates</td>
      <td>-</td>
      <td>Date et heure de fin d'administration</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index d'administration** :
- `idx_administration_patient_id` : Index sur patient_id
- `idx_administration_code_atc` : Index sur code ATC
- `idx_administration_denomination` : Index sur dénomination
- `idx_administration_date_heure_debut` : Index sur date de début
- `idx_administration_atc_hash` : Index de hachage pour recherche exacte ATC
- `idx_administration_timeline` : Index chronologique optimisé

---

#### Table `dossier_soins`

**Description** : Mesures et observations cliniques incluant signes vitaux, mesures physiques et données de soins infirmiers (linkId: 305831246173).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 soin_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique de l'observation</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>code_loinc</td>
      <td>VARCHAR(20)</td>
      <td>-</td>
      <td>-</td>
      <td>Code LOINC de l'observation</td>
    </tr>
    <tr>
      <td>libelle_test</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Libellé de l'observation</td>
    </tr>
    <tr>
      <td>valeur</td>
      <td>DECIMAL(15,6)</td>
      <td>CHECK ≥ 0</td>
      <td>-</td>
      <td>Valeur numérique mesurée</td>
    </tr>
    <tr>
      <td>unite</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Unité de mesure</td>
    </tr>
    <tr>
      <td>valeur_code</td>
      <td>VARCHAR(50)</td>
      <td>-</td>
      <td>-</td>
      <td>Valeur codée</td>
    </tr>
    <tr>
      <td>valeur_texte</td>
      <td>TEXT</td>
      <td>-</td>
      <td>-</td>
      <td>Valeur textuelle</td>
    </tr>
    <tr>
      <td>date_mesure</td>
      <td>DATE</td>
      <td>CHECK ≤ CURRENT_DATE</td>
      <td>-</td>
      <td>Date de la mesure</td>
    </tr>
    <tr>
      <td>unite_soins</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Unité de soins (non prévu dans le socle)</td>
    </tr>
    <tr>
      <td>professionnel</td>
      <td>VARCHAR(255)</td>
      <td>-</td>
      <td>-</td>
      <td>Professionnel réalisant la mesure (non prévu dans le socle)</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

**Index de soins** :
- `idx_soins_patient_id` : Index sur patient_id
- `idx_soins_loinc` : Index sur code LOINC
- `idx_soins_date_mesure` : Index sur date de mesure
- `idx_dossier_soins_timeline` : Index chronologique optimisé

---

#### Table `style_vie`

**Description** : Informations consolidées sur le mode de vie incluant tabac, alcool, drogues et activité physique (linkId: 1693164086678).

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Colonne</th>
      <th>Type</th>
      <th>Contraintes</th>
      <th>Défaut</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🔑 style_vie_id</td>
      <td>BIGSERIAL</td>
      <td>PRIMARY KEY</td>
      <td>-</td>
      <td>Identifiant unique du style de vie</td>
    </tr>
    <tr>
      <td>🔗 patient_id</td>
      <td>BIGINT</td>
      <td>NOT NULL, FK</td>
      <td>-</td>
      <td>Référence vers patient</td>
    </tr>
    <tr>
      <td>consommation_tabac</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Information sur la consommation de tabac</td>
    </tr>
    <tr>
      <td>consommation_alcool</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Information sur la consommation d'alcool</td>
    </tr>
    <tr>
      <td>consommation_autres_drogues</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Information sur la consommation d'autres drogues</td>
    </tr>
    <tr>
      <td>activite_physique</td>
      <td>VARCHAR(100)</td>
      <td>-</td>
      <td>-</td>
      <td>Information sur l'activité physique</td>
    </tr>
    <tr>
      <td>date_recueil</td>
      <td>DATE</td>
      <td>CHECK ≤ CURRENT_DATE</td>
      <td>-</td>
      <td>Date de recueil de l'information</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td>-</td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Horodatage de dernière modification</td>
    </tr>
  </tbody>
</table>

---

### Matrice des Relations

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Table Source</th>
      <th>Colonne</th>
      <th>Table Référencée</th>
      <th>Colonne Référencée</th>
      <th>Type de Relation</th>
      <th>Action DELETE</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>patient_adresse</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>donnees_pmsi</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>diagnostics</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>diagnostics</td>
      <td>pmsi_id</td>
      <td>donnees_pmsi</td>
      <td>pmsi_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>actes</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>actes</td>
      <td>pmsi_id</td>
      <td>donnees_pmsi</td>
      <td>pmsi_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>biologie</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>prescription</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>posologie</td>
      <td>prescription_id</td>
      <td>prescription</td>
      <td>prescription_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>administration</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>administration</td>
      <td>prescription_id</td>
      <td>prescription</td>
      <td>prescription_id</td>
      <td>1:N</td>
      <td>RESTRICT</td>
    </tr>
    <tr>
      <td>dossier_soins</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>style_vie</td>
      <td>patient_id</td>
      <td>patient</td>
      <td>patient_id</td>
      <td>1:N</td>
      <td>CASCADE</td>
    </tr>
  </tbody>
</table>

---

### Règles Métier et Contraintes CHECK

#### Contraintes sur la table `patient`

- **`chk_patient_sexe`** : Le sexe doit être 'h' (homme) ou 'f' (femme)
- **`chk_patient_date_naissance`** : Date de naissance entre 1900-01-01 et la date courante
- **`chk_patient_date_deces`** : Date de décès postérieure à la date de naissance et ≤ date courante
- **`chk_patient_nir_format`** : Format NIR : 13 à 15 chiffres
- **`chk_patient_rang_gemellaire`** : Rang gémellaire entre 1 et 10

#### Contraintes sur la table `patient_adresse`

- **`chk_patient_latitude`** : Latitude entre -90 et 90 degrés
- **`chk_patient_longitude`** : Longitude entre -180 et 180 degrés

#### Contraintes sur la table `donnees_pmsi`

- **`chk_pmsi_dates`** : Date de fin de séjour ≥ date de début de séjour
- **`chk_pmsi_age_admission`** : Âge à l'admission entre 0 et 150 ans

#### Contraintes sur la table `biologie`

- **`chk_biologie_bornes`** : Borne supérieure ≥ borne inférieure
- **`chk_biologie_type_examen`** : Type d'examen parmi 'fonction_renale', 'bilan_hepatique', 'hemogramme', 'autres'
- **`chk_biologie_valeur_positive`** : Valeur ≥ 0
- **`chk_biologie_date_prelevement`** : Date de prélèvement ≤ timestamp actuel
- **`chk_biologie_statut_validation`** : Statut parmi 'en_attente', 'valide', 'rejete', 'en_cours'

#### Contraintes sur les médicaments (`prescription`, `administration`, `posologie`)

- **`chk_prescription_dates`** : Date de fin ≥ date de début de prescription
- **`chk_administration_dates`** : Date/heure de fin ≥ date/heure de début
- **`chk_administration_quantite`** : Quantité > 0
- **`chk_posologie_prises_jour`** : Nombre de prises par jour entre 1 et 24
- **`chk_posologie_quantite`** : Quantité > 0
- **`chk_posologie_dates`** : Date/heure de fin ≥ date/heure de début

#### Contraintes sur les soins et lifestyle

- **`chk_soins_valeur_positive`** : Valeur mesurée ≥ 0
- **`chk_soins_date_mesure`** : Date de mesure ≤ date courante
- **`chk_style_vie_date_recueil`** : Date de recueil ≤ date courante

#### Contraintes sur les données cliniques

- **`chk_diagnostics_code_format`** : Code diagnostic entre 3 et 20 caractères
- **`chk_diagnostics_date_recueil`** : Date de recueil ≤ date courante
- **`chk_actes_code_format`** : Code acte entre 4 et 20 caractères
- **`chk_actes_date_acte`** : Date d'acte ≤ timestamp actuel
- **`chk_actes_date_recueil`** : Date de recueil ≤ date courante

---

### Notes d'Implémentation

#### Conventions de Nommage

- **Tables** : Noms en français, en minuscules avec underscores
- **Clés primaires** : `<table>_id` avec type BIGSERIAL
- **Clés étrangères** : `<table_référencée>_id`
- **Index** : Préfixe `idx_` suivi du nom de table et colonne(s)
- **Contraintes** : Préfixe `chk_`, `fk_` selon le type

#### Considérations Particulières

1. **Dénormalisation contrôlée** : Table biologie consolidée au lieu de tables séparées par type d'examen
2. **Flexibilité temporelle** : Biologie non liée obligatoirement à un séjour PMSI
3. **Extensibilité** : Champs commentés "non prévu dans le socle" pour extensions futures
4. **Audit complet** : Colonnes created_at/updated_at sur toutes les tables
5. **Validation robuste** : Contraintes CHECK pour l'intégrité métier
6. **Performance** : Index spécialisés pour les requêtes analytiques communes

#### Alignement FHIR

Le schéma maintient la traçabilité vers les linkId du questionnaire FHIR original, facilitant :
- Le mapping bidirectionnel avec les ressources FHIR
- La validation de conformité
- L'évolution contrôlée du modèle de données
- L'interopérabilité avec les systèmes FHIR

---

*Documentation générée automatiquement à partir du script DDL PostgreSQL pour les variables du socle EDSH*