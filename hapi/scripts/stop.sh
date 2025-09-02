#!/bin/bash

# HAPI FHIR Stop Script
# Gracefully stops all HAPI FHIR services

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info "Stopping HAPI FHIR services..."

# Stop services gracefully
docker-compose stop

print_info "Services stopped"

# Ask if user wants to remove containers
read -p "Do you want to remove containers? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose down
    print_info "Containers removed"
fi

# Ask if user wants to remove volumes (data)
read -p "Do you want to remove data volumes? WARNING: This will delete all data! (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Are you absolutely sure? This action cannot be undone!"
    read -p "Type 'DELETE' to confirm: " confirmation
    if [ "$confirmation" == "DELETE" ]; then
        docker-compose down -v
        print_info "Volumes removed"
    else
        print_info "Volume removal cancelled"
    fi
fi

print_info "Shutdown complete"