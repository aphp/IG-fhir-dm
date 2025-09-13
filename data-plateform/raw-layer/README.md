# 🏥 Couche de Données Brutes (Raw Layer)

Cette couche constitue la base de l'infrastructure de données pour le projet FHIR Implementation Guide pour la gestion des données de santé. Elle fournit l'infrastructure PostgreSQL conteneurisée et les outils de chargement des données brutes avec support français complet.

## 📋 Vue d'Ensemble des Tâches

Cette section décrit l'ordre pour l'exécution des tâches de mise en place de l'infrastructure de données brutes EHR.

### 🔄 Ordre d'Exécution des Tâches

#### 1. **Création de la Base de Données EHR** 

Première étape fondamentale : création du schéma de base de données PostgreSQL optimisé pour les données de santé françaises.

- `sql/ehr-ddl.sql` - Script DDL de création des tables
- Support complet Unicode et collation française
- Index de performance et contraintes de validation

#### 2. **Données de Test** 

**Caractéristiques :**
- 10 patients de test avec données françaises réalistes
- Fichiers CSV pour les 11 tables du modèle EHR
- Assurer la cohérence référentielle entre les tables
- Inclure des caractères spéciaux français dans les données

**Livrables :**
- 11 fichiers CSV dans `test/file/` 
- Données médicales françaises réalistes (diagnostics, prescriptions, etc.)
- Respect des codes standards (ICD-10, ATC, LOINC)

#### 3. **Loader Python**

Script Python avancé pour charger les données CSV avec gestion optimisée de l'encodage français.

**Caractéristiques :**
- Détection automatique de l'encodage des fichiers CSV français
- Chargement bulk optimisé via `psycopg2` et `COPY`
- Respect de l'ordre des dépendances entre tables
- Validation de l'intégrité des données

**Livrables :**
- `test/loader/load_test_patients.py` - Loader Python complet
- Support encodage UTF-8, Latin1, Windows-1252
- Logging détaillé et gestion d'erreurs robuste

**📖 Documentation :** Voir [test/loader/README.md](test/loader/README.md)

#### 4. **Infrastructure Docker**

Infrastructure conteneurisée complète avec support français optimisé.

**Caractérisques :**
- Conteneurisation PostgreSQL 16 avec locale française
- Configuration UTF-8 et collation française automatique
- Scripts d'initialisation automatique du schéma EHR
- Interface pgAdmin optionnelle pour administration

**Livrables :**
- `ehr-docker/docker-compose.yml` - Infrastructure complète
- `ehr-docker/init/` - Scripts d'initialisation SQL
- Configuration réseau isolé et volumes persistants
- Documentation de déploiement et maintenance

**📖 Documentation :** Voir [ehr-docker/README.md](ehr-docker/README.md)

## 🎯 Guide de Démarrage Rapide

### Prérequis

- Docker Engine 20.10+ et Docker Compose V2
- Python 3.7+ (pour le loader de données)
- PostgreSQL Client (optionnel, pour tests)
- Git (pour cloner le projet)

### Installation Complète (5 minutes)

