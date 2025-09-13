# 🏥 Infrastructure Docker PostgreSQL EHR avec Support Français

Infrastructure PostgreSQL conteneurisée optimisée pour les données de santé FHIR avec support complet du français.

## 🇫🇷 Fonctionnalités Principales

✅ **PostgreSQL 16** avec optimisations pour données de santé  
✅ **Support français complet**: UTF-8, collation française, locale fr_FR  
✅ **Caractères accentués**: é, è, ê, ë, à, ç, ù, œ, etc.  
✅ **Tri alphabétique français** avec collation appropriée  
✅ **Recherche textuelle française** avec configuration `french`  
✅ **Initialisation automatique** du schéma EHR  
✅ **Volumes persistants** pour données et logs  
✅ **Healthcheck intégré** et monitoring  
✅ **Interface pgAdmin** optionnelle  

## 📁 Structure des Fichiers

```
data-plateform/raw-layer/docker/
├── docker-compose.yml          # Configuration Docker Compose
├── init/                       # Scripts d'initialisation SQL
│   ├── 01-create-database.sql  # Création de la base de données
│   └── 02-create-tables.sql    # Création du schéma EHR
├── .env                        # Variables d'environnement (à créer)
├── .env.example               # Template de configuration
└── README.md                  # Cette documentation
```

## 🚀 Installation et Démarrage

### Prérequis

- Docker Engine 20.10+
- Docker Compose V2
- 2GB RAM disponible minimum
- 10GB espace disque libre

### 1. Configuration

```bash
# Copier le template de configuration
cp .env.example .env

# Éditer les variables d'environnement
nano .env

# IMPORTANT: Changer les mots de passe par défaut !
```

### 2. Démarrage de l'infrastructure

```bash
# Démarrage PostgreSQL seul
docker-compose up -d

# Démarrage avec pgAdmin (optionnel)
docker-compose --profile admin up -d

# Démarrage en mode développement complet
docker-compose --profile full up -d
```

### 3. Vérification du démarrage

```bash
# Vérifier l'état des services
docker-compose ps

# Voir les logs PostgreSQL
docker-compose logs postgres_ehr

# Vérifier la santé de PostgreSQL
docker-compose exec postgres_ehr pg_isready -U ehr_user -d ehr
```

## 🔧 Configuration

### Variables d'Environnement (.env)

```bash
# Base de données
POSTGRES_DB=ehr
POSTGRES_USER=ehr_user
POSTGRES_PASSWORD=votre_mot_de_passe_sécurisé

# Réseau
POSTGRES_HOST=localhost
POSTGRES_PORT=5433

# pgAdmin (optionnel)
PGADMIN_EMAIL=admin@ehr.local
PGADMIN_PASSWORD=admin_mot_de_passe_sécurisé
PGADMIN_PORT=8080
```

### Configuration Française Automatique

L'infrastructure configure automatiquement :

```sql
-- Encodage et locale
ENCODING = 'UTF8'
LC_COLLATE = 'fr_FR.UTF-8'
LC_CTYPE = 'fr_FR.UTF-8'
LC_MESSAGES = 'fr_FR.UTF-8'
LC_MONETARY = 'fr_FR.UTF-8'
LC_NUMERIC = 'fr_FR.UTF-8'
LC_TIME = 'fr_FR.UTF-8'

-- Recherche textuelle française
default_text_search_config = 'french'
```

## 🏗️ Schéma de Base de Données

### Tables Créées Automatiquement

1. **`patient`** - Informations démographiques patients
2. **`patient_adresse`** - Adresses et géocodage
3. **`donnees_pmsi`** - Données d'hospitalisation PMSI
4. **`diagnostics`** - Codes diagnostiques (ICD-10)
5. **`actes`** - Actes médicaux (CCAM)
6. **`biologie`** - Résultats de laboratoire (LOINC)
7. **`prescription`** - Prescriptions médicamenteuses (ATC)
8. **`posologie`** - Informations de dosage
9. **`administration`** - Administration de médicaments
10. **`dossier_soins`** - Dossier de soins et mesures
11. **`style_vie`** - Facteurs de style de vie

### Optimisations PostgreSQL 16

- **Index hash** pour recherches exactes
- **Index couvrants** avec colonnes INCLUDE
- **Index spatiaux GIST** pour géocodage
- **Recherche textuelle** avec support français
- **Contraintes de validation** complètes

## 💾 Connexion à la Base de Données

### Via Client PostgreSQL

