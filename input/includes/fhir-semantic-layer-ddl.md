
### Vue d'ensemble

Cette base de données PostgreSQL implémente une couche sémantique FHIR pour la gestion des données de santé françaises. Elle s'appuie sur les ressources FHIR utilisées par les profils DM (Data Management) pour l'interopérabilité et la gestion des données de santé en France.

#### Objectif
Le schéma FSL permet le stockage et la manipulation de données de santé selon les standards FHIR, tout en respectant les spécificités françaises (INS-NIR, CIM-10, CCAM, ATC). Il s'intègre dans l'écosystème des EDS (Entrepôts de Données de Santé) français.

#### Ressources FHIR Couvertes
- **Patient** : Profil patient avec identifiants INS-NIR
- **Encounter** : Interactions de soins et séjours hospitaliers
- **Condition** : Diagnostics et problèmes de santé (CIM-10)
- **Procedure** : Actes médicaux et chirurgicaux (CCAM)
- **Observation** : Résultats de laboratoire et signes vitaux (LOINC)
- **MedicationRequest** : Prescriptions médicamenteuses
- **MedicationAdministration** : Administration de médicaments

#### Conformité Française
- **INS-NIR** : Identifiants nationaux de santé
- **CIM-10** : Classification internationale des maladies
- **CCAM** : Classification commune des actes médicaux
- **PMSI** : Programme de médicalisation des systèmes d'information
- **ATC** : Classification anatomique, thérapeutique et chimique

### Schéma entité/relation

<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div class="viewer-container" style="height: 2016px;">
  <div class="svg-container" id="physical-model">
    {% include fsl-datamodel.svg %}
  </div>
</div>

### Tables de la Base de Données

#### 🏥 fhir_patient

