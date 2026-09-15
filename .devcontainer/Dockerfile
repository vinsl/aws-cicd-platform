FROM mcr.microsoft.com/devcontainers/python:1-3.11-bookworm

USER root

RUN set -eux; \
    rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarnpkg.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        unzip \
        lsb-release; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL https://apt.releases.hashicorp.com/gpg \
      | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/hashicorp.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends terraform; \
    terraform version; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) aws_arch="x86_64" ;; \
      arm64) aws_arch="aarch64" ;; \
      *) echo "Unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;; \
    esac; \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" \
      -o /tmp/awscliv2.zip; \
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    /tmp/aws/install; \
    aws --version; \
    rm -rf /tmp/aws /tmp/awscliv2.zip

USER vscode