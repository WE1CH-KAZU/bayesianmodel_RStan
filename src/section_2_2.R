library(here)
# ---- データの要約 ----
## ---- ヒストグラム ----

# import data
fish <- read.csv(here("data", "raw", "2-2-1-fish.csv"))
dim(fish)
head(fish, n = 2)

# histgram
hist(fish$length)


## ---- カーネル密度推定 ----
kernel_density <- density(fish$length)
plot(kernel_density)

# バンド幅を変えるとカーネル密度推定の可視化傾向が変わる
kernel_density_quater <- density(fish$length, adjust = 0.25)
kernel_density_quadruple <- density(fish$length, adjust = 4)

# 結果の可視化
plot(kernel_density,
  lwd = 2, # 線の太さ
  xlab = "", # ラベルを無表記
  ylim = c(0, 0.26), # レンジ幅
  main = "バンド幅を変えた時の可視化傾向の違い" # タイトル
)
# lines関数でグラフに上書き
lines(kernel_density_quater, col = 2)
lines(kernel_density_quadruple, col = 4)
# 凡例追加
legend(
  "topleft",
  col = c(1, 2, 4),
  lwd = 1,
  bty = "n",
  legend = c("normal", "quater", "quadruple")
)


## ---- 算術平均 ----
# 算術平均
mean(fish$length)

# 各種統計量
length(fish$length)
median(fish$length)
quantile(fish$length, probs = 0.25) # 25パーセンタイル
quantile(fish$length, probs = c(0.25, 0.75)) # 25, 75パーセンタイル

# 95% 区間
quantile(fish$length, probs = c(0.05, 0.95))


## ---- 共分散、積率相関係数 ----
# birdsファイルの読み込み
birds <- read.csv(here("data", "raw", "2-1-1-birds.csv"))
head(birds)

# 体と羽の大きさの相関係数
cor(birds$body_length, birds$feather_length)


## ---- 自己共分散, 自己相関係数, コレログラム ----
# ナイル川の流量データ
# "Nile"にはあらかじめデフォルトでナイル川の流量データが入っている
Nile

# 標本自己共分散を取得する
acf(
  Nile,
  type = "covariance", # 自己共分散を指定
  plot = TRUE, # 可視化するかどうか
  lag.max = 50
)

# 標本自己相関係数を取得する
acf(
  Nile,
  type = "correlation",
  plot = TRUE,
  lag.max = 24
)