**Description** : Profil Patient du socle commun des EDS. Démographie et informations administratives sur les individus recevant des soins.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Identifiant unique FHIR</td>
    </tr>
    <tr>
      <td>last_updated</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Dernière mise à jour</td>
    </tr>
    <tr>
      <td>active</td>
      <td>BOOLEAN</td>
      <td></td>
      <td></td>
      <td>Si l'enregistrement patient est actif</td>
    </tr>
    <tr>
      <td>identifiers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiants métier (tableau)</td>
    </tr>
    <tr>
      <td>nss_identifier</td>
      <td>VARCHAR(50)</td>
      <td>CHECK format</td>
      <td></td>
      <td>NSS - Numéro de Sécurité Sociale</td>
    </tr>
    <tr>
      <td>ins_nir_identifier</td>
      <td>VARCHAR(15)</td>
      <td>CHECK format</td>
      <td></td>
      <td>INS-NIR - Identifiant national de santé</td>
    </tr>
    <tr>
      <td>names</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Noms associés au patient</td>
    </tr>
    <tr>
      <td>full_names</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Représentation structurée des noms</td>
    </tr>
    <tr>
      <td>gender</td>
      <td>VARCHAR(10)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Genre administratif</td>
    </tr>
    <tr>
      <td>birth_date</td>
      <td>DATE</td>
      <td>CHECK range</td>
      <td></td>
      <td>Date de naissance</td>
    </tr>
    <tr>
      <td>deceased_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Information de décès</td>
    </tr>
    <tr>
      <td>deceased_date_time</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Date et heure de décès</td>
    </tr>
    <tr>
      <td>deceased_extension_death_source</td>
      <td>VARCHAR(10)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Source d'information de décès</td>
    </tr>
    <tr>
      <td>marital_status</td>
      <td>VARCHAR(4)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Statut marital</td>
    </tr>
    <tr>
      <td>address</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Adresses physiques</td>
    </tr>
    <tr>
      <td>address_extension_geolocation_latitude</td>
      <td>FLOAT</td>
      <td>CHECK range</td>
      <td></td>
      <td>Latitude de géolocalisation</td>
    </tr>
    <tr>
      <td>address_extension_geolocation_longitude</td>
      <td>FLOAT</td>
      <td>CHECK range</td>
      <td></td>
      <td>Longitude de géolocalisation</td>
    </tr>
    <tr>
      <td>address_extension_census_tract</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Code IRIS du recensement</td>
    </tr>
    <tr>
      <td>address_period_start</td>
      <td>DATE</td>
      <td></td>
      <td></td>
      <td>Date de début de validité d'adresse</td>
    </tr>
    <tr>
      <td>address_extension_pmsi_code_geo</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Extension code géographique PMSI</td>
    </tr>
    <tr>
      <td>address_extension_pmsi_code_geo_code</td>
      <td>VARCHAR(5)</td>
      <td>CHECK format</td>
      <td></td>
      <td>Code géographique PMSI</td>
    </tr>
    <tr>
      <td>telecoms</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Coordonnées de contact</td>
    </tr>
    <tr>
      <td>contacts</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Contacts d'urgence et tuteurs</td>
    </tr>
    <tr>
      <td>communications</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Langues de communication</td>
    </tr>
    <tr>
      <td>preferred_communication_languages</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Langues préférées</td>
    </tr>
    <tr>
      <td>multiple_birth_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Information sur naissance multiple</td>
    </tr>
    <tr>
      <td>multiple_birth_integer</td>
      <td>INTEGER</td>
      <td>CHECK range</td>
      <td></td>
      <td>Rang gémellaire</td>
    </tr>
    <tr>
      <td>general_practitioners</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Médecins traitants</td>
    </tr>
    <tr>
      <td>managing_organization</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Organisation gestionnaire</td>
    </tr>
    <tr>
      <td>links</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Liens vers autres patients</td>
    </tr>
    <tr>
      <td>meta</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Métadonnées FHIR</td>
    </tr>
    <tr>
      <td>implicit_rules</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Règles implicites</td>
    </tr>
    <tr>
      <td>resource_language</td>
      <td>VARCHAR(10)</td>
      <td></td>
      <td></td>
      <td>Langue de la ressource</td>
    </tr>
    <tr>
      <td>text_div</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Résumé textuel</td>
    </tr>
    <tr>
      <td>contained</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Ressources contenues</td>
    </tr>
    <tr>
      <td>extensions</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Extensions</td>
    </tr>
    <tr>
      <td>modifier_extensions</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Extensions modificatrices</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_patient_identifiers` : Index GIN sur identifiers
- `idx_patient_nss` : Index sur NSS
- `idx_patient_ins_nir` : Index sur INS-NIR
- `idx_patient_coordinates_gist` : Index spatial sur coordonnées
- `idx_patient_names_search` : Index de recherche textuelle française

**Règles Métier :**
- Date de naissance entre 1900 et aujourd'hui
- Coordonnées GPS valides (-90/90 pour latitude, -180/180 pour longitude)
- Format NSS : 13-15 chiffres
- Format INS-NIR : 15 chiffres exactement

#### 🏥 fhir_encounter

**Description** : Interaction entre un patient et des prestataires de soins pour fournir des services de santé.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Identifiant unique FHIR</td>
    </tr>
    <tr>
      <td>last_updated</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Dernière mise à jour</td>
    </tr>
    <tr>
      <td>status</td>
      <td>VARCHAR(20)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>État actuel de la rencontre</td>
    </tr>
    <tr>
      <td>status_history</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Historique des statuts</td>
    </tr>
    <tr>
      <td>class</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Classification de la rencontre</td>
    </tr>
    <tr>
      <td>class_display</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte d'affichage de la classe</td>
    </tr>
    <tr>
      <td>class_history</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Historique des classes</td>
    </tr>
    <tr>
      <td>types</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Types spécifiques de rencontre</td>
    </tr>
    <tr>
      <td>service_type</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Catégorisation large du service</td>
    </tr>
    <tr>
      <td>priority</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Urgence de la rencontre</td>
    </tr>
    <tr>
      <td>identifiers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiants métier</td>
    </tr>
    <tr>
      <td>subject</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Patient ou groupe présent</td>
    </tr>
    <tr>
      <td>🔗 subject_patient_id</td>
      <td>VARCHAR(64)</td>
      <td>NOT NULL, FK</td>
      <td></td>
      <td>Référence obligatoire au patient</td>
    </tr>
    <tr>
      <td>episodes_of_care</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Épisodes de soins</td>
    </tr>
    <tr>
      <td>based_on_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Rendez-vous planifiés</td>
    </tr>
    <tr>
      <td>participants</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Personnes impliquées</td>
    </tr>
    <tr>
      <td>appointments</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Rendez-vous</td>
    </tr>
    <tr>
      <td>period_start</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Heure de début</td>
    </tr>
    <tr>
      <td>period_end</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Heure de fin</td>
    </tr>
    <tr>
      <td>length</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Durée de la rencontre</td>
    </tr>
    <tr>
      <td>length_number_of_day</td>
      <td>INTEGER</td>
      <td>CHECK ≥ 0</td>
      <td></td>
      <td>Durée en jours</td>
    </tr>
    <tr>
      <td>reason_codes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Raisons codées</td>
    </tr>
    <tr>
      <td>reason_references</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Références aux raisons</td>
    </tr>
    <tr>
      <td>diagnoses</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Diagnostics</td>
    </tr>
    <tr>
      <td>account</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Comptes</td>
    </tr>
    <tr>
      <td>hospitalization</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Détails d'hospitalisation</td>
    </tr>
    <tr>
      <td>admit_source_text</td>
      <td>VARCHAR(255)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Source d'admission</td>
    </tr>
    <tr>
      <td>discharge_disposition_text</td>
      <td>VARCHAR(255)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Disposition de sortie</td>
    </tr>
    <tr>
      <td>locations</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Emplacements</td>
    </tr>
    <tr>
      <td>service_provider</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Prestataire de service</td>
    </tr>
    <tr>
      <td>service_provider_organization_display</td>
      <td>VARCHAR(64)</td>
      <td></td>
      <td></td>
      <td>Nom d'affichage du prestataire</td>
    </tr>
    <tr>
      <td>part_of</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Rencontre parent</td>
    </tr>
    <tr>
      <td>[Métadonnées FHIR standard]</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_encounter_patient` : Index sur subject_patient_id
