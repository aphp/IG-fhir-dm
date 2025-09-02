# HAPI FHIR Production Setup

A complete, production-ready HAPI FHIR JPA Server setup using Docker with PostgreSQL, monitoring, and security features.

## 🏗️ Architecture Overview

This setup includes:
- **HAPI FHIR JPA Server** (R4) - Main FHIR server
- **PostgreSQL 15** - Primary database with optimized configuration
- **Nginx** - Reverse proxy with SSL and security features
- **Prometheus** - Metrics collection and monitoring
- **Grafana** - Visualization and dashboards
- **PostgreSQL Exporter** - Database metrics

## 📋 Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows with WSL2
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: Minimum 20GB free space
- **CPU**: 2+ cores recommended

### Software Requirements
- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0+)
- `curl` (for health checks)
- `openssl` (for SSL certificates)

### Network Requirements
- Ports 80, 443, 3000, 8080, 9090 available
- Internet access for Docker image downloads

## 🚀 Quick Start

### 1. Initial Setup
```bash
# Clone or download this configuration
cd hapi

# Run the setup script
./scripts/setup.sh
```

The setup script will:
- Check prerequisites
- Create necessary directories
- Generate SSL certificates (self-signed for development)
- Create Docker network
- Pull required images
- Validate configuration

### 2. Configure Environment
```bash
# Copy and edit environment file
cp .env.example .env
nano .env  # or your preferred editor
```

**⚠️ Important**: Change these values in `.env`:
- `POSTGRES_PASSWORD` - Use a strong password
- `GRAFANA_PASSWORD` - Change from default 'admin'
- `HAPI_CORS_ALLOWED_ORIGIN` - Set appropriate origins for production

### 3. Start Services
```bash
# Start all services
./scripts/start.sh

# Or use docker-compose directly
docker-compose up -d
```

### 4. Verify Installation
```bash
# Check service health
./scripts/health-check.sh

# View logs
docker-compose logs -f
```

## 🌐 Access Points

After successful startup, access these endpoints:

| Service | URL | Credentials |
|---------|-----|-------------|
| HAPI FHIR Server | http://localhost:8080 | None |
| FHIR API | http://localhost:8080/fhir | None |
| FHIR API (HTTPS) | https://localhost/fhir | None |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | None |

## 📊 Sample Data

Load sample FHIR resources for testing:
```bash
./scripts/load-sample-data.sh
```

This creates:
- 1 Patient resource
- 1 Practitioner resource  
- 2 Observation resources (Blood Pressure, Weight)
- 1 Encounter resource

## 🔧 Configuration

### Environment Files

- `.env` - Development configuration
- `.env.production` - Production template
- `.env.example` - Documentation and examples

### Key Configuration Areas

#### HAPI FHIR Server
- `config/application.yaml` - Main HAPI configuration
- FHIR version, validation, subscriptions, bulk export
- JPA/Hibernate settings
- Security and CORS configuration

#### PostgreSQL
- `postgres/postgresql.conf` - Database performance tuning
- `postgres/init/01-init-db.sql` - Database initialization
- Connection pooling and memory settings

#### Nginx
- `nginx/nginx.conf` - Reverse proxy configuration
- SSL/TLS termination
- Rate limiting and security headers
- CORS handling

#### Monitoring
- `monitoring/prometheus/prometheus.yml` - Metrics collection
- `monitoring/grafana/` - Dashboards and datasources
- Alert rules for common issues

## 🛡️ Security Features

### Network Security
- Nginx reverse proxy with security headers
- Rate limiting for API endpoints
- SSL/TLS encryption (HTTPS)
- Firewall-friendly Docker networking

### Application Security
- CORS configuration
- Request validation
- SQL injection protection via JPA
- Container resource limits

### Database Security
- Dedicated database user with minimal privileges
- Connection pooling with timeouts
- Read-only user for analytics
- Audit logging capabilities

## 📈 Monitoring & Observability

### Metrics Collection
- **Application metrics**: HTTP requests, response times, errors
- **JVM metrics**: Memory usage, GC performance, thread pools
- **Database metrics**: Connections, query performance, locks
- **System metrics**: CPU, memory, disk usage

### Dashboards
- **HAPI FHIR Overview**: Request rates, response times, errors
- **JVM Performance**: Memory, GC, thread analysis  
- **Database Performance**: Connection pools, query statistics
- **System Resources**: CPU, memory, disk utilization

### Alerting
Pre-configured alerts for:
- Service downtime
- High error rates
- Memory exhaustion
- Database connection issues
- Slow response times

## 🔄 Operations

### Starting Services
```bash
./scripts/start.sh
```

### Stopping Services
```bash
./scripts/stop.sh
```

