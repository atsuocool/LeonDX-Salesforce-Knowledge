# LeonDX Auto Pipeline

## この自動化が行うこと

LeonDX Auto Pipeline は、GitHub の `main` に新しいコミットが入ったかを
Atsuo の Mac で 15 分ごとに確認します。更新があれば次の順で処理します。

1. `git fetch origin main` でリモートを確認する
2. `git pull --ff-only origin main` でローカルを更新する
3. 変更された対象 Markdown を LeonDX AI Sync に送る
4. `leondx-ai-sync status` で同期状態を確認する
5. 結果をログに保存する

CLI がファイル単位の `--file` または `--path` を提供する場合は、対象ファイル
だけを同期します。対応していない場合は、リポジトリ全体の同期を 1 回実行します。

## 承認の境界

この仕組みは Pull Request の承認やマージを行いません。

GitHub で Atsuo が内容を確認し、Pull Request を `main` にマージすることが
人間による承認の境界です。マージされた内容だけが自動処理の対象になります。

## 前提条件

- ローカルリポジトリが `main` ブランチにある
- 作業ツリーがクリーンである
- `origin/main` へ接続できる
- `leondx-ai-sync` がインストール・設定済みである
- CLI の認証情報が macOS Keychain などの安全な保存先にある

パイプラインは履歴を書き換えません。fast-forward できない場合は停止し、
`reset --hard` や force push は実行しません。

## インストール

最初にリポジトリを `main` へ切り替え、最新にします。

```bash
cd /Users/atsuo/Documents/LeonDX-Salesforce-Knowledge
git switch main
git pull --ff-only origin main
```

必要に応じて設定例をコピーします。このファイルは Git の対象外です。

```bash
cp config/auto-pipeline.example.env config/auto-pipeline.env
```

ドライランで安全に確認した後、LaunchAgent をインストールします。

```bash
scripts/leondx_auto_pipeline.sh --dry-run
scripts/install_auto_pipeline.sh
```

インストーラーは plist を
`~/Library/LaunchAgents/com.leondx.salesforce-knowledge-sync.plist` にコピーし、
現在のユーザーの絶対パスへ置換します。`plutil` で検証してから
`launchctl` で読み込みます。

## 設定

設定ファイルは `config/auto-pipeline.env` です。利用できる項目は次のとおりです。

- `REPO_PATH`: ローカルリポジトリの絶対パス
- `LOG_DIR`: ログの保存先
- `SYNC_COMMAND`: AI Sync のコマンド
- `STATUS_COMMAND`: 同期状態を確認するコマンド
- `EXCLUDED_PATHS`: コロン区切りの除外パス

標準の除外対象は `.github/`、`assets/`、`drafts/`、`config/`、
`automation/`、`scripts/`、`LICENSE`、`CODEOWNERS`、
`CONTRIBUTING.md` です。

## ドライラン

次のコマンドは fetch と比較だけを行います。

```bash
scripts/leondx_auto_pipeline.sh --dry-run
```

更新の有無、全変更ファイル、除外ファイル、同期予定ファイル、実行予定の
コマンドを表示します。pull、AI Sync、status コマンドは実行しません。

## 手動実行

自動実行を待たずに処理する場合は次を実行します。

```bash
scripts/leondx_auto_pipeline.sh
```

同時実行はロックで防止されます。別の処理が動作中の場合は安全に終了します。

## LaunchAgent の動作

LaunchAgent はログイン時と 15 分ごとにスクリプトを起動します。状態確認は
次のコマンドで行えます。

```bash
scripts/status_auto_pipeline.sh
launchctl list | grep com.leondx.salesforce-knowledge-sync
```

状態スクリプトは LaunchAgent、最新ログ、現在ブランチ、作業ツリー、
ローカルとリモートのコミット ID を表示します。

## ログ

パイプラインログは次の場所にタイムスタンプ付きで保存されます。

```text
~/Library/Logs/LeonDX-Auto-Pipeline/pipeline-YYYYMMDD-HHMMSS-PID.log
```

LaunchAgent 自体の標準出力と標準エラーも同じディレクトリに保存されます。
ログファイルの権限はパイプラインが `600` に設定します。

## 一時停止と再開

一時停止する場合は plist を削除せず unload します。

```bash
launchctl unload ~/Library/LaunchAgents/com.leondx.salesforce-knowledge-sync.plist
```

再開する場合は load します。

```bash
launchctl load -w ~/Library/LaunchAgents/com.leondx.salesforce-knowledge-sync.plist
```

## アンインストール

```bash
scripts/uninstall_auto_pipeline.sh
```

LaunchAgent の読み込みを解除し、インストール済み plist だけを削除します。
ログ、リポジトリ、設定ファイルは残ります。

## トラブルシューティング

まず状態と最新ログを確認します。

```bash
scripts/status_auto_pipeline.sh
```

よくある原因は、`main` 以外のブランチ、未コミット変更、ネットワーク停止、
AI Sync CLI の未インストール、CLI 認証切れです。pull より前に停止した場合は、
問題を直した後の手動実行か次の 15 分周期で再試行できます。

pull 後に AI Sync が失敗した場合、Git はすでに最新です。原因を直して
`leondx-ai-sync sync` と `leondx-ai-sync status` を手動実行してください。
次の GitHub 更新から自動処理が通常どおり続きます。

fast-forward 不可と表示された場合は、自動処理を続けず Git 履歴を確認します。
ローカルコミットを残すか別ブランチへ移すかを判断してから復旧してください。

## 作業ツリーが dirty の場合

パイプラインはローカル変更を上書きせず停止します。まず次で内容を確認します。

```bash
git status
git diff
```

必要な変更はコミットするか、別ブランチへ移します。一時退避する場合は内容を
確認してから `git stash push -u` を使えます。不要なファイルも手動で確認して
削除してください。パイプラインは自動削除や `reset --hard` を行いません。

## Mac がスリープ中またはオフラインの場合

スリープ中は 15 分周期の処理は実行されません。復帰後に LaunchAgent の周期が
再開します。オフライン時は fetch が失敗し、非ゼロ終了としてログに残ります。
ローカル Git は変更されず、オンラインになった後の周期で再試行します。

## セキュリティと API キー

API キーを plist、Git 管理ファイル、ログへ書かないでください。実際の `.env`、
`config/auto-pipeline.env`、`*.log` は `.gitignore` の対象です。ただし、設定ファイル
には非秘密の設定だけを置くことを推奨します。

認証情報は LeonDX AI Sync CLI が対応する macOS Keychain などの安全な方法で
設定してください。LaunchAgent は通常のターミナルのシェル設定を読みません。
CLI が LaunchAgent からも認証情報を取得できることを、手動実行で確認します。
スクリプトは認証情報や環境変数の値をコマンド表示に含めません。