- `idx_encounter_period` : Index temporel sur période
- `idx_encounter_status` : Index sur statut
- `idx_encounter_class` : Index GIN sur classe

**Règles Métier :**
- Période de fin ≥ période de début
- Durée en jours ≥ 0
- Période de début ≤ demain

#### 🏥 fhir_condition

**Description** : Condition clinique, problème, diagnostic ou autre événement de préoccupation clinique.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Identifiant unique FHIR</td>
    </tr>
    <tr>
      <td>last_updated</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Dernière mise à jour</td>
    </tr>
    <tr>
      <td>clinical_status</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Statut clinique de la condition</td>
    </tr>
    <tr>
      <td>clinical_status_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte du statut clinique</td>
    </tr>
    <tr>
      <td>verification_status</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Statut de vérification</td>
    </tr>
    <tr>
      <td>verification_status_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte du statut de vérification</td>
    </tr>
    <tr>
      <td>categories</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Catégories assignées</td>
    </tr>
    <tr>
      <td>categories_text</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Texte des catégories</td>
    </tr>
    <tr>
      <td>severity</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Sévérité subjective</td>
    </tr>
    <tr>
      <td>code</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identification de la condition (CIM-10)</td>
    </tr>
    <tr>
      <td>code_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte du code</td>
    </tr>
    <tr>
      <td>body_sites</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Localisation anatomique</td>
    </tr>
    <tr>
      <td>identifiers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiants métier</td>
    </tr>
    <tr>
      <td>subject</td>
      <td>JSONB</td>
      <td>NOT NULL</td>
      <td></td>
      <td>Patient concerné</td>
    </tr>
    <tr>
      <td>🔗 subject_patient_id</td>
      <td>VARCHAR(64)</td>
      <td>NOT NULL, FK</td>
      <td></td>
      <td>Référence au patient</td>
    </tr>
    <tr>
      <td>encounter</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Rencontre d'assertion</td>
    </tr>
    <tr>
      <td>🔗 encounter_id</td>
      <td>VARCHAR(64)</td>
      <td>FK</td>
      <td></td>
      <td>Référence à la rencontre</td>
    </tr>
    <tr>
      <td>onset_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Début de la condition</td>
    </tr>
    <tr>
      <td>abatement_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Résolution de la condition</td>
    </tr>
    <tr>
      <td>recorded_date</td>
      <td>DATE</td>
      <td></td>
      <td></td>
      <td>Date d'enregistrement</td>
    </tr>
    <tr>
      <td>recorder</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Personne ayant enregistré</td>
    </tr>
    <tr>
      <td>asserter</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Personne affirmant</td>
    </tr>
    <tr>
      <td>stages</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Stades de la condition</td>
    </tr>
    <tr>
      <td>evidences</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Preuves</td>
    </tr>
    <tr>
      <td>notes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Notes</td>
    </tr>
    <tr>
      <td>[Métadonnées FHIR standard]</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_condition_patient` : Index sur subject_patient_id
- `idx_condition_encounter` : Index sur encounter_id
- `idx_condition_code` : Index GIN sur code
- `idx_condition_clinical_status` : Index sur statut clinique

**Règles Métier :**
- Date d'enregistrement ≤ aujourd'hui
- Texte des champs non vide si présent

#### 🏥 fhir_procedure

**Description** : Action qui est ou a été effectuée sur un patient (avec codage CCAM).

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
            <td>🔑 id</td>
            <td>VARCHAR(64)</td>
            <td>PRIMARY KEY</td>
            <td></td>
            <td>Identifiant unique FHIR</td>
        </tr>
        <tr>
            <td>last_updated</td>
            <td>TIMESTAMP WITH TIME ZONE</td>
            <td></td>
            <td>CURRENT_TIMESTAMP</td>
            <td>Dernière mise à jour</td>
        </tr>
        <tr>
            <td>instantiates_canonical_s</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Références canoniques</td>
        </tr>
        <tr>
            <td>instantiates_uri_s</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>URIs d'instanciation</td>
        </tr>
        <tr>
            <td>status</td>
            <td>VARCHAR(20)</td>
            <td>CHECK enum</td>
            <td></td>
            <td>État de la procédure</td>
        </tr>
        <tr>
            <td>status_reason</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Raison du statut</td>
        </tr>
        <tr>
            <td>category</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Catégorie</td>
        </tr>
        <tr>
            <td>code</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Code de procédure (CCAM)</td>
        </tr>
        <tr>
            <td>code_text</td>
            <td>VARCHAR(255)</td>
            <td></td>
            <td></td>
            <td>Texte du code</td>
        </tr>
        <tr>
            <td>identifiers</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Identifiants métier</td>
        </tr>
        <tr>
            <td>based_on_s</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Basé sur</td>
        </tr>
        <tr>
            <td>part_of_s</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Partie de</td>
        </tr>
        <tr>
            <td>subject</td>
            <td>JSONB</td>
            <td>NOT NULL</td>
            <td></td>
            <td>Patient</td>
        </tr>
        <tr>
            <td>🔗 subject_patient_id</td>
            <td>VARCHAR(64)</td>
            <td>NOT NULL, FK</td>
            <td></td>
            <td>Référence au patient</td>
        </tr>
        <tr>
            <td>encounter</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Rencontre</td>
        </tr>
        <tr>
            <td>🔗 encounter_id</td>
            <td>VARCHAR(64)</td>
            <td>FK</td>
            <td></td>
            <td>Référence à la rencontre</td>
        </tr>
        <tr>
            <td>performed_x</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Timing d'exécution</td>
        </tr>
        <tr>
            <td>performed_date_time</td>
            <td>TIMESTAMP WITH TIME ZONE</td>
            <td></td>
            <td></td>
            <td>Date de réalisation</td>
        </tr>
        <tr>
            <td>recorder</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Enregistreur</td>
        </tr>
        <tr>
            <td>asserter</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Affirmant</td>
        </tr>
        <tr>
            <td>performers</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Exécutants</td>
        </tr>
        <tr>
            <td>performer_actor_practitioner_text</td>
            <td>TEXT</td>
            <td></td>
            <td></td>
            <td>Praticien exécutant</td>
        </tr>
        <tr>
            <td>location</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Emplacement</td>
        </tr>
        <tr>
            <td>reason_codes</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Codes de raison</td>
        </tr>
        <tr>
            <td>reason_references</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Références de raison</td>
        </tr>
        <tr>
            <td>body_sites</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Sites corporels</td>
        </tr>
        <tr>
            <td>outcome</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Résultat</td>
        </tr>
        <tr>
            <td>reports</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Rapports</td>
        </tr>
        <tr>
            <td>complications</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Complications</td>
        </tr>
        <tr>
            <td>complication_details</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Détails des complications</td>
        </tr>
        <tr>
            <td>follow_up_s</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Suivi</td>
        </tr>
        <tr>
            <td>notes</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Notes</td>
        </tr>
        <tr>
            <td>focal_devices</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Dispositifs focaux</td>
        </tr>
        <tr>
            <td>used_references</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Références utilisées</td>
        </tr>
        <tr>
            <td>used_codes</td>
            <td>JSONB</td>
            <td></td>
            <td></td>
            <td>Codes utilisés</td>
        </tr>
        <tr>
            <td>[Métadonnées FHIR standard]</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>created_at</td>
            <td>TIMESTAMP WITH TIME ZONE</td>
            <td></td>
            <td>CURRENT_TIMESTAMP</td>
            <td>Date de création</td>
        </tr>
        <tr>
            <td>updated_at</td>
            <td>TIMESTAMP WITH TIME ZONE</td>
            <td></td>
            <td>CURRENT_TIMESTAMP</td>
            <td>Date de modification</td>
        </tr>
    </tbody>
</table>

**Index Principaux :**
- `idx_procedure_patient` : Index sur subject_patient_id
- `idx_procedure_encounter` : Index sur encounter_id
- `idx_procedure_code` : Index GIN sur code
- `idx_procedure_performed` : Index sur performed_date_time

**Règles Métier :**
- Date d'exécution ≤ demain
- Texte du code non vide si présent

#### 🏥 fhir_observation

**Description** : Mesures et assertions simples faites sur un patient. Table générique pour tous les profils d'observation DM.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Identifiant unique FHIR</td>
    </tr>
    <tr>
      <td>last_updated</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Dernière mise à jour</td>
    </tr>
    <tr>
      <td>status</td>
      <td>VARCHAR(20)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Statut du résultat</td>
    </tr>
    <tr>
      <td>categories</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Classification du type</td>
    </tr>
    <tr>
      <td>categories_text</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Texte des catégories</td>
    </tr>
    <tr>
      <td>code</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Type d'observation (LOINC)</td>
    </tr>
    <tr>
      <td>code_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Nom de l'observation</td>
    </tr>
    <tr>
      <td>identifiers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiants métier</td>
    </tr>
    <tr>
      <td>based_on_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Basé sur</td>
    </tr>
    <tr>
      <td>part_of_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Partie de</td>
    </tr>
    <tr>
      <td>subject</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Sujet de l'observation</td>
    </tr>
    <tr>
      <td>🔗 subject_patient_id</td>
      <td>VARCHAR(64)</td>
      <td>FK</td>
      <td></td>
      <td>Référence au patient</td>
    </tr>
    <tr>
      <td>encounter</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Rencontre</td>
    </tr>
    <tr>
      <td>🔗 encounter_id</td>
      <td>VARCHAR(64)</td>
      <td>FK</td>
      <td></td>
      <td>Référence à la rencontre</td>
    </tr>
    <tr>
      <td>focus_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Focus</td>
    </tr>
    <tr>
      <td>effective_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Timing effectif</td>
    </tr>
    <tr>
      <td>effective_date_time</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Date/heure cliniquement pertinente</td>
    </tr>
    <tr>
      <td>issued</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Date d'émission</td>
    </tr>
    <tr>
      <td>performers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Responsables</td>
    </tr>
    <tr>
      <td>performer_organization_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Organisation exécutante</td>
    </tr>
    <tr>
      <td>value_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Valeur de résultat</td>
    </tr>
    <tr>
      <td>value_quantity_value</td>
      <td>FLOAT</td>
      <td>CHECK ≥ 0</td>
      <td></td>
      <td>Valeur numérique</td>
    </tr>
    <tr>
      <td>value_quantity_unit</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Unité de mesure</td>
    </tr>
    <tr>
      <td>data_absent_reason</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Raison d'absence de données</td>
    </tr>
    <tr>
      <td>interpretations</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Interprétations</td>
    </tr>
    <tr>
      <td>notes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Notes</td>
    </tr>
    <tr>
      <td>body_site</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Site corporel</td>
    </tr>
    <tr>
      <td>method</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Méthode</td>
    </tr>
    <tr>
      <td>specimen</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Échantillon</td>
    </tr>
    <tr>
      <td>device</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Dispositif</td>
    </tr>
    <tr>
      <td>reference_ranges</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Plages de référence</td>
    </tr>
    <tr>
      <td>reference_ranges_value</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Valeurs de référence</td>
    </tr>
    <tr>
      <td>has_members</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Membres</td>
    </tr>
    <tr>
      <td>derived_from_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Dérivé de</td>
    </tr>
    <tr>
      <td>components</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Composants</td>
    </tr>
    <tr>
      <td>[Métadonnées FHIR standard]</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_observation_patient` : Index sur subject_patient_id
