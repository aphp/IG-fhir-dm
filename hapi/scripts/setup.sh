#!/bin/bash

# HAPI FHIR Setup Script
# This script performs initial setup for the HAPI FHIR server

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_warning "This script should not be run as root for security reasons"
   exit 1
fi

print_info "Starting HAPI FHIR setup..."

# Check prerequisites
print_info "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_info "Docker found: $(docker --version)"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_info "Docker Compose found"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker."
    exit 1
fi
print_info "Docker daemon is running"

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p logs/hapi
mkdir -p logs/nginx
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/provisioning/{dashboards,datasources,notifiers}
mkdir -p monitoring/grafana/dashboards
mkdir -p nginx/conf.d
mkdir -p nginx/ssl
mkdir -p postgres/backup

# Set proper permissions
print_info "Setting directory permissions..."
chmod -R 755 logs
chmod -R 755 monitoring
chmod -R 755 nginx

# Check if .env file exists
if [ ! -f .env ]; then
    print_info "Creating .env file from .env.example..."
    cp .env.example .env
    print_warning "Please edit .env file and update passwords before starting the services"
    print_warning "Especially change these values:"
    print_warning "  - POSTGRES_PASSWORD"
    print_warning "  - GRAFANA_PASSWORD"
    read -p "Press enter to continue after updating .env file..."
fi

# Validate .env file
print_info "Validating environment configuration..."
source .env

if [ "$POSTGRES_PASSWORD" == "changeme123!" ] || [ "$POSTGRES_PASSWORD" == "hapi_password" ]; then
    print_error "Please change POSTGRES_PASSWORD in .env file to a secure password"
    exit 1
fi

if [ "$GRAFANA_PASSWORD" == "admin" ]; then
    print_warning "Grafana password is set to default. Consider changing it for production."
fi

# Generate self-signed SSL certificates (for development)
if [ ! -f nginx/ssl/cert.pem ]; then
    print_info "Generating self-signed SSL certificates for development..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost" \
        2>/dev/null
    print_info "SSL certificates generated (self-signed for development)"
fi

# Create Docker network if it doesn't exist
if ! docker network ls | grep -q hapi-network; then
    print_info "Creating Docker network..."
    docker network create --subnet=172.28.0.0/16 hapi-network
fi

# Pull Docker images
print_info "Pulling Docker images..."
docker-compose pull

# Validate Docker Compose configuration
print_info "Validating Docker Compose configuration..."
docker-compose config > /dev/null

if [ $? -eq 0 ]; then
    print_info "Docker Compose configuration is valid"
else
    print_error "Docker Compose configuration is invalid"
    exit 1
fi

# Create a backup of the current configuration
print_info "Creating configuration backup..."
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="backups/setup_${timestamp}"
mkdir -p "$backup_dir"
cp -r config "$backup_dir/" 2>/dev/null || true
cp -r nginx "$backup_dir/" 2>/dev/null || true
cp .env "$backup_dir/" 2>/dev/null || true
cp docker-compose.yml "$backup_dir/"
print_info "Configuration backed up to $backup_dir"

# Prompt for startup
echo ""
print_info "Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review and update the .env file with your specific configuration"
echo "2. Start the services with: ./scripts/start.sh or docker-compose up -d"
echo "3. Monitor logs with: docker-compose logs -f"
echo "4. Access HAPI FHIR at: http://localhost:8080"
echo "5. Access Grafana at: http://localhost:3000"
echo "6. Access Prometheus at: http://localhost:9090"
echo ""

read -p "Do you want to start the services now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Starting HAPI FHIR services..."
    docker-compose up -d
    
    print_info "Waiting for services to be healthy..."
    sleep 10
    
    # Check service health
    ./scripts/health-check.sh
else
    print_info "Services not started. Run './scripts/start.sh' when ready."
fi

print_info "Setup complete!"