#!/bin/bash
set -e  # Arrêter en cas d'erreur

echo "========================================="
echo "Initialisation de l'utilisateur SEMANTIC LAYER PostgreSQL"
echo "========================================="

# Variables avec valeurs par défaut si non définies
SEMANTIC_USER="${SEMANTIC_USER:-semantic_user}"
SEMANTIC_PASSWORD="${SEMANTIC_PASSWORD:-semantic_user_123}"
SEMANTIC_NAME="${SEMANTIC_DB:-semantic_layer}"
#DB_GRANT_SUPERUSER="${APP_GRANT_SUPERUSER:-false}"
#DB_CONNECTION_LIMIT="${APP_CONNECTION_LIMIT:--1}"  # -1 = illimité

echo "Configuration SEMANTIC LAYER:"
echo "  - Utilisateur: $SEMANTIC_USER"
echo "  - Base de données: $SEMANTIC_NAME"
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
if user_exists "$SEMANTIC_USER"; then
    echo "⚠️  L'utilisateur $SEMANTIC_USER existe déjà, mise à jour du mot de passe..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        ALTER USER ${SEMANTIC_USER} WITH PASSWORD '${SEMANTIC_PASSWORD}';
EOSQL
else
    echo "✅ Création de l'utilisateur $SEMANTIC_USER..."
    
    # Construire la commande CREATE USER selon les options
    if [ "$SEMANTIC_GRANT_SUPERUSER" = "true" ]; then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
            CREATE USER ${SEMANTIC_USER} WITH 
                PASSWORD '${SEMANTIC_PASSWORD}'
                SUPERUSER
                CREATEDB
                CREATEROLE;
EOSQL
    else
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
            CREATE USER ${SEMANTIC_USER} WITH 
                PASSWORD '${SEMANTIC_PASSWORD}'
                NOSUPERUSER
                NOCREATEDB
                NOCREATEROLE;
EOSQL
    fi
fi

# Créer la base de données
if database_exists $SEMANTIC_NAME; then
    echo "⚠️  La base de données "$SEMANTIC_NAME" existe déjà"
else
    echo "✅ Création de la base de données $SEMANTIC_NAME..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        CREATE DATABASE ${SEMANTIC_NAME} OWNER ${SEMANTIC_USER};
EOSQL
fi

# Accorder les privilèges
echo "✅ Configuration des privilèges..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    -- Privilèges sur la base de données
    GRANT ALL PRIVILEGES ON DATABASE ${SEMANTIC_NAME} TO ${SEMANTIC_USER};
EOSQL

# Se connecter à la nouvelle base pour configurer les permissions du schéma
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    -- Privilèges sur le schéma public
    GRANT ALL ON SCHEMA public TO ${SEMANTIC_USER};
    
    -- Privilèges par défaut pour les futures tables
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${SEMANTIC_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${SEMANTIC_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${SEMANTIC_USER};
    
    -- Si des tables existent déjà, donner les permissions
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${SEMANTIC_USER};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${SEMANTIC_USER};
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ${SEMANTIC_USER};
EOSQL

echo ""
echo "========================================="
echo "✅ Initialisation SEMANTIC LAYER terminée avec succès!"
echo "========================================="
echo ""
echo "Connexion possible avec:"
echo "  psql -h localhost -U $SEMANTIC_USER -d $SEMANTIC_NAME"
echo ""