- `idx_observation_encounter` : Index sur encounter_id
- `idx_observation_code` : Index GIN sur code
- `idx_observation_effective` : Index sur effective_date_time
- `idx_observation_value_numeric` : Index sur valeurs numériques

**Règles Métier :**
- Date effective ≤ demain
- Date d'émission ≥ date effective
- Valeurs numériques ≥ 0

#### 🏥 fhir_observation_component

**Description** : Composants d'observations pour les mesures multi-composants.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Clé technique</td>
    </tr>
    <tr>
      <td>🔗 observation_id</td>
      <td>VARCHAR(64)</td>
      <td>FK CASCADE</td>
      <td></td>
      <td>Référence à l'observation</td>
    </tr>
    <tr>
      <td>code</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Code LOINC</td>
    </tr>
    <tr>
      <td>code_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte du code</td>
    </tr>
    <tr>
      <td>value_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Valeur</td>
    </tr>
    <tr>
      <td>value_quantity_value</td>
      <td>FLOAT</td>
      <td>CHECK ≥ 0</td>
      <td></td>
      <td>Valeur numérique</td>
    </tr>
    <tr>
      <td>value_quantity_unit</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Unité</td>
    </tr>
    <tr>
      <td>data_absent_reason</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Raison d'absence</td>
    </tr>
    <tr>
      <td>interpretations</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Interprétations</td>
    </tr>
    <tr>
      <td>reference_ranges</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Plages de référence</td>
    </tr>
    <tr>
      <td>reference_ranges_value</td>
      <td>TEXT</td>
      <td></td>
      <td></td>
      <td>Valeurs de référence</td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_observation_component_parent` : Index sur observation_id
- `idx_observation_component_code` : Index GIN sur code
- `idx_observation_component_value` : Index sur valeurs

#### 🏥 fhir_medication_request

**Description** : Ordre ou demande de fourniture de médicament et instructions d'administration.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Identifiant unique FHIR</td>
    </tr>
    <tr>
      <td>last_updated</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Dernière mise à jour</td>
    </tr>
    <tr>
      <td>status</td>
      <td>VARCHAR(20)</td>
      <td>NOT NULL, CHECK enum</td>
      <td></td>
      <td>État actuel de l'ordre</td>
    </tr>
    <tr>
      <td>status_reason</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Raison du statut</td>
    </tr>
    <tr>
      <td>intent</td>
      <td>VARCHAR(20)</td>
      <td>NOT NULL, CHECK enum</td>
      <td></td>
      <td>Intention de la demande</td>
    </tr>
    <tr>
      <td>categories</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Type d'usage</td>
    </tr>
    <tr>
      <td>priority</td>
      <td>VARCHAR(20)</td>
      <td>CHECK enum</td>
      <td></td>
      <td>Urgence</td>
    </tr>
    <tr>
      <td>do_not_perform</td>
      <td>BOOLEAN</td>
      <td></td>
      <td></td>
      <td>Si interdiction d'action</td>
    </tr>
    <tr>
      <td>identifiers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiants métier</td>
    </tr>
    <tr>
      <td>based_on_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Basé sur</td>
    </tr>
    <tr>
      <td>reported_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Rapporté</td>
    </tr>
    <tr>
      <td>group_identifier</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiant de groupe</td>
    </tr>
    <tr>
      <td>course_of_therapy_type</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Type de cure</td>
    </tr>
    <tr>
      <td>insurances</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Assurances</td>
    </tr>
    <tr>
      <td>notes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Notes</td>
    </tr>
    <tr>
      <td>medication_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Médicament</td>
    </tr>
    <tr>
      <td>medication_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte du médicament</td>
    </tr>
    <tr>
      <td>🔗 subject_patient_id</td>
      <td>VARCHAR(64)</td>
      <td>NOT NULL, FK</td>
      <td></td>
      <td>Référence au patient</td>
    </tr>
    <tr>
      <td>🔗 encounter_id</td>
      <td>VARCHAR(64)</td>
      <td>FK</td>
      <td></td>
      <td>Référence à la rencontre</td>
    </tr>
    <tr>
      <td>supporting_informations</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Informations de support</td>
    </tr>
    <tr>
      <td>authored_on</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>requester</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Demandeur</td>
    </tr>
    <tr>
      <td>requester_practitioner_display</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Praticien demandeur</td>
    </tr>
    <tr>
      <td>performer</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Exécutant</td>
    </tr>
    <tr>
      <td>performer_type</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Type d'exécutant</td>
    </tr>
    <tr>
      <td>recorder</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Enregistreur</td>
    </tr>
    <tr>
      <td>reason_codes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Codes de raison</td>
    </tr>
    <tr>
      <td>reason_references</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Références de raison</td>
    </tr>
    <tr>
      <td>instantiates_canonical_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Instancie canonique</td>
    </tr>
    <tr>
      <td>instantiates_uri_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Instancie URI</td>
    </tr>
    <tr>
      <td>dosage_instructions</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Instructions de dosage</td>
    </tr>
    <tr>
      <td>dosage_instruction_route_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Voie d'administration</td>
    </tr>
    <tr>
      <td>dosage_instruction_dose_quantity_value</td>
      <td>FLOAT</td>
      <td>CHECK > 0</td>
      <td></td>
      <td>Dose</td>
    </tr>
    <tr>
      <td>dosage_instruction_dose_quantity_unit</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Unité de dose</td>
    </tr>
    <tr>
      <td>dosage_instruction_timing_bounds_period_start</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Début de période</td>
    </tr>
    <tr>
      <td>dosage_instruction_timing_bounds_period_end</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Fin de période</td>
    </tr>
    <tr>
      <td>dispense_request</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Demande de dispensation</td>
    </tr>
    <tr>
      <td>substitution</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Substitution</td>
    </tr>
    <tr>
      <td>prior_prescription</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Prescription antérieure</td>
    </tr>
    <tr>
      <td>detected_issues</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Problèmes détectés</td>
    </tr>
    <tr>
      <td>event_history</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Historique d'événements</td>
    </tr>
    <tr>
      <td>[Métadonnées FHIR standard]</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_med_request_patient` : Index sur subject_patient_id
