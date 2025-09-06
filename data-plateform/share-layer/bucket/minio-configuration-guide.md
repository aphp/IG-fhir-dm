# MinIO Installation and Configuration Guide

A complete guide for installing and configuring MinIO object storage on localhost for development and testing purposes.

## Prerequisites

### System Requirements
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+, CentOS 7+, Debian 9+)
- **CPU**: Minimum 2 cores (4+ recommended)
- **RAM**: Minimum 2GB (4GB+ recommended)
- **Storage**: At least 10GB free disk space for data storage
- **Network**: Port 9000 (API) and 9001 (Console) must be available

### Required Tools and Dependencies

#### For Standalone Installation
- **Windows**: PowerShell 5.0+ or Command Prompt
- **macOS**: Terminal with Homebrew (optional but recommended)
- **Linux**: wget or curl, systemd (for service management)

#### For Docker Installation
- Docker Desktop (Windows/macOS) or Docker Engine (Linux) version 20.10+
- Docker Compose version 2.0+ (optional but recommended)

### Port Availability Check

```bash
# Linux/macOS - Check if ports are available
lsof -i :9000
lsof -i :9001

# Windows PowerShell - Check if ports are available
netstat -an | findstr :9000
netstat -an | findstr :9001
```

> **Note**: If ports are in use, you'll need to either stop the conflicting service or configure MinIO to use different ports.

## Installation Methods

### Method 1: Standalone Installation

#### Windows

##### Download and Install

```powershell
# PowerShell - Download MinIO binary
Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile "C:\minio\minio.exe"

# Create data directory
New-Item -ItemType Directory -Force -Path "C:\minio\data"

# Create configuration directory
New-Item -ItemType Directory -Force -Path "C:\minio\config"
```

##### Set Environment Variables

```powershell
# Set MinIO root credentials (PowerShell)
[System.Environment]::SetEnvironmentVariable('MINIO_ROOT_USER', 'minioadmin', 'User')
[System.Environment]::SetEnvironmentVariable('MINIO_ROOT_PASSWORD', 'minioadmin123', 'User')

# Or for current session only
$env:MINIO_ROOT_USER = "minioadmin"
$env:MINIO_ROOT_PASSWORD = "minioadmin123"
```

##### Start MinIO Server

```powershell
# Start MinIO server
C:\minio\minio.exe server C:\minio\data --console-address ":9001"
```

##### Create Windows Service (Optional)

```powershell
# Install as Windows Service using NSSM (download from https://nssm.cc/)
# Download NSSM first, then:
nssm install MinIO "C:\minio\minio.exe" "server C:\minio\data --console-address :9001"
nssm set MinIO AppEnvironmentExtra MINIO_ROOT_USER=minioadmin MINIO_ROOT_PASSWORD=minioadmin123
nssm start MinIO
```

#### macOS

##### Download and Install

```bash
# Using Homebrew (recommended)
brew install minio/stable/minio

# Or download directly
curl -O https://dl.min.io/server/minio/release/darwin-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/

# Create data and config directories
mkdir -p ~/minio/data
mkdir -p ~/minio/config
```

##### Start MinIO Server

```bash
# Set credentials
export MINIO_ROOT_USER=minioadmin
export MINIO_ROOT_PASSWORD=minioadmin123

# Start server
minio server ~/minio/data --console-address ":9001"
```

##### Create LaunchAgent Service (Optional)

```bash
# Create LaunchAgent plist file
cat << EOF > ~/Library/LaunchAgents/io.minio.server.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>io.minio.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/minio</string>
        <string>server</string>
        <string>~/minio/data</string>
        <string>--console-address</string>
        <string>:9001</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>MINIO_ROOT_USER</key>
        <string>minioadmin</string>
        <key>MINIO_ROOT_PASSWORD</key>
        <string>minioadmin123</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# Load the service
launchctl load ~/Library/LaunchAgents/io.minio.server.plist
```

#### Linux (Ubuntu/Debian)

##### Download and Install

```bash
# Download MinIO binary
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/

# Create minio user and directories
sudo useradd -r minio-user -s /sbin/nologin
sudo mkdir -p /minio/data
sudo mkdir -p /etc/minio
sudo chown -R minio-user:minio-user /minio
sudo chown -R minio-user:minio-user /etc/minio
```

