#!/bin/bash

# HAPI FHIR Health Check Script
# Checks the health status of all services

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Load environment variables
if [ -f .env ]; then
    source .env
fi

echo "======================================"
echo "HAPI FHIR Services Health Check"
echo "======================================"
echo ""

# Check PostgreSQL
echo -n "PostgreSQL Database: "
if docker-compose exec -T postgres pg_isready -U ${POSTGRES_USER:-hapi} > /dev/null 2>&1; then
    print_success "Healthy"
    
    # Check database connection
    echo -n "  - Database Connection: "
    if docker-compose exec -T postgres psql -U ${POSTGRES_USER:-hapi} -d ${POSTGRES_DB:-hapi} -c "SELECT 1" > /dev/null 2>&1; then
        print_success "Connected"
    else
        print_error "Failed"
    fi
    
    # Check table count
    echo -n "  - HAPI Tables: "
    table_count=$(docker-compose exec -T postgres psql -U ${POSTGRES_USER:-hapi} -d ${POSTGRES_DB:-hapi} -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'" 2>/dev/null | tr -d ' ')
    if [ -n "$table_count" ] && [ "$table_count" -gt "0" ]; then
        print_success "$table_count tables found"
    else
        print_warning "No tables found (first run?)"
    fi
else
    print_error "Not responding"
fi
echo ""

# Check HAPI FHIR
echo -n "HAPI FHIR Server: "
if curl -f -s http://localhost:${HAPI_PORT:-8080}/fhir/metadata > /dev/null 2>&1; then
    print_success "Healthy"
    
    # Check API endpoint
    echo -n "  - API Endpoint: "
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${HAPI_PORT:-8080}/fhir/Patient)
    if [ "$response" == "200" ]; then
        print_success "Responding (HTTP $response)"
    else
        print_warning "Responding (HTTP $response)"
    fi
    
    # Check FHIR version
    echo -n "  - FHIR Version: "
    version=$(curl -s http://localhost:${HAPI_PORT:-8080}/fhir/metadata | grep -o '"fhirVersion":"[^"]*' | sed 's/"fhirVersion":"//' | head -1)
    if [ -n "$version" ]; then
        print_success "$version"
    else
        print_warning "Unable to determine"
    fi
else
    print_error "Not responding"
fi
echo ""

# Check Nginx
echo -n "Nginx Proxy: "
if curl -f -s http://localhost:${NGINX_HTTP_PORT:-80} > /dev/null 2>&1; then
    print_success "Healthy"
    
    # Check HTTPS
    echo -n "  - HTTPS: "
    if curl -f -s -k https://localhost:${NGINX_HTTPS_PORT:-443} > /dev/null 2>&1; then
        print_success "Enabled"
    else
        print_warning "Not configured"
    fi
else
    print_warning "Not responding"
fi
echo ""

# Check Prometheus
echo -n "Prometheus: "
if curl -f -s http://localhost:${PROMETHEUS_PORT:-9090}/-/healthy > /dev/null 2>&1; then
    print_success "Healthy"
    
    # Check targets
    echo -n "  - Scrape Targets: "
    targets=$(curl -s http://localhost:${PROMETHEUS_PORT:-9090}/api/v1/targets | grep -o '"health":"up"' | wc -l)
    if [ "$targets" -gt "0" ]; then
        print_success "$targets targets up"
    else
        print_warning "No targets up"
    fi
else
    print_warning "Not responding"
fi
echo ""

# Check Grafana
echo -n "Grafana: "
if curl -f -s http://localhost:${GRAFANA_PORT:-3000}/api/health > /dev/null 2>&1; then
    print_success "Healthy"
    
    # Check datasources
    echo -n "  - Datasources: "
    # Note: This requires authentication
    print_warning "Check manually at http://localhost:${GRAFANA_PORT:-3000}"
else
    print_warning "Not responding"
fi
echo ""

# Check PostgreSQL Exporter
echo -n "PostgreSQL Exporter: "
if curl -f -s http://localhost:${POSTGRES_EXPORTER_PORT:-9187}/metrics > /dev/null 2>&1; then
    print_success "Healthy"
else
    print_warning "Not responding"
fi
echo ""

# Container Status
echo "======================================"
echo "Container Status"
echo "======================================"
docker-compose ps

echo ""
echo "======================================"
echo "Resource Usage"
echo "======================================"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" $(docker-compose ps -q)

echo ""
echo "======================================"
echo "Health check completed"
echo "======================================" 