- `idx_med_request_encounter` : Index sur encounter_id
- `idx_med_request_status` : Index sur status
- `idx_med_request_medication_text` : Index sur medication_text
- `idx_med_request_authored` : Index sur authored_on

**Règles Métier :**
- Date de création ≤ demain
- Fin de période ≥ début de période
- Dose > 0 si spécifiée

#### 🏥 fhir_medication_administration

**Description** : Événement de consommation ou d'administration d'un médicament à un patient.

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
      <td>🔑 id</td>
      <td>VARCHAR(64)</td>
      <td>PRIMARY KEY</td>
      <td></td>
      <td>Identifiant unique FHIR</td>
    </tr>
    <tr>
      <td>last_updated</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Dernière mise à jour</td>
    </tr>
    <tr>
      <td>status</td>
      <td>VARCHAR(20)</td>
      <td>NOT NULL, CHECK enum</td>
      <td></td>
      <td>État de l'administration</td>
    </tr>
    <tr>
      <td>status_reasons</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Raisons du statut</td>
    </tr>
    <tr>
      <td>category</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Catégorie</td>
    </tr>
    <tr>
      <td>identifiers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Identifiants métier</td>
    </tr>
    <tr>
      <td>instantiates_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Instancie</td>
    </tr>
    <tr>
      <td>part_of_s</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Partie de</td>
    </tr>
    <tr>
      <td>medication_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Médicament</td>
    </tr>
    <tr>
      <td>medication_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Texte du médicament</td>
    </tr>
    <tr>
      <td>🔗 subject_patient_id</td>
      <td>VARCHAR(64)</td>
      <td>NOT NULL, FK</td>
      <td></td>
      <td>Référence au patient</td>
    </tr>
    <tr>
      <td>context</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Contexte</td>
    </tr>
    <tr>
      <td>🔗 context_encounter_id</td>
      <td>VARCHAR(64)</td>
      <td>FK</td>
      <td></td>
      <td>Référence à la rencontre</td>
    </tr>
    <tr>
      <td>supporting_informations</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Informations de support</td>
    </tr>
    <tr>
      <td>effective_x</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Timing effectif</td>
    </tr>
    <tr>
      <td>effective_date_time</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td></td>
      <td>Date/heure effective</td>
    </tr>
    <tr>
      <td>performers</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Exécutants</td>
    </tr>
    <tr>
      <td>reason_codes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Codes de raison</td>
    </tr>
    <tr>
      <td>reason_references</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Références de raison</td>
    </tr>
    <tr>
      <td>request</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Demande</td>
    </tr>
    <tr>
      <td>🔗 request_medication_request_id</td>
      <td>VARCHAR(64)</td>
      <td>FK</td>
      <td></td>
      <td>Référence à la prescription</td>
    </tr>
    <tr>
      <td>devices</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Dispositifs</td>
    </tr>
    <tr>
      <td>notes</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Notes</td>
    </tr>
    <tr>
      <td>dosage</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Dosage</td>
    </tr>
    <tr>
      <td>dosage_route_text</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Voie d'administration</td>
    </tr>
    <tr>
      <td>dosage_dose_value</td>
      <td>FLOAT</td>
      <td>CHECK > 0</td>
      <td></td>
      <td>Dose administrée</td>
    </tr>
    <tr>
      <td>dosage_dose_unit</td>
      <td>VARCHAR(255)</td>
      <td></td>
      <td></td>
      <td>Unité de dose</td>
    </tr>
    <tr>
      <td>event_history</td>
      <td>JSONB</td>
      <td></td>
      <td></td>
      <td>Historique d'événements</td>
    </tr>
    <tr>
      <td>[Métadonnées FHIR standard]</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>created_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de création</td>
    </tr>
    <tr>
      <td>updated_at</td>
      <td>TIMESTAMP WITH TIME ZONE</td>
      <td></td>
      <td>CURRENT_TIMESTAMP</td>
      <td>Date de modification</td>
    </tr>
  </tbody>