##### Create Configuration File

```bash
# Create environment file
sudo tee /etc/default/minio << EOF
# MinIO configuration
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD="minioadmin123"
MINIO_VOLUMES="/minio/data"
MINIO_OPTS="--console-address :9001"
EOF

# Secure the configuration file
sudo chmod 600 /etc/default/minio
sudo chown minio-user:minio-user /etc/default/minio
```

##### Create Systemd Service

```bash
# Create systemd service file
sudo tee /etc/systemd/system/minio.service << EOF
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local/
User=minio-user
Group=minio-user
EnvironmentFile=/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"\${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server \$MINIO_OPTS \$MINIO_VOLUMES
Restart=always
StandardOutput=journal
StandardError=inherit
LimitNOFILE=65536
TasksMax=infinity
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable minio
sudo systemctl start minio
```

### Method 2: Docker Installation

#### Docker Prerequisites

```bash
# Verify Docker installation
docker --version
docker compose version  # or docker-compose --version
```

#### Single Container Setup

```bash
# Create data directory
mkdir -p ~/minio/data

# Run MinIO container
docker run -d \
  --name minio \
  -p 9000:9000 \
  -p 9001:9001 \
  -v ~/minio/data:/data \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin123 \
  quay.io/minio/minio:latest \
  server /data --console-address ":9001"
```

#### Docker Compose Setup

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  minio:
    image: quay.io/minio/minio:latest
    container_name: minio
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
      - minio_config:/root/.minio
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
      MINIO_BROWSER: on
      MINIO_DOMAIN: localhost
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    restart: unless-stopped

volumes:
  minio_data:
    driver: local
  minio_config:
    driver: local
```

Start with Docker Compose:

```bash
# Start MinIO
docker compose up -d

# View logs
docker compose logs -f minio

# Stop MinIO
docker compose down
```

## Essential Configuration

### 1. Access Credentials

#### Default Credentials
- **Username**: minioadmin
- **Password**: minioadmin123

#### Changing Credentials

```bash
# Standalone - Set before starting server
export MINIO_ROOT_USER=mynewadmin
export MINIO_ROOT_PASSWORD=mysecurepassword123

# Docker - Update environment variables
docker run -d \
  -e MINIO_ROOT_USER=mynewadmin \
  -e MINIO_ROOT_PASSWORD=mysecurepassword123 \
  # ... other options
```

> **Security Note**: Always change default credentials in production environments. Use strong passwords with at least 12 characters.

### 2. Port Configuration

```bash
# API Port (default: 9000)
minio server /data --address ":9000"

# Console Port (default: 9001)
minio server /data --console-address ":9001"

# Custom ports example
minio server /data --address ":8080" --console-address ":8081"
```

### 3. Storage Location

```bash
# Single directory
minio server /path/to/storage

# Multiple directories (erasure coding)
minio server /mnt/disk1 /mnt/disk2 /mnt/disk3 /mnt/disk4

# Using expansion notation
minio server /mnt/disk{1...4}
```

### 4. Region Settings

```bash
# Set region (default: us-east-1)
export MINIO_REGION_NAME=eu-west-1
minio server /data

# Or in configuration file
MINIO_REGION_NAME="eu-west-1"
```

### 5. Browser Access

```bash
# Enable browser (default)
export MINIO_BROWSER=on

# Disable browser
export MINIO_BROWSER=off

# Redirect browser to specific URL
export MINIO_BROWSER_REDIRECT_URL=https://console.example.com
```

### 6. TLS/SSL Setup (Optional)

```bash
# Generate self-signed certificate for testing
mkdir -p ~/.minio/certs

# Generate private key
openssl genrsa -out ~/.minio/certs/private.key 2048

# Generate certificate
openssl req -new -x509 -days 365 \
  -key ~/.minio/certs/private.key \
  -out ~/.minio/certs/public.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Start MinIO with TLS
minio server --certs-dir ~/.minio/certs /data
```

## Quick Start Commands

### MinIO Client (mc) Setup

```bash
# Download MinIO Client
# Linux
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