```bash
# Connexion depuis l'hôte
psql -h localhost -p 5433 -U ehr_user -d ehr

# Connexion depuis un autre conteneur
psql -h postgres_ehr -p 5432 -U ehr_user -d ehr
```

### Via pgAdmin

1. Accéder à http://localhost:8080
2. Se connecter avec les identifiants configurés dans `.env`
3. Ajouter un serveur :
   - Nom: EHR PostgreSQL
   - Hôte: postgres_ehr
   - Port: 5432
   - Base: ehr
   - Utilisateur/Mot de passe: depuis `.env`

### Via Python (psycopg2)

```python
import psycopg2

# Configuration de connexion
conn_params = {
    'host': 'localhost',
    'port': 5433,
    'database': 'ehr',
    'user': 'ehr_user',
    'password': 'votre_mot_de_passe',
    'client_encoding': 'UTF8'
}

# Connexion avec support français
conn = psycopg2.connect(**conn_params)
conn.set_client_encoding('UTF8')
```

## 📊 Import de Données CSV Françaises

### Utilisation du Loader Python

```bash
# Aller dans le répertoire du loader
cd ../test/loader

# Installer les dépendances
pip install -r requirements.txt

# Charger les données de test avec détection d'encodage
python load_test_patients.py \
    --database ehr \
    --user ehr_user \
    --password votre_mot_de_passe \
    --host localhost \
    --port 5433 \
    --clear
```

### Import Manuel avec Caractères Français

```sql
-- Définir l'encodage pour la session
SET client_encoding = 'UTF8';

-- Import avec COPY pour performance optimale
COPY patient(nom, prenom, sexe, date_naissance) 
FROM '/path/to/patients.csv' 
WITH (FORMAT CSV, HEADER true, ENCODING 'UTF8');

-- Vérifier l'import des caractères français
SELECT nom, prenom 
FROM patient 
WHERE nom ~ '[éèêëàâäçîïôöùûüÿñ]'
ORDER BY nom COLLATE "fr_FR";
```

## 🔍 Requêtes avec Support Français

### Recherche Textuelle Française

```sql
-- Recherche insensible aux accents
SELECT nom, prenom 
FROM patient 
WHERE to_tsvector('french', nom || ' ' || prenom) @@ to_tsquery('french', 'francois');

-- Fonction de nettoyage des accents
SELECT clean_french_text('François-José Müller');
-- Résultat: 'francois-jose muller'
```

### Tri Alphabétique Français

```sql
-- Tri correct avec collation française
SELECT nom, prenom 
FROM patient 
ORDER BY nom COLLATE "fr_FR.UTF-8", prenom COLLATE "fr_FR.UTF-8";

-- Tri avec caractères spéciaux
SELECT * FROM patient 
WHERE nom LIKE '%ç%' OR nom LIKE '%é%'
ORDER BY nom COLLATE "fr_FR";
```

### Requêtes avec Dates Françaises

```sql
-- Affichage de dates en français
SELECT 
    nom,
    prenom,
    to_char(date_naissance, 'DD TMMonth YYYY', 'lc_time=fr_FR.UTF-8') as date_naissance_fr
FROM patient
ORDER BY date_naissance DESC;
```

## 🛠️ Gestion des Problèmes d'Encodage

### Problèmes Courants et Solutions

#### 1. Caractères Affichés Incorrectement

```bash
# Vérifier l'encodage de la base
docker-compose exec postgres_ehr psql -U ehr_user -d ehr -c "SHOW server_encoding;"

# Vérifier la locale
docker-compose exec postgres_ehr locale
```

#### 2. Erreurs d'Import CSV

```sql
-- Détecter l'encodage d'un fichier
\! file -i /path/to/file.csv

-- Import avec encodage spécifique
COPY table_name FROM '/path/to/file.csv' 
WITH (FORMAT CSV, ENCODING 'LATIN1');
```

#### 3. Tri Incorrect des Caractères Français

```sql
-- Vérifier la collation
SELECT datname, datcollate, datctype 
FROM pg_database 
WHERE datname = 'ehr';

-- Forcer la collation française
SELECT * FROM table_name ORDER BY column_name COLLATE "fr_FR.UTF-8";
```

## 📈 Monitoring et Maintenance

### Vérification de l'État

```bash
# Santé des conteneurs
docker-compose ps
docker-compose exec postgres_ehr pg_isready

# Statistiques de performance
docker stats ehr_postgres_db

# Espace disque utilisé
docker-compose exec postgres_ehr du -sh /var/lib/postgresql/data
```