</table>

**Index Principaux :**
- `idx_med_admin_patient` : Index sur subject_patient_id
- `idx_med_admin_encounter` : Index sur context_encounter_id
- `idx_med_admin_request` : Index sur request_medication_request_id
- `idx_med_admin_status` : Index sur status
- `idx_med_admin_effective` : Index sur effective_date_time

**Règles Métier :**
- Date effective ≤ demain
- Dose > 0 si spécifiée

### Matrice des Relations

<table style="width: 100%;">
  <thead>
    <tr>
      <th>Table Source</th>
      <th>Table Cible</th>
      <th>Type de Relation</th>
      <th>Colonne FK</th>
      <th>Cascade</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>fhir_encounter</td>
      <td>fhir_patient</td>
      <td>Plusieurs vers Un</td>
      <td>subject_patient_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_condition</td>
      <td>fhir_patient</td>
      <td>Plusieurs vers Un</td>
      <td>subject_patient_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_condition</td>
      <td>fhir_encounter</td>
      <td>Plusieurs vers Un</td>
      <td>encounter_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_procedure</td>
      <td>fhir_patient</td>
      <td>Plusieurs vers Un</td>
      <td>subject_patient_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_procedure</td>
      <td>fhir_encounter</td>
      <td>Plusieurs vers Un</td>
      <td>encounter_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_observation</td>
      <td>fhir_patient</td>
      <td>Plusieurs vers Un</td>
      <td>subject_patient_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_observation</td>
      <td>fhir_encounter</td>
      <td>Plusieurs vers Un</td>
      <td>encounter_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_observation_component</td>
      <td>fhir_observation</td>
      <td>Plusieurs vers Un</td>
      <td>observation_id</td>
      <td>CASCADE</td>
    </tr>
    <tr>
      <td>fhir_medication_request</td>
      <td>fhir_patient</td>
      <td>Plusieurs vers Un</td>
      <td>subject_patient_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_medication_request</td>
      <td>fhir_encounter</td>
      <td>Plusieurs vers Un</td>
      <td>encounter_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_medication_administration</td>
      <td>fhir_patient</td>
      <td>Plusieurs vers Un</td>
      <td>subject_patient_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_medication_administration</td>
      <td>fhir_encounter</td>
      <td>Plusieurs vers Un</td>
      <td>context_encounter_id</td>
      <td>-</td>
    </tr>
    <tr>
      <td>fhir_medication_administration</td>
      <td>fhir_medication_request</td>
      <td>Plusieurs vers Un</td>
      <td>request_medication_request_id</td>
      <td>-</td>
    </tr>
  </tbody>
