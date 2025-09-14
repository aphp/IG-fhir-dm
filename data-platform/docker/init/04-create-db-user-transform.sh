#!/bin/bash
set -e  # Arrêter en cas d'erreur

echo "========================================="
echo "Initialisation de l'utilisateur TRANSFORM LAYER PostgreSQL"
echo "========================================="

# Variables avec valeurs par défaut si non définies
TRANSFORM_USER="${TRANSFORM_USER:-transform_user}"
TRANSFORM_PASSWORD="${TRANSFORM_PASSWORD:-transform_user_123}"
TRANSFORM_NAME="${TRANSFORM_DB:-transform_layer}"
#DB_GRANT_SUPERUSER="${APP_GRANT_SUPERUSER:-false}"
#DB_CONNECTION_LIMIT="${APP_CONNECTION_LIMIT:--1}"  # -1 = illimité

echo "Configuration TRANSFORM LAYER:"
echo "  - Utilisateur: $TRANSFORM_USER"
echo "  - Base de données: $TRANSFORM_NAME"
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
if user_exists "$TRANSFORM_USER"; then
    echo "⚠️  L'utilisateur $TRANSFORM_USER existe déjà, mise à jour du mot de passe..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        ALTER USER ${TRANSFORM_USER} WITH PASSWORD '${TRANSFORM_PASSWORD}';
EOSQL
else
    echo "✅ Création de l'utilisateur $TRANSFORM_USER..."
    
    # Construire la commande CREATE USER selon les options
    if [ "$TRANSFORM_GRANT_SUPERUSER" = "true" ]; then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
            CREATE USER ${TRANSFORM_USER} WITH 
                PASSWORD '${TRANSFORM_PASSWORD}'
                SUPERUSER
                CREATEDB
                CREATEROLE;
EOSQL
    else
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
            CREATE USER ${TRANSFORM_USER} WITH 
                PASSWORD '${TRANSFORM_PASSWORD}'
                NOSUPERUSER
                NOCREATEDB
                NOCREATEROLE;
EOSQL
    fi
fi

# Créer la base de données
if database_exists $TRANSFORM_NAME; then
    echo "⚠️  La base de données "$TRANSFORM_NAME" existe déjà"
else
    echo "✅ Création de la base de données "$TRANSFORM_NAME"..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        CREATE DATABASE ${TRANSFORM_NAME} OWNER ${TRANSFORM_USER};
EOSQL
fi

# Accorder les privilèges
echo "✅ Configuration des privilèges..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    -- Privilèges sur la base de données
    GRANT ALL PRIVILEGES ON DATABASE ${TRANSFORM_NAME} TO ${TRANSFORM_USER};
EOSQL

# Se connecter à la nouvelle base pour configurer les permissions du schéma
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    -- Privilèges sur le schéma public
    GRANT ALL ON SCHEMA public TO ${TRANSFORM_USER};
    
    -- Privilèges par défaut pour les futures tables
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${TRANSFORM_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${TRANSFORM_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${TRANSFORM_USER};
    
    -- Si des tables existent déjà, donner les permissions
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${TRANSFORM_USER};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${TRANSFORM_USER};
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ${TRANSFORM_USER};
EOSQL

echo ""
echo "========================================="
echo "✅ Initialisation TRANSFORM LAYER terminée avec succès!"
echo "========================================="
echo ""
echo "Connexion possible avec:"
echo "  psql -h localhost -U $TRANSFORM_USER -d $TRANSFORM_NAME"
echo ""