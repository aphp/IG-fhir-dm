#!/bin/bash

# HAPI FHIR Start Script
# Starts all HAPI FHIR services with health checks

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env exists
if [ ! -f .env ]; then
    print_error ".env file not found. Please run ./scripts/setup.sh first"
    exit 1
fi

# Load environment variables
source .env

print_info "Starting HAPI FHIR services..."

# Start services
docker-compose up -d

# Wait for PostgreSQL to be ready
print_info "Waiting for PostgreSQL to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T postgres pg_isready -U ${POSTGRES_USER:-hapi} > /dev/null 2>&1; then
        print_info "PostgreSQL is ready"
        break
    fi
    attempt=$((attempt + 1))
    echo -n "."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    print_error "PostgreSQL failed to start"
    docker-compose logs postgres
    exit 1
fi

# Wait for HAPI FHIR to be ready
print_info "Waiting for HAPI FHIR to be ready..."
max_attempts=60
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost:${HAPI_PORT:-8080}/fhir/metadata > /dev/null 2>&1; then
        print_info "HAPI FHIR is ready"
        break
    fi
    attempt=$((attempt + 1))
    echo -n "."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    print_error "HAPI FHIR failed to start"
    docker-compose logs hapi-fhir
    exit 1
fi

# Display service status
print_info "Service Status:"
docker-compose ps

echo ""
print_info "Services started successfully!"
echo ""
echo "Access points:"
echo "  - HAPI FHIR Server: http://localhost:${HAPI_PORT:-8080}"
echo "  - HAPI FHIR API: http://localhost:${HAPI_PORT:-8080}/fhir"
echo "  - Grafana: http://localhost:${GRAFANA_PORT:-3000} (admin/${GRAFANA_PASSWORD:-admin})"
echo "  - Prometheus: http://localhost:${PROMETHEUS_PORT:-9090}"
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f [service-name]"
echo "  - Stop services: ./scripts/stop.sh"
echo "  - Check health: ./scripts/health-check.sh"
echo "  - Load sample data: ./scripts/load-sample-data.sh"