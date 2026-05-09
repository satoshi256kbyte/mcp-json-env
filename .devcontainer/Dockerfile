FROM mcr.microsoft.com/devcontainers/python:1-3.13-bookworm

# Remove the Yarn repository whose GPG key has become invalid,
# preventing apt-get update from succeeding during feature installation.
RUN rm -f /etc/apt/sources.list.d/yarn.list

# Set git safe.directory to allow VS Code Git extension to work
# with bind-mounted workspace (host UID differs from container UID)
RUN git config --system --add safe.directory /workspaces/mcp-json-env