# macOS
brew install minio/stable/mc

# Windows PowerShell
Invoke-WebRequest -Uri "https://dl.min.io/client/mc/release/windows-amd64/mc.exe" -OutFile "C:\minio\mc.exe"
```

### Configure MinIO Client

```bash
# Add MinIO server to mc configuration
mc alias set local http://localhost:9000 minioadmin minioadmin123

# Verify connection
mc admin info local
```

### Create First Bucket

```bash
# Create bucket
mc mb local/my-first-bucket

# List buckets
mc ls local

# Set bucket policy to public (optional)
mc anonymous set download local/my-first-bucket
```

### Upload and Download Files

```bash
# Upload file
mc cp /path/to/file.txt local/my-first-bucket

# Download file
mc cp local/my-first-bucket/file.txt /path/to/download/

# Mirror directory
mc mirror /local/directory local/my-first-bucket
```

### Bucket Policies

```bash
# Set public read policy
mc anonymous set download local/my-first-bucket

# Set public read/write policy
mc anonymous set public local/my-first-bucket

# Remove anonymous access
mc anonymous remove local/my-first-bucket

# Custom bucket policy (policy.json)
mc admin policy add local customPolicy policy.json
mc admin policy set local customPolicy user=myuser
```

## Verification & Testing

### Check if MinIO is Running

```bash
# Using curl
curl -I http://localhost:9000/minio/health/live

# Expected output:
# HTTP/1.1 200 OK

# Using mc client
mc admin info local

# Check service status (Linux)
sudo systemctl status minio

# Check Docker container
docker ps | grep minio
```

### Test Connectivity

```bash
# Test API endpoint
curl -X GET http://localhost:9000

# Test Console access (in browser)
# Navigate to: http://localhost:9001

# Test with MinIO Client
mc ls local/
```

### Verify Storage Functionality

```bash
# Create test file
echo "Hello MinIO" > test.txt

# Upload test file
mc cp test.txt local/test-bucket/

# List files
mc ls local/test-bucket/

# Download and verify
mc cp local/test-bucket/test.txt test-downloaded.txt
cat test-downloaded.txt

# Clean up
mc rm local/test-bucket/test.txt
rm test.txt test-downloaded.txt
```

### Performance Testing

```bash
# Run MinIO's built-in speedtest
mc admin speedtest local

# Benchmark with custom size and duration
mc admin speedtest local --size 64MiB --duration 30s
```

## Troubleshooting

### Port Conflicts

**Problem**: "bind: address already in use"

```bash
# Find process using port 9000
# Linux/macOS
lsof -i :9000
kill -9 <PID>

# Windows PowerShell
Get-Process -Id (Get-NetTCPConnection -LocalPort 9000).OwningProcess
Stop-Process -Id <PID>

# Alternative: Use different ports
minio server --address ":8080" --console-address ":8081" /data
```

### Permission Errors

**Problem**: "permission denied" when accessing data directory

```bash
# Linux/macOS - Fix ownership
sudo chown -R $(whoami):$(whoami) ~/minio/data

# Set correct permissions
chmod -R 755 ~/minio/data

# For systemd service
sudo chown -R minio-user:minio-user /minio/data
```

### Storage Path Problems

**Problem**: "Unable to initialize backend"

```bash
# Verify path exists
ls -la /path/to/storage

# Create if missing
mkdir -p /path/to/storage

# Check disk space
df -h /path/to/storage

# Verify write permissions
touch /path/to/storage/test && rm /path/to/storage/test
```

### Connection Refused Errors

**Problem**: Cannot connect to MinIO

```bash
# Check if MinIO is running
ps aux | grep minio

# Check logs
# Standalone
journalctl -u minio -f

# Docker
docker logs minio

# Verify firewall rules (Linux)
sudo ufw status
sudo ufw allow 9000
sudo ufw allow 9001

# Windows Firewall
New-NetFirewallRule -DisplayName "MinIO API" -Direction Inbound -LocalPort 9000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "MinIO Console" -Direction Inbound -LocalPort 9001 -Protocol TCP -Action Allow
```

### Console Not Accessible

**Problem**: API works but console doesn't load

```bash
# Verify console address is set
minio server /data --console-address ":9001"

