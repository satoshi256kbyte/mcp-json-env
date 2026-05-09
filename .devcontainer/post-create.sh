#!/bin/bash
set -e

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Kiro CLI
yes | bash -c "$(curl -fsSL https://cli.kiro.dev/install)"

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Sync Python dependencies
uv sync

# Configure gh CLI auth from GITHUB_PERSONAL_ACCESS_TOKEN if available
if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    gh auth login --with-token <<< "$GITHUB_PERSONAL_ACCESS_TOKEN"
    echo "gh auth: configured from GITHUB_PERSONAL_ACCESS_TOKEN"
fi
