# AGENTS.md

このファイルは GitHub Copilot coding agent がリポジトリを扱う際のガイダンスを提供します。

## プロジェクト概要

Copilot agent mode、Claude Code、Kiro CLI で共通して使える MCP 設定を、devcontainer 経由の環境変数で扱うための最小構成テンプレートです。

- Python 3.13 / `asdf` + `uv` ベースの開発環境
- devcontainer で `.devcontainer/.env` の環境変数をコンテナへ引き継ぎます
- API キーは環境変数で管理し、MCP 設定ファイルに直接記載しません

## MCP サーバーの利用

このリポジトリには AWS 操作および GitHub 操作を支援する MCP サーバーが設定されています（`.vscode/mcp.json`）。

### AWS 操作

AWS に関する操作を行う場合は、以下の MCP サーバーを活用してください。

- **aws-mcp**: AWS の汎用的な操作（リソースの確認・作成・変更など）に使用します。`mcp-proxy-for-aws` 経由で AWS MCP エンドポイントに接続します。リージョンは `ap-northeast-1` です。
- **iam-policy-autopilot**: IAM ポリシーの作成・分析・最適化に特化した MCP サーバーです。IAM 関連の操作にはこちらを優先して使用してください。

### GitHub 操作

GitHub に関する操作を行う場合は、以下の MCP サーバーを活用してください。

- **github**: `@modelcontextprotocol/server-github` を使用した GitHub MCP サーバーです。リポジトリの情報取得、Issue・Pull Request の操作、コード検索など GitHub API を活用した操作に使用してください。環境変数 `GITHUB_PERSONAL_ACCESS_TOKEN` で認証します。

## 開発コマンド

```bash
# 仮想環境の作成
uv venv --python "$(asdf which python)"

# パッケージの追加
uv add <package-name>

# 依存関係の同期
uv sync
```
