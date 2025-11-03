# ライブラリの検索パス
```
.libPaths()

# 出力結果
[1] "C:/Users/あなた/Documents/R/win-library/4.4"
[2] "C:/Program Files/R/R-4.4.1/library"
```
- 1行目 → ユーザライブラリ（あなたが後から追加したもの）
- 2行目 → システムライブラリ（Rインストール時に付属する基本パッケージ）

削除してよいのは基本的に「ユーザライブラリ」側だけです。システムライブラリを消すと、R 本体を壊します。

# バックアップ：現状の一覧を安全に保存
## まずは「ユーザーライブラリ」だけを見る
### 1) ライブラリパスの確認
```
.libPaths()
```

### 2) 先頭（通常ユーザーライブラリ）だけに限定して一覧取得
```r
user_lib <- .libPaths()[1]
user_inst <- rownames(installed.packages(lib.loc = user_lib))
length(user_inst); head(user_inst)
```

## 「base + recommended」を正しく作る
```r
base_pkgs <- rownames(installed.packages(priority = "base"))
rec_pkgs  <- rownames(installed.packages(priority = "recommended"))
protected <- unique(c(base_pkgs, rec_pkgs))
```

## ユーザーライブラリに入っていて、かつ保護対象でないものだけを削除
```r
removable <- setdiff(user_inst, protected)
length(removable); removable
```

### ドライラン（何が消えるか確認）
```r
setdiff(removable, character(0))
```

### 実削除（ユーザーライブラリを明示）
```r
if (length(removable)) {
  remove.packages(removable, lib = user_lib) # lib = でライブラリ指定
}
```

# 現状確認用コマンド
```
sessionInfo()                       # R のバージョンとプラットフォーム確認
getOption("repos")                  # 参照中の CRAN ミラー
.libPaths()                         # 先頭がユーザーライブラリ
capabilities("libcurl")             # TRUE が望ましい
Sys.getenv(c("http_proxy","https_proxy","CURL_CA_BUNDLE"))
```

# ライブラリ参照先の変更
```
ミラーの固定をやめ、CDN 経由に切替（最重要）
```
## Posit Package Manager（PPM：バイナリ豊富で速い）
```r
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))
install.packages("renv")
```

## CRAN Cloud（クラウド・ミラー）
```r
options(repos = c(CRAN = "https://cloud.r-project.org"))
```

# クリーンアンインストールし終わったら…
```r
install.packages("renv")
renv::init()
```
この操作で、poetryと同じように環境管理機能がディレクトリに適用される  
この後、新しくpackagesをインストールしたら、
```
renv::snapshot()
```
をして、gitでコミットすれば更新される。

今後は、
```r
install.packages("pkgname")
```
ではなく
```r
# 最新版インストール
renv::install("pkgname")

# バージョン指定インストール
renv::install("pkgname@X.XX.X")
```
を使っていく事

# renvで管理されている内容を知りたいとき
### 概要を知る
```
renv::status()
```
現在の環境とrenv.lockファイルとの差分を確認する  
なにも差分がなければ以下が出力される
```
No issues found -- the project is in a consistent state.
```

### 現環境でrenv管理下の下でのインストールパッケージ一覧を知る
```
renv::dependencies()
```
一覧が表示される  
都度```renv::snapshot```をとること

### 現環境のすべての概要を1コマンドで把握する
```
renv::diagnostics()
```

# renvで環境構築が終わったら...
### RStudioプロジェクト設定（.Rproj設定）
- Tools > Project Options で.Proj毎のセッティングが可能。より上位はGlobal Optionsで。
- 以下の設定はGlobal Optionsで行っておいて、Project Optionsでも{Default}ではなく指定しておけばなお良し。
- RStudio の GUI で設定しておくと全員の開発体験が安定します。
- .Rproj は設定ファイルとして自動保存されるため、Git で追跡して問題ありません。
- rig（Rのバージョン管理）は使用しないのでデフォルトでOK
```
| 設定項目                                  | 推奨値                     | 理由            
| ---------------------------------------- | ----------------           | ------------- 
| Restore .RData into workspace at startup | OFF                        | セッション汚染防止
| Save workspace to .RData on exit         | Never                      | 再現性保持
| Use R version                            | rig で選択したバージョン固定 | チーム環境一致
| Code > Saving > Line endings             | “POSIX (LF)”               | クロスプラットフォーム互換
| Encoding                                 | “UTF-8”                    | 国際化対応
```
### .Rprofile（プロジェクト内の起動設定）
- Pythonの```settings.json + .env```に近い役割  
プロジェクト毎に起動時設定を統一させる
```r
# .Rprofile （プロジェクト直下に作成）
options(
  repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"),
  download.file.method = "libcurl",
  scipen = 999,                   # 科学表記を抑制
  dplyr.summarise.inform = FALSE, # 冗長出力を抑制
  renv.verbose = TRUE
)

# プロジェクトルートをここに固定
if (requireNamespace("here", quietly = TRUE)) {
  message("Project root: ", here::here())
}

# ローカル設定ファイル（非Git管理）を読み込む
# APIキーやパスワード、フォルダパスなどを管理する.Renvironを読み込む
if (file.exists(".Renviron")) readRenviron(".Renviron")

```

