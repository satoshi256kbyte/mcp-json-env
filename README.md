# mcp-json-env-devcontainer

Copilot agent mode、Claude Code、Kiro CLI で共通して使える MCP 設定を環境変数で扱うための最小構成テンプレートです。

環境変数の渡し方として **2 通り** に対応しています：

| 方式 | 対象 | 使用ファイル |
|---|---|---|
| **devcontainer** | VS Code + Dev Containers | `.devcontainer/.env.secrets` |
| **direnv** | ローカル（devcontainer を使わない場合） | `.env.local` |

## 含まれるもの

- `/.devcontainer/devcontainer.json`
  - Python 3.13 の devcontainer image をベースに、AWS CLI / GitHub CLI / Docker-in-Docker を features で追加します
  - 起動時に `.devcontainer/.env.secrets` の環境変数をコンテナへ引き継ぎます
  - `postCreateCommand` で `uv` / Kiro CLI / Claude Code をインストールし、`gh auth setup-git` と `uv sync` を実行します
  - ホストの `~/.aws` / `~/.claude` / `~/.claude.json` / `~/.ssh` をバインドマウントし、認証情報をホストと共有します
  - `~/.config/gh` は Docker Volume（`gh-config`）で管理し、Rebuild 後も gh CLI のトークンを保持します
- `/pyproject.toml`
  - `uv` 用の最小 Python プロジェクト定義（`requires-python` で 3.13 を指定）
- `/.devcontainer/.env.secrets.example`
  - devcontainer 用の環境変数テンプレートファイル
- `/.env.local.sample`
  - direnv（ローカル）用の環境変数テンプレートファイル
- `/.envrc`
  - direnv の設定ファイル。`.env.local` が存在すれば自動で読み込みます
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

### VS Code MCP の `envFile` による環境変数の読み込み

VS Code の MCP 設定（`.vscode/mcp.json`）では、`envFile` プロパティを使って `.env` 形式のファイルから環境変数を読み込めます。

```jsonc
{
    "servers": {
        "github": {
            "command": "docker",
            "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
            "envFile": "${workspaceFolder}/.env.local",
            "type": "stdio"
        }
    }
}
```

#### なぜ `envFile` が必要か

VS Code の `${env:VAR}` は **VS Code プロセス自身の環境変数** を参照します。direnv でシェルにセットした環境変数は、VS Code を Dock や Spotlight から起動した場合には引き継がれません。

`envFile` を使えば、VS Code の起動方法に依存せず `.env.local` から直接環境変数を読み込めます。direnv（シェル用）と `envFile`（VS Code MCP 用）で同じ `.env.local` ファイルを共有できるため、管理が一元化されます。

> **注意:** `envFile` と `env` を同時に指定した場合、`env` 側の値が優先されます。`env` に `${env:VAR}` を書くと、VS Code プロセスの環境変数（空の可能性がある）で `envFile` の値が上書きされてしまうため、`envFile` を使う場合は `env` に同じ変数を書かないでください。

#### 公式ドキュメント

`envFile` プロパティは VS Code 公式ドキュメントの MCP 設定リファレンスに記載されています。

