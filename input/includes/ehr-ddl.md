
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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 patient_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique du patient |
| nom | VARCHAR(255) | - | - | Nom patient (linkId: 8605698058770) |
| prenom | VARCHAR(255) | - | - | Prénom patient (linkId: 6214879623503) |
| nir | VARCHAR(15) | CHECK format | - | Numéro inscription au Répertoire - NIR (linkId: 5711960356160) |
| ins | VARCHAR(50) | - | - | Identité Nationale de Santé - INS (linkId: 3764723550987) |
| date_naissance | DATE | CHECK validité | - | Date de naissance (linkId: 5036133558154) |
| sexe | VARCHAR(20) | CHECK ('h', 'f') | - | Sexe consolidé depuis PMSI (linkId: 3894630481120) |
| date_deces | DATE | CHECK cohérence | - | Date de décès (linkId: 5633552097315) |
| source_deces | VARCHAR(50) | - | - | Source de la date de décès (linkId: 9098810065693) |
| rang_gemellaire | INTEGER | CHECK (1-10) | - | Rang gémellaire du bénéficiaire (linkId: 6931296968515) |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 patient_adresse_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique de l'adresse |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| latitude | DECIMAL(10,7) | CHECK (-90 à 90) | - | Latitude du domicile patient (linkId: 3709843054556) |
| longitude | DECIMAL(10,7) | CHECK (-180 à 180) | - | Longitude du domicile patient (linkId: 7651448032665) |
| code_iris | VARCHAR(20) | - | - | Code IRIS du lieu de résidence |
| libelle_iris | VARCHAR(200) | - | - | Libellé IRIS du lieu de résidence |
| code_geographique_residence | VARCHAR(10) | - | - | Code géographique de résidence |
| libelle_geographique_residence | VARCHAR(200) | - | - | Libellé géographique de résidence |
| date_recueil | DATE | - | - | Date de recueil de l'information |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

**Index spécialisés** :
- `idx_patient_coords_gist` : Index spatial GIST pour les coordonnées géographiques
- `idx_patient_adresse_iris` : Index sur code IRIS
- `idx_patient_adresse_date` : Index composé patient/date de recueil

---

#### Table `donnees_pmsi`

