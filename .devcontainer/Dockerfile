FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG USERNAME=vscode

ENV ASDF_DIR=/usr/local/share/asdf
ENV PATH=${ASDF_DIR}/bin:${ASDF_DIR}/shims:/home/${USERNAME}/.local/bin:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncurses5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        tk-dev \
        unzip \
        xz-utils \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" --branch v0.16.4 \
    && chown -R "${USERNAME}:${USERNAME}" "${ASDF_DIR}" \
    && su "${USERNAME}" -c "curl -LsSf https://astral.sh/uv/install.sh | sh" \
    && su "${USERNAME}" -c "bash -lc '. ${ASDF_DIR}/asdf.sh && asdf plugin add python https://github.com/danhper/asdf-python.git'"

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

RUN echo '. /usr/local/share/asdf/asdf.sh' >> "/home/${USERNAME}/.bashrc" \
    && echo 'export PATH="/usr/local/share/asdf/bin:/usr/local/share/asdf/shims:$HOME/.local/bin:$PATH"' >> "/home/${USERNAME}/.bashrc"