</table>

### Règles Métier

#### Contraintes de Validation des Données

##### Patient
- **Dates** : `birth_date` entre 1900 et aujourd'hui, `deceased_date_time` ≥ `birth_date`
- **Coordonnées** : Latitude [-90, 90], longitude [-180, 180]
- **Identifiants** : NSS 13-15 chiffres, INS-NIR 15 chiffres exactement
- **Naissance multiple** : Rang entre 1 et 10
- **Code géographique PMSI** : 2-5 chiffres

##### Encounter
- **Période** : `period_end` ≥ `period_start`, `period_start` ≤ demain
- **Durée** : `length_number_of_day` ≥ 0
- **Sources d'admission** : Mutation, Transfert définitif/provisoire, Domicile, Naissance, Décédé pour prélèvement
- **Dispositions de sortie** : Mutation, Transfert définitif/provisoire, Domicile, Décès

##### Temporelles Générales
- **Dates d'enregistrement** ≤ aujourd'hui
- **Dates d'exécution/effective** ≤ demain
- **Dates d'émission** ≥ dates effectives

##### Valeurs Numériques
- **Observations** : Valeurs ≥ 0
- **Médicaments** : Doses > 0 si spécifiées

##### Intégrité Textuelle
- Tous les champs texte doivent être non vides s'ils sont présents
- Validation JSONB : Format JSON valide et types appropriés