### .Renviron (環境変数：秘匿情報や設定値を入力保存するファイル)
- ```.Renviron```を作成してAPIキーやフォルダパスを入力しておく
- ```.gitignore```のリストに加えておくことで秘匿性が上がる
```
# .Renviron
DATA_PATH="C:/Users/mkwkz/Documents/Rproject/data"
API_KEY="xxxx-xxxx-xxxx"

Sys.getenv("DATA_PATH")
```

### ディレクトリ構成
- 明示的なルールはない
- モジュール用の```.R```ファイルは```lib/```にいれて```sorce("lib/func.R)```や```devtool::load_all()```で利用する
```
# ディレクトリツールメーカー（https://pote-chil.com/tools/directory-tree-generator）

root
├─ data
│   ├─ processed
│   └─ raw
├─ fig
├─ renv <- 環境管理フォルダ
├─ src <- ここに開発コードを記述
├─ lib <- 再利用用開発コード
├─ report
├─ .gitignore
├─ .Renviron
├─ .Rhistory
├─ .Rprofile
├─ .projet_name.Rproj
├─ renv.lock
└─ .README.md
```

### コーディングの管理（styler, lintr）
- RUFFと同じ環境をRStudioで構築する
#### install
```r
install.packages(c("styler","lintr"))
renv::snapshot() # これでrenv.lockに記録
```
これで styler と lintr がプロジェクト環境にインストールされます。
- 目的と役割の違い
  - styler : コードのフォーマット（整形）: black や autopep8 に相当
  - lintr : コーディング規約やバグを検知（lint） : ruff, flake8, pylint に相当

#### setting (Styler)
- styler の実行コマンド(単発)
```r
# これらのコードをconsole上で実行すればOK

library(styler)

styler::style_file("scripts/example.R")  # 指定するファイル単体
styler::style_dir("R")                   # フォルダ全体

```
- コードを作成した後呼び出して実行する
```r
# lib/に"style_prj.R"などの名前で作成

message("Styling all R files in project...")

library(styler)
styler::style_dir("lib")
styler::style_dir("src")

message("✅ Styling completed.")

```
```r
# 整形したいR上、またはconsole上で実行
source("lib/style_project.R")
```
#### setting (lintr)
- RUFF と同じ使い方をするので、まずは設定ファイルを作成する
- rootに```.lintr```を新規作成して、以下の設定（超基本のデフォルト設定）を記述する
```r
linters: with_defaults(
  line_length_linter(120),         # 行長120文字
  object_usage_linter = NULL,      # 未使用変数の警告を無効化
  commented_code_linter = NULL,    # コメントアウトされたコードの警告を無効化
  object_name_linter = NULL        # 命名規則チェックをオフ
)
encoding: "UTF-8"

```
このルールを設定した後、Global Options > code > diagnosticsの設定を済ませる  
設定内容は```fig/lintr_setting_in_globaloptions.png```の画像を参照  
  
※設定が終わったらRStudioの再起動を行う。

### パスの管理（here）
R では、ファイルを開いたり保存したりする際に「カレントワーキングディレクトリ（作業ディレクトリ）」を基準にします。  
- オーソドックスな方法
```r
setwd("C:/Users/****/R/project/root") # ワーキングディレクトリを指定
df <- read.csv("data/raw/data.csv") # 読み込み
```
この方法だと、別のユーザーがこのコードを実行した際に```setwd()```内が異なるので動作しない  
これを簡単に管理するためのパッケージとして```here```を使う

```r
# インストール
install.packages("here")
renv::snaphot()
```
```r
# ロードと読み込み
library(here)
df <- read.csv(here("data","data.csv"))
```
フォルダすべてをクローンした後にこのコードで誰でも data.csv を df に渡すことができる

```r
# プロジェクトルートの絶対パスを返す
here::here()
```


# R script上で見出しを作る方法
```r
# ---- 見出し ----
## ---- 中見出し ----
### ---- 小見出し ----
```
この記述で見出しが生成される  
見出し一覧は「Ctrl + Shit + o」で表示可能


# パッケージのアンインストール
- .Rproj, renv管理下でインストールしsnapshot()もとった後  
やっぱりアンインストールしたいとき

```r
renv::remove("名前")
```
この操作はあくまでプロジェクトライブラリのみ  
ユーザーライブラリに入ったものは操作されない。