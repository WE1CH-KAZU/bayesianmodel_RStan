# ライブラリの検索パス
.libPaths()

[1] "C:/Users/あなた/Documents/R/win-library/4.4"
[2] "C:/Program Files/R/R-4.4.1/library"

- 1行目 → ユーザライブラリ（あなたが後から追加したもの）
- 2行目 → システムライブラリ（Rインストール時に付属する基本パッケージ）

削除してよいのは基本的に「ユーザライブラリ」側だけです。システムライブラリを消すと、R 本体を壊します。

# バックアップ：現状の一覧を安全に保存
## まずは「ユーザーライブラリ」だけを見る
### 1) ライブラリパスの確認
.libPaths()

### 2) 先頭（通常ユーザーライブラリ）だけに限定して一覧取得
user_lib <- .libPaths()[1]
user_inst <- rownames(installed.packages(lib.loc = user_lib))
length(user_inst); head(user_inst)

## 「base + recommended」を正しく作る
base_pkgs <- rownames(installed.packages(priority = "base"))
rec_pkgs  <- rownames(installed.packages(priority = "recommended"))
protected <- unique(c(base_pkgs, rec_pkgs))

## ユーザーライブラリに入っていて、かつ保護対象でないものだけを削除
removable <- setdiff(user_inst, protected)
length(removable); removable

### ドライラン（何が消えるか確認）
setdiff(removable, character(0))

### 実削除（ユーザーライブラリを明示）
if (length(removable)) {
  remove.packages(removable, lib = user_lib) # lib = でライブラリ指定
}


# 現状確認用コマンド
sessionInfo()                       # R のバージョンとプラットフォーム確認
getOption("repos")                  # 参照中の CRAN ミラー
.libPaths()                         # 先頭がユーザーライブラリ
capabilities("libcurl")             # TRUE が望ましい
Sys.getenv(c("http_proxy","https_proxy","CURL_CA_BUNDLE"))


# ライブラリ参照先の変更
ミラーの固定をやめ、CDN 経由に切替（最重要）
## Posit Package Manager（PPM：バイナリ豊富で速い）
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))
install.packages("renv")

## CRAN Cloud（クラウド・ミラー）
options(repos = c(CRAN = "https://cloud.r-project.org"))

# クリーンアンインストールし終わったら…
install.packages("renv")
renv::init()

この操作で、poetryと同じように環境管理機能がディレクトリに適用される
この後、新しくpackagesをインストールしたら、
renv::snapshot()
をして、gitでコミットすれば更新される。
