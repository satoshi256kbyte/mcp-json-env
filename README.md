# mcp-json-env-devcontainer

Copilot agent mode、Claude Code、Kiro CLI で共通して使える MCP 設定を、devcontainer 経由の環境変数で扱うための最小構成テンプレートです。

## 含まれるもの

- `/.devcontainer/devcontainer.json`
  - devcontainer 起動時に `.devcontainer/.env` ファイルの環境変数をコンテナへ引き継ぎます
  - `asdf` と `uv` を使って Python 3.13 をセットアップします
- `/.devcontainer/Dockerfile`
  - devcontainer 用の Docker イメージ定義（Ubuntu 24.04 ベース）
- `/.tool-versions`
  - `asdf` 用の Python バージョン定義
- `/pyproject.toml`
  - `uv` 用の最小 Python プロジェクト定義
- `/.devcontainer/.env.example`
  - 環境変数のテンプレートファイル
- `/.vscode/mcp.json`
  - Copilot agent mode / VS Code 用 MCP 設定
- `/.mcp.json`
  - Claude Code 用 MCP 設定
- `/.kiro/settings/mcp.json`
  - Kiro CLI 用 MCP 設定

## MCP 設定ファイル一覧

| ファイルパス | 対応ツール | 備考 |
|---|---|---|
| `/.vscode/mcp.json` | VS Code (Copilot agent mode) | `${env:VAR}` 形式で環境変数を参照 |
| `/.mcp.json` | Claude Code | `${VAR}` 形式で環境変数を参照 |
| `/.kiro/settings/mcp.json` | Kiro CLI | `${VAR}` 形式で環境変数を参照 |

> **補足:** VS Code の MCP 設定では `${env:VAR}` のように `env:` プレフィックスが必要です。Claude Code および Kiro CLI では `${VAR}` のように直接変数名を指定します。これはツールごとの仕様の違いです。

## devcontainer の使い方

### 1. `.env` ファイルを作成する

`.devcontainer/` ディレクトリに `.env` ファイルを作成し、必要な環境変数を設定します。
`.devcontainer/.env.example` をコピーして利用してください。

```bash
cp .devcontainer/.env.example .devcontainer/.env
```

`.devcontainer/.env` ファイルを編集し、実際の値を設定します。

```dotenv
MCP_SERVER_URL=https://your-mcp-server.example/mcp
MCP_SERVER_API_KEY=replace-with-your-api-key
```

> **注意:** `.devcontainer/.env` ファイルは `.gitignore` に含まれているため、Git にコミットされません。API キーなどの機密情報を安全に管理できます。

### 2. devcontainer を起動する

VS Code で **Reopen in Container**（コマンドパレット → `Dev Containers: Reopen in Container`）を実行します。

### 3. 初回セットアップ

初回作成時に devcontainer が以下を自動実行します：

- `asdf` 経由で Python 3.13 をインストール
- `uv venv` で仮想環境を作成

### 4. MCP サーバーを設定する

各 `mcp.json` の `template-remote` を、利用したい MCP サーバー定義に合わせて編集します。

### 5. Python パッケージの管理

Python パッケージは必要に応じて `uv add ...` / `uv sync` で管理します。

## ポイント

- API キーは `mcp.json` に直接書かず、環境変数参照で扱います
- `.env` ファイルで環境変数を管理するため、ホストのシェルに `export` する必要はありません
- devcontainer が `.devcontainer/.env` ファイルの環境変数をコンテナへ受け渡すため、Copilot agent mode / Claude Code / Kiro CLI から同じ値を使えます
- Python は `asdf` と `uv` を前提にした 3.13 系です
