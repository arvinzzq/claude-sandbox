#!/usr/bin/env bash
# setup_claude_mcp_docker.sh
# One-click setup: Generate Dockerfile -> Build image -> Install and configure MCP -> Generate startup script
# Scope limited to current directory (mounted as /workspace), safe to enable --dangerous
set -euo pipefail

IMAGE_NAME="claudecode-playwright:latest"
CONTAINER_NAME="claudecode-sandbox"
WORKDIR_IN_CONTAINER="/workspace"
HOST_WORKDIR="${PWD}"

# Host persistence (recommended to keep, avoid re-downloading/losing config)
CLAUDE_CFG_HOST="$HOME/.claude.json"
MS_PW_CACHE_HOST="$HOME/.ms-playwright"
CLAUDE_CACHE_HOST="$HOME/.cache/claude-code"
CLAUDE_CONFIG_HOST="$HOME/.claude"

# Whether to change config and cache to within project (fully self-contained)
# Set to 1 to mount the above three items under current directory's .sandbox
LOCALIZE_ALL=${LOCALIZE_ALL:-0}

# To inject environment variables (API keys etc.), create .env in current directory (optional)
ENV_FILE_PATH="${HOST_WORKDIR}/.env"
USE_ENV_FILE=0
[[ -f "${ENV_FILE_PATH}" ]] && USE_ENV_FILE=1

require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1"; exit 1; }; }

write_dockerfile() {
  cat > Dockerfile <<'EOF'
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
EOF
}

prepare_mounts() {
  if [[ "${LOCALIZE_ALL}" = "1" ]]; then
    mkdir -p ".sandbox/ms-playwright" ".sandbox/cache-claude" ".sandbox/config" ".sandbox/claude-config"
    CLAUDE_CFG_HOST="${HOST_WORKDIR}/.sandbox/config/.claude.json"
    MS_PW_CACHE_HOST="${HOST_WORKDIR}/.sandbox/ms-playwright"
    CLAUDE_CACHE_HOST="${HOST_WORKDIR}/.sandbox/cache-claude"
    CLAUDE_CONFIG_HOST="${HOST_WORKDIR}/.sandbox/claude-config"
  else
    mkdir -p "${MS_PW_CACHE_HOST}" "${CLAUDE_CACHE_HOST}" "${CLAUDE_CONFIG_HOST}"
  fi
  [[ -f "${CLAUDE_CFG_HOST}" ]] || touch "${CLAUDE_CFG_HOST}"
}

build_image() {
  echo ">>> Building image ${IMAGE_NAME} ..."
  docker build -t "${IMAGE_NAME}" .
}


write_runner() {
  cat > claude-in-docker <<'EOS'
#!/usr/bin/env bash
# Usage:
#   ./claude-in-docker                 # Enter container shell (/workspace)
#   ./claude-in-docker --code          # Start Claude Code (safe mode)
#   ./claude-in-docker --code --dangerous  # Start Claude Code (dangerous mode)
set -euo pipefail

IMAGE_NAME="claudecode-playwright:latest"
CONTAINER_NAME="claudecode-sandbox"
WORKDIR_IN_CONTAINER="/workspace"

HOST_WORKDIR="${PWD}"

# Use localized configuration if exists, otherwise use image defaults
if [[ -f ".sandbox/config/.claude.json" ]]; then
  CLAUDE_CFG_HOST="${HOST_WORKDIR}/.sandbox/config/.claude.json"
  USE_HOST_CONFIG=1
else
  USE_HOST_CONFIG=0
fi

# Cache directories (always use host paths for persistence)
if [[ -d ".sandbox" ]]; then
  MS_PW_CACHE_HOST="${HOST_WORKDIR}/.sandbox/ms-playwright"
  CLAUDE_CACHE_HOST="${HOST_WORKDIR}/.sandbox/cache-claude"
  CLAUDE_CONFIG_HOST="${HOST_WORKDIR}/.sandbox/claude-config"
else
  MS_PW_CACHE_HOST="$HOME/.ms-playwright"
  CLAUDE_CACHE_HOST="$HOME/.cache/claude-code"
  CLAUDE_CONFIG_HOST="$HOME/.claude"
fi

ENV_FILE_PATH="${HOST_WORKDIR}/.env"
USE_ENV_FILE=0
[[ -f "${ENV_FILE_PATH}" ]] && USE_ENV_FILE=1

MODE_SHELL=1
RUN_CODE=0
ENABLE_DANGEROUS=0

for arg in "$@"; do
  case "$arg" in
    --code) MODE_SHELL=0; RUN_CODE=1 ;;
    --dangerous) ENABLE_DANGEROUS=1 ;;
    *) echo "Unknown argument: $arg"; echo "Usage: $0 [--code] [--dangerous]"; exit 1 ;;
  esac
