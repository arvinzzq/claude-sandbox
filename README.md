# Claude Code Docker Environment

A one-click Docker environment for running Claude Code CLI with multiple MCP (Model Context Protocol) servers.

## Features

- **One-click setup**: Automated Docker environment configuration
- **7 MCP servers**: Pre-configured with essential MCP servers
- **Multi-instance support**: Run multiple Claude Code instances simultaneously
- **Instance monitoring**: Real-time monitoring and management of instances
- **Security-focused**: Isolated environment with non-root user
- **Environment variables**: Easy API key and configuration management

## Quick Start

### 1. Setup

```bash
# Clone this repository
git clone <your-repo-url>
cd claude-sandbox

# Run the one-click setup script
bash setup_claude_mcp_docker.sh
```

### 2. Configure Environment Variables

Create a `.env` file with your API keys:

```bash
# Claude Code Environment Variables
ANTHROPIC_BASE_URL=https://api.anthropic.com
ANTHROPIC_AUTH_TOKEN=your_anthropic_api_key_here

# MCP Server Environment Variables (optional)
NOTION_API_KEY=your_notion_api_key_here
CONTEXT7_API_KEY=your_context7_api_key_here

# Other Optional Environment Variables
# ANTHROPIC_MODEL=claude-3-sonnet-20240229
# DEBUG=1
```

### 3. Usage

#### Basic Usage

```bash
# Enter container shell
./claude-in-docker

# Start Claude Code (safe mode)
./claude-in-docker --code

# Start Claude Code (dangerous mode - allows more system operations)
./claude-in-docker --code --dangerous
```

#### Multiple Instances with tmux

```bash
# Enter container shell
./claude-in-docker

# Inside container, start multiple instances
tmux new-session -d -s claude1 'claude code'
tmux new-session -d -s claude2 'claude code --dangerous'
tmux new-session -d -s claude3 'claude code'

# Use the monitor script to manage instances
./claude-monitor
```

## Scripts Overview

### `setup_claude_mcp_docker.sh`
One-click setup script that:
- Generates optimized Dockerfile
- Builds Docker image with Claude Code CLI and Playwright
- Configures 7 MCP servers
- Creates startup scripts

### `claude-in-docker`
Container launcher script with multiple modes:
- Shell mode: Interactive bash shell in container
- Code mode: Direct Claude Code CLI launch
- Dangerous mode: Claude Code with extended permissions

### `claude-monitor`
Real-time monitoring dashboard for managing multiple Claude Code instances:
- Instance status monitoring
- Quick instance switching
- Log viewing
- Instance management (start/stop/restart)

## MCP Servers Included

The environment comes pre-configured with these MCP servers:

1. **context7** - Documentation and code examples
2. **fetch** - Web content fetching
3. **filesystem** - File system operations
4. **memory** - Persistent memory and knowledge graphs
5. **sequential-thinking** - Multi-step reasoning
6. **notion** - Notion workspace integration
7. **playwright** - Web automation and testing

## Environment Options

### Localized Configuration

For project-specific configuration (everything stored in project directory):

```bash
LOCALIZE_ALL=1 bash setup_claude_mcp_docker.sh
```

This creates a `.sandbox/` directory containing:
- `.sandbox/config/.claude.json`
- `.sandbox/ms-playwright`
- `.sandbox/cache-claude`

### Custom Environment Variables

The `.env` file supports any environment variables needed by Claude Code or MCP servers. Common examples:

```bash
# Claude Code configuration
ANTHROPIC_BASE_URL=https://your-proxy.com/api
ANTHROPIC_AUTH_TOKEN=your_token
ANTHROPIC_MODEL=claude-3-opus-20240229

# MCP server keys
NOTION_API_KEY=secret_...
CONTEXT7_API_KEY=upstash_...
GITHUB_TOKEN=ghp_...

# Debug options
DEBUG=1
VERBOSE=1
```

## Monitoring Multiple Instances

The `claude-monitor` script provides a real-time dashboard:

### Features
- **Status indicators**: Visual status for each instance
- **Activity tracking**: Last activity timestamp
- **Quick navigation**: Press 1-9 to jump to instances
- **Management controls**: Restart, kill, or create new instances
- **Log viewing**: View recent output from any instance

### Controls
- `[1-9]` - Enter corresponding Claude instance
- `[r]` - Restart all instances
- `[k]` - Kill all instances
- `[s]` - Start new instance
- `[l]` - View instance logs
- `[h]` - Show help
- `[q]` - Exit monitor

## Security Features

- **Non-root user**: All operations run as `dev` user
- **Isolated workspace**: Limited to `/workspace` directory
- **Environment isolation**: Docker container separation
- **Gitignore protection**: Sensitive files excluded from version control

## Container Management

### Stopping Docker Processes

#### Exit from Container
```bash
# If inside container shell
exit

# If in tmux session
Ctrl+B, D  # Detach from tmux session
exit       # Exit container
```

#### Stop from Host Machine
```bash
# View running containers
docker ps

# Stop specific container
docker stop claudecode-sandbox

# Force kill container
docker kill claudecode-sandbox

# Stop all running containers
docker stop $(docker ps -q)
```

#### Cleanup Resources
```bash
# Remove stopped containers
docker rm claudecode-sandbox

# Clean up all stopped containers
docker container prune

# Clean up system resources (images, networks, etc.)
docker system prune
```

### Managing Multiple Instances

#### View Running Containers
```bash
# Show all running containers
docker ps

# Show containers with specific name pattern
docker ps | grep claudecode
```

#### Access Running Container
```bash
# Enter running container
docker exec -it claudecode-sandbox bash

# If multiple containers, use container ID
docker exec -it <container_id> bash
```

#### Stop Specific Instances
```bash
# Multiple instances have different names
docker stop claudecode-sandbox
docker stop claudecode-sandbox-2
docker stop claudecode-sandbox-3
```

### Monitor Script Controls

#### claude-monitor Management
```bash
# Inside monitoring interface:
q  # Exit monitor
k  # Kill all Claude instances (container keeps running)
```

#### tmux Session Management
```bash
# Inside container:
tmux list-sessions           # List all sessions
tmux kill-server            # Kill all tmux sessions
tmux kill-session -t claude1 # Kill specific session
```

### Common Operations

#### Complete Cleanup and Restart
```bash
# Stop and remove all related containers
docker ps | grep claudecode | awk '{print $1}' | xargs docker stop
docker ps -a | grep claudecode | awk '{print $1}' | xargs docker rm

# Restart fresh
./claude-in-docker --code
```

#### Quick Restart
```bash
# Stop current container
docker stop claudecode-sandbox

# Restart
./claude-in-docker --code
```

## Troubleshooting

### Docker Issues
```bash
# Check if Docker is running
docker ps

# Rebuild image if needed
docker build -t claudecode-playwright:latest .

# Clean up containers
docker system prune
```

### MCP Connection Issues
```bash
# Check MCP server status inside container
./claude-in-docker
claude mcp list
claude mcp health
```

### Permission Issues
```bash
# Make scripts executable
chmod +x claude-in-docker claude-monitor setup_claude_mcp_docker.sh
```

## Requirements

- Docker Desktop or Docker Engine
- Bash shell
- Internet connection (for image downloads and MCP servers)

## File Structure

```
claude-sandbox/
├── setup_claude_mcp_docker.sh  # One-click setup script
├── claude-in-docker            # Container launcher
├── claude-monitor               # Instance monitoring dashboard
├── Dockerfile                   # Docker image definition
├── .env                        # Environment variables (create this)
├── .gitignore                  # Git exclusions
└── README.md                   # This file
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the [MIT License](LICENSE).