**Description** : Table centrale des données de séjour PMSI (Programme de médicalisation des systèmes d'information) - point de liaison pour toutes les données cliniques (linkId: 2825244231605).

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 pmsi_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique du séjour PMSI |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| mode_sortie | VARCHAR(100) | - | - | Mode de sortie du séjour |
| age_admission | INTEGER | CHECK (0-150) | - | Âge à l'admission (nécessaire si pas de date de naissance) |
| date_debut_sejour | DATE | - | - | Date de début du séjour |
| date_fin_sejour | DATE | CHECK cohérence dates | - | Date de fin du séjour |
| mode_entree | VARCHAR(100) | - | - | Mode d'entrée dans l'établissement |
| etablissement | VARCHAR(255) | - | - | Établissement de soins |
| service | VARCHAR(255) | - | - | Service médical |
| unite_fonctionnelle | VARCHAR(255) | - | - | Unité fonctionnelle |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 diagnostic_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique du diagnostic |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| 🔗 pmsi_id | BIGINT | NOT NULL, FK | - | Référence vers séjour PMSI |
| code_diagnostic | VARCHAR(20) | NOT NULL, CHECK longueur | - | Code diagnostic CIM-10 |
| type_diagnostic | VARCHAR(50) | - | - | Type de diagnostic (principal, associé, etc.) |
| libelle_diagnostic | TEXT | - | - | Libellé descriptif du diagnostic |
| date_recueil | DATE | CHECK ≤ CURRENT_DATE | - | Date de recueil de l'information |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

**Index de recherche** :
- `idx_diagnostics_pmsi_id` : Index sur pmsi_id
- `idx_diagnostics_code` : Index sur code diagnostic
- `idx_diagnostics_type` : Index sur type de diagnostic
- `idx_diagnostics_pmsi_code` : Index composé pmsi/code
- `idx_diagnostics_patient_code` : Index composé patient/code/date

---

#### Table `actes`

**Description** : Actes médicaux et procédures réalisés durant les séjours utilisant les classifications CCAM et autres standards (linkId: 591926901726).

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 acte_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique de l'acte |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| 🔗 pmsi_id | BIGINT | NOT NULL, FK | - | Référence vers séjour PMSI |
| code_acte | VARCHAR(20) | NOT NULL, CHECK longueur | - | Code de l'acte médical (CCAM, etc.) |
| libelle_acte | TEXT | - | - | Libellé descriptif de l'acte |
| date_acte | TIMESTAMP | CHECK ≤ CURRENT_TIMESTAMP | - | Date et heure de réalisation de l'acte |
| executant | VARCHAR(255) | - | - | Professionnel exécutant (non prévu dans le socle) |
| date_recueil | DATE | CHECK ≤ CURRENT_DATE | - | Date de recueil de l'information |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 biologie_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique du résultat biologique |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| code_loinc | VARCHAR(20) | - | - | Code LOINC identifiant le test biologique |
| libelle_test | VARCHAR(255) | - | - | Libellé descriptif du test |
| type_examen | VARCHAR(100) | CHECK types valides | - | Type examen: fonction_renale, bilan_hepatique, hemogramme, autres |
| valeur | DECIMAL(15,6) | CHECK ≥ 0 | - | Valeur numérique du résultat |
| unite | VARCHAR(50) | - | - | Unité de mesure |
| valeur_texte | TEXT | - | - | Valeur textuelle du résultat |
| date_prelevement | TIMESTAMP WITH TIME ZONE | CHECK ≤ CURRENT_TIMESTAMP | - | Date et heure du prélèvement |
| statut_validation | VARCHAR(50) | CHECK valeurs valides | - | Statut de validation (en_attente, valide, rejete, en_cours) |
| borne_inf_normale | DECIMAL(15,6) | CHECK cohérence bornes | - | Borne inférieure de normalité |
| borne_sup_normale | DECIMAL(15,6) | CHECK cohérence bornes | - | Borne supérieure de normalité |
| laboratoire | VARCHAR(255) | - | - | Laboratoire d'analyse (non prévu dans le socle) |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 prescription_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique de la prescription |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| prescripteur | VARCHAR(50) | - | - | Professionnel prescripteur |
| denomination | VARCHAR(255) | - | - | Dénomination du médicament |
| code_atc | VARCHAR(20) | - | - | Code ATC du médicament |
| voie_administration | VARCHAR(100) | - | - | Voie d'administration prévue |
| date_prescription | DATE | - | - | Date de la prescription (non prévu dans le socle) |
| date_debut_prescription | DATE | CHECK cohérence dates | - | Date de début de la prescription |
| date_fin_prescription | DATE | CHECK cohérence dates | - | Date de fin de la prescription |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 posologie_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique de la posologie |
| 🔗 prescription_id | BIGINT | NOT NULL, FK | - | Référence vers prescription |
| nombre_prises_par_jour | INTEGER | CHECK (1-24) | - | Nombre de prises par jour |
| quantite | DECIMAL(10,3) | CHECK > 0 | - | Quantité par prise |
| unite_quantite | VARCHAR(20) | - | - | Unité de la quantité |
| date_heure_debut | TIMESTAMP | CHECK cohérence dates | - | Date et heure de début |
| date_heure_fin | TIMESTAMP | CHECK cohérence dates | - | Date et heure de fin |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

---

#### Table `administration`

**Description** : Données d'exposition médicamenteuse avec codage ATC pour la pharmacovigilance et la recherche clinique, traçant les administrations réelles (linkId: 817801935685).

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 administration_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique de l'administration |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| 🔗 prescription_id | BIGINT | FK | - | Référence vers prescription (optionnelle) |
| denomination | VARCHAR(255) | - | - | Dénomination du médicament administré |
| code_atc | VARCHAR(20) | - | - | Code ATC du médicament |
| voie_administration | VARCHAR(100) | - | - | Voie d'administration réelle |
| quantite | DECIMAL(10,3) | CHECK > 0 | - | Quantité administrée |
| unite_quantite | VARCHAR(20) | - | - | Unité de la quantité |
| date_heure_debut | TIMESTAMP | CHECK cohérence dates | - | Date et heure de début d'administration |
| date_heure_fin | TIMESTAMP | CHECK cohérence dates | - | Date et heure de fin d'administration |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 soin_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique de l'observation |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| code_loinc | VARCHAR(20) | - | - | Code LOINC de l'observation |
| libelle_test | VARCHAR(255) | - | - | Libellé de l'observation |
| valeur | DECIMAL(15,6) | CHECK ≥ 0 | - | Valeur numérique mesurée |
| unite | VARCHAR(50) | - | - | Unité de mesure |
| valeur_code | VARCHAR(50) | - | - | Valeur codée |
| valeur_texte | TEXT | - | - | Valeur textuelle |
| date_mesure | DATE | CHECK ≤ CURRENT_DATE | - | Date de la mesure |
| unite_soins | VARCHAR(255) | - | - | Unité de soins (non prévu dans le socle) |
| professionnel | VARCHAR(255) | - | - | Professionnel réalisant la mesure (non prévu dans le socle) |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

**Index de soins** :
- `idx_soins_patient_id` : Index sur patient_id
- `idx_soins_loinc` : Index sur code LOINC
- `idx_soins_date_mesure` : Index sur date de mesure
- `idx_dossier_soins_timeline` : Index chronologique optimisé

---

#### Table `style_vie`

**Description** : Informations consolidées sur le mode de vie incluant tabac, alcool, drogues et activité physique (linkId: 1693164086678).

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 style_vie_id | BIGSERIAL | PRIMARY KEY | - | Identifiant unique du style de vie |
| 🔗 patient_id | BIGINT | NOT NULL, FK | - | Référence vers patient |
| consommation_tabac | VARCHAR(100) | - | - | Information sur la consommation de tabac |
| consommation_alcool | VARCHAR(100) | - | - | Information sur la consommation d'alcool |
| consommation_autres_drogues | VARCHAR(100) | - | - | Information sur la consommation d'autres drogues |
| activite_physique | VARCHAR(100) | - | - | Information sur l'activité physique |
| date_recueil | DATE | CHECK ≤ CURRENT_DATE | - | Date de recueil de l'information |
| created_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de création |
| updated_at | TIMESTAMP WITH TIME ZONE | - | CURRENT_TIMESTAMP | Horodatage de dernière modification |
{: .grid}

---

### Matrice des Relations

| Table Source | Colonne | Table Référencée | Colonne Référencée | Type de Relation | Action DELETE |
|--------------|---------|------------------|-------------------|------------------|---------------|
| patient_adresse | patient_id | patient | patient_id | 1:N | CASCADE |
| donnees_pmsi | patient_id | patient | patient_id | 1:N | CASCADE |
| diagnostics | patient_id | patient | patient_id | 1:N | CASCADE |
| diagnostics | pmsi_id | donnees_pmsi | pmsi_id | 1:N | CASCADE |
| actes | patient_id | patient | patient_id | 1:N | CASCADE |
| actes | pmsi_id | donnees_pmsi | pmsi_id | 1:N | CASCADE |
| biologie | patient_id | patient | patient_id | 1:N | CASCADE |
| prescription | patient_id | patient | patient_id | 1:N | CASCADE |
| posologie | prescription_id | prescription | prescription_id | 1:N | CASCADE |
| administration | patient_id | patient | patient_id | 1:N | CASCADE |
| administration | prescription_id | prescription | prescription_id | 1:N | RESTRICT |
| dossier_soins | patient_id | patient | patient_id | 1:N | CASCADE |
| style_vie | patient_id | patient | patient_id | 1:N | CASCADE |
{: .grid}

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

*Documentation générée automatiquement à partir du script DDL PostgreSQL pour les variables du socle EDSH*