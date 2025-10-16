
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
<div class="viewer-container" style="height: 1783px;">
  <div class="svg-container" id="physical-model">
    {% include fsl-datamodel.svg %}
  </div>
</div>

### Tables de la Base de Données

#### 🏥 fhir_patient

**Description** : Profil Patient du socle commun des EDS. Démographie et informations administratives sur les individus recevant des soins.

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| active | BOOLEAN | | | Si l'enregistrement patient est actif |
| identifiers | JSONB | | | Identifiants métier (tableau) |
| nss_identifier | VARCHAR(50) | CHECK format | | NSS - Numéro de Sécurité Sociale |
| ins_nir_identifier | VARCHAR(15) | CHECK format | | INS-NIR - Identifiant national de santé |
| names | JSONB | | | Noms associés au patient |
| full_names | TEXT | | | Représentation structurée des noms |
| gender | VARCHAR(10) | CHECK enum | | Genre administratif |
| birth_date | DATE | CHECK range | | Date de naissance |
| deceased_x | JSONB | | | Information de décès |
| deceased_date_time | TIMESTAMP WITH TIME ZONE | | | Date et heure de décès |
| deceased_extension_death_source | VARCHAR(10) | CHECK enum | | Source d'information de décès |
| marital_status | VARCHAR(4) | CHECK enum | | Statut marital |
| address | JSONB | | | Adresses physiques |
| address_extension_geolocation_latitude | FLOAT | CHECK range | | Latitude de géolocalisation |
| address_extension_geolocation_longitude | FLOAT | CHECK range | | Longitude de géolocalisation |
| address_extension_census_tract | VARCHAR(255) | | | Code IRIS du recensement |
| address_period_start | DATE | | | Date de début de validité d'adresse |
| address_extension_pmsi_code_geo | JSONB | | | Extension code géographique PMSI |
| address_extension_pmsi_code_geo_code | VARCHAR(5) | CHECK format | | Code géographique PMSI |
| telecoms | JSONB | | | Coordonnées de contact |
| contacts | JSONB | | | Contacts d'urgence et tuteurs |
| communications | JSONB | | | Langues de communication |
| preferred_communication_languages | TEXT | | | Langues préférées |
| multiple_birth_x | JSONB | | | Information sur naissance multiple |
| multiple_birth_integer | INTEGER | CHECK range | | Rang gémellaire |
| general_practitioners | JSONB | | | Médecins traitants |
| managing_organization | JSONB | | | Organisation gestionnaire |
| links | JSONB | | | Liens vers autres patients |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| status | VARCHAR(20) | CHECK enum | | État actuel de la rencontre |
| status_history | JSONB | | | Historique des statuts |
| class | JSONB | | | Classification de la rencontre |
| class_display | VARCHAR(255) | | | Texte d'affichage de la classe |
| class_history | JSONB | | | Historique des classes |
| types | JSONB | | | Types spécifiques de rencontre |
| service_type | JSONB | | | Catégorisation large du service |
| priority | JSONB | | | Urgence de la rencontre |
| identifiers | JSONB | | | Identifiants métier |
| subject | JSONB | | | Patient ou groupe présent |
| 🔗 subject_patient_id | VARCHAR(64) | NOT NULL, FK | | Référence obligatoire au patient |
| episodes_of_care | JSONB | | | Épisodes de soins |
| based_on_s | JSONB | | | Rendez-vous planifiés |
| participants | JSONB | | | Personnes impliquées |
| appointments | JSONB | | | Rendez-vous |
| period_start | TIMESTAMP WITH TIME ZONE | | | Heure de début |
| period_end | TIMESTAMP WITH TIME ZONE | | | Heure de fin |
| length | JSONB | | | Durée de la rencontre |
| length_number_of_day | INTEGER | CHECK ≥ 0 | | Durée en jours |
| reason_codes | JSONB | | | Raisons codées |
| reason_references | JSONB | | | Références aux raisons |
| diagnoses | JSONB | | | Diagnostics |
| account | JSONB | | | Comptes |
| hospitalization | JSONB | | | Détails d'hospitalisation |
| admit_source_text | VARCHAR(255) | CHECK enum | | Source d'admission |
| discharge_disposition_text | VARCHAR(255) | CHECK enum | | Disposition de sortie |
| locations | JSONB | | | Emplacements |
| service_provider | JSONB | | | Prestataire de service |
| service_provider_organization_display | VARCHAR(64) | | | Nom d'affichage du prestataire |
| part_of | JSONB | | | Rencontre parent |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| clinical_status | JSONB | | | Statut clinique de la condition |
| clinical_status_text | VARCHAR(255) | | | Texte du statut clinique |
| verification_status | JSONB | | | Statut de vérification |
| verification_status_text | VARCHAR(255) | | | Texte du statut de vérification |
| categories | JSONB | | | Catégories assignées |
| categories_text | TEXT | | | Texte des catégories |
| severity | JSONB | | | Sévérité subjective |
| code | JSONB | | | Identification de la condition (CIM-10) |
| code_text | VARCHAR(255) | | | Texte du code |
| body_sites | JSONB | | | Localisation anatomique |
| identifiers | JSONB | | | Identifiants métier |
| subject | JSONB | NOT NULL | | Patient concerné |
| 🔗 subject_patient_id | VARCHAR(64) | NOT NULL, FK | | Référence au patient |
| encounter | JSONB | | | Rencontre d'assertion |
| 🔗 encounter_id | VARCHAR(64) | FK | | Référence à la rencontre |
| onset_x | JSONB | | | Début de la condition |
| abatement_x | JSONB | | | Résolution de la condition |
| recorded_date | DATE | | | Date d'enregistrement |
| recorder | JSONB | | | Personne ayant enregistré |
| asserter | JSONB | | | Personne affirmant |
| stages | JSONB | | | Stades de la condition |
| evidences | JSONB | | | Preuves |
| notes | JSONB | | | Notes |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| instantiates_canonical_s | JSONB | | | Références canoniques |
| instantiates_uri_s | JSONB | | | URIs d'instanciation |
| status | VARCHAR(20) | CHECK enum | | État de la procédure |
| status_reason | JSONB | | | Raison du statut |
| category | JSONB | | | Catégorie |
| code | JSONB | | | Code de procédure (CCAM) |
| code_text | VARCHAR(255) | | | Texte du code |
| identifiers | JSONB | | | Identifiants métier |
| based_on_s | JSONB | | | Basé sur |
| part_of_s | JSONB | | | Partie de |
| subject | JSONB | NOT NULL | | Patient |
| 🔗 subject_patient_id | VARCHAR(64) | NOT NULL, FK | | Référence au patient |
| encounter | JSONB | | | Rencontre |
| 🔗 encounter_id | VARCHAR(64) | FK | | Référence à la rencontre |
| performed_x | JSONB | | | Timing d'exécution |
| performed_date_time | TIMESTAMP WITH TIME ZONE | | | Date de réalisation |
| recorder | JSONB | | | Enregistreur |
| asserter | JSONB | | | Affirmant |
| performers | JSONB | | | Exécutants |
| performer_actor_practitioner_text | TEXT | | | Praticien exécutant |
| location | JSONB | | | Emplacement |
| reason_codes | JSONB | | | Codes de raison |
| reason_references | JSONB | | | Références de raison |
| body_sites | JSONB | | | Sites corporels |
| outcome | JSONB | | | Résultat |
| reports | JSONB | | | Rapports |
| complications | JSONB | | | Complications |
| complication_details | JSONB | | | Détails des complications |
| follow_up_s | JSONB | | | Suivi |
| notes | JSONB | | | Notes |
| focal_devices | JSONB | | | Dispositifs focaux |
| used_references | JSONB | | | Références utilisées |
| used_codes | JSONB | | | Codes utilisés |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| status | VARCHAR(20) | CHECK enum | | Statut du résultat |
| categories | JSONB | | | Classification du type |
| categories_text | TEXT | | | Texte des catégories |
| code | JSONB | | | Type d'observation (LOINC) |
| code_text | VARCHAR(255) | | | Nom de l'observation |
| identifiers | JSONB | | | Identifiants métier |
| based_on_s | JSONB | | | Basé sur |
| part_of_s | JSONB | | | Partie de |
| subject | JSONB | | | Sujet de l'observation |
| 🔗 subject_patient_id | VARCHAR(64) | FK | | Référence au patient |
| encounter | JSONB | | | Rencontre |
| 🔗 encounter_id | VARCHAR(64) | FK | | Référence à la rencontre |
| focus_s | JSONB | | | Focus |
| effective_x | JSONB | | | Timing effectif |
| effective_date_time | TIMESTAMP WITH TIME ZONE | | | Date/heure cliniquement pertinente |
| issued | TIMESTAMP WITH TIME ZONE | | | Date d'émission |
| performers | JSONB | | | Responsables |
| performer_organization_text | VARCHAR(255) | | | Organisation exécutante |
| value_x | JSONB | | | Valeur de résultat |
| value_quantity_value | FLOAT | CHECK ≥ 0 | | Valeur numérique |
| value_quantity_unit | VARCHAR(255) | | | Unité de mesure |
| data_absent_reason | JSONB | | | Raison d'absence de données |
| interpretations | JSONB | | | Interprétations |
| notes | JSONB | | | Notes |
| body_site | JSONB | | | Site corporel |
| method | JSONB | | | Méthode |
| specimen | JSONB | | | Échantillon |
| device | JSONB | | | Dispositif |
| reference_ranges | JSONB | | | Plages de référence |
| reference_ranges_value | TEXT | | | Valeurs de référence |
| has_members | JSONB | | | Membres |
| derived_from_s | JSONB | | | Dérivé de |
| components | JSONB | | | Composants |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Clé technique |
| 🔗 observation_id | VARCHAR(64) | FK CASCADE | | Référence à l'observation |
| code | JSONB | | | Code LOINC |
| code_text | VARCHAR(255) | | | Texte du code |
| value_x | JSONB | | | Valeur |
| value_quantity_value | FLOAT | CHECK ≥ 0 | | Valeur numérique |
| value_quantity_unit | VARCHAR(255) | | | Unité |
| data_absent_reason | JSONB | | | Raison d'absence |
| interpretations | JSONB | | | Interprétations |
| reference_ranges | JSONB | | | Plages de référence |
| reference_ranges_value | TEXT | | | Valeurs de référence |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