# Check browser settings
export MINIO_BROWSER=on

# Clear browser cache or try incognito mode
```

## Configuration File Example

### Complete Configuration Template

Create `/etc/minio/config.env` (Linux) or `C:\minio\config.env` (Windows):

```bash
# MinIO Server Configuration
# This file contains all configurable parameters for MinIO server

# ============================================
# CORE CONFIGURATION
# ============================================

# Root credentials (REQUIRED - change from defaults!)
# Minimum 3 characters for username, 8 for password
MINIO_ROOT_USER="admin"
MINIO_ROOT_PASSWORD="changeme123!"

# Server addresses
# API address (default: ":9000")
MINIO_ADDRESS=":9000"
# Console address (default: ":9001")
MINIO_CONSOLE_ADDRESS=":9001"

# Storage paths
# Single disk: MINIO_VOLUMES="/data"
# Multiple disks: MINIO_VOLUMES="/mnt/disk{1...4}"
MINIO_VOLUMES="/minio/data"

# ============================================
# REGION CONFIGURATION
# ============================================

# Region name (default: "us-east-1")
# Used for S3 signature validation
MINIO_REGION_NAME="us-east-1"

# ============================================
# BROWSER CONFIGURATION
# ============================================

# Enable/disable web console (on/off, default: on)
MINIO_BROWSER="on"

# Redirect URL for browser access (optional)
# MINIO_BROWSER_REDIRECT_URL="https://console.example.com"

# ============================================
# DOMAIN CONFIGURATION
# ============================================

# Domain name for virtual-host-style requests
# Enable path-style requests: leave empty
# Enable virtual-host-style: set to your domain
MINIO_DOMAIN=""

# ============================================
# SECURITY CONFIGURATION
# ============================================

# TLS Configuration
# Directory containing private.key and public.crt
# MINIO_CERTS_DIR="/home/user/.minio/certs"

# Enable automatic TLS certificate generation (Let's Encrypt)
# MINIO_SERVER_URL="https://minio.example.com"

# JWT Token
# MINIO_IDENTITY_OPENID_CONFIG_URL="https://auth.example.com/.well-known/openid-configuration"
# MINIO_IDENTITY_OPENID_CLIENT_ID="minio"

# ============================================
# STORAGE CLASS CONFIGURATION
# ============================================

# Define storage classes for different redundancy levels
# Format: "EC:PARITY"
# EC = Number of erasure coded data blocks
# PARITY = Number of parity blocks
MINIO_STORAGE_CLASS_STANDARD="EC:2"
MINIO_STORAGE_CLASS_RRS="EC:1"

# ============================================
# CACHE CONFIGURATION
# ============================================

# Enable disk caching
# MINIO_CACHE="on"
# MINIO_CACHE_DRIVES="/mnt/cache{1...4}"
# MINIO_CACHE_EXCLUDE="*.pdf"
# MINIO_CACHE_QUOTA=80
# MINIO_CACHE_AFTER=3
# MINIO_CACHE_WATERMARK_LOW=70
# MINIO_CACHE_WATERMARK_HIGH=90

# ============================================
# COMPRESSION CONFIGURATION
# ============================================

# Enable compression for specific MIME types
MINIO_COMPRESS="on"
MINIO_COMPRESS_EXTENSIONS=".txt,.log,.csv,.json,.xml,.js,.css,.html"
MINIO_COMPRESS_MIME_TYPES="text/*,application/json,application/xml"

# ============================================
# MONITORING & METRICS
# ============================================

# Prometheus metrics endpoint
MINIO_PROMETHEUS_URL="http://localhost:9090"
MINIO_PROMETHEUS_JOB_ID="minio-job"

# Enable audit logging
# MINIO_AUDIT_WEBHOOK_ENABLE="on"
# MINIO_AUDIT_WEBHOOK_ENDPOINT="http://localhost:8080/audit"

# ============================================
# NOTIFICATION TARGETS
# ============================================

# PostgreSQL notification
# MINIO_NOTIFY_POSTGRES_ENABLE="on"
# MINIO_NOTIFY_POSTGRES_CONNECTION_STRING="host=localhost port=5432 user=postgres password=password dbname=minio sslmode=disable"
# MINIO_NOTIFY_POSTGRES_TABLE="events"

