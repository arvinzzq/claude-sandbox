# Claude Code Docker Environment

<div align="center">

**🚀 A Production-Ready Docker Environment for Claude Code CLI with MCP Servers**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green)](https://claude.ai/code)
[![MCP](https://img.shields.io/badge/MCP-7%20Servers-orange)](https://modelcontextprotocol.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*Streamline your AI development workflow with a containerized, secure, and scalable Claude Code environment*

</div>

---

## 🎯 Overview

Claude Code Docker Environment is a comprehensive, production-ready containerization solution for running Claude Code CLI with multiple Model Context Protocol (MCP) servers. This project eliminates setup complexity while providing a secure, isolated, and scalable development environment for AI-powered coding workflows.

### ✨ Key Benefits

- **🔧 Zero Configuration Complexity** - One-click setup with automated Docker environment
- **🛡️ Enhanced Security** - Isolated container environment with non-root user execution
- **📈 Scalability** - Multi-instance support with real-time monitoring dashboard
- **🔌 Rich Integration** - Pre-configured with 7 essential MCP servers
- **⚡ Development Optimized** - Hot-reload support and persistent configuration
- **🌐 Production Ready** - Comprehensive logging, monitoring, and error handling

---

## 🚀 Features

### Core Functionality
- **One-Click Setup**: Automated Docker environment configuration with zero manual intervention
- **7 Pre-configured MCP Servers**: Essential tools for documentation, web automation, file operations, and more
- **Multi-Instance Support**: Run multiple Claude Code instances simultaneously with tmux integration
- **Real-Time Monitoring**: Interactive dashboard for instance management and monitoring
- **Security-First Design**: Isolated environment with restricted permissions and non-root execution

### Advanced Capabilities
- **Environment Variables Management**: Centralized configuration for API keys and custom settings
- **Localized Configuration**: Project-specific configuration options with sandboxed storage
- **Container Lifecycle Management**: Comprehensive start, stop, restart, and cleanup operations
- **Debug & Troubleshooting**: Built-in debugging tools and comprehensive error handling
- **Cross-Platform Compatibility**: Supports macOS, Linux, and Windows with Docker Desktop

---

## 📦 Quick Start

### Prerequisites

- **Docker Desktop** (v4.0+) or **Docker Engine** (v20.0+)
- **Bash** shell environment
- **Internet connection** for image downloads and MCP server functionality

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/arvinzzq/claude-sandbox.git
cd claude-sandbox

# Run the automated setup script
bash setup_claude_mcp_docker.sh
```

### 2. Configuration

Create a `.env` file with your API credentials:

```bash
# Required: Claude Code Configuration
ANTHROPIC_BASE_URL=https://api.anthropic.com
ANTHROPIC_AUTH_TOKEN=your_anthropic_api_key_here

# Optional: MCP Server Integrations
NOTION_API_KEY=your_notion_api_key_here
CONTEXT7_API_KEY=your_context7_api_key_here
GITHUB_TOKEN=your_github_token_here

# Optional: Advanced Configuration
ANTHROPIC_MODEL=claude-3-sonnet-20240229
DEBUG=1
```

⚠️ **Security Note**: Never commit your `.env` file to version control. It's already included in `.gitignore`.

### 3. Launch

```bash
# Basic usage - Enter container shell
./claude-in-docker

# Direct Claude Code launch
./claude-in-docker --code

# Advanced mode with extended permissions
./claude-in-docker --code --dangerous
```

---

## 🛠️ Usage Guide

### Basic Operations

#### Single Instance Mode
```bash
# Launch Claude Code in safe mode
./claude-in-docker --code

# Launch with extended system access
./claude-in-docker --code --dangerous
```

#### Multi-Instance Mode with Monitoring
```bash
# Enter container environment
./claude-in-docker

# Start multiple instances (inside container)
tmux new-session -d -s claude1 'claude code'
tmux new-session -d -s claude2 'claude code --dangerous'
tmux new-session -d -s claude3 'claude code'

# Launch monitoring dashboard
./claude-monitor
```

### Monitoring Dashboard

The `claude-monitor` script provides a real-time management interface:

**Features:**
- 📊 Live status indicators for all instances
- ⏱️ Activity tracking with timestamps
- 🔄 Instance management (restart, kill, create)
- 📝 Log viewing and debugging
- ⌨️ Keyboard shortcuts for quick navigation

**Controls:**
- `[1-9]` - Switch to corresponding instance
- `[r]` - Restart all instances
- `[k]` - Kill all instances
- `[s]` - Start new instance
- `[l]` - View instance logs
- `[h]` - Display help
- `[q]` - Exit monitor

---

## 🔧 Configuration Options

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ANTHROPIC_BASE_URL` | Claude API endpoint | `https://api.anthropic.com` | ✅ |
| `ANTHROPIC_AUTH_TOKEN` | Your Claude API key | - | ✅ |
| `ANTHROPIC_MODEL` | Default Claude model | `claude-3-sonnet-20240229` | ❌ |
| `NOTION_API_KEY` | Notion integration key | - | ❌ |
| `CONTEXT7_API_KEY` | Context7 service key | - | ❌ |
| `GITHUB_TOKEN` | GitHub API token | - | ❌ |
| `DEBUG` | Enable debug logging | `0` | ❌ |
| `VERBOSE` | Verbose output mode | `0` | ❌ |

### Localized Configuration

For project-specific setups with all data stored locally:

```bash
LOCALIZE_ALL=1 bash setup_claude_mcp_docker.sh
```

This creates a `.sandbox/` directory containing:
- `.sandbox/config/.claude.json` - Claude Code configuration
- `.sandbox/ms-playwright` - Playwright browser data
- `.sandbox/cache-claude` - Application cache

---

## 🔌 MCP Servers

The environment includes 7 pre-configured MCP servers:

| Server | Purpose | Features |
|--------|---------|----------|
| **🔗 context7** | Documentation & Examples | Code samples, API documentation |
| **🌐 fetch** | Web Content Retrieval | HTTP requests, content parsing |
| **📁 filesystem** | File System Operations | Read, write, directory management |
| **🧠 memory** | Persistent Memory | Knowledge graphs, context storage |
| **🎯 sequential-thinking** | Multi-Step Reasoning | Complex problem solving |
| **📝 notion** | Notion Integration | Workspace management, note-taking |
| **🎭 playwright** | Web Automation | Browser testing, UI automation |

### MCP Server Health Check

```bash
# Inside container
claude mcp list      # List all configured servers
claude mcp health    # Check server status
```

---

## 🐳 Container Management

### Lifecycle Operations

```bash
# View running containers
docker ps

# Stop container
docker stop claudecode-sandbox

# Force kill container
docker kill claudecode-sandbox

# Remove container
docker rm claudecode-sandbox

# Complete cleanup
docker system prune
```

### Multiple Instances

```bash
# Stop all Claude containers
docker ps | grep claudecode | awk '{print $1}' | xargs docker stop

# Clean restart
docker ps -a | grep claudecode | awk '{print $1}' | xargs docker rm
./claude-in-docker --code
```

---

## 🛡️ Security Features

- **🔒 Non-Root Execution**: All operations run as unprivileged `dev` user
- **📁 Workspace Isolation**: Limited to `/workspace` directory scope
- **🐳 Container Isolation**: Full Docker container separation
- **🚫 Gitignore Protection**: Sensitive files automatically excluded
- **🔐 Environment Security**: API keys managed through environment variables

---

## 🔍 Troubleshooting

### Common Issues

**Docker Connection Problems**
```bash
# Verify Docker is running
docker ps

# Rebuild if needed
docker build -t claudecode-playwright:latest .
```

**MCP Server Issues**
```bash
# Check server status
./claude-in-docker
claude mcp health

# Restart with fresh configuration
docker restart claudecode-sandbox
```

**Permission Errors**
```bash
# Fix script permissions
chmod +x claude-in-docker claude-monitor setup_claude_mcp_docker.sh
```

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
# In .env file
DEBUG=1
VERBOSE=1

# Or temporarily
DEBUG=1 ./claude-in-docker --code
```

---

## 📁 Project Structure

```
claude-sandbox/
├── 📜 setup_claude_mcp_docker.sh    # Automated setup script
├── 🚀 claude-in-docker              # Container launcher
├── 📊 claude-monitor                # Monitoring dashboard
├── 🐳 Dockerfile                    # Docker image definition
├── 🔧 claude-config.json            # MCP server configuration
├── 🌍 .env                          # Environment variables (create this)
├── 🚫 .gitignore                    # Git exclusions
└── 📚 README.md                     # This documentation
```

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** with appropriate tests
4. **Commit your changes**: `git commit -m 'Add amazing feature'`
5. **Push to the branch**: `git push origin feature/amazing-feature`
6. **Open a Pull Request**

### Contribution Guidelines

- Follow existing code style and conventions
- Add tests for new functionality
- Update documentation for API changes
- Ensure all scripts pass shellcheck validation
- Test changes across different platforms

### Reporting Issues

Please use the [GitHub Issues](https://github.com/arvinzzq/claude-sandbox/issues) page to report bugs or request features. Include:

- **Environment details** (OS, Docker version)
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Logs and error messages**

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### MIT License Summary

- ✅ **Commercial use**
- ✅ **Modification**
- ✅ **Distribution**
- ✅ **Private use**
- ❌ **Liability**
- ❌ **Warranty**

---

## 🙏 Acknowledgments

- **[Anthropic](https://anthropic.com)** - For Claude AI and the Model Context Protocol
- **[Docker](https://docker.com)** - For containerization platform
- **[Playwright](https://playwright.dev)** - For web automation capabilities
- **Open Source Community** - For continuous inspiration and collaboration

---

## 📞 Support

- **📚 Documentation**: Check this README and inline help (`./claude-monitor` then press `h`)
- **🐛 Bug Reports**: [GitHub Issues](https://github.com/arvinzzq/claude-sandbox/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/arvinzzq/claude-sandbox/discussions)
- **📧 Contact**: Available through GitHub Issues

---

<div align="center">

**⭐ Star this repository if it helped you!**

*Built with ❤️ for the AI development community*

</div>