**Index Principaux :**
- `idx_observation_component_parent` : Index sur observation_id
- `idx_observation_component_code` : Index GIN sur code
- `idx_observation_component_value` : Index sur valeurs

#### 🏥 fhir_medication_request

**Description** : Ordre ou demande de fourniture de médicament et instructions d'administration.

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| status | VARCHAR(20) | NOT NULL, CHECK enum | | État actuel de l'ordre |
| status_reason | JSONB | | | Raison du statut |
| intent | VARCHAR(20) | NOT NULL, CHECK enum | | Intention de la demande |
| categories | JSONB | | | Type d'usage |
| priority | VARCHAR(20) | CHECK enum | | Urgence |
| do_not_perform | BOOLEAN | | | Si interdiction d'action |
| identifiers | JSONB | | | Identifiants métier |
| based_on_s | JSONB | | | Basé sur |
| reported_x | JSONB | | | Rapporté |
| group_identifier | JSONB | | | Identifiant de groupe |
| course_of_therapy_type | JSONB | | | Type de cure |
| insurances | JSONB | | | Assurances |
| notes | JSONB | | | Notes |
| medication_x | JSONB | | | Médicament |
| medication_text | VARCHAR(255) | | | Texte du médicament |
| subject | JSONB | | | Patient concerné |
| 🔗 subject_patient_id | VARCHAR(64) | NOT NULL, FK | | Référence au patient |
| 🔗 encounter_id | VARCHAR(64) | FK | | Référence à la rencontre |
| supporting_informations | JSONB | | | Informations de support |
| authored_on | TIMESTAMP WITH TIME ZONE | | | Date de création |
| requester | JSONB | | | Demandeur |
| requester_practitioner_display | VARCHAR(255) | | | Praticien demandeur |
| performer | JSONB | | | Exécutant |
| performer_type | JSONB | | | Type d'exécutant |
| recorder | JSONB | | | Enregistreur |
| reason_codes | JSONB | | | Codes de raison |
| reason_references | JSONB | | | Références de raison |
| instantiates_canonical_s | JSONB | | | Instancie canonique |
| instantiates_uri_s | JSONB | | | Instancie URI |
| dosage_instructions | JSONB | | | Instructions de dosage |
| dosage_instruction_route_text | VARCHAR(255) | | | Voie d'administration |
| dosage_instruction_dose_quantity_value | FLOAT | CHECK > 0 | | Dose |
| dosage_instruction_dose_quantity_unit | VARCHAR(255) | | | Unité de dose |
| dosage_instruction_timing_bounds_period_start | TIMESTAMP WITH TIME ZONE | | | Début de période |
| dosage_instruction_timing_bounds_period_end | TIMESTAMP WITH TIME ZONE | | | Fin de période |
| dispense_request | JSONB | | | Demande de dispensation |
| substitution | JSONB | | | Substitution |
| prior_prescription | JSONB | | | Prescription antérieure |
| detected_issues | JSONB | | | Problèmes détectés |
| event_history | JSONB | | | Historique d'événements |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Colonne | Type | Contraintes | Défaut | Description |
|---------|------|-------------|--------|-------------|
| 🔑 id | VARCHAR(64) | PRIMARY KEY | | Identifiant unique FHIR |
| last_updated | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Dernière mise à jour |
| status | VARCHAR(20) | NOT NULL, CHECK enum | | État de l'administration |
| status_reasons | JSONB | | | Raisons du statut |
| category | JSONB | | | Catégorie |
| identifiers | JSONB | | | Identifiants métier |
| instantiates_s | JSONB | | | Instancie |
| part_of_s | JSONB | | | Partie de |
| medication_x | JSONB | | | Médicament |
| medication_text | VARCHAR(255) | | | Texte du médicament |
| subject | JSONB | | | Patient concerné |
| 🔗 subject_patient_id | VARCHAR(64) | NOT NULL, FK | | Référence au patient |
| context | JSONB | | | Contexte |
| 🔗 context_encounter_id | VARCHAR(64) | FK | | Référence à la rencontre |
| supporting_informations | JSONB | | | Informations de support |
| effective_x | JSONB | | | Timing effectif |
| effective_date_time | TIMESTAMP WITH TIME ZONE | | | Date/heure effective |
| performers | JSONB | | | Exécutants |
| reason_codes | JSONB | | | Codes de raison |
| reason_references | JSONB | | | Références de raison |
| request | JSONB | | | Demande |
| 🔗 request_medication_request_id | VARCHAR(64) | FK | | Référence à la prescription |
| devices | JSONB | | | Dispositifs |
| notes | JSONB | | | Notes |
| dosage | JSONB | | | Dosage |
| dosage_route_text | VARCHAR(255) | | | Voie d'administration |
| dosage_dose_value | FLOAT | CHECK > 0 | | Dose administrée |
| dosage_dose_unit | VARCHAR(255) | | | Unité de dose |
| event_history | JSONB | | | Historique d'événements |
| meta | JSONB | | | Métadonnées FHIR |
| implicit_rules | VARCHAR(255) | | | Règles implicites |
| resource_language | VARCHAR(10) | | | Langue de la ressource |
| text_div | TEXT | | | Résumé textuel |
| contained | JSONB | | | Ressources contenues |
| extensions | JSONB | | | Extensions |
| modifier_extensions | JSONB | | | Extensions modificatrices |
| created_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de création |
| updated_at | TIMESTAMP WITH TIME ZONE | | CURRENT_TIMESTAMP | Date de modification |
{: .grid}

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

