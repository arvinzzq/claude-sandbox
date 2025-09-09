FROM mcr.microsoft.com/playwright:v1.47.2-jammy

# 升级 npm 并安装 Claude Code CLI
RUN npm i -g npm@latest && \
    npm i -g @anthropic-ai/claude-code@latest

# 创建非 root 用户，降低风险
RUN useradd -m dev && mkdir -p /workspace && chown -R dev:dev /workspace
USER dev
WORKDIR /workspace

# 基础镜像已包含浏览器，跳过安装

# 环境优化
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1