done

RUN_ARGS=(docker run -it --rm
  --name "${CONTAINER_NAME}"
  --shm-size=2g
  -v "${HOST_WORKDIR}:${WORKDIR_IN_CONTAINER}"
  -v "${MS_PW_CACHE_HOST}:/ms-playwright"
  -v "${CLAUDE_CACHE_HOST}:/home/dev/.cache/claude-code"
  -v "${CLAUDE_CONFIG_HOST}:/home/dev/.claude"
  -w "${WORKDIR_IN_CONTAINER}"
)

# Only mount host config if using localized configuration
if [[ "${USE_HOST_CONFIG}" -eq 1 ]]; then
  RUN_ARGS+=(-v "${CLAUDE_CFG_HOST}:/home/dev/.claude.json")
fi

if [[ "${USE_ENV_FILE}" = "1" ]]; then
  RUN_ARGS+=( --env-file "${ENV_FILE_PATH}" )
fi
RUN_ARGS+=( "${IMAGE_NAME}" )

if [[ "${MODE_SHELL}" -eq 1 && "${RUN_CODE}" -eq 0 ]]; then
  exec "${RUN_ARGS[@]}" bash
else
  if [[ "${ENABLE_DANGEROUS}" -eq 1 ]]; then
    exec "${RUN_ARGS[@]}" bash -lc 'claude code --dangerous'
  else
    exec "${RUN_ARGS[@]}" bash -lc 'claude code'
  fi
fi
EOS
  chmod +x claude-in-docker
  echo ">>> Generated startup script: $(realpath ./claude-in-docker)"
}

main() {
  require_cmd docker
  echo ">>> Writing Dockerfile ..."
  write_dockerfile

  echo ">>> Preparing mount directories/configs ..."
  prepare_mounts

  echo ">>> Building Docker image ..."
  build_image

  echo ">>> MCP servers are pre-configured in Docker image ..."

  echo ">>> Generating startup script ..."
  write_runner

  cat <<'TIP'

✅ Complete!

Common usage:
1) Enter container shell (safe by default):     ./claude-in-docker
2) Start Claude Code (safe mode):              ./claude-in-docker --code
3) Start Claude Code (dangerous mode):         ./claude-in-docker --code --dangerous

Notes:
- All operations are limited to current directory (mounted to container /workspace).
- If you want config and cache to fully follow the project, set environment variable before execution:
    LOCALIZE_ALL=1 bash setup_claude_mcp_docker.sh
  Then current directory will have .sandbox/ containing:
    .sandbox/config/.claude.json
    .sandbox/ms-playwright
    .sandbox/cache-claude
- To inject environment variables (API keys etc.): create .env in current directory, e.g.:
    ANTHROPIC_BASE_URL=your_base_url
    ANTHROPIC_AUTH_TOKEN=your_token  
    NOTION_API_KEY=your_secret_token
    CONTEXT7_API_KEY=...
  Script and startup commands will automatically read .env.

TIP
}

main "$@"
