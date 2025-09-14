#!/bin/bash
set -e  # Arrêter en cas d'erreur

echo "========================================="
echo "Initialisation de l'utilisateur EHR PostgreSQL"
echo "========================================="

# Variables avec valeurs par défaut si non définies
EHR_USER="${EHR_USER:-ehr_user}"
EHR_PASSWORD="${EHR_PASSWORD:-ehr_user_123}"
EHR_DB="${EHR_DB:-ehr}"
#DB_GRANT_SUPERUSER="${APP_GRANT_SUPERUSER:-false}"
#DB_CONNECTION_LIMIT="${APP_CONNECTION_LIMIT:--1}"  # -1 = illimité

echo "Configuration HAPI:"
echo "  - Utilisateur: $EHR_USER"
echo "  - Base de données: $EHR_DB"
#echo "  - Superuser: $DB_GRANT_SUPERUSER"
#echo "  - Limite de connexions: $DB_CONNECTION_LIMIT"
echo ""

# Fonction pour vérifier si un utilisateur existe
user_exists() {
    psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_user WHERE usename='$1'" | grep -q 1
}

# Fonction pour vérifier si une base existe
database_exists() {
    psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='$1'" | grep -q 1
}

# Créer l'utilisateur
if user_exists "$EHR_USER"; then
    echo "⚠️  L'utilisateur $EHR_USER existe déjà, mise à jour du mot de passe..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        ALTER USER ${EHR_USER} WITH PASSWORD '${EHR_PASSWORD}';
EOSQL
else
    echo "✅ Création de l'utilisateur $EHR_USER..."
    
    # Construire la commande CREATE USER selon les options
    if [ "$EHR_GRANT_SUPERUSER" = "true" ]; then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
            CREATE USER ${EHR_USER} WITH 
                PASSWORD '${EHR_PASSWORD}'
                SUPERUSER
                CREATEDB
                CREATEROLE;
EOSQL
    else
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
            CREATE USER ${EHR_USER} WITH 
                PASSWORD '${EHR_PASSWORD}'
                NOSUPERUSER
                NOCREATEDB
                NOCREATEROLE;
EOSQL
    fi
fi

# Créer la base de données
if database_exists $EHR_DB; then
    echo "⚠️  La base de données ehr existe déjà"
else
    echo "✅ Création de la base de données hapi..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        CREATE DATABASE ${EHR_DB} OWNER ${EHR_USER};
EOSQL
fi

# Accorder les privilèges
echo "✅ Configuration des privilèges..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    -- Privilèges sur la base de données
    GRANT ALL PRIVILEGES ON DATABASE ${EHR_DB} TO ${EHR_USER};
EOSQL

# Se connecter à la nouvelle base pour configurer les permissions du schéma
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    -- Privilèges sur le schéma public
    GRANT ALL ON SCHEMA public TO ${EHR_USER};
    
    -- Privilèges par défaut pour les futures tables
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${EHR_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${EHR_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${EHR_USER};
    
    -- Si des tables existent déjà, donner les permissions
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${EHR_USER};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${EHR_USER};
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ${EHR_USER};
EOSQL

echo ""
echo "========================================="
echo "✅ Initialisation EHR terminée avec succès!"
echo "========================================="
echo ""
echo "Connexion possible avec:"
echo "  psql -h localhost -U $EHR_USER -d $EHR_DB"
echo ""