```bash
# 1. Aller dans le répertoire de l'infrastructure Docker
cd data-plateform/raw-layer/ehr-docker

# 2. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos propres mots de passe

# 3. Démarrer l'infrastructure PostgreSQL
docker-compose up -d postgres_ehr

# 4. Vérifier que PostgreSQL est prêt
docker-compose logs postgres_ehr
docker-compose exec postgres_ehr pg_isready -U ehr_user -d ehr

# 5. Charger les données de test
cd ../test/loader
pip install -r requirements.txt

python load_test_patients.py \
    --host localhost \
    --port 5433 \
    --database ehr \
    --user ehr_user \
    --password ehr_user_123 \
    --csv-dir ../file \
    --clear

---

## 📊 Architecture de la Couche Raw Layer

```
data-plateform/raw-layer/
├── 📁 ehr-docker/              # Infrastructure Docker PostgreSQL
│   ├── docker-compose.yml      # Configuration des services
│   ├── init/                   # Scripts d'initialisation SQL
│   │   ├── 01-create-database.sql
│   │   └── 02-create-tables.sql
│   └── README.md               # Documentation infrastructure
│
├── 📁 test/                    # Données et outils de test
│   ├── file/                   # Fichiers CSV de données test
│   │   ├── patient.csv
│   │   ├── patient_adresse.csv
│   │   ├── donnees_pmsi.csv
│   │   └── ... (8 autres tables)
│   └── loader/                 # Loader Python avancé
│       ├── load_test_patients.py
│       ├── requirements.txt
│       └── README.md           # Documentation loader
│
└── 📄 README.md               # Cette documentation
```

## 🔧 Technologies et Outils

### Base de Données
- **PostgreSQL 16** - SGBD principal avec optimisations françaises
- **UTF-8 Encoding** - Support complet caractères français
- **Collation française** - Tri alphabétique correct (à, ç, é, è, etc.)
- **Extensions** - uuid-ossp, unaccent, pg_stat_statements

### Outils de Développement
- **Docker & Docker Compose** - Conteneurisation et orchestration
- **Python 3.7+** avec psycopg2 - Chargement optimisé des données
- **pgAdmin 4** - Interface d'administration web (optionnelle)
- **Git** - Versioning et déploiement

### Standards de Santé
- **Codes ICD-10** - Diagnostics médicaux
- **Codes ATC** - Classification thérapeutique des médicaments
- **Codes LOINC** - Résultats de laboratoire  
- **Codes CCAM** - Classification commune des actes médicaux
- **PMSI** - Programme de médicalisation des systèmes d'information
---

## 📈 Performance et Monitoring

### Métriques Clés
- **Temps de démarrage** : < 60 secondes pour l'infrastructure complète
- **Chargement des données** : ~172 rows en < 5 secondes  
- **Utilisation mémoire** : 512MB-2GB selon configuration
- **Espace disque** : ~100MB pour données de test

### Monitoring Intégré
```bash
# État des services
docker-compose ps

# Statistiques en temps réel
docker stats ehr_postgres_db

# Métriques PostgreSQL
docker-compose exec postgres_ehr psql -U ehr_user -d ehr -c "
SELECT schemaname, relname, n_tup_ins as rows, n_tup_upd as updates
FROM pg_stat_user_tables 
ORDER BY n_tup_ins DESC;
"
```
---

## 🔒 Sécurité et Bonnes Pratiques

### Configuration Sécurisée
- ✅ Mots de passe configurables via variables d'environnement
- ✅ Réseau Docker isolé pour sécurité
- ✅ Utilisateur PostgreSQL dédié (non-root)
- ✅ Volumes persistants pour données critiques
- ✅ Healthchecks automatiques des services

### Recommandations de Production
1. **Changez tous les mots de passe par défaut**
2. **Activez SSL/TLS pour les connexions externes**
3. **Configurez des sauvegardes automatiques**
4. **Limitez l'accès réseau aux ports nécessaires**
5. **Surveillez les logs et métriques de performance**

---

## 🆘 Support et Dépannage

### Problèmes Courants

#### ❌ Erreur de caractères français
```bash
# Solution : Vérifier l'encodage
docker-compose exec postgres_ehr psql -U ehr_user -d ehr -c "SHOW server_encoding;"
# Doit retourner : UTF8
```

#### ❌ Port 5433 déjà utilisé
```bash
# Solution : Changer le port dans .env
echo "POSTGRES_PORT=5434" >> .env
docker-compose down && docker-compose up -d
```

#### ❌ Données de test non chargées
```bash
# Solution : Vérifier l'ordre des étapes
cd test/loader
python load_test_patients.py --validate-only --database ehr --user ehr_user
```

### Commandes de Diagnostic
```bash
# Logs détaillés
docker-compose logs --tail=50 postgres_ehr

# Connexion de débogage  
docker-compose exec postgres_ehr psql -U ehr_user -d ehr

# Reset complet (⚠️ perte de données)
docker-compose down -v && docker-compose up -d
```

---

## 📚 Ressources Supplémentaires

### Documentation Référencée
- [Infrastructure Docker](ehr-docker/README.md) - Guide complet de déploiement
- [Loader Python](test/loader/README.md) - Documentation du chargeur de données
- [Fichiers de Prompts](prompt/) - Guides détaillés par tâche

### Standards et Conformité
- **FHIR R4** - Base pour la modélisation des ressources
- **HL7 France** - Profils français des ressources FHIR
- **ANS** (Agence du Numérique en Santé) - Standards français e-santé
- **RGPD** - Conformité protection des données personnelles

---

🇫🇷 **Infrastructure EHR complète avec support français optimal pour données de santé FHIR !**

*Version 1.0.0 - EHR Team - Support UTF-8 complet*