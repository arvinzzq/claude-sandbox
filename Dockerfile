FROM mcr.microsoft.com/playwright:v1.47.2-jammy

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tmux \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Upgrade npm and install Claude Code CLI
RUN npm i -g npm@latest && \
    npm i -g @anthropic-ai/claude-code@latest

# Install MCP server packages globally
RUN npm i -g @modelcontextprotocol/server-filesystem && \
    npm i -g @modelcontextprotocol/server-memory && \
    npm i -g @modelcontextprotocol/server-sequential-thinking && \
    npm i -g @upstash/context7-mcp && \
    npm i -g @playwright/mcp

# Create non-root user to reduce risk
RUN useradd -m dev && mkdir -p /workspace && chown -R dev:dev /workspace

# Switch to dev user and copy pre-configured MCP settings
USER dev

# Copy pre-configured Claude configuration with MCP servers
COPY claude-config.json /home/dev/.claude.json

WORKDIR /workspace

# Environment optimization
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1
