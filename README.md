# mcp-json-env-devcontainer

Copilot agent mode、Claude Code、Kiro CLI で共通して使える MCP 設定を、devcontainer 経由の環境変数で扱うための最小構成テンプレートです。

## 含まれるもの

- `/.devcontainer/devcontainer.json`
  - devcontainer 起動時にホスト環境変数をコンテナへ引き継ぎます
  - `asdf` と `uv` を使って Python 3.13 をセットアップします
- `/.tool-versions`
  - `asdf` 用の Python バージョン定義
- `/pyproject.toml`
  - `uv` 用の最小 Python プロジェクト定義
- `/.vscode/mcp.json`
  - Copilot agent mode / VS Code 用 MCP 設定
- `/.mcp.json`
  - Claude Code 用 MCP 設定
- `/.kiro/settings/mcp.json`
  - Kiro CLI 用 MCP 設定

## 使い方

1. devcontainer を開く前に、ホスト側で必要な環境変数を設定します。

```bash
export MCP_SERVER_URL="https://your-mcp-server.example/mcp"
export MCP_SERVER_API_KEY="replace-with-your-api-key"
```

2. VS Code で **Reopen in Container** します。
3. 初回作成時に devcontainer が `asdf` 経由で Python 3.13 をインストールし、`uv venv` で仮想環境を作成します。
4. 各 `mcp.json` の `template-remote` を、利用したい MCP サーバー定義に合わせて編集します。
5. Python パッケージは必要に応じて `uv add ...` / `uv sync` で管理します。

## ポイント

- API キーは `mcp.json` に直接書かず、環境変数参照で扱います
- devcontainer がホスト環境変数をコンテナへ受け渡すため、Copilot agent mode / Claude Code / Kiro CLI から同じ値を使えます
- Python は `asdf` と `uv` を前提にした 3.13 系です
