You are devops-docket-k8s. Create a complete, production-ready setup for HAPI FHIR using Docker with PostgreSQL as the database backend.

Provide the following deliverables:

1. **Docker Compose Configuration**
   - Complete docker-compose.yml file with:
     - HAPI FHIR JPA Server container
     - PostgreSQL database container
     - Proper networking configuration
     - Volume mappings for data persistence
     - Environment variables for configuration
     - Health checks for both services
     - Resource limits and restart policies

2. **PostgreSQL Configuration**
   - Database initialization scripts
   - User creation and permissions
   - Connection pooling settings
   - Performance tuning parameters for FHIR workloads
   - Backup strategy configuration

3. **HAPI FHIR Configuration**
   - application.yaml configuration file with:
     - Database connection settings
     - FHIR version support (R4)
     - Validation settings
     - CORS configuration
     - Security settings (if applicable)
     - Subscription settings
     - Bulk export configuration
   - JVM memory settings optimization

4. **Environment Files**
   - Your working directory is `hapi`.
   - .env file template with all configurable parameters
   - .env.example with documentation for each variable
   - Separate configs for development, staging, and production

5. **Initialization and Setup Scripts**
   - Shell script for first-time setup linux/mac and Powershell (Windows)
   - Database migration handling
   - Sample data loading script (optional)
   - Health check verification script

6. **Networking and Security**
   - Reverse proxy configuration (nginx/traefik example)
   - SSL/TLS setup instructions
   - Firewall rules recommendations
   - API rate limiting configuration

7. **Monitoring and Logging**
   - Log aggregation setup
   - Prometheus metrics export configuration
   - Basic Grafana dashboard for FHIR metrics
   - Alert rules for common issues

8. **Documentation**
   - README.md with:
     - Prerequisites and system requirements
     - Step-by-step installation guide
     - Configuration options explained
     - Troubleshooting common issues
     - Performance tuning guidelines
     - Backup and restore procedures
     - Upgrade path documentation

For each configuration file, include:
- Inline comments explaining key settings
- Security best practices notes
- Performance implications of different options
- Links to relevant documentation

Ensure all configurations follow these principles:
- Production-ready defaults
- Security-first approach
- Scalability considerations
- Easy maintenance and updates
- Compliance with FHIR standards

Format all code blocks with proper syntax highlighting and include file paths where each file should be placed in the project structure.