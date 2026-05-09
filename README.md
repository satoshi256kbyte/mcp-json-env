# mcp-json-env-devcontainer

Copilot agent mode、Claude Code、Kiro CLI で共通して使える MCP 設定を、devcontainer 経由の環境変数で扱うための最小構成テンプレートです。

## 含まれるもの

- `/.devcontainer/devcontainer.json`
  - Python 3.13 の devcontainer image をベースに、AWS CLI / GitHub CLI / Docker-in-Docker を features で追加します
  - 起動時に `.devcontainer/.env.secrets` の環境変数をコンテナへ引き継ぎます
  - `postCreateCommand` で `uv` / Kiro CLI / Claude Code をインストールし、`uv sync` を実行します
  - ホストの `~/.aws` / `~/.claude` / `~/.claude.json` / `~/.gitconfig` をバインドマウントし、認証情報をホストと共有します
    - ホストの `credential.helper`（例: `osxkeychain`）がコンテナ内で動作しない問題は、`remoteEnv` の `GIT_CONFIG_COUNT` / `GIT_CONFIG_KEY_0` / `GIT_CONFIG_VALUE_0` で `credential.helper` を空に上書きして回避しています
- `/pyproject.toml`
  - `uv` 用の最小 Python プロジェクト定義（`requires-python` で 3.13 を指定）
- `/.devcontainer/.env.secrets.example`
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

### 1. `.env.secrets` ファイルを作成する

`.devcontainer/` ディレクトリに `.env.secrets` ファイルを作成し、必要な環境変数を設定します。
`.devcontainer/.env.secrets.example` をコピーして利用してください。

```bash
cp .devcontainer/.env.secrets.example .devcontainer/.env.secrets
```

`.devcontainer/.env.secrets` ファイルを編集し、実際の値を設定します。

```dotenv
GITHUB_PERSONAL_ACCESS_TOKEN=replace-with-your-github-personal-access-token
```

> **注意:** `.devcontainer/.env.secrets` ファイルは `.gitignore` に含まれているため、Git にコミットされません。API キーなどの機密情報を安全に管理できます。

### 2. devcontainer を起動する

VS Code で **Reopen in Container**（コマンドパレット → `Dev Containers: Reopen in Container`）を実行します。

### 3. 初回セットアップ

初回作成時に devcontainer が以下を自動実行します：

- features で AWS CLI / GitHub CLI / Docker-in-Docker をインストール
- `postCreateCommand` で `uv` / Kiro CLI / Claude Code をインストール
- `uv sync` で仮想環境（`.venv`）を作成し依存をインストール

### 4. Kiro CLI の認証

devcontainer 内にはブラウザがないため、デバイスフローを使って認証します。

```bash
kiro-cli login --use-device-flow
```

表示される URL をホスト側のブラウザで開き、認証コードを入力してください。

### 5. Python パッケージの管理

Python パッケージは必要に応じて `uv add ...` / `uv sync` で管理します。

## AWS 認証

MCP サーバー経由で AWS を操作するには、事前に AWS への認証を済ませておく必要があります。
devcontainer 内で以下のコマンドを実行し、AWS にログインしてください。

```bash
aws login
```

> **補足:** AWS IAM Identity Center (旧 AWS SSO) を利用している場合は `aws sso login --profile <プロファイル名>` を使用してください。プロファイルの設定は `aws configure sso` で行えます。

## トラブルシューティング

### DevContainer 起動後に Git リモートリポジトリが認識されない / 認証情報が引き継がれない

ホスト Mac の `~/.gitconfig` に設定されている `credential.helper`（例: `osxkeychain`）がコンテナ内に存在しないため、Git 認証が失敗します。さらに、この失敗により VS Code の内蔵クレデンシャル転送（`GIT_ASKPASS`）も使われなくなり、プッシュ・プル操作や Copilot Chat の認証に影響します。

**対策（このテンプレートで実施済み）:**

- `devcontainer.json` の `remoteEnv` で Git の環境変数ベース設定（`GIT_CONFIG_COUNT` / `GIT_CONFIG_KEY_0` / `GIT_CONFIG_VALUE_0`）を使い、`credential.helper` を空に上書きしています
- これによりホストの `credential.helper` が無効化され、VS Code の `GIT_ASKPASS` によるクレデンシャル転送が正常に動作します

### DevContainer 起動後に Copilot Chat が使えない（"No delegate found that can handle the connection"）

VS Code の Copilot Chat は、VS Code 内蔵の GitHub 認証プロバイダ（OAuth フロー）を使用して接続します。コンテナ環境に `GITHUB_TOKEN` 環境変数が存在すると、VS Code の OAuth 認証フローと競合し、上記エラーが発生します。

**主な原因:**

- `ghcr.io/devcontainers/features/github-cli` feature が、ホストの `gh` CLI 認証情報をもとに **自動的に `GITHUB_TOKEN` を設定する**ため、ユーザーが明示的に設定していなくても競合が発生します
- `.devcontainer/.env.secrets` に `GITHUB_TOKEN` を設定した場合も同様です

**対策（このテンプレートで実施済み）:**

- `devcontainer.json` の `remoteEnv` で `"GITHUB_TOKEN": ""` を設定し、github-cli feature が注入するトークンを VS Code プロセスから除外しています
- MCP サーバーの認証には `GITHUB_PERSONAL_ACCESS_TOKEN` を使用しています（VS Code の内蔵認証と競合しない名前）

**それでも解決しない場合:**

1. `.devcontainer/.env.secrets` に `GITHUB_TOKEN` が含まれていないか確認してください
2. VS Code のホスト側で GitHub アカウントにサインインしていることを確認してください（左下のアカウントアイコン → GitHub でサインイン）
3. DevContainer を **Rebuild** してください（コマンドパレット → `Dev Containers: Rebuild Container`）

## ポイント

- API キーは `mcp.json` に直接書かず、環境変数参照で扱います
- `.env.secrets` ファイルで環境変数を管理するため、ホストのシェルに `export` する必要はありません
- devcontainer が `.devcontainer/.env.secrets` ファイルの環境変数をコンテナへ受け渡すため、Copilot agent mode / Claude Code / Kiro CLI から同じ値を使えます
- Python は devcontainer image にプリインストールされた 3.13 を `uv` で扱います
- ホスト Mac の `~/.aws` / `~/.claude` / `~/.claude.json` をバインドマウントしているため、AWS / Claude Code のログインはホストとコンテナで共有されます
- ホスト Mac の `~/.gitconfig` をバインドマウントし、`remoteEnv` の `GIT_CONFIG_*` 環境変数で `credential.helper` を無効化しています（VS Code のクレデンシャル転送と競合しないようにするため）