### Logs et Diagnostics

```bash
# Logs PostgreSQL
docker-compose logs -f postgres_ehr

# Logs avec timestamp
docker-compose logs -f --timestamps postgres_ehr

# Logs d'erreurs uniquement
docker-compose logs postgres_ehr 2>&1 | grep ERROR
```

### Sauvegarde et Restauration

```bash
# Sauvegarde complète
docker-compose exec postgres_ehr pg_dump -U ehr_user -d ehr > backup_ehr.sql

# Sauvegarde avec compression
docker-compose exec postgres_ehr pg_dump -U ehr_user -d ehr | gzip > backup_ehr.sql.gz

# Restauration
docker-compose exec -T postgres_ehr psql -U ehr_user -d ehr < backup_ehr.sql
```

## 🔒 Sécurité

### Recommandations de Production

1. **Mots de passe forts** (12+ caractères, mixte)
2. **SSL/TLS** activé pour connexions externes
3. **Pare-feu** limitant l'accès au port 5433
4. **Sauvegrades régulières** automatisées
5. **Monitoring** des connexions et performances

### Configuration SSL/TLS

```yaml
# Ajout dans docker-compose.yml
environment:
  - POSTGRES_INITDB_ARGS=--auth-host=md5 --auth-local=md5
  - POSTGRES_HOST_AUTH_METHOD=md5
volumes:
  - ./ssl/server.crt:/var/lib/postgresql/server.crt:ro
  - ./ssl/server.key:/var/lib/postgresql/server.key:ro
command: >
  postgres
  -c ssl=on
  -c ssl_cert_file=/var/lib/postgresql/server.crt
  -c ssl_key_file=/var/lib/postgresql/server.key
```

## 🧪 Tests et Validation

### Test de Configuration Française

```sql
-- Test des caractères français
SELECT check_french_encoding();

-- Test du tri français
CREATE TEMP TABLE test_tri AS 
SELECT unnest(ARRAY['André', 'Émile', 'Zoé', 'Élise']) as nom;

SELECT nom FROM test_tri ORDER BY nom COLLATE "fr_FR.UTF-8";
```

### Test de Performance

```sql
-- Statistiques d'index
SELECT schemaname, tablename, indexname, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE schemaname = 'public'
ORDER BY idx_tup_read DESC;

-- Performance des requêtes
SELECT query, mean_time, calls 
FROM pg_stat_statements 
WHERE query LIKE '%patient%'
ORDER BY mean_time DESC;
```

## 📞 Support et Dépannage

### Commandes Utiles

```bash
# Redémarrer PostgreSQL seul
docker-compose restart postgres_ehr

# Réinitialiser complètement (⚠️ PERTE DE DONNÉES)
docker-compose down -v
docker-compose up -d

# Accès shell au conteneur
docker-compose exec postgres_ehr bash

# Connexion psql directe
docker-compose exec postgres_ehr psql -U ehr_user -d ehr
```

### FAQ

**Q: Comment changer le mot de passe PostgreSQL ?**
```sql
ALTER USER ehr_user PASSWORD 'nouveau_mot_de_passe';
```

**Q: Comment augmenter les performances ?**
```bash
# Ajuster les paramètres dans .env
POSTGRES_SHARED_BUFFERS=512MB
POSTGRES_EFFECTIVE_CACHE_SIZE=2GB
```

**Q: Comment activer les logs de requêtes lentes ?**
```bash
# Dans docker-compose.yml
-c log_min_duration_statement=500
```

## 🔄 Mise à Jour

### Mise à Jour de PostgreSQL

```bash
# Sauvegarder avant mise à jour
docker-compose exec postgres_ehr pg_dumpall -U ehr_user > backup_full.sql

# Mettre à jour l'image
docker-compose pull postgres_ehr
docker-compose up -d postgres_ehr
```

### Mise à Jour du Schéma

```bash
# Appliquer les migrations
docker-compose exec postgres_ehr psql -U ehr_user -d ehr -f /docker-entrypoint-initdb.d/migration.sql
```

## 📄 Licence et Contribution

Ce projet est conçu pour les données de santé FHIR avec support français optimal.

**Équipe de maintenance**: EHR Team  
**Version**: 1.0.0  
**Support français**: Complet (UTF-8, fr_FR.UTF-8)  

---

🇫🇷 **Infrastructure PostgreSQL prête pour données de santé françaises avec support FHIR complet !**