# Webhook notification
# MINIO_NOTIFY_WEBHOOK_ENABLE="on"
# MINIO_NOTIFY_WEBHOOK_ENDPOINT="http://localhost:3000/webhook"

# ============================================
# ETCD CONFIGURATION (for distributed setup)
# ============================================

# MINIO_ETCD_ENDPOINTS="http://localhost:2379"
# MINIO_ETCD_PATH_PREFIX="/minio"
# MINIO_ETCD_COREDNS_PATH="/skydns"

# ============================================
# KMS CONFIGURATION
# ============================================

# KES server for encryption
# MINIO_KMS_KES_ENDPOINT="https://kes.example.com:7373"
# MINIO_KMS_KES_KEY_FILE="/path/to/key.pem"
# MINIO_KMS_KES_CERT_FILE="/path/to/cert.pem"
# MINIO_KMS_KES_KEY_NAME="my-key"

# ============================================
# PERFORMANCE TUNING
# ============================================

# API rate limiting
MINIO_API_REQUESTS_MAX="1600"
MINIO_API_REQUESTS_DEADLINE="10s"

# Disk performance tuning
MINIO_DISK_USAGE_CHECK_INTERVAL="5m"
MINIO_DISK_MAX_CONCURRENT_IO="100"

# Scanner speed
MINIO_SCANNER_SPEED="default"  # Options: slow, default, fast, fastest

# ============================================
# LOGGING CONFIGURATION
# ============================================

# Console logging
MINIO_LOG_LEVEL="INFO"  # Options: FATAL, ERROR, WARN, INFO, DEBUG, TRACE

# JSON logging
# MINIO_LOG_JSON="on"

# Anonymous usage statistics
MINIO_TELEMETRY="off"
```

### Using the Configuration File

#### Linux/macOS

```bash
# Source the configuration file
source /etc/minio/config.env
minio server $MINIO_OPTS $MINIO_VOLUMES

# Or with systemd
# Update /etc/systemd/system/minio.service to use:
EnvironmentFile=/etc/minio/config.env
```

#### Windows

```powershell
# Load configuration in PowerShell
Get-Content C:\minio\config.env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

# Start MinIO
C:\minio\minio.exe server C:\minio\data
```

#### Docker

```bash
# Use with Docker
docker run -d \
  --env-file /path/to/config.env \
  -v ~/minio/data:/data \
  quay.io/minio/minio:latest \
  server /data
```

## Best Practices

### Security Recommendations

1. **Always change default credentials** before exposing MinIO to network
2. **Use TLS/SSL** for production deployments
3. **Enable audit logging** to track access and modifications
4. **Implement bucket policies** to control access at granular level
5. **Regular backups** of MinIO data and configuration
6. **Use IAM policies** for fine-grained access control
7. **Enable versioning** for critical buckets
8. **Implement lifecycle policies** for automatic data management

### Performance Optimization

1. **Use SSD storage** for better I/O performance
2. **Configure erasure coding** for data redundancy
3. **Enable caching** for frequently accessed data
4. **Use multiple disks** for better throughput
5. **Monitor with Prometheus** for performance insights
6. **Tune scanner speed** based on workload
7. **Implement compression** for text-based content
8. **Use appropriate storage classes** for different data types

### Operational Excellence

1. **Automate deployments** with Infrastructure as Code
2. **Implement monitoring and alerting**
3. **Regular updates** to latest stable version
4. **Document custom configurations**
5. **Test disaster recovery procedures**
6. **Use distributed mode** for high availability
7. **Implement proper logging** and log rotation
8. **Regular security audits** and penetration testing

## Conclusion

This guide provides comprehensive instructions for installing and configuring MinIO on localhost. Whether you choose standalone or Docker installation, follow the security recommendations and best practices for a robust object storage solution.

For production deployments, consider:
- Distributed MinIO setup for high availability
- External KMS for encryption key management
- Load balancers for traffic distribution
- Comprehensive monitoring and alerting
- Regular backup and disaster recovery testing

For more information, visit the [official MinIO documentation](https://docs.min.io).