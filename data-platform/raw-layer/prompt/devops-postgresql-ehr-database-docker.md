<goal>
Create a complete Docker infrastructure for PostgreSQL with optimal support for French.
</goal>
<instructions>
I want to dockerize a PostgreSQL database with the following specifications:
1. Structure of the files to be created:
```
data-platform/raw-layer/ehr-docker/
├── Dockerfile
├── docker-compose.yml
├── init/
│   ├── 01-create-database.sql
│   └── 02-create-tables.sql
├── .env
├── .env.example
└── README.md
```
2. Required PostgreSQL configuration:
- **PostgreSQL version:** 16 (latest stable)
- **Database:** `ehr` (created automatically if it does not exist)
- **Encoding:** UTF-8 with full French support
- **Locale:** fr_FR.UTF-8
- **Collation:** French_France or fr_FR for correct French alphabetical sorting
- **Exposed port:** 5432 (mapped to host port 5433 to avoid conflicts)
- **Persistent volumes:** for PostgreSQL data
3. Database initialization:
- Automatically create the `ehr` database on first startup
- Execute the SQL script `data-platform\raw-layer\sql\ehr-ddl.sql` to create the tables
- The script must handle cases where the tables already exist (CREATE TABLE IF NOT EXISTS)
- Configure the appropriate user privileges
4. Environment variables (.env):
```
POSTGRES_DB=ehr
POSTGRES_USER=ehr_user
POSTGRES_PASSWORD=ehr_user_123
POSTGRES_HOST=localhost
POSTGRES_PORT=5433
```
5. Optimizations for French:
- System locale configuration set to fr_FR.UTF-8
- PostgreSQL settings for French collation and search:
  - `lc_collate = 'fr_FR.UTF-8'`
  - `lc_ctype = 'fr_FR.UTF-8'`
  - `lc_messages = 'fr_FR.UTF-8'`
  - `lc_monetary = 'fr_FR.UTF-8'`
  - `lc_numeric = 'fr_FR.UTF-8'`
  - `lc_time = 'fr_FR.UTF-8'`
- Support for French accents and special characters (é, è, ê, ë, à, ç, ù, œ, etc.)
6. SQL initialization scripts:
Based on:
- data-platform\raw-layer\sql\create_ehr_database.sql -> 01-create-database.sql
- data-platform\raw-layer\sql\ehr-ddl.sql -> 02-create-tables.sql
7. Docker Compose features :
- Healthcheck to verify that PostgreSQL is ready
- Restart policy: unless-stopped
- Custom network for isolation
- Labels for documentation
- Memory and CPU limits if needed
8. Documentation (README.md) :
- Installation and startup instructions
- How to connect to the database
- How to import CSV data in French
- Handling common encoding issues
- Example queries with French collation
</instructions>
<recommandations>
- All files must be in UTF-8
- Comments in the code must be in French
- Include error handling and logging
- Secure passwords (use .env, no hardcoding)
</recommandations>
<output>
The structure of the files to be created is as follows: `data-platform\raw-layer\ehr-docker` containing Dockerfile, docker-compose.yml, an init/ folder with 01-create-database.sql and 02-create-tables.sql, .env and .env.example files, and README.md.
</output>

<claude>
<summary>
📊 Spécifications Techniques Respectées

  ✅ PostgreSQL 16 avec optimisations françaises
  ✅ Base ehr créée automatiquement
  ✅ UTF-8 + fr_FR.UTF-8 locale et collation
  ✅ Port 5433 mappé pour éviter conflits
  ✅ Volumes persistants pour données
  ✅ Scripts DDL adaptés avec CREATE TABLE IF NOT EXISTS
  ✅ Variables d'environnement sécurisées dans .env
  ✅ Healthcheck et restart policy
  ✅ Documentation complète avec exemples français
  ✅ Support caractères accentués et tri français
</summary>
</claude>