message("Styling all R files in project...")

library(styler)
# styler::style_dir("R") # モジュール
styler::style_dir("src") # 開発コード

message("✅ Styling completed.")