### Stratégie d'Indexation

#### Index de Performance PostgreSQL

##### Index Primaires et de Clés Étrangères
- Index B-tree sur toutes les clés primaires
- Index sur toutes les clés étrangères pour optimiser les jointures

##### Index Spécialisés

**Hash (Recherches Exactes)**
- `idx_patient_nss_hash` : Recherche rapide par NSS
- `idx_patient_ins_nir_hash` : Recherche rapide par INS-NIR
- `idx_observation_code_hash` : Recherche rapide par code LOINC

**GIN (Données JSONB)**
- Index sur tous les champs JSONB pour requêtes complexes
- Support des opérateurs `@>`, `?`, `?&`, `?|`

**GiST (Données Spatiales et Temporelles)**
- `idx_patient_coordinates_gist` : Requêtes géospatiales
- `idx_encounter_period_range` : Requêtes sur plages temporelles

**Recherche Textuelle**
- `idx_patient_names_search` : Recherche full-text en français
- Index sur tous les champs `*_text` pour recherche rapide

##### Index Composites
- `idx_encounter_patient_period` : Historique patient
- `idx_observation_patient_code` : Résultats par patient et type
- `idx_med_request_patient_active` : Prescriptions actives

#### Optimisations Spécifiques

**Création Concurrente**
- Tous les index créés avec `CONCURRENTLY` pour éviter les interruptions

**Index Partiels**
- Uniquement sur les lignes avec données non NULL
- Réduction de la taille des index

**Index Couvrants**
- Certains index incluent des colonnes supplémentaires
- Évitent les accès aux tables principales

### Notes d'Implémentation

#### Conventions de Nommage

##### Champs FHIR
- **snake_case** remplace **camelCase** (`basedOn` → `based_on`)
- **Pluralisation** pour cardinalité > 1
- **Suffixes** : `_id` pour FK socle, `_display` pour contexte, `_text` pour affichage

##### Types de Données
- **Primitifs** → Types PostgreSQL équivalents
- **Complexes** → JSONB sauf décomposition spécifique
- **Références socle** → Clés étrangères typées
- **Références contexte** → Champs display textuels

##### Extensions et Propriétés [x]
- **Extensions** → JSONB avec champs spécifiques si intérêt
- **Propriétés [x]** → `_x` en JSONB + champs spécifiques

#### Utilisation de JSONB

**Avantages**
- Flexibilité pour structures FHIR complexes
- Requêtes natives PostgreSQL
- Indexation GIN performante
- Validation de type intégrée

**Patterns d'Usage**
- Stockage complet en JSONB + extraction de champs critiques
- Index GIN pour requêtes structurées
- Contraintes de validation JSON

#### Métadonnées FHIR

**Champs Standard**
- `meta` : Informations de version, profils, sécurité
- `text_div` : Résumé narratif
- `extensions` : Extensions standardisées
- `contained` : Ressources imbriquées

### Conformité et Standards

#### Standards FHIR
- **Version** : FHIR R4 (4.0.1)
- **Profils** : Profils DM français
- **Terminologies** : LOINC, SNOMED CT, CIM-10, CCAM, ATC

#### Réglementations Françaises
- **INS** : Identité Nationale de Santé
- **PMSI** : Programme de Médicalisation
- **RGPD** : Protection des données personnelles
- **HDS** : Hébergement de Données de Santé

#### Interopérabilité
- **IHE** : Profils d'intégration (PAM, PIXm, PDQm)
- **HL7** : Standards de messagerie
- **CI-SIS** : Cadre d'Interopérabilité français

---

*Documentation générée à partir du script DDL PostgreSQL pour la couche sémantique FHIR.*
*Version : 1.0 | Date : 2025-09-15*