> **envFile** — Path to an environment file to load more variables（例: `"${workspaceFolder}/.env"`）
>
> — [MCP configuration reference - Standard I/O (stdio) servers](https://code.visualstudio.com/docs/copilot/reference/mcp-configuration#_standard-io-stdio-servers)

### Kiro CLI / Claude Code の環境変数について

Kiro CLI（`.kiro/settings/mcp.json`）および Claude Code（`.mcp.json`）には、VS Code の `envFile` に相当するプロパティはありません。環境変数は起動元シェルから継承されるため、direnv（ローカル）または devcontainer の `remoteEnv`（コンテナ内）で事前にセットしておく必要があります。

ターミナルから起動する Kiro CLI / Claude Code では、VS Code のように Dock・Spotlight 起動でシェル環境が引き継がれない問題は発生しません。

## direnv を使ったローカルセットアップ（devcontainer を使わない場合）

devcontainer を使わずにホスト Mac 上で直接作業するときは、[direnv](https://direnv.net/) を使って環境変数を管理します。

### 仕組み

`.envrc` ファイルが `dotenv_if_exists .env.local` を実行します。ディレクトリに入ると direnv がこれを検知し、`.env.local` が存在すれば自動で環境変数を読み込みます。これにより MCP 設定ファイルが参照する `GITHUB_PERSONAL_ACCESS_TOKEN` がシェルに展開された状態で Claude Code などのツールが起動します。

```
.envrc           # 「.env.local があれば読み込む」という指示が書かれている（Git 管理対象）
.env.local       # 実際のトークンを書く（.gitignore 済み、Git には含めない）
.env.local.sample  # .env.local のテンプレート（Git 管理対象）
```

### 1. direnv をインストールする

```bash
brew install direnv
```

インストール後、シェルに hook を追加します。macOS Catalina 以降はデフォルトシェルが zsh のため、通常は zsh の設定を使います。

**zsh（`~/.zshrc`）— Mac のデフォルト：**

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**bash（`~/.bashrc`）— bash に変更している場合：**

```bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
```

### 2. `.env.local` を作成する

`.env.local.sample` をコピーして `.env.local` を作成します。

```bash
cp .env.local.sample .env.local
```

`.env.local` を編集し、実際の値を設定します。

```dotenv
GITHUB_PERSONAL_ACCESS_TOKEN=replace-with-your-github-personal-access-token
```

> **注意:** `.env.local` は `.gitignore` に含まれているため、Git にコミットされません。

### 3. direnv を許可する

初回（または `.envrc` が変更されたとき）は、以下のコマンドで direnv を許可する必要があります。

```bash
direnv allow
```

以降はディレクトリに入るたびに自動で `.env.local` が読み込まれます。

```bash
direnv: loading .env.local
```

### 4. 動作確認

```bash
echo $GITHUB_PERSONAL_ACCESS_TOKEN
```

トークンが表示されれば設定完了です。Claude Code / Kiro CLI を起動すると GitHub MCP サーバーが認証済み状態で動作します。

---

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

### 4. Python パッケージの管理

Python パッケージは必要に応じて `uv add ...` / `uv sync` で管理します。

---

## コンテナの起動・停止・リビルド

### 通常の起動・停止

| 操作 | コマンドパレット | 説明 |
|---|---|---|
| 起動（初回 / 停止後） | `Dev Containers: Reopen in Container` | コンテナを起動して接続する |
| 停止 | `Dev Containers: Reopen Folder Locally` | コンテナを停止してローカルに戻る |
| 停止のみ | Docker Desktop でコンテナを Stop | VS Code を閉じただけではコンテナは停止しない |

> **補足:** 停止して再起動（Stop → Start）した場合、`postCreateCommand` は実行されません。インストール済みのツールや Docker Volume の認証情報はそのまま残ります。

### リビルドが必要なケース

以下を変更したときは、コンテナを**リビルド**（再構築）する必要があります：

- `devcontainer.json` の変更（`features`、`mounts`、`remoteEnv`、`postCreateCommand` など）
- `Dockerfile` の変更
- `.devcontainer/.env.secrets` の変更（環境変数の追加・変更）

### リビルドの実行

コマンドパレットで以下を実行します：

```
Dev Containers: Rebuild Container
```

> **注意:** リビルド時に Docker Volume（`gh-config`）は削除されません。ただし、`postCreateCommand` が再実行されるため、インストール処理（`uv`、Kiro CLI、Claude Code など）は最初からやり直しになります（数分かかります）。

### リビルド後の認証状態

| サービス | リビルド後 |
|---|---|
| GitHub (gh CLI / git) | **不要**（Volume が残るため） |
| GitHub Copilot | **不要**（VS Code がホストから自動転送） |
| AWS | **不要**（バインドマウントのため） |
| Claude Code | **不要**（バインドマウントのため） |
| Kiro CLI | 要確認（セッション切れの場合は `kiro-cli login --use-device-flow`） |

---

## 認証セットアップ

### GitHub 認証（gh CLI / git HTTPS）

**仕組み：** `~/.config/gh` は Docker Volume（`gh-config`）で管理します。ホストの認証情報は共有せず、コンテナ固有のトークンを Volume に永続化します。Rebuild してもトークンは消えません。

**初回のみ必要な操作：**

> **実行場所: コンテナ内** （VS Code のターミナル）

```bash
gh auth login
```

ブラウザが使えないため、デバイスフローを選んでください：

1. `GitHub.com` を選択
2. `HTTPS` を選択
3. `Login with a web browser` を選択
4. 表示される URL を**ホスト側のブラウザ**で開き、コードを入力

ログイン後、git の HTTPS 認証も自動で設定されます（`postCreateCommand` で `gh auth setup-git` 済み）。

**2回目以降（Rebuild 後も含む）：** Volume にトークンが残るため、再ログイン不要です。

> **注意:** `GITHUB_TOKEN` 環境変数は設定しないでください。GitHub Copilot の OAuth 認証と競合し、Copilot Chat が使えなくなります。

---

### GitHub Copilot 認証（VS Code 拡張）

**仕組み：** VS Code がホストの GitHub アカウント情報をコンテナへ自動転送します。コンテナ側での操作は不要です。

**必要な操作：**

> **実行場所: ホスト側** の VS Code

VS Code 左下のアカウントアイコン → **「GitHub でサインイン」** を実行してください。

サインイン済みであれば、コンテナ起動時に自動転送されるため、コンテナ内での追加操作は不要です。

---

### AWS 認証

**仕組み：** ホストの `~/.aws` ディレクトリをバインドマウントしています。ホストで認証済みの場合はコンテナ内でもそのまま使えます。`~/.aws` はバインドマウントのため、どちらで実行しても両側に反映されます。

**ホストで認証済みの場合：** 追加操作は不要です。

**未認証の場合：**

> **実行場所: ホスト側またはコンテナ内**（どちらでも可）

AWS IAM Identity Center（SSO）を利用しているときは：

```bash
aws sso login --profile <プロファイル名>
```

プロファイルを初めて設定する場合：

```bash
aws configure sso
```

---

### Claude Code 認証

**仕組み：** ホストの `~/.claude` / `~/.claude.json` をバインドマウントしています。ホストで認証済みであれば、コンテナ内でも自動的に認証済み状態になります。

**ホストで認証済みの場合：** 追加操作は不要です。

**未認証の場合：**

> **実行場所: ホスト側**

コンテナを起動する前に、ホスト側で Claude Code にログインしてください。

```bash
claude
```

---

### Kiro CLI 認証

**仕組み：** Kiro CLI の認証情報は Docker Volume（`kiro-session-data` 相当）には保持されず、セッションが切れると再ログインが必要です。コンテナ内にはブラウザがないため、デバイスフローを使います。

**必要な操作：**

> **実行場所: コンテナ内**（VS Code のターミナル）

```bash
kiro-cli login --use-device-flow
```

表示される URL を**ホスト側のブラウザ**で開き、認証コードを入力してください。

---

## 認証方式まとめ

| サービス | 方式 | 初回操作 | Rebuild 後 |
|---|---|---|---|
| GitHub (gh CLI / git) | Docker Volume | `gh auth login`（コンテナ内） | 不要 |
| GitHub Copilot | VS Code 自動転送 | ホスト VS Code でサインイン済みであること | 不要 |
| AWS | バインドマウント | ホストで認証済みなら不要 | 不要 |
| Claude Code | バインドマウント | ホストで認証済みなら不要 | 不要 |
| Kiro CLI | デバイスフロー | `kiro-cli login --use-device-flow`（コンテナ内） | 要確認 |

---

## ポイント

- API キーは `mcp.json` に直接書かず、環境変数参照で扱います
- **devcontainer 利用時：** `.devcontainer/.env.secrets` で環境変数を管理するため、ホストのシェルに `export` する必要はありません
- **ローカル利用時：** direnv + `.env.local` で環境変数を管理します。シェルへの手動 `export` は不要です
- どちらの方式でも Copilot agent mode / Claude Code / Kiro CLI から同じ MCP 設定ファイルを使えます
- Python は devcontainer image にプリインストールされた 3.13 を `uv` で扱います