| Table Source | Table Cible | Type de Relation | Colonne FK | Cascade |
|--------------|-------------|------------------|------------|---------|
| fhir_encounter | fhir_patient | Plusieurs vers Un | subject_patient_id | - |
| fhir_condition | fhir_patient | Plusieurs vers Un | subject_patient_id | - |
| fhir_condition | fhir_encounter | Plusieurs vers Un | encounter_id | - |
| fhir_procedure | fhir_patient | Plusieurs vers Un | subject_patient_id | - |
| fhir_procedure | fhir_encounter | Plusieurs vers Un | encounter_id | - |
| fhir_observation | fhir_patient | Plusieurs vers Un | subject_patient_id | - |
| fhir_observation | fhir_encounter | Plusieurs vers Un | encounter_id | - |
| fhir_observation_component | fhir_observation | Plusieurs vers Un | observation_id | CASCADE |
| fhir_medication_request | fhir_patient | Plusieurs vers Un | subject_patient_id | - |
| fhir_medication_request | fhir_encounter | Plusieurs vers Un | encounter_id | - |
| fhir_medication_administration | fhir_patient | Plusieurs vers Un | subject_patient_id | - |
| fhir_medication_administration | fhir_encounter | Plusieurs vers Un | context_encounter_id | - |
| fhir_medication_administration | fhir_medication_request | Plusieurs vers Un | request_medication_request_id | - |
{: .grid}

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