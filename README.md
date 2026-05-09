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
GITHUB_PERSONAL_ACCESS_TOKEN=replace-with-your-github-personal-access-token
```

> **注意:** `.devcontainer/.env` ファイルは `.gitignore` に含まれているため、Git にコミットされません。API キーなどの機密情報を安全に管理できます。

### 2. devcontainer を起動する

VS Code で **Reopen in Container**（コマンドパレット → `Dev Containers: Reopen in Container`）を実行します。

### 3. 初回セットアップ

初回作成時に devcontainer が以下を自動実行します：

- `asdf` 経由で Python 3.13 をインストール
- `uv venv` で仮想環境を作成

### . Python パッケージの管理

Python パッケージは必要に応じて `uv add ...` / `uv sync` で管理します。

## AWS 認証

MCP サーバー経由で AWS を操作するには、事前に AWS への認証を済ませておく必要があります。
devcontainer 内で以下のコマンドを実行し、AWS にログインしてください。

```bash
aws login
```

> **補足:** AWS IAM Identity Center (旧 AWS SSO) を利用している場合は `aws sso login --profile <プロファイル名>` を使用してください。プロファイルの設定は `aws configure sso` で行えます。

## ポイント

- API キーは `mcp.json` に直接書かず、環境変数参照で扱います
- `.env` ファイルで環境変数を管理するため、ホストのシェルに `export` する必要はありません
- devcontainer が `.devcontainer/.env` ファイルの環境変数をコンテナへ受け渡すため、Copilot agent mode / Claude Code / Kiro CLI から同じ値を使えます
- Python は `asdf` と `uv` を前提にした 3.13 系です
