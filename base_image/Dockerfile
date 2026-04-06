FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# China apt mirror
RUN sed -i 's|http://archive.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's|http://security.ubuntu.com|http://mirrors.aliyun.com|g' /etc/apt/sources.list.d/ubuntu.sources

# System dependencies + openssh-server
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git zip unzip wget gnupg xz-utils screen \
    bubblewrap \
    python3.12 python3.12-venv python3-pip \
    php8.3-cli php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip socat jq \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI (China mirror)
RUN curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
       https://mirrors.aliyun.com/docker-ce/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Node.js 22 (npmmirror binary)
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then ARCH="x64"; fi \
    && curl -fsSL https://npmmirror.com/mirrors/node/v22.16.0/node-v22.16.0-linux-${ARCH}.tar.xz \
       | tar -xJ --strip-components=1 -C /usr/local/

# npm China mirror + global tools
RUN npm config set registry https://registry.npmmirror.com \
    && npm install -g @khanacademy/format-claude-stream

# Claude Code CLI
# RUN curl -fsSL https://claude.ai/install.sh | bash
RUN npm install -g @anthropic-ai/claude-code

# codex cli
RUN npm i -g @openai/codex

# MinIO client (mc)
RUN curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc

# sshd setup
RUN mkdir -p /run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitUserEnvironment.*/PermitUserEnvironment yes/' /etc/ssh/sshd_config \
    && echo 'AcceptEnv *' >> /etc/ssh/sshd_config

# cw user
RUN useradd -m -s /bin/bash cw \
    && usermod -aG docker cw 2>/dev/null || true \
    && mkdir -p /home/cw/.ssh /home/cw/workspace \
    && chmod 700 /home/cw/.ssh \
    && chown -R cw:cw /home/cw

# Copy uv to system PATH
RUN cp /root/.local/bin/uv /usr/local/bin/uv \
    && cp /root/.local/bin/uvx /usr/local/bin/uvx 2>/dev/null || true

RUN echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/cw/.local/bin"' > /etc/environment


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# run as root to setup things.
ENTRYPOINT ["/entrypoint.sh"]