### Health Checks
```bash
./scripts/health-check.sh
```

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f hapi-fhir
docker-compose logs -f postgres
```

### Scaling
```bash
# Scale HAPI FHIR instances
docker-compose up -d --scale hapi-fhir=3
```

## 💾 Backup & Recovery

### Database Backup
```bash
# Create backup
docker-compose exec postgres pg_dump -U hapi -d hapi > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker-compose exec -T postgres psql -U hapi -d hapi < backup_file.sql
```

### Configuration Backup
```bash
# Backup configurations
tar -czf hapi-config-backup-$(date +%Y%m%d).tar.gz config/ nginx/ monitoring/ .env
```

### Volume Backup
```bash
# Backup Docker volumes
docker run --rm -v hapi_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data-backup.tar.gz /data
```

## 🔧 Performance Tuning

### Database Optimization
- Adjust `shared_buffers` and `effective_cache_size` based on available RAM
- Monitor slow queries via `pg_stat_statements`
- Create additional indexes for frequent FHIR searches
- Regular `VACUUM` and `ANALYZE` operations

### HAPI FHIR Optimization
- Increase JVM heap size (`JVM_HEAP_MAX`) for large datasets
- Adjust connection pool settings (`HIKARI_MAXIMUM_POOL_SIZE`)
- Enable/disable features based on usage patterns
- Configure appropriate pagination limits

### System Resources
```bash
# Monitor resource usage
docker stats

# Adjust container limits in docker-compose.yml
# CPU and memory limits per service
```

## 🐛 Troubleshooting

### Common Issues

#### Service Won't Start
1. Check port availability: `netstat -tulpn | grep :8080`
2. Verify Docker daemon is running
3. Check logs: `docker-compose logs [service-name]`
4. Validate configuration: `docker-compose config`

#### Database Connection Issues
1. Verify PostgreSQL is running: `docker-compose ps postgres`
2. Check connection settings in `.env` file
3. Test connection: `docker-compose exec postgres pg_isready -U hapi`
4. Review PostgreSQL logs: `docker-compose logs postgres`

#### High Memory Usage
1. Monitor JVM heap: Check Grafana dashboard
2. Adjust heap settings: `JVM_HEAP_MAX` in `.env`
3. Enable GC logging: Add JVM options in docker-compose.yml
4. Check for memory leaks: Use profiling tools

#### Slow Performance
1. Check database performance: Review slow query logs
2. Monitor connection pool: Check HikariCP metrics
3. Verify resource limits: `docker stats`
4. Review Nginx access logs for patterns

### Log Locations
- **HAPI FHIR**: `logs/hapi/`
- **Nginx**: `logs/nginx/`
- **PostgreSQL**: Available via `docker-compose logs postgres`
- **Prometheus**: Available via `docker-compose logs prometheus`

### Debugging Commands
```bash
# Enter container shell
docker-compose exec hapi-fhir /bin/bash
docker-compose exec postgres /bin/bash

# Check container resources
docker-compose exec hapi-fhir cat /proc/meminfo
docker-compose exec hapi-fhir top

# Validate configurations
docker-compose config
nginx -t  # (inside nginx container)
```

## 🔄 Upgrade Process

### HAPI FHIR Upgrades
1. Review [HAPI FHIR changelog](https://github.com/hapifhir/hapi-fhir/releases)
2. Update `HAPI_VERSION` in `.env`
3. Backup database and configurations
4. Test in development environment first
5. Plan for downtime during database migrations

### Database Upgrades
1. Backup existing data
2. Update PostgreSQL image version
3. Test compatibility with HAPI FHIR version
4. Monitor performance after upgrade

## 🤝 Contributing

### Development Setup
1. Fork this repository
2. Create feature branch
3. Test changes thoroughly
4. Update documentation
5. Submit pull request

### Configuration Updates
- Test in development environment first
- Document changes in commit messages
- Update `.env.example` if adding new variables
- Update this README for new features

## 📚 Additional Resources

### FHIR Resources
- [FHIR R4 Specification](http://hl7.org/fhir/R4/)
- [HAPI FHIR Documentation](https://hapifhir.io/hapi-fhir/docs/)
- [FHIR Test Data](https://github.com/smart-on-fhir/sample-patients)

### Docker & DevOps
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

### Monitoring
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [JVM Monitoring Best Practices](https://docs.oracle.com/javase/8/docs/technotes/guides/management/)

## 📄 License

This configuration is provided under the MIT License. See LICENSE file for details.

## 🆘 Support

### Community Support
- [HAPI FHIR Google Group](https://groups.google.com/forum/#!forum/hapi-fhir)
- [HL7 FHIR Chat](https://chat.fhir.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/hapi-fhir)

### Professional Support
Consider [Smile CDR](https://smilecdr.com/) for enterprise-grade FHIR server solutions and professional support.

---

**⚠️ Important Notes:**
- This setup is optimized for production use but requires proper security hardening
- Always use strong passwords and secure configurations in production
- Regularly update Docker images and apply security patches
- Monitor logs and metrics for unusual activity
- Backup data regularly and test restore procedures