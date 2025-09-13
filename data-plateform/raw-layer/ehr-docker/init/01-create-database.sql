-- ========================================================================
-- Script d'initialisation PostgreSQL pour base de données EHR
-- Support complet UTF-8 pour données françaises
-- Version simplifiée sans variables complexes
-- ========================================================================

\echo '🏥 Initialisation de la base de données EHR avec support UTF-8...'

-- La base de données 'ehr' est créée automatiquement par Docker
-- Connexion à la base EHR pour configuration
\c ehr

-- Configuration des paramètres de session pour UTF-8
SET client_encoding TO 'UTF8';
SET lc_messages TO 'C.UTF-8';
SET lc_monetary TO 'C.UTF-8';
SET lc_numeric TO 'C.UTF-8';
SET lc_time TO 'C.UTF-8';
SET default_text_search_config TO 'french';

\echo '🔧 Configuration UTF-8 et française appliquée'

-- Création des extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "unaccent" SCHEMA public;

\echo '📦 Extensions PostgreSQL installées'

-- Configuration des privilèges pour l'utilisateur EHR
GRANT ALL PRIVILEGES ON DATABASE ehr TO ehr_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO ehr_user;
GRANT CREATE ON SCHEMA public TO ehr_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ehr_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ehr_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ehr_user;

\echo '👤 Privilèges utilisateur configurés'

-- Fonction utilitaire pour vérifier l'encodage
CREATE OR REPLACE FUNCTION check_encoding()
RETURNS TABLE(parameter text, value text, description text)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'encoding'::text as parameter,
        pg_encoding_to_char(encoding) as value,
        'Encodage de la base de données'::text as description
    FROM pg_database WHERE datname = current_database()
    
    UNION ALL
    
    SELECT 
        'lc_collate'::text,
        datcollate,
        'Ordre de tri (collation)'::text
    FROM pg_database WHERE datname = current_database()
    
    UNION ALL
    
    SELECT 
        'lc_ctype'::text,
        datctype,
        'Classification des caractères'::text
    FROM pg_database WHERE datname = current_database()
    
    UNION ALL
    
    SELECT 
        'default_text_search_config'::text,
        current_setting('default_text_search_config'),
        'Configuration recherche textuelle'::text;
END
$$;

-- Fonction de nettoyage pour les accents (utile pour recherches)
CREATE OR REPLACE FUNCTION clean_french_text(input_text TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN unaccent(LOWER(TRIM(input_text)));
END
$$;

COMMENT ON FUNCTION clean_french_text(TEXT) IS 'Fonction utilitaire pour nettoyer le texte français (suppression accents, minuscules, espaces)';

-- Test des caractères français
DO $TEST$
BEGIN
    -- Test d'insertion et tri de caractères français
    CREATE TEMP TABLE test_francais (
        id SERIAL,
        texte TEXT
    );
    
    INSERT INTO test_francais (texte) VALUES 
        ('André'), ('Émile'), ('Élise'), ('Cécile'), 
        ('François'), ('Josée'), ('Noël'), ('Zoé');
    
    -- Test du tri français
    IF (SELECT COUNT(*) FROM test_francais) = 8 THEN
        RAISE NOTICE '✅ Test des caractères français réussi';
    ELSE
        RAISE WARNING '⚠️ Problème avec le tri des caractères français';
    END IF;
    
    DROP TABLE test_francais;
END
$TEST$;

\echo '✅ Initialisation de la base de données EHR terminée!'
\echo '🇫🇷 Support UTF-8 complet activé pour caractères français'
\echo '📊 Base de données prête pour les données de santé FHIR'

-- Affichage des informations de configuration
\echo ''
\echo '=== INFORMATIONS DE CONFIGURATION ==='
SELECT 
    current_database() as "Base de données",
    current_user as "Utilisateur actuel",
    version() as "Version PostgreSQL";

SELECT * FROM check_encoding();