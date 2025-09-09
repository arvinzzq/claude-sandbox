FROM mcr.microsoft.com/playwright:v1.47.2-jammy

# Upgrade npm and install Claude Code CLI
RUN npm i -g npm@latest && \
    npm i -g @anthropic-ai/claude-code@latest

# Create non-root user to reduce risk
RUN useradd -m dev && mkdir -p /workspace && chown -R dev:dev /workspace
USER dev
WORKDIR /workspace

# Base image already contains browsers, skip installation

# Environment optimization
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1
