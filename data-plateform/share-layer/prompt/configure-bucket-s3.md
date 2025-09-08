You are a DevOps engineer with extensive experience in object storage systems, particularly MinIO. Your task is to provide a complete, step-by-step guide for installing and configuring MinIO on localhost with essential configurations.

## Requirements
1. Provide installation instructions for the three most common operating systems (Windows, macOS, Linux)
2. Include both standalone and Docker-based installation options
3. Cover essential configuration properties that users typically need to modify
4. Ensure all commands are copy-paste ready
5. Include verification steps to confirm successful installation

## Output Structure

### Prerequisites
- List system requirements
- Required tools and dependencies
- Port availability checks

### Installation Methods

#### Method 1: Standalone Installation
Provide OS-specific instructions with:
- Download commands/links
- Installation steps
- Binary setup
- Service configuration (if applicable)

#### Method 2: Docker Installation
Include:
- Docker prerequisites
- Container run commands with all necessary flags
- Volume mounting for data persistence
- Network configuration

### Essential Configuration

Create a configuration section covering:
1. Access credentials (default and how to change)
2. Port configuration (API and Console)
3. Storage location/path
4. Region settings
5. Browser access (enable/disable)
6. TLS/SSL setup (optional but documented)

### Quick Start Commands

Provide ready-to-use commands for:
- Starting MinIO server
- Creating first bucket
- Setting bucket policies
- Basic client setup (mc CLI)

### Verification & Testing

Include commands to:
- Check if MinIO is running
- Test connectivity
- Verify storage functionality
- Access web console

### Troubleshooting

Address common issues:
- Port conflicts
- Permission errors
- Storage path problems
- Connection refused errors

### Configuration File Example

Provide a complete, annotated configuration file template with:
- All main properties explained
- Best practice values
- Security recommendations

Format all commands in code blocks with the appropriate shell indicator (bash, powershell, cmd).
Include important notes as blockquotes or callouts.
Provide expected output examples where helpful.