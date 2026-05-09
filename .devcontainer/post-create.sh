#!/bin/bash
set -e

# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Kiro CLI
yes | bash -c "$(curl -fsSL https://cli.kiro.dev/install)"

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Install Python dependencies
uv sync

# Create container-local .gitconfig that includes host settings
# but clears credential.helper to avoid conflicts with VS Code's
# built-in GIT_ASKPASS credential forwarding.
# (Host's .gitconfig is mounted at ~/.gitconfig-host)
printf '[include]\n    path = ~/.gitconfig-host\n[credential]\n    helper = \n' > /home/vscode/.gitconfig
