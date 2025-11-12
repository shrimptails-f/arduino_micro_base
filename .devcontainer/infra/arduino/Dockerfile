FROM gcc:12-bookworm

ARG APP_ROOT

ENV TZ=Asia/Tokyo \
    LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# 共通パッケージをまとめてインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    locales \
    vim \
    keychain \
    ripgrep \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    python3 \
    gcc-avr \
    gdb \
    avr-libc \
    avrdude \
    make \
    clang-format \
    cppcheck \
    git && \
    localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8 && \
    curl -fsSL "https://github.com/go-task/task/releases/download/v3.9.0/task_linux_amd64.deb" -o /tmp/task.deb && \
    apt-get install -y /tmp/task.deb && \
    rm -f /tmp/task.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Node.js (v22) インストール
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    NO_PROXY=localhost,127.0.0.1,::1,auth.openai.com

# Codexを公式ガイド通りにグローバルインストール
RUN npm i -g @openai/codex

# 開発ユーザー作成
RUN groupadd -g 1000 dev && \
    useradd -m -u 1000 -g dev -s /bin/bash dev && \
    chown -R dev:dev /home/dev

# VS Code Server 用ディレクトリ
# VS Code Server 用のディレクトリを事前に作成して権限を設定
RUN mkdir -p /home/dev/.vscode-server/bin /home/dev/.vscode-server/extensions && \
    chown -R dev:dev /home/dev/.vscode-server

WORKDIR $APP_ROOT

USER dev

# bashrc 設定
COPY --chown=dev:dev .devcontainer/infra/arduino/.bashrc /home/dev/.bashrc

# Claude Code インストール
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/dev/.bashrc && \
    echo 'eval `keychain --eval --agents ssh id_rsa 2>/dev/null`' >> /home/dev/.bashrc

ENV PATH="/home/dev/.local/bin:${PATH}"
