###
# .Rprofileは起動時に自動実行される
# 重い処理やinstall.packages()のような操作を入れないようにする
###

message("------------ .Rprofile's message ------------")
source("renv/activate.R")

# .Rprofile （プロジェクト直下に作成）
# repos: install.packagesの閲覧先
options(
  repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"),
  download.file.method = "libcurl",
  scipen = 999,                   # 科学表記を抑制
  dplyr.summarise.inform = FALSE, # 冗長出力を抑制
  renv.verbose = TRUE
)

# プロジェクトルートをここに固定
# 相対パスを統一する
if (requireNamespace("here", quietly = TRUE)) {
  message("Project root: ", here::here())
}

# ローカル設定ファイル（非Git管理）を読み込む
# APIキーやパスワード、フォルダパスなどを管理する.Renvironを読み込む
if (file.exists(".Renviron")) readRenviron(".Renviron")

# renv環境を自動アクティブ化
if (requireNamespace("renv", quietly = TRUE)) renv::activate()

# Option
# 任意の便利パッケージのロード
# if (requireNamespace("tidyverse", quietly = TRUE)) {
#   suppressMessages(library(tidyverse))
# }
